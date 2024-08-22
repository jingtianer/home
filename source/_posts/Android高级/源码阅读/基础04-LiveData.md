---
title: 基础04-LiveData
date: 2024-8-06 21:15:36
tags: Android-官方源码
categories: 
    - Android
    - 手撸Android源码
toc: true
language: zh-CN
---

## LiveData

### LiveData的观察者
```kotlin
fun interface Observer<T> {

    /**
     * Called when the data is changed to [value].
     */
    fun onChanged(value: T)
}
```

- 通过`onChanged`函数分派数据变化

### 成员
```java
@SuppressWarnings("WeakerAccess") /* synthetic access */
final Object mDataLock = new Object();
static final int START_VERSION = -1;
@SuppressWarnings("WeakerAccess") /* synthetic access */
static final Object NOT_SET = new Object();

private SafeIterableMap<Observer<? super T>, ObserverWrapper> mObservers =
        new SafeIterableMap<>();

// how many observers are in active state
@SuppressWarnings("WeakerAccess") /* synthetic access */
int mActiveCount = 0;
// to handle active/inactive reentry, we guard with this boolean
private boolean mChangingActiveState;
private volatile Object mData; // 1️⃣：当前的data
// when setData is called, we set the pending data and actual data swap happens on the main
// thread
@SuppressWarnings("WeakerAccess") /* synthetic access */
volatile Object mPendingData = NOT_SET; // 2️⃣：给多线程使用的，在4️⃣mPostValueRunnable中使用
private int mVersion; // 3️⃣：mVersion是数据版本

private boolean mDispatchingValue;
@SuppressWarnings("FieldCanBeLocal")
private boolean mDispatchInvalidated;
private final Runnable mPostValueRunnable = new Runnable() {// 4️⃣mPostValueRunnable，在主线程中将mPendingData设置为当前值
    @SuppressWarnings("unchecked")
    @Override
    public void run() {
        Object newValue;
        synchronized (mDataLock) {
            newValue = mPendingData;
            mPendingData = NOT_SET;
        }
        setValue((T) newValue);
    }
};
```

- 数据存在mData中
- mPendingData给多线程使用的，在mPostValueRunnable时设置为当前值
- mVersion是数据版本
- mPostValueRunnable，在主线程中将mPendingData设置为当前值

### 构造
```java
public LiveData(T value) {
    mData = value;
    mVersion = START_VERSION + 1;
}

public LiveData() {
    mData = NOT_SET;
    mVersion = START_VERSION;
}
```

### get 和 set

```java
@MainThread
protected void setValue(T value) {
    assertMainThread("setValue");
    mVersion++;
    mData = value;
    dispatchingValue(null);
}

@SuppressWarnings("unchecked")
@Nullable
public T getValue() {
    Object data = mData;
    if (data != NOT_SET) {
        return (T) data;
    }
    return null;
}

protected void postValue(T value) {
    boolean postTask;
    synchronized (mDataLock) {
        postTask = mPendingData == NOT_SET;
        mPendingData = value;
    }
    if (!postTask) {
        return;
    }
    ArchTaskExecutor.getInstance().postToMainThread(mPostValueRunnable);
}
```

- 每次set,mVersion都会自增1，并调用dispatchingValue
- 非主线程中调用postValue在主线程中更新值, mPendingData是被异步更新的，但最终mData都在主线程中被set
- postValue和mPostValueRunnable更新mPendingData时先获取mDataLock对象的锁，runnable执行后会将mPendingData设置为NOT_SET。如果postValue时mPendingData不是NOT_SET，就不会重复post runnable

### 分派事件

