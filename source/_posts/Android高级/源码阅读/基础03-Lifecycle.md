---
title: 基础03-Lifecycle
date: 2024-7-31 21:15:36
tags: Android-官方源码
categories: 
    - Android
    - 手撸Android源码
toc: true
language: zh-CN
---

## lifeCycle的Observer
```kotlin
public interface LifecycleObserver

public interface DefaultLifecycleObserver : LifecycleObserver {
    /**
     * Notifies that `ON_CREATE` event occurred.
     *
     *
     * This method will be called after the [LifecycleOwner]'s `onCreate`
     * method returns.
     *
     * @param owner the component, whose state was changed
     */
    public fun onCreate(owner: LifecycleOwner) {}

    /**
     * Notifies that `ON_START` event occurred.
     *
     *
     * This method will be called after the [LifecycleOwner]'s `onStart` method returns.
     *
     * @param owner the component, whose state was changed
     */
    public fun onStart(owner: LifecycleOwner) {}

    /**
     * Notifies that `ON_RESUME` event occurred.
     *
     *
     * This method will be called after the [LifecycleOwner]'s `onResume`
     * method returns.
     *
     * @param owner the component, whose state was changed
     */
    public fun onResume(owner: LifecycleOwner) {}

    /**
     * Notifies that `ON_PAUSE` event occurred.
     *
     *
     * This method will be called before the [LifecycleOwner]'s `onPause` method
     * is called.
     *
     * @param owner the component, whose state was changed
     */
    public fun onPause(owner: LifecycleOwner) {}

    /**
     * Notifies that `ON_STOP` event occurred.
     *
     *
     * This method will be called before the [LifecycleOwner]'s `onStop` method
     * is called.
     *
     * @param owner the component, whose state was changed
     */
    public fun onStop(owner: LifecycleOwner) {}

    /**
     * Notifies that `ON_DESTROY` event occurred.
     *
     *
     * This method will be called before the [LifecycleOwner]'s `onDestroy` method
     * is called.
     *
     * @param owner the component, whose state was changed
     */
    public fun onDestroy(owner: LifecycleOwner) {}
}

public fun interface LifecycleEventObserver : LifecycleObserver {
    /**
     * Called when a state transition event happens.
     *
     * @param source The source of the event
     * @param event The event
     */
    public fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event)
}
```

- 可以看到，我们在使用`lifecycle.addObserver()`时，可以传入`LifecycleEventObserver`或`DefaultLifecycleObserver`，一个通过`event`获取当前状态，一个通过不同的回调函数获取当前状态

## Activity树
```text
Activity -- AccountAuthenticatorActivity
         |- ActivityGroup -- TabActivity
         |- ExpandableListActivity
         |- LauncherActivity
         |- ListActivity -- PreferenceActivity
         |- NativeActivity
         |- androidx.core.app.ComponentActivity -- androidx.activity.ComponentActivity -- FragmentActivity -- AppCompatActivity
                                                |- PreviewActivity
         |- BootstrapActivity
         |- EmptyActivity
         |- EmptyFloatingActivity
```

## LifecycleOwner

```kotlin
public interface LifecycleOwner {
    /**
     * Returns the Lifecycle of the provider.
     *
     * @return The lifecycle of the provider.
     */
    public val lifecycle: Lifecycle
}
```

`androidx.core.app.ComponentActivity`和`androidx.activity.ComponentActivity`都声明了对`LifecycleOwner`的实现

可以拿到`lifecycle`的`Activity`有
- androidx.core.app.ComponentActivity
- androidx.activity.ComponentActivity
- FragmentActivity
- AppCompatActivity
- PreviewActivity

## androidx.core.app.ComponentActivity中的lifecycle

```kotlin
@Suppress("LeakingThis")
private val lifecycleRegistry = LifecycleRegistry(this)
override val lifecycle: Lifecycle
    get() = lifecycleRegistry
@CallSuper
override fun onSaveInstanceState(outState: Bundle) {
    lifecycleRegistry.currentState = Lifecycle.State.CREATED
    super.onSaveInstanceState(outState)
}
```

