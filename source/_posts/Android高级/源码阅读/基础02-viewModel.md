---
title: 基础02-viewModel
date: 2024-7-31 21:15:36
tags: Android-官方源码
categories: 
    - Android
    - 手撸Android源码
toc: true
language: zh-CN
---

## ViewModel简介
在了解ViewModel之前，我们先来了解一下MVC, MVP, MVVM的发展[Difference Between MVC, MVP and MVVM Architecture Pattern in Android](https://www.geeksforgeeks.org/difference-between-mvc-mvp-and-mvvm-architecture-pattern-in-android/)


## [ViewModelStoreOwner](https://developer.android.com/reference/kotlin/androidx/lifecycle/ViewModelStoreOwner)

```kotlin
interface ViewModelStoreOwner {

    /**
     * The owned [ViewModelStore]
     */
    val viewModelStore: ViewModelStore
}
```

- 实现了`ViewModelStoreOwner`的类会有一个`viewModelStore`属性
- 在创建`ViewModel`时会传递这个变量，具体传递方式在见[by viewModels()](#by-viewmodels)
- 实现了`ViewModelStoreOwner`的直接子类有： [ComponentActivity](https://developer.android.com/reference/androidx/activity/ComponentActivity), [Fragment](https://developer.android.com/reference/androidx/fragment/app/Fragment) 和 [NavBackStackEntry](https://developer.android.com/reference/androidx/navigation/NavBackStackEntry)

## ViewModelStore
实际上就是维护了一个`MutableMap<String, ViewModel>`

```kotlin
open class ViewModelStore {

    private val map = mutableMapOf<String, ViewModel>()

    /**
     * @hide
     */
    @RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    fun put(key: String, viewModel: ViewModel) {
        val oldViewModel = map.put(key, viewModel)
        oldViewModel?.onCleared()
    }

    /**
     * Returns the `ViewModel` mapped to the given `key` or null if none exists.
     */
    /**
     * @hide
     */
    @RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    operator fun get(key: String): ViewModel? {
        return map[key]
    }

    /**
     * @hide
     */
    @RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    fun keys(): Set<String> {
        return HashSet(map.keys)
    }

    /**
     * Clears internal storage and notifies `ViewModel`s that they are no longer used.
     */
    fun clear() {
        for (vm in map.values) {
            vm.clear()
        }
        map.clear()
    }
}
```

发现就是在对map读写，注意到put方法会调用同key值的旧ViewModel的`onCleared`
- `onCleared`并不执行任何操作，是提供给子类进行回收资源的回调。`ViewModel`真正进行资源回收（调用`Closeable`的`close`方法）的函数是`clear`，put中并没有调用，这是一个很奇怪的问题，具体的原因在[下面](#a-viewmodelstoreput问题)会解释
- 那么这个key是什么呢，[下面](#viewmodelprovider的get方法)再看吧

## `by viewModels()`

### `ComponentActivity`的`viewModels()`

```kotlin
@MainThread
public inline fun <reified VM : ViewModel> ComponentActivity.viewModels(
    noinline extrasProducer: (() -> CreationExtras)? = null,
    noinline factoryProducer: (() -> Factory)? = null
): Lazy<VM> {
    val factoryPromise = factoryProducer ?: {
        defaultViewModelProviderFactory
    }

    return ViewModelLazy(
        VM::class,
        { viewModelStore }, // 1️⃣ viewModelStore的传递在这里
        factoryPromise, 
        { extrasProducer?.invoke() ?: this.defaultViewModelCreationExtras }
    )
}
```

可以看到`viewModels()`实际上是`ComponentActivity`的一个扩展方法，返回了`ViewModelLazy`对`ViewModel`的属性进行代理

## ViewModelLazy

```kotlin
public class ViewModelLazy<VM : ViewModel> @JvmOverloads constructor(
    private val viewModelClass: KClass<VM>,
    private val storeProducer: () -> ViewModelStore,
    private val factoryProducer: () -> ViewModelProvider.Factory,
    private val extrasProducer: () -> CreationExtras = { CreationExtras.Empty }
) : Lazy<VM> {
    private var cached: VM? = null

    override val value: VM
        get() {
            val viewModel = cached
            return if (viewModel == null) {
                val factory = factoryProducer()
                val store = storeProducer()
                ViewModelProvider(
                    store,
                    factory,
                    extrasProducer()
                ).get(viewModelClass.java).also {
                    cached = it
                }
            } else {
                viewModel
            }
        }

    override fun isInitialized(): Boolean = cached != null
}
```

可以看到当属性首次`get`时会构造`ViewModelProvider`并调用`get`方法获取`viewModel`对象

## ViewModelProvider

### `ViewModelProvider`的`get`方法

```kotlin
@MainThread
public open operator fun <T : ViewModel> get(modelClass: Class<T>): T {
    val canonicalName = modelClass.canonicalName
        ?: throw IllegalArgumentException("Local and anonymous classes can not be ViewModels")
    return get("$DEFAULT_KEY:$canonicalName", modelClass)
}

public open operator fun <T : ViewModel> get(key: String, modelClass: Class<T>): T {
    val viewModel = store[key] // 1️⃣ 从store中取viewModel
    if (modelClass.isInstance(viewModel)) { // 2️⃣ 判断合法性
        (factory as? OnRequeryFactory)?.onRequery(viewModel!!)
        return viewModel as T
    } else {
        @Suppress("ControlFlowWithEmptyBody")
        if (viewModel != null) {
            // TODO: log a warning.
        }
    }
    val extras = MutableCreationExtras(defaultCreationExtras)
    extras[VIEW_MODEL_KEY] = key
    // AGP has some desugaring issues associated with compileOnly dependencies so we need to
    // fall back to the other create method to keep from crashing.
    return try {
        factory.create(modelClass, extras) // 3️⃣ 通过factory创建ViewModel
    } catch (e: AbstractMethodError) { // 3️⃣ 通过factory创建ViewModel
        factory.create(modelClass)
    }.also { store.put(key, it) } // 4️⃣ 存入store
}
```

- 1️⃣ 从`store`中取`viewModel`，这个`store`就是上面提到的[ViewModelStore](#viewmodelstore), 这里可以看到其`key`就是类名
- 2️⃣ 判断合法性，`isInstance`函数首先判空，其次判断是否为对应的类型，这一步的判空是为了判断是否需要构造`ViewModel`实例，避免返回空；这一步的判断类型则是为了提高安全性，返回时强转不会强转失败
- 3️⃣ 通过`factory`创建，这一步显而易见，创建新的实例。这里的`factory`默认值是通过`ComponentActivity`构造的`SavedStateViewModelFactory`
- 4️⃣ 存入`store`，在创建后存入`store`中

### A: ViewModelStore.put()问题
> 这里可以推测，如果同一个`ViewModelStoreOwner`中声明了多个同类型的`ViewModel`，根据2️⃣的判断，他们会是同一个实例。`ViewModelStore.put`时一般不会存在同key值的`ViewModel`对象，所以那里是否调用`clear`进行资源回收也就不是很重要了。
## ViewModel
ViewModel类实际上不是实际实现，持有`ViewModelImpl`的实例，对其方法进行代理
### 类定义
```kotlin
public actual abstract class ViewModel
```

几个注意的点：
- actual: 介绍看[这里](https://www.baeldung.com/kotlin/actual-expect-keywords), 大概是和跨端相关的。
- abstract

### clear方法
```kotlin
protected actual open fun onCleared() {}

@MainThread
internal actual fun clear() {
    impl?.clear()
    onCleared()
}
```

- 这里可以看到稍有不同的是，除了代理调用`ViewModelImpl`的`clear`方法，还调用了钩子方法`onCleared`
- 另外很有趣的是`ViewModelImpl`和`ViewModel`并没有继承关系，也没有继承相同的接口

## ViewModelImpl

### 关键的属性

```kotlin
private val keyToCloseables = mutableMapOf<String, AutoCloseable>()

/**
    * @see [keyToCloseables]
    */
private val closeables = mutableSetOf<AutoCloseable>()
```

可以看到维护了一个map和一个set，保存`AutoCloseable`

### addCloseable

```kotlin
fun addCloseable(key: String, closeable: AutoCloseable) {
    // Although no logic should be done after user calls onCleared(), we will
    // ensure that if it has already been called, the closeable attempting to
    // be added will be closed immediately to ensure there will be no leaks.
    if (isCleared) {
        closeWithRuntimeException(closeable)
        return
    }

    val oldCloseable = synchronized(lock) { keyToCloseables.put(key, closeable) }
    closeWithRuntimeException(oldCloseable)
}

/** @see [ViewModel.addCloseable] */
fun addCloseable(closeable: AutoCloseable) {
    // Although no logic should be done after user calls onCleared(), we will
    // ensure that if it has already been called, the closeable attempting to
    // be added will be closed immediately to ensure there will be no leaks.
    if (isCleared) {
        closeWithRuntimeException(closeable)
        return
    }

    synchronized(lock) { closeables += closeable }
}
```

- 可以看到两个函数，一个是添加到map中，一个是添加到set中
- 如果当前ViewModel已经被clear了，那么会调用`closeWithRuntimeException`，这个方法会调用其close方法，并将close时出现的异常转换为`RuntimeException`抛出
- 如果map中有同key值的closeable，那么也会调用`closeWithRuntimeException`将其关闭
- 这两个函数也可以提供给用户使用

### 构造方法

```kotlin
constructor()

constructor(viewModelScope: CoroutineScope) {
    addCloseable(VIEW_MODEL_SCOPE_KEY, viewModelScope.asCloseable())
}

constructor(vararg closeables: AutoCloseable) {
    this.closeables += closeables
}

constructor(viewModelScope: CoroutineScope, vararg closeables: AutoCloseable) {
    addCloseable(VIEW_MODEL_SCOPE_KEY, viewModelScope.asCloseable())
    this.closeables += closeables
}
```

- 可以看到，只允许传递一个`CoroutineScope`，会将其转化为closeable，存到map中
- 看上去只允许传递一个`CoroutineScope`，但是还是可以通过相同的方法传递多个用`CloseableCoroutineScope`包装过的Scope对象
- 这个构造允许传递一个`CoroutineScope`完全是为了将其转化为Closeable对象，没有别的意义，感觉很多余。


### clear
```kotlin
@MainThread
fun clear() {
    if (isCleared) return // 1️⃣

    isCleared = true // 2️⃣
    synchronized(lock) {
        for (closeable in keyToCloseables.values) {
            closeWithRuntimeException(closeable)
        }
        for (closeable in closeables) {
            closeWithRuntimeException(closeable)
        }
        // Clear only resources without keys to prevent accidental recreation of resources.
        // For example, `viewModelScope` would be recreated leading to unexpected behaviour.
        closeables.clear()
    }
}
```

- `@MainThread`标明该方法应该被在主线程调用
- 方法其实就是把所有closeable关掉，再把set清空，但是map却没有清空？
- 可以看到1️⃣和2️⃣并不是原子的，如果clear被多个线程同时调用，有可能存在map里的closeable被close两次的情况。

## SavedStateViewModelFactory

### create方法

```kotlin
override fun <T : ViewModel> create(modelClass: Class<T>, extras: CreationExtras): T { // 1️⃣
    val key = extras[ViewModelProvider.NewInstanceFactory.VIEW_MODEL_KEY]
        ?: throw IllegalStateException(
            "VIEW_MODEL_KEY must always be provided by ViewModelProvider"
        )

    return if (extras[SAVED_STATE_REGISTRY_OWNER_KEY] != null &&
        extras[VIEW_MODEL_STORE_OWNER_KEY] != null) {
        val application = extras[ViewModelProvider.AndroidViewModelFactory.APPLICATION_KEY]
        val isAndroidViewModel = AndroidViewModel::class.java.isAssignableFrom(modelClass)
        val constructor: Constructor<T>? = if (isAndroidViewModel && application != null) {
            findMatchingConstructor(modelClass, ANDROID_VIEWMODEL_SIGNATURE)
        } else {
            findMatchingConstructor(modelClass, VIEWMODEL_SIGNATURE)
        }
        // doesn't need SavedStateHandle
        if (constructor == null) {
            return factory.create(modelClass, extras)
        }
        val viewModel = if (isAndroidViewModel && application != null) {
            newInstance(modelClass, constructor, application, extras.createSavedStateHandle())
        } else {
            newInstance(modelClass, constructor, extras.createSavedStateHandle())
        }
        viewModel
    } else {
        val viewModel = if (lifecycle != null) {
            create(key, modelClass)
        } else {
            throw IllegalStateException("SAVED_STATE_REGISTRY_OWNER_KEY and" +
                "VIEW_MODEL_STORE_OWNER_KEY must be provided in the creation extras to" +
                "successfully create a ViewModel.")
        }
        viewModel
    }
}

/**
    * Creates a new instance of the given `Class`.
    *
    * @param key a key associated with the requested ViewModel
    * @param modelClass a `Class` whose instance is requested
    * @return a newly created ViewModel
    *
    * @throws UnsupportedOperationException if the there is no lifecycle
    */
fun <T : ViewModel> create(key: String, modelClass: Class<T>): T { // 2️⃣
    // empty constructor was called.
    val lifecycle = lifecycle
        ?: throw UnsupportedOperationException(
            "SavedStateViewModelFactory constructed with empty constructor supports only " +
                "calls to create(modelClass: Class<T>, extras: CreationExtras)."
        )
    val isAndroidViewModel = AndroidViewModel::class.java.isAssignableFrom(modelClass)
    val constructor: Constructor<T>? = if (isAndroidViewModel && application != null) {
        findMatchingConstructor(modelClass, ANDROID_VIEWMODEL_SIGNATURE)
    } else {
        findMatchingConstructor(modelClass, VIEWMODEL_SIGNATURE)
    }
    // doesn't need SavedStateHandle
    constructor
        ?: // If you are using a stateful constructor and no application is available, we
        // use an instance factory instead.
        return if (application != null) factory.create(modelClass)
        else instance.create(modelClass)
    val controller = LegacySavedStateHandleController.create(
        savedStateRegistry!!, lifecycle, key, defaultArgs
    )
    val viewModel: T = if (isAndroidViewModel && application != null) {
        newInstance(modelClass, constructor, application!!, controller.handle)
    } else {
        newInstance(modelClass, constructor, controller.handle)
    }
    viewModel.setTagIfAbsent(
        AbstractSavedStateViewModelFactory.TAG_SAVED_STATE_HANDLE_CONTROLLER, controller
    )
    return viewModel
}

```

- 1️⃣和2️⃣大体流程上都是获取构造函数，创建实例对象
- 区别在于`newInstance`的第四个参数不同，一个通过`extras`获取，一个通过`LegacySavedStateHandleController`获得，看起来很复杂，但是看一下这个`newInstance`的实现就会发现，第四个参数实际上就是构造函数的参数

```kotlin
internal fun <T : ViewModel?> newInstance(
    modelClass: Class<T>,
    constructor: Constructor<T>,
    vararg params: Any
): T {
    return try {
        constructor.newInstance(*params)
    } catch (e: IllegalAccessException) {
        throw RuntimeException("Failed to access $modelClass", e)
    } catch (e: InstantiationException) {
        throw RuntimeException("A $modelClass cannot be instantiated.", e)
    } catch (e: InvocationTargetException) {
        throw RuntimeException(
            "An exception happened in constructor of $modelClass", e.cause
        )
    }
}
```

## viewModelStore何时被clear
在ComponentActivty的初始化时，会看到下面这段代码
```kotlin
lifecycle.addObserver(LifecycleEventObserver { _, event ->
    if (event == Lifecycle.Event.ON_DESTROY) {
        // Clear out the available context
        contextAwareHelper.clearAvailableContext()
        // And clear the ViewModelStore
        if (!isChangingConfigurations) {
            viewModelStore.clear()
        }
        reportFullyDrawnExecutor.activityDestroyed()
    }
})
```

如果Activity生命周期到了`ON_DESTROY`，且不是夜间模式改变等情况，就会将viewModel清空，做到了界面和数据分离。

## CoroutineScope是如何变成Closeable的
```kotlin
internal fun CoroutineScope.asCloseable() = CloseableCoroutineScope(coroutineScope = this)

/**
 * [CoroutineScope] that provides a method to [close] it, causing the rejection of any new tasks and
 * cleanup of all underlying resources associated with the scope.
 */
internal class CloseableCoroutineScope(
    override val coroutineContext: CoroutineContext,
) : AutoCloseable, CoroutineScope {

    constructor(coroutineScope: CoroutineScope) : this(coroutineScope.coroutineContext)

    override fun close() = coroutineContext.cancel()
}
```

> `CloseableCoroutineScope`实现了`AutoCloseable`, 在close方法中将协程cancel掉

## CreationExtras
在[SavedStateViewModelFactory的create方法](#create方法)中，可以看到factory会拿到一个`CreationExtras`
在[by viewModels()](#by-viewmodels)时，会传递一个构造`CreationExtras`的函数，如果没提供，就使用默认`ComponentActivity`提供的`defaultViewModelCreationExtras`

### 默认的`CreationExtras`
```kotlin
override val defaultViewModelCreationExtras: CreationExtras
    /**
        * {@inheritDoc}
        *
        * The extras of [getIntent] when this is first called will be used as
        * the defaults to any [androidx.lifecycle.SavedStateHandle] passed to a view model
        * created using this extra.
        */
    get() {
        val extras = MutableCreationExtras()
        if (application != null) {
            extras[APPLICATION_KEY] = application
        }
        extras[SAVED_STATE_REGISTRY_OWNER_KEY] = this
        extras[VIEW_MODEL_STORE_OWNER_KEY] = this
        val intentExtras = intent?.extras
        if (intentExtras != null) {
            extras[DEFAULT_ARGS_KEY] = intentExtras
        }
        return extras
    }
```

可以看到里面存了当前的Application对象，还有两个this，还会将`intent.extra`放进去
> MutableCreationExtras其实也是维护了一个map

## 给ViewModel传参
- 前面提到我们可以指定`Factory`和`CreationExtras`
- 可以自己编写`Factory`，从`CreationExtras`中获取参数，下面是示例代码
```kotlin
class MainViewModel(
    private val coroutineScope: CoroutineScope = CloseableCoroutineScope(), 
    param1: String, 
    param2: Int
) : ViewModel(coroutineScope) {

    companion object {
        override fun <T : ViewModel> create(modelClass: Class<T>, extras: CreationExtras): T {
            val param1 = extras[MY_PARAM_KEY1]!!
            val param2 = extras[MY_PARAM_KEY2]!!
            return MainViewModel(param1 = param1, param2 = param2) as T
        }
        val MY_PARAM_KEY1 = object : CreationExtras.Key<String> {}
        val MY_PARAM_KEY2 = object : CreationExtras.Key<Int> {}
    }
}
```

```kotlin
class MyActivity : AppCompatActivity() {
    private val viewModel : MainViewModel by viewModels({
        return@viewModels MutableCreationExtras().apply {
            set(MainViewModel.MY_PARAM_KEY1, "1")
            set(MainViewModel.MY_PARAM_KEY2, 2)
        }
    }){
        return@viewModels MainViewModel.Factory
    }
}
```

## Fragment.viewModels

```kotlin
@MainThread
public inline fun <reified VM : ViewModel> Fragment.viewModels(
    noinline ownerProducer: () -> ViewModelStoreOwner = { this },
    noinline extrasProducer: (() -> CreationExtras)? = null,
    noinline factoryProducer: (() -> Factory)? = null
): Lazy<VM> {
    val owner by lazy(LazyThreadSafetyMode.NONE) { ownerProducer() }
    return createViewModelLazy(
        VM::class,
        { owner.viewModelStore },
        {
            extrasProducer?.invoke()
            ?: (owner as? HasDefaultViewModelProviderFactory)?.defaultViewModelCreationExtras
            ?: CreationExtras.Empty
        },
        factoryProducer ?: {
            (owner as? HasDefaultViewModelProviderFactory)?.defaultViewModelProviderFactory
                ?: defaultViewModelProviderFactory
        })
}
```

- 支持创建/获取其他`owner`的`ViewModel`
- 和`ComponentActivity`一样，`createViewModelLazy`的返回的也是`ViewModelLazy`类

## Fragment.activityViewModels

```kotlin
@MainThread
public inline fun <reified VM : ViewModel> Fragment.activityViewModels(
    noinline extrasProducer: (() -> CreationExtras)? = null,
    noinline factoryProducer: (() -> Factory)? = null
): Lazy<VM> = createViewModelLazy(
    VM::class, { requireActivity().viewModelStore },
    { extrasProducer?.invoke() ?: requireActivity().defaultViewModelCreationExtras },
    factoryProducer ?: { requireActivity().defaultViewModelProviderFactory }

)
```

- 获取`activity`的`viewModelStore`

## 获取父fragment的viewModel

```kotlin
val parentFragmentViewModel:XXXViewModel by viewModels(ownerProducer = { requireParentFragment() })
```

## navigation图的viewModel
```kotlin
val naviViewModel : MainViewModel by navGraphViewModels(R.id.xxx)
val naviViewModel1 : MainViewModel by viewModels(ownerProducer = { findNavController().getBackStackEntry(R.id.xxx) })
```

```kotlin
@MainThread
public inline fun <reified VM : ViewModel> Fragment.navGraphViewModels(
    @IdRes navGraphId: Int,
    noinline extrasProducer: (() -> CreationExtras)? = null,
    noinline factoryProducer: (() -> ViewModelProvider.Factory)? = null
): Lazy<VM> {
    val backStackEntry by lazy {
        findNavController().getBackStackEntry(navGraphId)
    }
    val storeProducer: () -> ViewModelStore = {
        backStackEntry.viewModelStore
    }
    return createViewModelLazy(
        VM::class, storeProducer,
        { extrasProducer?.invoke() ?: backStackEntry.defaultViewModelCreationExtras },
        factoryProducer ?: { backStackEntry.defaultViewModelProviderFactory }
    )
}
```

- navGraphViewModels其实就是调用了`findNavController().getBackStackEntry(navGraphId)`，然后获取其`viewModelStore`

## 非lazy获取的viewModel
```kotlin
val viewModel = ViewModelProvider(this.viewModelStore, ViewModelProvider.NewInstanceFactory.instance)[MainViewModel::class.java]
val viewModel = ViewModelProvider(this.viewModelStore, MainViewModel.Factory, MutableCreationExtras().apply {
    set(MainViewModel.MY_PARAM_KEY1, "1")
    set(MainViewModel.MY_PARAM_KEY2, 2)
})[MainViewModel::class.java]
```

## Compose获取viewModel
```kotlin
@Composable
fun Greeting(string: String, modifier: Modifier = Modifier, vm : MainViewModel = viewModel()) {
    Text(
        text = string,
        modifier = modifier
    )
}
```

```kotlin
@Composable
public inline fun <reified VM : ViewModel> viewModel(
    viewModelStoreOwner: ViewModelStoreOwner = checkNotNull(LocalViewModelStoreOwner.current) {
        "No ViewModelStoreOwner was provided via LocalViewModelStoreOwner"
    },
    key: String? = null,
    factory: ViewModelProvider.Factory? = null,
    extras: CreationExtras = if (viewModelStoreOwner is HasDefaultViewModelProviderFactory) {
        viewModelStoreOwner.defaultViewModelCreationExtras
    } else {
        CreationExtras.Empty
    }
): VM = viewModel(VM::class, viewModelStoreOwner, key, factory, extras)
```

```kotlin
@Suppress("MissingJvmstatic")
@Composable
public fun <VM : ViewModel> viewModel(
    modelClass: KClass<VM>,
    viewModelStoreOwner: ViewModelStoreOwner = checkNotNull(LocalViewModelStoreOwner.current) {
        "No ViewModelStoreOwner was provided via LocalViewModelStoreOwner"
    },
    key: String? = null,
    factory: ViewModelProvider.Factory? = null,
    extras: CreationExtras = if (viewModelStoreOwner is HasDefaultViewModelProviderFactory) {
        viewModelStoreOwner.defaultViewModelCreationExtras
    } else {
        CreationExtras.Empty
    }
): VM = viewModelStoreOwner.get(modelClass, key, factory, extras)
```

```kotlin
internal fun <VM : ViewModel> ViewModelStoreOwner.get(
    modelClass: KClass<VM>,
    key: String? = null,
    factory: ViewModelProvider.Factory? = null,
    extras: CreationExtras = if (this is HasDefaultViewModelProviderFactory) {
        this.defaultViewModelCreationExtras
    } else {
        CreationExtras.Empty
    }
): VM {
    val provider = if (factory != null) {
        ViewModelProvider.create(this.viewModelStore, factory, extras)
    } else if (this is HasDefaultViewModelProviderFactory) {
        ViewModelProvider.create(this.viewModelStore, this.defaultViewModelProviderFactory, extras)
    } else {
        ViewModelProvider.create(this)
    }
    return if (key != null) {
        provider[key, modelClass]
    } else {
        provider[modelClass]
    }
}
```

```kotlin
interface HasDefaultViewModelProviderFactory {
    /**
     * Returns the default [ViewModelProvider.Factory] that should be
     * used when no custom `Factory` is provided to the
     * [ViewModelProvider] constructors.
     */
    val defaultViewModelProviderFactory: ViewModelProvider.Factory

    /**
     * Returns the default [CreationExtras] that should be passed into
     * [ViewModelProvider.Factory.create] when no overriding
     * [CreationExtras] were passed to the [ViewModelProvider] constructors.
     */
    val defaultViewModelCreationExtras: CreationExtras
        get() = CreationExtras.Empty
}
```

- `store`来自`LocalViewModelStoreOwner.current`
- factory和extras来自`HasDefaultViewModelProviderFactory`

## 备忘单
[![](https://developer.android.com/static/images/topic/libraries/architecture/viewmodel-apis-cheatsheet.png?hl=zh-cn)](https://developer.android.com/topic/libraries/architecture/viewmodel/viewmodel-cheatsheet?hl=zh-cn)