#### dispatchingValue
```java
@SuppressWarnings("WeakerAccess") /* synthetic access */
void dispatchingValue(@Nullable ObserverWrapper initiator) {
    if (mDispatchingValue) {
        mDispatchInvalidated = true;
        return;
    }
    mDispatchingValue = true;
    do {
        mDispatchInvalidated = false;
        if (initiator != null) {
            considerNotify(initiator);
            initiator = null;
        } else {
            for (Iterator<Map.Entry<Observer<? super T>, ObserverWrapper>> iterator =
                    mObservers.iteratorWithAdditions(); iterator.hasNext(); ) {
                considerNotify(iterator.next().getValue());
                if (mDispatchInvalidated) {
                    break;
                }
            }
        }
    } while (mDispatchInvalidated);
    mDispatchingValue = false;
}
```

- 如果当前正在分派，则退出，并通过`mDispatchInvalidated`打断后续分派
- 如果参数不空，则只分派给参数，否则分派给所有observer

#### considerNotify

```java
private void considerNotify(ObserverWrapper observer) {
    if (!observer.mActive) {
        return;
    }
    // Check latest state b4 dispatch. Maybe it changed state but we didn't get the event yet.
    //
    // we still first check observer.active to keep it as the entrance for events. So even if
    // the observer moved to an active state, if we've not received that event, we better not
    // notify for a more predictable notification order.
    if (!observer.shouldBeActive()) {
        observer.activeStateChanged(false);
        return;
    }
    if (observer.mLastVersion >= mVersion) {
        return;
    }
    observer.mLastVersion = mVersion;
    observer.mObserver.onChanged((T) mData);
}
```

- 如果`observer`非`active`状态，不分派
- 如果`observer`上次的数据版本大于当前版本，不分派
- 更新`observer`的数据版本
- 调用`observer`的`onChanged`分派数据变化

### ObserverWrapper

```java
private abstract class ObserverWrapper {
    final Observer<? super T> mObserver;
    boolean mActive;
    int mLastVersion = START_VERSION;

    ObserverWrapper(Observer<? super T> observer) {
        mObserver = observer;
    }

    abstract boolean shouldBeActive();

    boolean isAttachedTo(LifecycleOwner owner) {
        return false;
    }

    void detachObserver() {
    }

    void activeStateChanged(boolean newActive) {
        if (newActive == mActive) {
            return;
        }
        // immediately set active state, so we'd never dispatch anything to inactive
        // owner
        mActive = newActive;
        changeActiveCounter(mActive ? 1 : -1);
        if (mActive) {
            dispatchingValue(this);
        }
    }
}
```

- 对`Observer`进行包装，记录了当前的数据`version`和`active`状态
- 当`activeStateChanged`被调用时，首先判断与原来的`active`状态是否一致，如果一致，则直接返回
- 如果不一致，则更新`active`状态，并调用外部类(`LiveData`)的`changeActiveCounter`
- 如果当前`active`状态从`false`变为`true`，则调用`dispatchingValue`，立刻向观察者传递最新的数据状态

### changeActiveCounter
```java
@MainThread
void changeActiveCounter(int change) {
    int previousActiveCount = mActiveCount;
    mActiveCount += change;
    if (mChangingActiveState) {
        return;
    }
    mChangingActiveState = true;
    try {
        while (previousActiveCount != mActiveCount) {
            boolean needToCallActive = previousActiveCount == 0 && mActiveCount > 0;
            boolean needToCallInactive = previousActiveCount > 0 && mActiveCount == 0;
            previousActiveCount = mActiveCount;
            if (needToCallActive) {
                onActive();
            } else if (needToCallInactive) {
                onInactive();
            }
        }
    } finally {
        mChangingActiveState = false;
    }
}
```

- 会保存当前状态为`active`的`observer`的数量
- 这个函数会更新其值
- 如果原来`active`的个数为0，现在大于0，那么调用`onActive`
- 如果原来`active`的个数大于0，现在为0，那么调用`onInactive`

### onActive和onInactive

```java
protected void onInactive() {

}
protected void onActive() {

}
```

给子类用的钩子方法，用于通知当前是否有`active`的`observer`

### AlwaysActiveObserver