- 很意外的是`ComponentActivity`并不是在每个生命周期回调函数中调用`lifecycleRegistry`的`setCurrentState`，从而分发生命周期

## LifecycleRegistry

### addObserver
```kotlin
override fun addObserver(observer: LifecycleObserver) {
    enforceMainThreadIfNeeded("addObserver")
    val initialState = if (state == State.DESTROYED) State.DESTROYED else State.INITIALIZED
    val statefulObserver = ObserverWithState(observer, initialState)
    val previous = observerMap.putIfAbsent(observer, statefulObserver)
    if (previous != null) {
        return
    }
    val lifecycleOwner = lifecycleOwner.get()
        ?: // it is null we should be destroyed. Fallback quickly
        return
    val isReentrance = addingObserverCounter != 0 || handlingEvent
    var targetState = calculateTargetState(observer)
    addingObserverCounter++
    while (statefulObserver.state < targetState && observerMap.contains(observer)
    ) {
        pushParentState(statefulObserver.state)
        val event = Event.upFrom(statefulObserver.state)
            ?: throw IllegalStateException("no event up from ${statefulObserver.state}")
        statefulObserver.dispatchEvent(lifecycleOwner, event)
        popParentState()
        // mState / subling may have been changed recalculate
        targetState = calculateTargetState(observer)
    }
    if (!isReentrance) {
        // we do sync only on the top level.
        sync()
    }
    addingObserverCounter--
}
```

- 这里看到`addObserver`首先将observer包装成`ObserverWithState`，并将其加入到`observerMap`
- 加入后立刻调用`dispatchEvent`将最新的状态传递出去


```kotlin
private fun sync() {
    val lifecycleOwner = lifecycleOwner.get()
        ?: throw IllegalStateException(
            "LifecycleOwner of this LifecycleRegistry is already " +
                "garbage collected. It is too late to change lifecycle state."
        )
    while (!isSynced) {
        newEventOccurred = false
        if (state < observerMap.eldest()!!.value.state) {
            backwardPass(lifecycleOwner)
        }
        val newest = observerMap.newest()
        if (!newEventOccurred && newest != null && state > newest.value.state) {
            forwardPass(lifecycleOwner)
        }
    }
    newEventOccurred = false
}
```

- 这里看到`sync`会调用`backwardPass`和`forwardPass`

```kotlin
private fun forwardPass(lifecycleOwner: LifecycleOwner) {
    @Suppress()
    val ascendingIterator: Iterator<Map.Entry<LifecycleObserver, ObserverWithState>> =
        observerMap.iteratorWithAdditions()
    while (ascendingIterator.hasNext() && !newEventOccurred) {
        val (key, observer) = ascendingIterator.next()
        while (observer.state < state && !newEventOccurred && observerMap.contains(key)
        ) {
            pushParentState(observer.state)
            val event = Event.upFrom(observer.state)
                ?: throw IllegalStateException("no event up from ${observer.state}")
            observer.dispatchEvent(lifecycleOwner, event)
            popParentState()
        }
    }
}

private fun backwardPass(lifecycleOwner: LifecycleOwner) {
    val descendingIterator = observerMap.descendingIterator()
    while (descendingIterator.hasNext() && !newEventOccurred) {
        val (key, observer) = descendingIterator.next()
        while (observer.state > state && !newEventOccurred && observerMap.contains(key)
        ) {
            val event = Event.downFrom(observer.state)
                ?: throw IllegalStateException("no event down from ${observer.state}")
            pushParentState(event.targetState)
            observer.dispatchEvent(lifecycleOwner, event)
            popParentState()
        }
    }
}
```

- 这里看到`sync`被调用后，就会根据`observer`的情况和`state`的不同，按照需要将`state`的变化传递给`observer`


### ObserverWithState

```kotlin
internal class ObserverWithState(observer: LifecycleObserver?, initialState: State) {
    var state: State
    var lifecycleObserver: LifecycleEventObserver

    init {
        lifecycleObserver = Lifecycling.lifecycleEventObserver(observer!!)
        state = initialState
    }

    fun dispatchEvent(owner: LifecycleOwner?, event: Event) {
        val newState = event.targetState
        state = min(state, newState)
        lifecycleObserver.onStateChanged(owner!!, event)
        state = newState
    }
}
```

- 首先这里看到一个关键的函数调用`onStateChanged`，也就是当`dispatchEvent`被调用时，`state`的改变就会传递给`observer`

### setCurrentState作用

```kotlin
override var currentState: State
    get() = state
    /**
        * Moves the Lifecycle to the given state and dispatches necessary events to the observers.
        *
        * @param state new state
        */
    set(state) {
        enforceMainThreadIfNeeded("setCurrentState")
        moveToState(state)
    }
```

```kotlin
private fun moveToState(next: State) {
    if (state == next) {
        return
    }
    check(!(state == State.INITIALIZED && next == State.DESTROYED)) {
        "no event down from $state in component ${lifecycleOwner.get()}"
    }
    state = next
    if (handlingEvent || addingObserverCounter != 0) {
        newEventOccurred = true
        // we will figure out what to do on upper level.
        return
    }
    handlingEvent = true
    sync()
    handlingEvent = false
    if (state == State.DESTROYED) {
        observerMap = FastSafeIterableMap()
    }
}
```

- 可以看到这里对`state`进行一定逻辑判断后，调用了`sync`，也就是当前`state`的改变会传递给`observer`
- `activity`传递`state`的方式看起来还是通过`setCurrentState`，但是并没有在`CompinentActivity`中的各个生命周期函数中调用

### ObserverWithState如何处理两种LifecycleObserver

```kotlin
init {
    lifecycleObserver = Lifecycling.lifecycleEventObserver(observer!!)
    state = initialState
}
```
可以看到构造函数中将`observer`通过`Lifecycling.lifecycleEventObserver`对`observer`进行了包装

```kotlin
public fun lifecycleEventObserver(`object`: Any): LifecycleEventObserver {
    val isLifecycleEventObserver = `object` is LifecycleEventObserver
    val isDefaultLifecycleObserver = `object` is DefaultLifecycleObserver
    if (isLifecycleEventObserver && isDefaultLifecycleObserver) {
        return DefaultLifecycleObserverAdapter(
            `object` as DefaultLifecycleObserver,
            `object` as LifecycleEventObserver
        )
    }
    if (isDefaultLifecycleObserver) {
        return DefaultLifecycleObserverAdapter(`object` as DefaultLifecycleObserver, null)
    }
    if (isLifecycleEventObserver) {
        return `object` as LifecycleEventObserver
    }
    val klass: Class<*> = `object`.javaClass
    val type = getObserverConstructorType(klass)
    if (type == GENERATED_CALLBACK) {
        val constructors = classToAdapters[klass]!!
        if (constructors.size == 1) {
            val generatedAdapter = createGeneratedAdapter(
                constructors[0], `object`
            )
            return SingleGeneratedAdapterObserver(generatedAdapter)
        }
        val adapters: Array<GeneratedAdapter> = Array(constructors.size) { i ->
            createGeneratedAdapter(constructors[i], `object`)
        }
        return CompositeGeneratedAdaptersObserver(adapters)
    }
    return ReflectiveGenericLifecycleObserver(`object`)
}
```

- 可以看到这里会判断`observer`的类型，如果是`DefaultLifecycleObserver`，则会使用`DefaultLifecycleObserverAdapter`对`observer`进行适配

- 这里可以看到，适配器考虑到了`Observer`即是`LifecycleEventObserver`又是`DefaultLifecycleObserver`的情况