```java
private class AlwaysActiveObserver extends ObserverWrapper {

    AlwaysActiveObserver(Observer<? super T> observer) {
        super(observer);
    }

    @Override
    boolean shouldBeActive() {
        return true;
    }
}
```

- 这类`Observer`会一直处于`active`状态
- `observeForever`会创建`AlwaysActiveObserver`，创建后立刻调用`activeStateChanged(true)`更新`active`状态，`active`总数

### 添加AlwaysActiveObserver
```java
public void observeForever(@NonNull Observer<? super T> observer) {
    assertMainThread("observeForever");
    AlwaysActiveObserver wrapper = new AlwaysActiveObserver(observer);
    ObserverWrapper existing = mObservers.putIfAbsent(observer, wrapper);
    if (existing instanceof LiveData.LifecycleBoundObserver) {
        throw new IllegalArgumentException("Cannot add the same observer"
                + " with different lifecycles");
    }
    if (existing != null) {
        return;
    }
    wrapper.activeStateChanged(true);
}
```

### LifecycleBoundObserver

```java
class LifecycleBoundObserver extends ObserverWrapper implements LifecycleEventObserver {
    @NonNull
    final LifecycleOwner mOwner;

    LifecycleBoundObserver(@NonNull LifecycleOwner owner, Observer<? super T> observer) {
        super(observer);
        mOwner = owner;
    }

    @Override
    boolean shouldBeActive() {
        return mOwner.getLifecycle().getCurrentState().isAtLeast(STARTED);
    }

    @Override
    public void onStateChanged(@NonNull LifecycleOwner source,
            @NonNull Lifecycle.Event event) {
        Lifecycle.State currentState = mOwner.getLifecycle().getCurrentState();
        if (currentState == DESTROYED) {
            removeObserver(mObserver);
            return;
        }
        Lifecycle.State prevState = null;
        while (prevState != currentState) {
            prevState = currentState;
            activeStateChanged(shouldBeActive());
            currentState = mOwner.getLifecycle().getCurrentState();
        }
    }

    @Override
    boolean isAttachedTo(LifecycleOwner owner) {
        return mOwner == owner;
    }

    @Override
    void detachObserver() {
        mOwner.getLifecycle().removeObserver(this);
    }
}
```

- 同时实现了`LifecycleEventObserver`，可以观察`lifecycle`
- 保存对应的`lifecycleOwner`
- 根据`shouldBeActive`，当关联的`Lifecycle`到达了`started`及以后的状态，就是`active`的了
- 当`lifecycle`状态变化时
  - 如果到了`destroyed`,则调用外部类的`removeObserver`移除当前`observer`
  - 然后进一个循环，调用`activeStateChanged`更新当前的active状态，直到两次获取`lifecycle`的当前状态都相同时，退出循环

### 添加一个LifecycleBoundObserver

```java
@MainThread
public void observe(@NonNull LifecycleOwner owner, @NonNull Observer<? super T> observer) {
    assertMainThread("observe");
    if (owner.getLifecycle().getCurrentState() == DESTROYED) {
        // ignore
        return;
    }
    LifecycleBoundObserver wrapper = new LifecycleBoundObserver(owner, observer);
    ObserverWrapper existing = mObservers.putIfAbsent(observer, wrapper);
    if (existing != null && !existing.isAttachedTo(owner)) {
        throw new IllegalArgumentException("Cannot add the same observer"
                + " with different lifecycles");
    }
    if (existing != null) {
        return;
    }
    owner.getLifecycle().addObserver(wrapper);
}
```

- 创建`LifecycleBoundObserver`，并立刻将其注册到`lifecycle`的`observer`中
- `lifecycle`添加`observer`后，会立刻传递状态，这里也可以立刻根据`lifecycle`的状态更新`active`状态，进而向观察者分派当前值

### 移除observer