#### DefaultLifecycleObserverAdapter
``` kotlin
internal class DefaultLifecycleObserverAdapter(
    private val defaultLifecycleObserver: DefaultLifecycleObserver,
    private val lifecycleEventObserver: LifecycleEventObserver?
) : LifecycleEventObserver {
    override fun onStateChanged(source: LifecycleOwner, event: Lifecycle.Event) {
        when (event) {
            Lifecycle.Event.ON_CREATE -> defaultLifecycleObserver.onCreate(source)
            Lifecycle.Event.ON_START -> defaultLifecycleObserver.onStart(source)
            Lifecycle.Event.ON_RESUME -> defaultLifecycleObserver.onResume(source)
            Lifecycle.Event.ON_PAUSE -> defaultLifecycleObserver.onPause(source)
            Lifecycle.Event.ON_STOP -> defaultLifecycleObserver.onStop(source)
            Lifecycle.Event.ON_DESTROY -> defaultLifecycleObserver.onDestroy(source)
            Lifecycle.Event.ON_ANY ->
                throw IllegalArgumentException("ON_ANY must not been send by anybody")
        }
        lifecycleEventObserver?.onStateChanged(source, event)
    }
}
```

- 这里就很清晰了，`DefaultLifecycleObserverAdapter`根据当前的`state`调用`DefaultLifecycleObserver`的各个回调

### handleLifecycleEvent
```kotlin
/**
    * Sets the current state and notifies the observers.
    *
    * Note that if the `currentState` is the same state as the last call to this method,
    * calling this method has no effect.
    *
    * @param event The event that was received
    */
open fun handleLifecycleEvent(event: Event) {
    enforceMainThreadIfNeeded("handleLifecycleEvent")
    moveToState(event.targetState)
}
```

- 这里看到`handleLifecycleEvent`也有设置`state`的作用

## Activity生命周期相关函数
### 回调结构定义
```java
private final ArrayList<Application.ActivityLifecycleCallbacks> mActivityLifecycleCallbacks =
        new ArrayList<Application.ActivityLifecycleCallbacks>();
```

此处定义了一个回调的接口`List`

### 注册与删除
```java
public void registerActivityLifecycleCallbacks(
        @NonNull Application.ActivityLifecycleCallbacks callback) {
    synchronized (mActivityLifecycleCallbacks) {
        mActivityLifecycleCallbacks.add(callback);
    }
}

public void unregisterActivityLifecycleCallbacks(
        @NonNull Application.ActivityLifecycleCallbacks callback) {
    synchronized (mActivityLifecycleCallbacks) {
        mActivityLifecycleCallbacks.remove(callback);
    }
}
```

### 回调`list`转数组

```java
private Object[] collectActivityLifecycleCallbacks() {
    Object[] callbacks = null;
    synchronized (mActivityLifecycleCallbacks) {
        if (mActivityLifecycleCallbacks.size() > 0) {
            callbacks = mActivityLifecycleCallbacks.toArray();
        }
    }
    return callbacks;
}
```

- 下面介绍的`dispatchActivityXXX`函数将调用`collectActivityLifecycleCallbacks`获取所有`callbacks`，然后调用`callbacks`的`onActivityXXX`函数

### dispatchActivityPreCreated
```java
private void dispatchActivityPreCreated(@Nullable Bundle savedInstanceState) {
    getApplication().dispatchActivityPreCreated(this, savedInstanceState);
    Object[] callbacks = collectActivityLifecycleCallbacks();
    if (callbacks != null) {
        for (int i = 0; i < callbacks.length; i++) {
            ((Application.ActivityLifecycleCallbacks) callbacks[i]).onActivityPreCreated(this,
                    savedInstanceState);
        }
    }
}
```
### dispatchActivityCreated
```java
private void dispatchActivityCreated(@Nullable Bundle savedInstanceState) {
    getApplication().dispatchActivityCreated(this, savedInstanceState);
    Object[] callbacks = collectActivityLifecycleCallbacks();
    if (callbacks != null) {
        for (int i = 0; i < callbacks.length; i++) {
            ((Application.ActivityLifecycleCallbacks) callbacks[i]).onActivityCreated(this,
                    savedInstanceState);
        }
    }
}
```
### dispatchActivityPostCreated
```java
private void dispatchActivityPostCreated(@Nullable Bundle savedInstanceState) {
    Object[] callbacks = collectActivityLifecycleCallbacks();
    if (callbacks != null) {
        for (int i = 0; i < callbacks.length; i++) {
            ((Application.ActivityLifecycleCallbacks) callbacks[i]).onActivityPostCreated(this,
                    savedInstanceState);
        }
    }
    getApplication().dispatchActivityPostCreated(this, savedInstanceState);
}
```