```java
@MainThread
public void removeObserver(@NonNull final Observer<? super T> observer) {
    assertMainThread("removeObserver");
    ObserverWrapper removed = mObservers.remove(observer);
    if (removed == null) {
        return;
    }
    removed.detachObserver();
    removed.activeStateChanged(false);
}

/**
 * Removes all observers that are tied to the given {@link LifecycleOwner}.
 *
 * @param owner The {@code LifecycleOwner} scope for the observers to be removed.
 */
@SuppressWarnings("WeakerAccess")
@MainThread
public void removeObservers(@NonNull final LifecycleOwner owner) {
    assertMainThread("removeObservers");
    for (Map.Entry<Observer<? super T>, ObserverWrapper> entry : mObservers) {
        if (entry.getValue().isAttachedTo(owner)) {
            removeObserver(entry.getKey());
        }
    }
}
```

- 从map中删除observer
  - 调用`activeStateChanged(false)`, 将其`active`状态变成`false`，减少活跃状态的数量，按需调用onInactive(),
  - 调用`detachObserver`，如果是`LifecycleBoundObserver`，就停止从lifecycle中观察状态。

## MutableLiveData

```java
@SuppressWarnings("WeakerAccess")
public class MutableLiveData<T> extends LiveData<T> {

    /**
     * Creates a MutableLiveData initialized with the given {@code value}.
     *
     * @param value initial value
     */
    public MutableLiveData(T value) {
        super(value);
    }

    /**
     * Creates a MutableLiveData with no value assigned to it.
     */
    public MutableLiveData() {
        super();
    }

    @Override
    public void postValue(T value) {
        super.postValue(value);
    }

    @Override
    public void setValue(T value) {
        super.setValue(value);
    }
}
```

- 好猫猫简洁
- postValue和setValue升级成public了

## MediatorLiveData

- 配置多个更新源`LiveData`，当观察到一个`LiveData`发生改变，则执行相应的动作

```java
public class MediatorLiveData<T> extends MutableLiveData<T> {
    private SafeIterableMap<LiveData<?>, Source<?>> mSources = new SafeIterableMap<>();

    /**
     * Creates a MediatorLiveData with no value assigned to it.
     */
    public MediatorLiveData() {
        super();
    }

    /**
     * Creates a MediatorLiveData initialized with the given {@code value}.
     *
     * @param value initial value
     */
    public MediatorLiveData(T value) {
        super(value);
    }

    /**
     * Starts to listen to the given {@code source} LiveData, {@code onChanged} observer will be
     * called when {@code source} value was changed.
     * <p>
     * {@code onChanged} callback will be called only when this {@code MediatorLiveData} is active.
     * <p> If the given LiveData is already added as a source but with a different Observer,
     * {@link IllegalArgumentException} will be thrown.
     *
     * @param source    the {@code LiveData} to listen to
     * @param onChanged The observer that will receive the events
     * @param <S>       The type of data hold by {@code source} LiveData
     */
    @MainThread
    public <S> void addSource(@NonNull LiveData<S> source, @NonNull Observer<? super S> onChanged) {
        if (source == null) {
            throw new NullPointerException("source cannot be null");
        }
        Source<S> e = new Source<>(source, onChanged);
        Source<?> existing = mSources.putIfAbsent(source, e);
        if (existing != null && existing.mObserver != onChanged) {
            throw new IllegalArgumentException(
                    "This source was already added with the different observer");
        }
        if (existing != null) {
            return;
        }
        if (hasActiveObservers()) {
            e.plug();
        }
    }

    /**
     * Stops to listen the given {@code LiveData}.
     *
     * @param toRemote {@code LiveData} to stop to listen
     * @param <S>      the type of data hold by {@code source} LiveData
     */
    @MainThread
    public <S> void removeSource(@NonNull LiveData<S> toRemote) {
        Source<?> source = mSources.remove(toRemote);
        if (source != null) {
            source.unplug();
        }
    }

    @CallSuper
    @Override
    protected void onActive() {
        for (Map.Entry<LiveData<?>, Source<?>> source : mSources) {
            source.getValue().plug();
        }
    }

    @CallSuper
    @Override
    protected void onInactive() {
        for (Map.Entry<LiveData<?>, Source<?>> source : mSources) {
            source.getValue().unplug();
        }
    }

    private static class Source<V> implements Observer<V> {
        final LiveData<V> mLiveData;
        final Observer<? super V> mObserver;
        int mVersion = START_VERSION;

        Source(LiveData<V> liveData, final Observer<? super V> observer) {
            mLiveData = liveData;
            mObserver = observer;
        }

        void plug() {
            mLiveData.observeForever(this);
        }

        void unplug() {
            mLiveData.removeObserver(this);
        }

        @Override
        public void onChanged(@Nullable V v) {
            if (mVersion != mLiveData.getVersion()) {
                mVersion = mLiveData.getVersion();
                mObserver.onChanged(v);
            }
        }
    }
}
```