- 每段代码几乎是一样的，就不全贴上来了
- 没贴上来的还有
  - dispatchActivityPreStarted, dispatchActivityStarted, dispatchActivityPostStarted
  - dispatchActivityPreResumed, dispatchActivityResumed, dispatchActivityPostResumed
  - dispatchActivityPrePaused, dispatchActivityPaused, dispatchActivityPostPaused
  - dispatchActivitySaveInstanceState, dispatchActivitySaveInstanceState, dispatchActivityPostSaveInstanceState
  - dispatchActivityPreDestroyed, dispatchActivityDestroyed, dispatchActivityPostDestroyed
  - dispatchActivityConfigurationChanged

## ReportFragment

- reportFragment负责传递Activity的生命周期

### ReportFragment的初始化
```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    ReportFragment.injectIfNeededIn(this)
}
```

```kotlin
fun injectIfNeededIn(activity: Activity) {
    if (Build.VERSION.SDK_INT >= 29) {
        // On API 29+, we can register for the correct Lifecycle callbacks directly
        LifecycleCallbacks.registerIn(activity)
    }
    // Prior to API 29 and to maintain compatibility with older versions of
    // ProcessLifecycleOwner (which may not be updated when lifecycle-runtime is updated and
    // need to support activities that don't extend from FragmentActivity from support lib),
    // use a framework fragment to get the correct timing of Lifecycle events
    val manager = activity.fragmentManager
    if (manager.findFragmentByTag(REPORT_FRAGMENT_TAG) == null) {
        manager.beginTransaction().add(ReportFragment(), REPORT_FRAGMENT_TAG).commit()
        // Hopefully, we are the first to make a transaction.
        manager.executePendingTransactions()
    }
}
```

- `api`29之后，会使用`LifecycleCallbacks.registerIn`
- 另外还会使用`ReportFragment`来报告`activity`的生命周期

### ReportFragment分发生命周期(API 29之前)

```kotlin
private var processListener: ActivityInitializationListener? = null

private fun dispatchCreate(listener: ActivityInitializationListener?) {
    listener?.onCreate()
}

private fun dispatchStart(listener: ActivityInitializationListener?) {
    listener?.onStart()
}

private fun dispatchResume(listener: ActivityInitializationListener?) {
    listener?.onResume()
}

override fun onActivityCreated(savedInstanceState: Bundle?) {
    super.onActivityCreated(savedInstanceState)
    dispatchCreate(processListener)
    dispatch(Lifecycle.Event.ON_CREATE)
}

override fun onStart() {
    super.onStart()
    dispatchStart(processListener)
    dispatch(Lifecycle.Event.ON_START)
}

override fun onResume() {
    super.onResume()
    dispatchResume(processListener)
    dispatch(Lifecycle.Event.ON_RESUME)
}

override fun onPause() {
    super.onPause()
    dispatch(Lifecycle.Event.ON_PAUSE)
}

override fun onStop() {
    super.onStop()
    dispatch(Lifecycle.Event.ON_STOP)
}

override fun onDestroy() {
    super.onDestroy()
    dispatch(Lifecycle.Event.ON_DESTROY)
    // just want to be sure that we won't leak reference to an activity
    processListener = null
}
```

- 可以看到，当`Fragment`的声明周期函数被调用时，会调用`dispatch`，将`activity`的生命周期进行传递