感觉就是帮我们`observeForever`，没什么特殊的

## CoroutineLiveData

- 这种livedata提供给一个执行异步的协程，在携程中进行耗时操作，通过`emit`, `emitSource`发送数据，给观察者进行观察
- 其他的使用方法和`LiveData`一样，对其进行观察，当数据变化时，接收到数据变化

### 使用方法

- emit: 

```kotlin
// a LiveData that tries to load the `User` from local cache first and then tries to fetch
// from the server and also yields the updated value
val user = liveData {
    // check local storage
    val cached = cache.loadUser(id)
    if (cached != null) {
        emit(cached)
    }
    if (cached == null || cached.isStale()) {
        val fresh = api.fetch(id) // errors are ignored for brevity
        cache.save(fresh)
        emit(fresh)
    }
}
```

> 这里liveData函数产生了一个`LiveData`，并提供了一个代码块，这个代码块回进行耗时操作，通过`emit`函数更新`LiveData`的数据
> - 几个问题
>   - 代码块何时执行？
>   - emit如何更新数据？

```kotlin
// a LiveData that immediately receives a LiveData<User> from the database and yields it as a
// source but also tries to back-fill the database from the server
val user = liveData {
    val fromDb: LiveData<User> = roomDatabase.loadUser(id)
    emitSource(fromDb)
    val updated = api.fetch(id) // errors are ignored for brevity
    roomDatabase.insert(updated)
}
```
- 从数据库读取`User`类型的数据，返回`fromDb`，然后通过`emitSource`观察该`fromDb`，当`fromDb`更新时，更新`user`
- 同时执行其他相关的，数据库更新操作

```kotlin
public fun <T> liveData(
    context: CoroutineContext = EmptyCoroutineContext,
    timeoutInMs: Long = DEFAULT_TIMEOUT,
    block: suspend LiveDataScope<T>.() -> Unit
): LiveData<T> = CoroutineLiveData(context, timeoutInMs, block)

// 支持Duration的Api
@RequiresApi(Build.VERSION_CODES.O)
@JvmOverloads
public fun <T> liveData(
    timeout: Duration,
    context: CoroutineContext = EmptyCoroutineContext,
    block: suspend LiveDataScope<T>.() -> Unit
): LiveData<T> = CoroutineLiveData(context, Api26Impl.toMillis(timeout), block)

@RequiresApi(26)
internal object Api26Impl {
    fun toMillis(timeout: Duration): Long {
        return timeout.toMillis()
    }
}
```

- 可以传入一个`CoroutineContext`，用于指定协程的执行环境，默认是`EmptyCoroutineContext`
- 可以传入一个`timeoutInMs`，具体作用下面再说

### CoroutineLiveData