### dispatch
```kotlin
private fun dispatch(event: Lifecycle.Event) {
    if (Build.VERSION.SDK_INT < 29) {
        // Only dispatch events from ReportFragment on API levels prior
        // to API 29. On API 29+, this is handled by the ActivityLifecycleCallbacks
        // added in ReportFragment.injectIfNeededIn
        dispatch(activity, event)
    }
}

internal fun dispatch(activity: Activity, event: Lifecycle.Event) {
    if (activity is LifecycleRegistryOwner) {
        activity.lifecycle.handleLifecycleEvent(event)
        return
    }
    if (activity is LifecycleOwner) {
        val lifecycle = (activity as LifecycleOwner).lifecycle
        if (lifecycle is LifecycleRegistry) {
            lifecycle.handleLifecycleEvent(event)
        }
    }
}
```
- 仅在`api 29`之前通过`ReportFragment`来进行`activity`的生命周期传递
- 这里就可以看到上面分析的`LifecycleRegistry`类了，获取`activity`中的`lifecycle`再调用`handleLifecycleEvent`来更新`activity`的生命周期，进而将生命周期改变传递给`listener`

## API 29及以后Activity分发生命周期

### 回到`ReportFragment`
```kotlin
fun injectIfNeededIn(activity: Activity) {
    if (Build.VERSION.SDK_INT >= 29) {
        // On API 29+, we can register for the correct Lifecycle callbacks directly
        LifecycleCallbacks.registerIn(activity)
    }
    // ...
}
```
大于等于`Api 29`时，会调用`registerIn`
### `registerIn`
```kotlin
@JvmStatic
fun registerIn(activity: Activity) {
    activity.registerActivityLifecycleCallbacks(LifecycleCallbacks())
}
```