```kotlin
internal class CoroutineLiveData<T>(
    context: CoroutineContext = EmptyCoroutineContext,
    timeoutInMs: Long = DEFAULT_TIMEOUT,
    block: Block<T>
) : MediatorLiveData<T>() {
    private var blockRunner: BlockRunner<T>?
    private var emittedSource: EmittedSource? = null

    init {
        // use an intermediate supervisor job so that if we cancel individual block runs due to losing
        // observers, it won't cancel the given context as we only cancel w/ the intention of possibly
        // relaunching using the same parent context.
        val supervisorJob = SupervisorJob(context[Job])

        // The scope for this LiveData where we launch every block Job.
        // We default to Main dispatcher but developer can override it.
        // The supervisor job is added last to isolate block runs.
        val scope = CoroutineScope(Dispatchers.Main.immediate + context + supervisorJob)
        blockRunner = BlockRunner(
            liveData = this,
            block = block,
            timeoutInMs = timeoutInMs,
            scope = scope
        ) {
            blockRunner = null
        }
    }

    internal suspend fun emitSource(source: LiveData<T>): DisposableHandle {
        clearSource()
        val newSource = addDisposableSource(source)
        emittedSource = newSource
        return newSource
    }

    internal suspend fun clearSource() {
        emittedSource?.disposeNow()
        emittedSource = null
    }

    override fun onActive() {
        super.onActive()
        blockRunner?.maybeRun()
    }

    override fun onInactive() {
        super.onInactive()
        blockRunner?.cancel()
    }
}
```

- `onActive`和`onInactive`两个函数的内容标明，代码块会在活跃观察者数量大于1时开始执行，没有活跃观察者时被`cancel`
- 注意到`CoroutineLiveData`是一个`MediatorLiveData`，下面要考

### Block的运行和取消

```kotlin
internal class BlockRunner<T>(
    private val liveData: CoroutineLiveData<T>,
    private val block: Block<T>,
    private val timeoutInMs: Long,
    private val scope: CoroutineScope,
    private val onDone: () -> Unit
) {
    // currently running block job.
    private var runningJob: Job? = null

    // cancelation job created in cancel.
    private var cancellationJob: Job? = null

    @MainThread
    fun maybeRun() {
        cancellationJob?.cancel()
        cancellationJob = null
        if (runningJob != null) {
            return
        }
        runningJob = scope.launch {
            val liveDataScope = LiveDataScopeImpl(liveData, coroutineContext)
            block(liveDataScope)
            onDone()
        }
    }

    @MainThread
    fun cancel() {
        if (cancellationJob != null) {
            error("Cancel call cannot happen without a maybeRun")
        }
        cancellationJob = scope.launch(Dispatchers.Main.immediate) {
            delay(timeoutInMs)
            if (!liveData.hasActiveObservers()) {
                // one last check on active observers to avoid any race condition between starting
                // a running coroutine and cancelation
                runningJob?.cancel()
                runningJob = null
            }
        }
    }
}
```

- maybeRun很简单，就是在指定的`scope`中启动一个协程，执行`block`
- cancel也很简单，就是在协程中先等待一段时间，然后判断是否有活跃的观察者，如果没有，则取消`runningJob`

- 我们观察到block是`LiveDataScope`的扩展函数，对应的具体实现类是`LiveDataScopeImpl`

### LiveDataScope

```kotlin
public interface LiveDataScope<T> {
    /**
     * Set's the [LiveData]'s value to the given [value]. If you've called [emitSource] previously,
     * calling [emit] will remove that source.
     *
     * Note that this function suspends until the value is set on the [LiveData].
     *
     * @param value The new value for the [LiveData]
     *
     * @see emitSource
     */
    public suspend fun emit(value: T)

    /**
     * Add the given [LiveData] as a source, similar to [MediatorLiveData.addSource]. Calling this
     * method will remove any source that was yielded before via [emitSource].
     *
     * @param source The [LiveData] instance whose values will be dispatched from the current
     * [LiveData].
     *
     * @see emit
     * @see MediatorLiveData.addSource
     * @see MediatorLiveData.removeSource
     */
    public suspend fun emitSource(source: LiveData<T>): DisposableHandle

    /**
     * References the current value of the [LiveData].
     *
     * If the block never `emit`ed a value, [latestValue] will be `null`. You can use this
     * value to check what was then latest value `emit`ed by your `block` before it got cancelled.
     *
     * Note that if the block called [emitSource], then `latestValue` will be last value
     * dispatched by the `source` [LiveData].
     */
    public val latestValue: T?
}
```

定义了emit函数和emitSource函数

### LiveDataScopeImpl

```kotlin
internal class LiveDataScopeImpl<T>(
    internal var target: CoroutineLiveData<T>,
    context: CoroutineContext
) : LiveDataScope<T> {

    override val latestValue: T?
        get() = target.value

    // use `liveData` provided context + main dispatcher to communicate with the target
    // LiveData. This gives us main thread safety as well as cancellation cooperation
    private val coroutineContext = context + Dispatchers.Main.immediate

    override suspend fun emitSource(source: LiveData<T>): DisposableHandle =
        withContext(coroutineContext) {
            return@withContext target.emitSource(source)
        }

    @SuppressLint("NullSafeMutableLiveData")
    override suspend fun emit(value: T) = withContext(coroutineContext) {
        target.clearSource()
        target.value = value
    }
}
```

- emit函数的实现是调用`CoroutineLiveData`的`clearSource`,并更新`LiveData`值
- emitSource的实现是在协程上下文中执行`CoroutineLiveData`的`emitSource`

### CoroutineLiveData的emitSource

```kotlin
internal suspend fun clearSource() {
    emittedSource?.disposeNow()
    emittedSource = null
}
internal suspend fun emitSource(source: LiveData<T>): DisposableHandle {
    clearSource()
    val newSource = addDisposableSource(source)
    emittedSource = newSource
    return newSource
}
```

- emitSource首先调用clearSource
  - 将已发射的source进行dispose
- 创建新的emittedSource

#### addDisposableSource

```kotlin
internal suspend fun <T> MediatorLiveData<T>.addDisposableSource(
    source: LiveData<T>
): EmittedSource = withContext(Dispatchers.Main.immediate) {
    addSource(source) {
        value = it
    }
    EmittedSource(
        source = source,
        mediator = this@addDisposableSource
    )
}
```

- CoroutineLiveData本身就是一个MediatorLiveData
- addDisposableSource时首先通过addSource为自身添加一个source
- 在该source变化时，更新自身的值
- 创建一个`EmittedSource`，并返回

### CoroutineLiveData的clearSource
```kotlin
internal suspend fun clearSource() {
    emittedSource?.disposeNow()
    emittedSource = null
}
```
#### EmittedSource

```kotlin
internal class EmittedSource(
    private val source: LiveData<*>,
    private val mediator: MediatorLiveData<*>
) : DisposableHandle {
    // @MainThread
    private var disposed = false
    /**
     * Unlike [dispose] which cannot be sync because it not a coroutine (and we do not want to
     * lock), this version is a suspend function and does not return until source is removed.
     */
    suspend fun disposeNow() = withContext(Dispatchers.Main.immediate) {
        removeSource()
    }

    override fun dispose() {
        CoroutineScope(Dispatchers.Main.immediate).launch {
            removeSource()
        }
    }

    @MainThread
    private fun removeSource() {
        if (!disposed) {
            mediator.removeSource(source)
            disposed = true
        }
    }
}
```

emittedSource就是为了方便dispose而创建的，dispose就是把source移除

- 在block中，如果我们emitSource了，如果在未来某时刻，我们不再需要这个source了，可以调用`emitSource`返回的`EmittedSource`对象的`dispose`方法来移除
- emit和emitSource存在互斥性，使用emit后，之前的source就会失效

## PublisherLiveData

- rxjava兼容的livedata，使用rxjava的`Publisher`作为数据源