- 这里看到，调用了[activity](#activity生命周期相关函数)的`registerActivityLifecycleCallbacks`，`activity`会在发生生命周期改变时调用回调`LifecycleCallbacks`

### LifecycleCallbacks

```kotlin
internal class LifecycleCallbacks : Application.ActivityLifecycleCallbacks {
    override fun onActivityCreated(
        activity: Activity,
        bundle: Bundle?
    ) {}

    override fun onActivityPostCreated(
        activity: Activity,
        savedInstanceState: Bundle?
    ) {
        dispatch(activity, Lifecycle.Event.ON_CREATE)
    }

    override fun onActivityStarted(activity: Activity) {}

    override fun onActivityPostStarted(activity: Activity) {
        dispatch(activity, Lifecycle.Event.ON_START)
    }

    override fun onActivityResumed(activity: Activity) {}

    override fun onActivityPostResumed(activity: Activity) {
        dispatch(activity, Lifecycle.Event.ON_RESUME)
    }

    override fun onActivityPrePaused(activity: Activity) {
        dispatch(activity, Lifecycle.Event.ON_PAUSE)
    }

    override fun onActivityPaused(activity: Activity) {}

    override fun onActivityPreStopped(activity: Activity) {
        dispatch(activity, Lifecycle.Event.ON_STOP)
    }

    override fun onActivityStopped(activity: Activity) {}

    override fun onActivitySaveInstanceState(
        activity: Activity,
        bundle: Bundle
    ) {}

    override fun onActivityPreDestroyed(activity: Activity) {
        dispatch(activity, Lifecycle.Event.ON_DESTROY)
    }

    override fun onActivityDestroyed(activity: Activity) {}

    companion object {
        @JvmStatic
        fun registerIn(activity: Activity) {
            activity.registerActivityLifecycleCallbacks(LifecycleCallbacks())
        }
    }
}
```

- 这里看到`LifecycleCallbacks`调用了[dispatch()](#dispatch)函数，将`activity`的生命周期进行了分发

## Fragment的lifecycle
### 实现`LifecycleOwner`

```java
public class Fragment implements ComponentCallbacks, OnCreateContextMenuListener, LifecycleOwner,
        ViewModelStoreOwner, HasDefaultViewModelProviderFactory, SavedStateRegistryOwner,
        ActivityResultCaller {
    @Override
    @NonNull
    public Lifecycle getLifecycle() {
        return mLifecycleRegistry;
    }
```

### 初始化`Lifecycle`
```java
public Fragment() {
    initLifecycle();
}
private void initLifecycle() {
    mLifecycleRegistry = new LifecycleRegistry(this);
    mSavedStateRegistryController = SavedStateRegistryController.create(this);
    // The default factory depends on the SavedStateRegistry so it
    // needs to be reset when the SavedStateRegistry is reset
    mDefaultFactory = null;
    if (!mOnPreAttachedListeners.contains(mSavedStateAttachListener)) {
        registerOnPreAttachListener(mSavedStateAttachListener);
    }
}
```

### 传递事件

`fragment`的生命周期传递比较简单，就是在`fragment`各个生命周期时调用`handleLifecycleEvent`

```java
void performCreate(Bundle savedInstanceState) {
    mChildFragmentManager.noteStateNotSaved();
    mState = CREATED;
    mCalled = false;
    mLifecycleRegistry.addObserver(new LifecycleEventObserver() {
        @Override
        public void onStateChanged(@NonNull LifecycleOwner source,
                @NonNull Lifecycle.Event event) {
            if (event == Lifecycle.Event.ON_STOP) {
                if (mView != null) {
                    mView.cancelPendingInputEvents();
                }
            }
        }
    });
    onCreate(savedInstanceState);
    mIsCreated = true;
    if (!mCalled) {
        throw new SuperNotCalledException("Fragment " + this
                + " did not call through to super.onCreate()");
    }
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_CREATE);
}
```

```java
void performStart() {
    mChildFragmentManager.noteStateNotSaved();
    mChildFragmentManager.execPendingActions(true);
    mState = STARTED;
    mCalled = false;
    onStart();
    if (!mCalled) {
        throw new SuperNotCalledException("Fragment " + this
                + " did not call through to super.onStart()");
    }
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_START);
    if (mView != null) {
        mViewLifecycleOwner.handleLifecycleEvent(Lifecycle.Event.ON_START);
    }
    mChildFragmentManager.dispatchStart();
}
```

```java
void performResume() {
    mChildFragmentManager.noteStateNotSaved();
    mChildFragmentManager.execPendingActions(true);
    mState = RESUMED;
    mCalled = false;
    onResume();
    if (!mCalled) {
        throw new SuperNotCalledException("Fragment " + this
                + " did not call through to super.onResume()");
    }
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_RESUME);
    if (mView != null) {
        mViewLifecycleOwner.handleLifecycleEvent(Lifecycle.Event.ON_RESUME);
    }
    mChildFragmentManager.dispatchResume();
}
```

```java
void performPause() {
    mChildFragmentManager.dispatchPause();
    if (mView != null) {
        mViewLifecycleOwner.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE);
    }
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_PAUSE);
    mState = AWAITING_ENTER_EFFECTS;
    mCalled = false;
    onPause();
    if (!mCalled) {
        throw new SuperNotCalledException("Fragment " + this
                + " did not call through to super.onPause()");
    }
}
```

```java
void performStop() {
    mChildFragmentManager.dispatchStop();
    if (mView != null) {
        mViewLifecycleOwner.handleLifecycleEvent(Lifecycle.Event.ON_STOP);
    }
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_STOP);
    mState = ACTIVITY_CREATED;
    mCalled = false;
    onStop();
    if (!mCalled) {
        throw new SuperNotCalledException("Fragment " + this
                + " did not call through to super.onStop()");
    }
}
```

```java
void performDestroy() {
    mChildFragmentManager.dispatchDestroy();
    mLifecycleRegistry.handleLifecycleEvent(Lifecycle.Event.ON_DESTROY);
    mState = ATTACHED;
    mCalled = false;
    mIsCreated = false;
    onDestroy();
    if (!mCalled) {
        throw new SuperNotCalledException("Fragment " + this
                + " did not call through to super.onDestroy()");
    }
}
```