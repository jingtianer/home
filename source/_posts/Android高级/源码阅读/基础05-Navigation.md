---
title: 基础05-Navigation
date: 2024-8-07 21:15:36
tags: Android-官方源码
categories: 
    - Android
    - 手撸Android源码
toc: true
language: zh-CN
---

## 简介

`NavController`是中央导航 API。它会跟踪用户访问过的目的地，并允许用户在目的地之间移动。

### 获取`NavController`

- fragment

如果是NavHostFragment
```kotlin
val navController = this.navController
```

如果是普通Fragment
```kotlin
val navController = this.findNavController()
```

- compose

```kotlin
val navController = rememberNavController()
```

`NavHostFragment`实现了`NavHost`接口，可以直接获取`NavController`。

- view

```kotlin
val navController = view.findNavController()
// 这个view必须在一个NavHost之中
```

- activity

先获取`Activity`中的`NavHostFragment`，再获取`NavController`。
```kotlin
val navHostFragment =
    supportFragmentManager.findFragmentById(R.id.nav_host_fragment) as NavHostFragment
val navController = navHostFragment.navController
```

使用Activity的扩展函数`findNavController`，可以获取`NavController`。

```kotlin
val navController = activity.findNavController(R.id.view_within_navhost)
// R.id.view_within_navhost这个view必须在一个NavHost之中
```

#### Fragment.findNavController

```kotlin
public fun Fragment.findNavController(): NavController =
    NavHostFragment.findNavController(this)
```

```kotlin
@JvmStatic
public fun findNavController(fragment: Fragment): NavController {
    var findFragment: Fragment? = fragment
    while (findFragment != null) {
        if (findFragment is NavHostFragment) {
            return findFragment.navHostController
        }
        val primaryNavFragment = findFragment.parentFragmentManager
            .primaryNavigationFragment
        if (primaryNavFragment is NavHostFragment) {
            return primaryNavFragment.navHostController
        }
        findFragment = findFragment.parentFragment
    }

    // Try looking for one associated with the view instead, if applicable
    val view = fragment.view
    if (view != null) {
        return Navigation.findNavController(view)
    }

    // For DialogFragments, look at the dialog's decor view
    val dialogDecorView = (fragment as? DialogFragment)?.dialog?.window?.decorView
    if (dialogDecorView != null) {
        return Navigation.findNavController(dialogDecorView)
    }
    throw IllegalStateException("Fragment $fragment does not have a NavController set")
}
```

- 从当前fragment开始寻找
  - 如果有`NavHostFragment`，就返回他的`NavController`
  - 如果没有，就找`parentFragmentManager`的`primaryNavigationFragment`
    - 如果是`NavHostFragment`，就返回他的`NavController`
    - 如果不是，就把当前`fragment`设置为`parentFragment`，重复上面过程，直到找到一个`NavHostFragment`或没有`parentFragment`为止
- 如果当前fragment及父fragment中找不到`NavHostFragment`，就尝试从当前fragment的`view`中寻找
- 如果还是找不到，尝试判断当前`fragment`是否为`DialogFragment`，如果是，则从`DialogFragment`的`decorView`中查找
- 如果还是找不到，就抛出异常

#### View.findNavController

```kotlin
public fun View.findNavController(): NavController =
    Navigation.findNavController(this)
```

#### Activity.findNavController

```kotlin
public fun Activity.findNavController(
    @IdRes viewId: Int
): NavController = Navigation.findNavController(this, viewId)
```

```kotlin
@JvmStatic
public fun findNavController(activity: Activity, @IdRes viewId: Int): NavController {
    val view = ActivityCompat.requireViewById<View>(activity, viewId)
    return findViewNavController(view)
        ?: throw IllegalStateException(
            "Activity $activity does not have a NavController set on $viewId"
        )
}
```

- Activity就是比View多了一步`findViewById`

#### `findViewNavController(view: View)`

```kotlin
private fun findViewNavController(view: View): NavController? =
    generateSequence(view) {
        it.parent as? View?
    }.mapNotNull {
        getViewNavController(it)
    }.firstOrNull()
```

- 其实就是从当前view开始，一直找到根view，如果过程中有`NavController`，就返回
- 其中一个设置`nav_controller_view_tag`的地方可以看[NavHostFragment#onviewcreated](#onviewcreated)

```kotlin
@Suppress("UNCHECKED_CAST")
private fun getViewNavController(view: View): NavController? {
    val tag = view.getTag(R.id.nav_controller_view_tag)
    var controller: NavController? = null
    if (tag is WeakReference<*>) {
        controller = (tag as WeakReference<NavController>).get()
    } else if (tag is NavController) {
        controller = tag
    }
    return controller
}
```

```kotlin
@kotlin.internal.LowPriorityInOverloadResolution
public fun <T : Any> generateSequence(seed: T?, nextFunction: (T) -> T?): Sequence<T> =
    if (seed == null)
        EmptySequence
    else
        GeneratorSequence({ seed }, nextFunction)
```


### 导航图

#### 使用kotlin DSL

```kotlin
public inline fun NavController.createGraph(
    startDestination: String,
    route: String? = null,
    builder: NavGraphBuilder.() -> Unit
): NavGraph = navigatorProvider.navigation(startDestination, route, builder)
```

#### xml

首先，创建一个 NavHostFragment。它充当包含实际导航图的导航宿主。

NavHostFragment 的最小实现：

```xml
<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <androidx.fragment.app.FragmentContainerView
        android:id="@+id/nav_host_fragment"
        android:name="androidx.navigation.fragment.NavHostFragment"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        app:navGraph="@navigation/nav_graph" />

</FrameLayout>
```

NavHostFragment 包含 app:navGraph 属性。使用此属性可将导航图连接到导航宿主。以下示例展示了如何实现该图：

```xml
<navigation xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:id="@+id/nav_graph"
    app:startDestination="@id/profile">
   <!-- Action back to destination which launched into this profile -->
   <action android:id="@+id/action_global_profile"
                       app:popUpTo="@id/profile"
                       app:popUpToInclusive="true" />
    <fragment
        android:id="@+id/profile"
        android:name="com.example.ProfileFragment"
        android:label="Profile">

        <!-- Action to navigate from Profile to Friends List. -->
        <action
            android:id="@+id/action_profile_to_friendslist"
            app:destination="@id/friendslist" />
    </fragment>

    <fragment
        android:id="@+id/friendslist"
        android:name="com.example.FriendsListFragment"
        android:label="Friends List">
        <!-- 深层链接 -->
        <!-- https://developer.android.com/guide/navigation/design/deep-link?hl=zh-cn -->
        <deepLink app:uri="www.example.com"
                app:action="android.intent.action.MY_ACTION"
                app:mimeType="type/subtype"/>
    </fragment>

    <!-- Add other fragment destinations similarly. -->

    <!-- 对话框目的地 -->
    <dialog
        android:id="@+id/my_dialog_fragment"
        android:name="androidx.navigation.myapp.MyDialogFragment">
        <argument android:name="myarg" android:defaultValue="@null" />
            <action
                android:id="@+id/myaction"
                app:destination="@+id/another_destination"/>
    </dialog>

    <!-- Activity目的地 -->
    <activity
        android:id="@+id/sampleActivityDestination"
        android:name="com.example.android.navigation.activity.DestinationActivity"
        android:label="@string/sampleActivityTitle" />

    <!-- 嵌套图 -->
    <!-- 应用中的登录流程、向导或其他子流程通常是嵌套导航图的最佳表示形式。通过以这种方式嵌套独立的子导航流程，您可以更轻松地理解和管理应用界面的主流程。 -->

    <navigation android:id="@+id/sendMoneyGraph" app:startDestination="@id/chooseRecipient">
       <fragment
           android:id="@+id/chooseRecipient"
           android:name="com.example.cashdog.cashdog.ChooseRecipient"
           android:label="fragment_choose_recipient"
           tools:layout="@layout/fragment_choose_recipient">
           <action
               android:id="@+id/action_chooseRecipient_to_chooseAmountFragment"
               app:destination="@id/chooseAmountFragment" />
       </fragment>
       <fragment
           android:id="@+id/chooseAmountFragment"
           android:name="com.example.cashdog.cashdog.ChooseAmountFragment"
           android:label="fragment_choose_amount"
           tools:layout="@layout/fragment_choose_amount" />
   </navigation>
</navigation>
```

## NavHostFragment

```kotlin
public open class NavHostFragment : Fragment(), NavHost {
    // ...
}
```

实现了`navHost`接口，也就是有了一个`navHostController`属性

### navHostController

```kotlin
final override val navController: NavController
        get() = navHostController

internal val navHostController: NavHostController by lazy { // 1: lazy
    val context = checkNotNull(context) { // 2: 获取context并判空
        "NavController cannot be created before the fragment is attached"
    }
    NavHostController(context).apply { // 3: 生成实例
        setLifecycleOwner(this@NavHostFragment) // 4: 传递fragment为lifecycleOwner
        setViewModelStore(viewModelStore) // 5: 传递fragment的viewModelStore
        onCreateNavHostController(this) // 6: 回调通知fragment
        savedStateRegistry.consumeRestoredStateForKey(KEY_NAV_CONTROLLER_STATE)?.let {
            restoreState(it)
        }
        savedStateRegistry.registerSavedStateProvider(KEY_NAV_CONTROLLER_STATE) {
            saveState() ?: Bundle.EMPTY
        }
        savedStateRegistry.consumeRestoredStateForKey(KEY_GRAPH_ID)?.let { bundle ->
            graphId = bundle.getInt(KEY_GRAPH_ID)
        }
        savedStateRegistry.registerSavedStateProvider(KEY_GRAPH_ID) {
            if (graphId != 0) {
                bundleOf(KEY_GRAPH_ID to graphId)
            } else {
                Bundle.EMPTY
            }
        } // 7: savedState相关的看不懂，todo: 以后再看
        if (graphId != 0) { // // 8: setGraph
            // Set from onInflate()
            setGraph(graphId) // 8.1: 导航图id不为0，有效，设置导航图
        } else {
            // See if it was set by NavHostFragment.create()
            val args = arguments
            val graphId = args?.getInt(KEY_GRAPH_ID) ?: 0
            val startDestinationArgs = args?.getBundle(KEY_START_DESTINATION_ARGS)
            if (graphId != 0) { // 8.2: 尝试从fragment的`arguments`获取导航图和startDestinationArgs
                setGraph(graphId, startDestinationArgs)
            }
        }
    }
}
```

就是创建了一个`navHostController`,详细内容看[NavHostController类](#navhostcontroller类)

#### 1: lazy
这个没啥说的，就是懒加载

#### 2: 获取context并判空

- `fragment`的`getContext`

```kotlin
@Nullable
public Context getContext() {
    return mHost == null ? null : mHost.getContext();
}
```
> `mHost`会在`FragmentStateManager`调用`moveToExpectedState`时，如果移动到`Fragment.ATTACHED`状态，调用`attach`方法时，进行初始化
>
> // todo: 再挖个坑以后学习


#### 6: 回调通知fragment
- 这里调用的是`NavHostFragment`的方法
```kotlin
@Suppress("DEPRECATION")
@CallSuper
protected open fun onCreateNavHostController(navHostController: NavHostController) {
    onCreateNavController(navHostController)
}
```

```kotlin
/**
* Callback for when the [NavController][getNavController] is created. If you
* support any custom destination types, their [Navigator] should be added here to
* ensure it is available before the navigation graph is inflated / set.
*
* By default, this adds a [DialogFragmentNavigator] and [FragmentNavigator].
*
* This is only called once when the navController is called. This will be called in [onCreate]
* if the navController has not yet been called. This should not be called directly by
* subclasses.
*
* @param navController The newly created [NavController].
*/
@Suppress("DEPRECATION")
@CallSuper
@Deprecated(
    """Override {@link #onCreateNavHostController(NavHostController)} to gain
    access to the full {@link NavHostController} that is created by this NavHostFragment."""
)
protected open fun onCreateNavController(navController: NavController) {
    navController.navigatorProvider +=
        DialogFragmentNavigator(requireContext(), childFragmentManager)
    navController.navigatorProvider.addNavigator(createFragmentNavigator())
}
```

> 1. 创建`getNavController`时的回调函数。如果您支持任何自定义目标类型，则应将其导航器添加到此处，以确保在导航图`inflate/set`之前可用。 
> 2. 默认情况下，这会添加一个`DialogFragmentNavigator`和`FragmentNavigator`。 
> 3. 它只在`navController`被调用时被调用一次。如果`navController`还没有被调用，这个函数会在`onCreate`中被调用。子类不应该直接调用这个方法。

翻译一下这个函数的注释
1. 第一句是说子类可以重写这个方法，添加自定义的Navigator
2. 第二句是说默认会添加`DialogFragmentNavigator`和`FragmentNavigator`
3. 要理解第三句先看下面代码，`navHostController`时lazy，但是在`Fragment#onCreate`时会主动出发他的创建过程
```kotlin
@CallSuper
public override fun onCreate(savedInstanceState: Bundle?) {
    // We are accessing the NavController here to ensure that it is always created by this point
    navHostController
    if (savedInstanceState != null) {
        if (savedInstanceState.getBoolean(KEY_DEFAULT_NAV_HOST, false)) {
            defaultNavHost = true
            parentFragmentManager.beginTransaction()
                .setPrimaryNavigationFragment(this)
                .commit()
        }
    }

    // We purposefully run this last as this will trigger the onCreate() of
    // child fragments, which may be relying on having the NavController already
    // created and having its state restored by that point.
    super.onCreate(savedInstanceState)
}
```

#### 7: savedState相关的看不懂，todo: 以后再看

// todo: 占坑，以后再看

#### 8: setGraph
- 导航图id不为0，有效，设置导航图
- 导航图id为0, 尝试从fragment的`arguments`获取`导航图id`和`startDestinationArgs`
- setArguments是父类`Fragment`的一个方法，`mArguments`就是一个`Bundle`

```java
public void setArguments(@Nullable Bundle args) {
    if (mFragmentManager != null && isStateSaved()) {
        throw new IllegalStateException("Fragment already added and state has been saved");
    }
    mArguments = args;
}
```

### 创建NavHostFragment
```kotlin
@JvmOverloads
@JvmStatic
public fun create(
    @NavigationRes graphResId: Int,
    startDestinationArgs: Bundle? = null
): NavHostFragment {
    var b: Bundle? = null
    if (graphResId != 0) {
        b = Bundle()
        b.putInt(KEY_GRAPH_ID, graphResId)
    }
    if (startDestinationArgs != null) {
        if (b == null) {
            b = Bundle()
        }
        b.putBundle(KEY_START_DESTINATION_ARGS, startDestinationArgs)
    }
    val result = NavHostFragment()
    if (b != null) {
        result.arguments = b
    }
    return result
}
```
- 可以看到, `KEY_GRAPH_ID`和`KEY_START_DESTINATION_ARGS`

### 几个key的定义

```kotlin
public companion object {
    /**
        */
    @RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    public const val KEY_GRAPH_ID: String = "android-support-nav:fragment:graphId"

    /**
        */
    @RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    public const val KEY_START_DESTINATION_ARGS: String =
        "android-support-nav:fragment:startDestinationArgs"
    private const val KEY_NAV_CONTROLLER_STATE =
        "android-support-nav:fragment:navControllerState"
    private const val KEY_DEFAULT_NAV_HOST = "android-support-nav:fragment:defaultHost"
}
```
- `KEY_GRAPH_ID`和`KEY_START_DESTINATION_ARGS`被限制在同组lib中使用，也就是不推荐我们自己手动通过这两个key来设置`导航图id`和`args`

```kotlin
private var graphId = 0
```
`graphId`也是`private`的，也无法通过继承的方式修改他的值

### onInflate

```kotlin
@CallSuper
public override fun onInflate(
    context: Context,
    attrs: AttributeSet,
    savedInstanceState: Bundle?
) {
    super.onInflate(context, attrs, savedInstanceState)
    context.obtainStyledAttributes(
        attrs,
        androidx.navigation.R.styleable.NavHost
    ).use { navHost ->
        val graphId = navHost.getResourceId(
            androidx.navigation.R.styleable.NavHost_navGraph, 0
        )
        if (graphId != 0) {
            this.graphId = graphId
        }
    }
    context.obtainStyledAttributes(attrs, R.styleable.NavHostFragment).use { array ->
        val defaultHost = array.getBoolean(R.styleable.NavHostFragment_defaultNavHost, false)
        if (defaultHost) {
            defaultNavHost = true
        }
    }
}
```

导航图和`defaultNavHost`可以在`FragmentContainerView`的`xml`中使用`navGraph`和`defaultNavHost`定义


### onSaveInstanceState
- `onSaveInstanceState`时如果`defaultNavHost`是`true`会把这个状态存起来，`onCreate`时恢复
```kotlin
@CallSuper
public override fun onSaveInstanceState(outState: Bundle) {
    super.onSaveInstanceState(outState)
    if (defaultNavHost) {
        outState.putBoolean(KEY_DEFAULT_NAV_HOST, true)
    }
}
```

### onCreate

```kotlin
@CallSuper
public override fun onCreate(savedInstanceState: Bundle?) {
    // We are accessing the NavController here to ensure that it is always created by this point
    navHostController
    if (savedInstanceState != null) {
        if (savedInstanceState.getBoolean(KEY_DEFAULT_NAV_HOST, false)) {
            defaultNavHost = true
            parentFragmentManager.beginTransaction()
                .setPrimaryNavigationFragment(this)
                .commit()
        }
    }

    // We purposefully run this last as this will trigger the onCreate() of
    // child fragments, which may be relying on having the NavController already
    // created and having its state restored by that point.
    super.onCreate(savedInstanceState)
}
```

### onViewCreated
- 会给view设置`navHostController`
```kotlin
public override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
    super.onViewCreated(view, savedInstanceState)
    check(view is ViewGroup) { "created host view $view is not a ViewGroup" }
    Navigation.setViewNavController(view, navHostController)
    // When added programmatically, we need to set the NavController on the parent - i.e.,
    // the View that has the ID matching this NavHostFragment.
    if (view.getParent() != null) {
        viewParent = view.getParent() as View
        if (viewParent!!.id == id) {
            Navigation.setViewNavController(viewParent!!, navHostController)
        }
    }
}
```
通过view的`setTag`设置
```kotlin
@JvmStatic
public fun setViewNavController(view: View, controller: NavController?) {
    view.setTag(R.id.nav_controller_view_tag, controller)
}
```

### onDestroyView
- 非常对称的，在onDestroyView时，会把`viewParent`中的`navHostController`设置为`null`
```kotlin
public override fun onDestroyView() {
    super.onDestroyView()
    viewParent?.let { it ->
        if (Navigation.findNavController(it) === navHostController) {
            Navigation.setViewNavController(it, null)
        }
    }
    viewParent = null
}
```

### defaultNavHost
如果在`attach`时发现是`defaultNavHost`，会提交一个`setPrimaryNavigationFragment`的`transaction`，追踪这个操作，他具体做了以下内容
```java
void setPrimaryNavigationFragment(@Nullable Fragment f) {
    if (f != null && (!f.equals(findActiveFragment(f.mWho))
            || (f.mHost != null && f.mFragmentManager != this))) {
        throw new IllegalArgumentException("Fragment " + f
                + " is not an active fragment of FragmentManager " + this);
    }
    Fragment previousPrimaryNav = mPrimaryNav;
    mPrimaryNav = f;
    dispatchParentPrimaryNavigationFragmentChanged(previousPrimaryNav);
    dispatchParentPrimaryNavigationFragmentChanged(mPrimaryNav);
}
private void dispatchParentPrimaryNavigationFragmentChanged(@Nullable Fragment f) {
    if (f != null && f.equals(findActiveFragment(f.mWho))) {
        f.performPrimaryNavigationFragmentChanged();
    }
}
```
- 找到前一个`primaryNavigationFragment`，和将要设置为`defaultNav`的`fragment`,调用其`performPrimaryNavigationFragmentChanged`操作
```java
void performPrimaryNavigationFragmentChanged() {
    boolean isPrimaryNavigationFragment = mFragmentManager.isPrimaryNavigation(this);
    // Only send out the callback / dispatch if the state has changed
    if (mIsPrimaryNavigationFragment == null
            || mIsPrimaryNavigationFragment != isPrimaryNavigationFragment) {
        mIsPrimaryNavigationFragment = isPrimaryNavigationFragment;
        onPrimaryNavigationFragmentChanged(isPrimaryNavigationFragment);
        mChildFragmentManager.dispatchPrimaryNavigationFragmentChanged();
    }
}
```
- 更新Fragment中的`mIsPrimaryNavigationFragment`这个flag，并且找到子fragment，也去更新其状态
- 调用钩子函数`onPrimaryNavigationFragmentChanged`

```kotlin
public void onPrimaryNavigationFragmentChanged(boolean isPrimaryNavigationFragment) {
}
```

- 他是一个空的方法，子类可以重写，`NavHostFragment`也没有实现它，看来是给程序员自由发挥的。
- 官方文档中[创建 NavHostFragment
](https://developer.android.com/guide/navigation/use-graph/programmatic?hl=zh-cn#create_a_navhostfragment)提到这个操作会`"允许您的 NavHost 截获对系统“返回”按钮的按下操作"`。上面的代码好像并没有体现出来。


## NavHostController类

- `NavHostController`继承自`NavController`，其中没有什么代码，其本身是open的，但它把父类的几个方法设置为`final`，包括：
  - setLifecycleOwner
  - setOnBackPressedDispatcher
  - enableOnBackPressed
  - setViewModelStore

## NavController
### 3: 生成实例

NavHostController构造函数

```kotlin
public open class NavHostController(context: Context) 
    : NavController(context) {
    // ...
}
```

```kotlin
public open class NavController(
    /** @suppress */
    @get:RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    public val context: Context
) {
    // ...
    init {
        _navigatorProvider.addNavigator(NavGraphNavigator(_navigatorProvider))
        _navigatorProvider.addNavigator(ActivityNavigator(context))
    }
    // ...
}
```

- 传递`context`就是存起来以后会用
- 通过`context`创建`ActivityNavigator`

- 可以先剧透一下，`Navigator`就是一个具体实施跳转等操作的类
  - 比如`ActivityNavigator`就会调用`startActivity`
  - `FragmentNavigator`就会构造`FragmentTransaction`来跳转`fragment`

### 4: 传递fragment为lifecycleOwner

```kotlin
public final override fun setLifecycleOwner(owner: LifecycleOwner) {
    super.setLifecycleOwner(owner)
}
```

```kotlin
@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public open fun setLifecycleOwner(owner: LifecycleOwner) {
    if (owner == lifecycleOwner) {
        return
    }
    lifecycleOwner?.lifecycle?.removeObserver(lifecycleObserver)
    lifecycleOwner = owner
    owner.lifecycle.addObserver(lifecycleObserver)
}
```
- 去掉原来的owner，添加新的owner，并添加观察者
```kotlin
private val lifecycleObserver: LifecycleObserver = LifecycleEventObserver { _, event ->
    hostLifecycleState = event.targetState
    if (_graph != null) {
        for (entry in backQueue) {
            entry.handleLifecycleEvent(event)
        }
    }
}
```
- hostLifecycleState就是存对应的生命周期状态
- _graph是一个`NavGraph`, 在`setGraph`中初始化
- backQueue是存放`NavBackStackEntry`的双端队列

### 5: 传递fragment的viewModelStore
```kotlin
public final override fun setViewModelStore(viewModelStore: ViewModelStore) {
    super.setViewModelStore(viewModelStore)
}
```

```kotlin
@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public open fun setViewModelStore(viewModelStore: ViewModelStore) {
    if (viewModel == NavControllerViewModel.getInstance(viewModelStore)) {
        return
    }
    check(backQueue.isEmpty()) { "ViewModelStore should be set before setGraph call" }
    viewModel = NavControllerViewModel.getInstance(viewModelStore)
}
```
- 就是创建了一个`viewModel`，以后会用

### 8: setGraph

- 如果导航图id不为0，有效，设置导航图
```kotlin
public open fun setGraph(@NavigationRes graphResId: Int) {
    setGraph(navInflater.inflate(graphResId), null)
}
```

- 如果导航图为0，则尝试从`fragment`的`arguments`中获取`导航图id`和`startDestinationArgs`
```kotlin
@MainThread
@CallSuper
public open fun setGraph(@NavigationRes graphResId: Int, startDestinationArgs: Bundle?) {
    setGraph(navInflater.inflate(graphResId), startDestinationArgs)
}
```

最终都调用了`setGraph(graph: NavGraph, startDestinationArgs: Bundle?)`

```kotlin
/**
* Sets the [navigation graph][NavGraph] to the specified graph.
* Any current navigation graph data (including back stack) will be replaced.
*
* The graph can be retrieved later via [graph].
*
* @param graph graph to set
* @see NavController.setGraph
* @see NavController.graph
*/
@MainThread
@CallSuper
public open fun setGraph(graph: NavGraph, startDestinationArgs: Bundle?) {
    if (_graph != graph) {
        _graph?.let { previousGraph ->
            // Clear all saved back stacks by iterating through a copy of the saved keys,
            // thus avoiding any concurrent modification exceptions
            val savedBackStackIds = ArrayList(backStackMap.keys)
            savedBackStackIds.forEach { id ->
                clearBackStackInternal(id)
            }
            // Pop everything from the old graph off the back stack
            NavControllerInternal(previousGraph.id, true)
        }
        _graph = graph
        onGraphCreated(startDestinationArgs)
    } else {
        // first we update _graph with new instances from graph
        for (i in 0 until graph.nodes.size()) {
            val newDestination = graph.nodes.valueAt(i)
            val key = _graph!!.nodes.keyAt(i)
            _graph!!.nodes.replace(key, newDestination)
        }
        // then we update backstack with the new instances
        backQueue.forEach { entry ->
            // we will trace this hierarchy in new graph to get new destination instance
            val hierarchy = entry.destination.hierarchy.toList().asReversed()
            val newDestination = hierarchy.fold(_graph!!) {
                    newDest: NavDestination, oldDest: NavDestination ->
                if (oldDest == _graph && newDest == graph) {
                    // if root graph, it is already the node that matches with oldDest
                    newDest
                } else if (newDest is NavGraph) {
                    // otherwise we walk down the hierarchy to the next child
                    newDest.findNode(oldDest.id)!!
                } else {
                    // final leaf node found
                    newDest
                }
            }
            entry.destination = newDestination
        }
    }
}
```
- 考虑了两种情况，setGraph前后`_graph`和`graph`是否相等
  - 注意kt代码有运算符重载，实际上调用的是`NavGraph`的`equals`

```kotlin
override fun equals(other: Any?): Boolean {
    if (this === other) return true
    if (other == null || other !is NavGraph) return false
    return super.equals(other) &&
        nodes.size == other.nodes.size &&
        startDestinationId == other.startDestinationId &&
        nodes.valueIterator().asSequence().all { it == other.nodes.get(it.id) }
}
```

### navigate

#### 通过action的资源id跳转的
```kotlin
// id1: 
public open fun navigate(@IdRes resId: Int) {
    navigate(resId, null)
}
// id2: 
public open fun navigate(@IdRes resId: Int, args: Bundle?) {
    navigate(resId, args, null)
}
// id3: 
public open fun navigate(@IdRes resId: Int, args: Bundle?, navOptions: NavOptions?) {
    navigate(resId, args, navOptions, null)
}
// id4: 
public open fun navigate(
    @IdRes resId: Int,
    args: Bundle?,
    navOptions: NavOptions?,
    navigatorExtras: Navigator.Extras?
) {
    // ...
}
```
> 一个参数的调两个参数的，两个参数的调三个参数的
> 四个参数的巨长但也不是核心的方法，还会调用核心的navigate方法

```kotlin
// id4:
public open fun navigate(
    @IdRes resId: Int,
    args: Bundle?,
    navOptions: NavOptions?,
    navigatorExtras: Navigator.Extras?
) {
    var finalNavOptions = navOptions // 1: navOptions
    val currentNode = (
        if (backQueue.isEmpty())
            _graph
        else
            backQueue.last().destination
        ) ?: throw IllegalStateException(
            "No current destination found. Ensure a navigation graph has been set for " +
                "NavController $this."
        )

    @IdRes
    var destId = resId
    val navAction = currentNode.getAction(resId)
    var combinedArgs: Bundle? = null
    if (navAction != null) {
        if (finalNavOptions == null) { // 1.2: navOptions空的情况
            finalNavOptions = navAction.navOptions
        }
        destId = navAction.destinationId // 3: destId
        val navActionArgs = navAction.defaultArguments
        if (navActionArgs != null) {
            combinedArgs = Bundle()
            combinedArgs.putAll(navActionArgs)
        }
    }
    if (args != null) {
        if (combinedArgs == null) {
            combinedArgs = Bundle()
        }
        combinedArgs.putAll(args) // 2: 合并args
    }
    if (destId == 0 && finalNavOptions != null && (finalNavOptions.popUpToId != -1 ||
            finalNavOptions.popUpToRoute != null)
    ) {
        when { // 5: popUpTo
            finalNavOptions.popUpToRoute != null ->
                NavController(
                    finalNavOptions.popUpToRoute!!, finalNavOptions.isPopUpToInclusive()
                )
            finalNavOptions.popUpToId != -1 ->
                NavController(
                    finalNavOptions.popUpToId, finalNavOptions.isPopUpToInclusive()
                )
        }
        return
    }
    require(destId != 0) {
        "Destination id == 0 can only be used in conjunction with a valid navOptions.popUpTo"
    }
    val node = findDestination(destId) // 4: 找到destination的node
    if (node == null) {
        val dest = NavDestination.getDisplayName(context, destId)
        require(navAction == null) {
            "Navigation destination $dest referenced from action " +
                "${NavDestination.getDisplayName(context, resId)} cannot be found from " +
                "the current destination $currentNode"
        }
        throw IllegalArgumentException(
            "Navigation action/destination $dest cannot be found from the current " +
                "destination $currentNode"
        )
    }
    navigate(node, combinedArgs, finalNavOptions, navigatorExtras) // 6:
}
```
> 大概做了下面几件事
> - 1: 如果调用`navigate`时
>   - 1.1: `NavOptions`参数不空，则忽略当前`node`的`action`中存储的`NavOptions`
>   - 1.2: 如果空，则使用当前`node`的`action`中存储的`NavOptions`
> - 2: 将action的`defaultArguments`和参数中的`args`合并，并传递给核心的`navigate`
> - 3: 从action中获取`destinationId`
> - 4: 从当前图中找到`destinationId`对应的node
> - 5: 弹出导航栈，直到遇到对应的route或id
> - 6: 将`node`和合并的`args`, `NavOptions`, 还有`navigatorExtras`传递给核心的`navigate`方法

#### 通过NavDirections跳转的
```kotlin
// NavDirections1:
@MainThread
public open fun navigate(directions: NavDirections) {
    navigate(directions.actionId, directions.arguments, null)
}
// NavDirections2:
@MainThread
public open fun navigate(directions: NavDirections, navOptions: NavOptions?) {
    navigate(directions.actionId, directions.arguments, navOptions)
}
// NavDirections3:
@MainThread
public open fun navigate(directions: NavDirections, navigatorExtras: Navigator.Extras) {
    navigate(directions.actionId, directions.arguments, null, navigatorExtras)
}
```

先看一下NavDirections是啥

```kotlin
public interface NavDirections {
    @get:IdRes
    public val actionId: Int
    public val arguments: Bundle
}
```
其实就是把action-id和arguments包装了一下，最终也会调用`id4`

#### 通过Uri类型的DeepLink跳转的
```kotlin
// uri1:
@MainThread
public open fun navigate(deepLink: Uri) {
    navigate(NavDeepLinkRequest(deepLink, null, null))
}
// uri2:
@MainThread
public open fun navigate(deepLink: Uri, navOptions: NavOptions?) {
    navigate(NavDeepLinkRequest(deepLink, null, null), navOptions, null)
}
// uri3:
@MainThread
public open fun navigate(
    deepLink: Uri,
    navOptions: NavOptions?,
    navigatorExtras: Navigator.Extras?
) {
    navigate(NavDeepLinkRequest(deepLink, null, null), navOptions, navigatorExtras)
}
```
他们都会构造NavDeepLinkRequest对象然后调用`NavDeepLinkRequest3`

#### 通过route跳转的
```kotlin
// route1:
public fun navigate(route: String, builder: NavOptionsBuilder.() -> Unit) {
    navigate(route, navOptions(builder))
}
public fun navigate(
    route: String,
    navOptions: NavOptions? = null,
    navigatorExtras: Navigator.Extras? = null
) {
    navigate(
        NavDeepLinkRequest.Builder.fromUri(createRoute(route).toUri()).build(), navOptions,
        navigatorExtras
    )
}
```
- 通过route跳转的，最后也会变成deeplink

#### 通过NavDeepLinkRequest跳转的
```kotlin
// NavDeepLinkRequest1:
@MainThread
public open fun navigate(request: NavDeepLinkRequest) {
    navigate(request, null)
}
// NavDeepLinkRequest2:
@MainThread
public open fun navigate(request: NavDeepLinkRequest, navOptions: NavOptions?) {
    navigate(request, navOptions, null)
}
// NavDeepLinkRequest3:
@MainThread
public open fun navigate(
    request: NavDeepLinkRequest,
    navOptions: NavOptions?,
    navigatorExtras: Navigator.Extras?
) {
    // ...
}
```

```kotlin
public open fun navigate(
    request: NavDeepLinkRequest,
    navOptions: NavOptions?,
    navigatorExtras: Navigator.Extras?
) {
    requireNotNull(_graph) {
        "Cannot navigate to $request. Navigation graph has not been set for " +
            "NavController $this."
    }
    val deepLinkMatch = _graph!!.matchDeepLink(request)
    if (deepLinkMatch != null) {
        val destination = deepLinkMatch.destination
        val args = destination.addInDefaultArgs(deepLinkMatch.matchingArgs) ?: Bundle()
        val node = deepLinkMatch.destination
        val intent = Intent().apply {
            setDataAndType(request.uri, request.mimeType)
            action = request.action
        }
        args.putParcelable(KEY_DEEP_LINK_INTENT, intent)
        navigate(node, args, navOptions, navigatorExtras)
    } else {
        throw IllegalArgumentException(
            "Navigation destination that matches request $request cannot be found in the " +
                "navigation graph $_graph"
        )
    }
}
```
- 通过matchDeepLink方法找到match对象
  - 如果没有match，抛出异常
  - 如果有match，从match对象中取出`destination`，和`id4`方法一样，最终都会调用核心的`navigate`方法，同样需要找到核心`navigate`方法所需的几个参数
    - node: 从destination对象中获得
    - args: 从destination对象中获得
    - navOptions: 函数参数
    - navigatorExtras: 函数参数
  - 调用核心的`navigate`方法

#### 核心的navigate方法

```kotlin
private fun navigate(
    node: NavDestination,
    args: Bundle?,
    navOptions: NavOptions?,
    navigatorExtras: Navigator.Extras?
) {
    navigatorState.values.forEach { state ->
        state.isNavigating = true
    }
    var popped = false
    var launchSingleTop = false
    var navigated = false
    if (navOptions != null) {
        when { // 1: 根据navOptions的不同情况，pop栈
            navOptions.popUpToRoute != null ->
                popped = NavControllerInternal(
                    navOptions.popUpToRoute!!,
                    navOptions.isPopUpToInclusive(),
                    navOptions.shouldPopUpToSaveState()
                )
            navOptions.popUpToId != -1 ->
                popped = NavControllerInternal(
                    navOptions.popUpToId,
                    navOptions.isPopUpToInclusive(),
                    navOptions.shouldPopUpToSaveState()
                )
        }
    }
    val finalArgs = node.addInDefaultArgs(args)
    // Now determine what new destinations we need to add to the back stack
    if (navOptions?.shouldRestoreState() == true && backStackMap.containsKey(node.id)) {
        navigated = restoreStateInternal(node.id, finalArgs, navOptions, navigatorExtras) // 2: 需要恢复状态，且backStackMap中存在对应的node的情况
    } else {
        launchSingleTop = navOptions?.shouldLaunchSingleTop() == true &&
            launchSingleTopInternal(node, args) //3: singleTop的情况

        if (!launchSingleTop) { // 不需要singleTop的情况
            // Not a single top operation, so we're looking to add the node to the back stack
            val backStackEntry = NavBackStackEntry.create(
                context, node, finalArgs, hostLifecycleState, viewModel
            )
            val navigator = _navigatorProvider.getNavigator<Navigator<NavDestination>>(
                node.navigatorName
            )
            navigator.navigateInternal(listOf(backStackEntry), navOptions, navigatorExtras) {
                navigated = true
                addEntryToBackStack(node, finalArgs, it)
            }
        }
    }
    updateOnBackPressedCallbackEnabled() // 4: 看起来是设置一个flag
    navigatorState.values.forEach { state ->
        state.isNavigating = false // 5: 又设置一个flag
    }
    if (popped || navigated || launchSingleTop) {
        dispatchOnDestinationChanged() // 6: 调用回调
    } else {
        updateBackStackLifecycle() // 7: 更新导航栈的生命周期
    }
}
```

- 根据上面的注释，一共做了7件事

##### 2: 需要恢复状态，且backStackMap中存在对应的node的情况
```kotlin
public class NavOptions internal constructor(
    private val singleTop: Boolean,
    private val restoreState: Boolean,
    // ...
) {
    public fun shouldRestoreState(): Boolean {
        return restoreState
    }
    // ...
    public class Builder {
        private var singleTop = false
        private var restoreState = false
        // ...
        public fun setRestoreState(restoreState: Boolean): Builder {
            this.restoreState = restoreState
            return this
        }
    }
}
```
- `shouldRestoreState`返回的是`restoreState`，是在构造时确定的

```kotlin
private fun restoreStateInternal(
    id: Int,
    args: Bundle?,
    navOptions: NavOptions?,
    navigatorExtras: Navigator.Extras?
): Boolean {
    if (!backStackMap.containsKey(id)) {
        return false // 1: 首先是防止backStackMap中没有对应的node
    }
    val backStackId = backStackMap[id]
    // Clear out the state we're going to restore so that it isn't restored a second time
    backStackMap.values.removeAll { it == backStackId } // 2: 删除map中所有和backStackId相等的entry
    val backStackState = backStackStates.remove(backStackId) // 3: 删除backStackStates中对应的entry
    // Now restore the back stack from its saved state
    val entries = instantiateBackStack(backStackState) // 4: 更新backStackState中的NavBackStackEntryState
    return executeRestoreState(entries, args, navOptions, navigatorExtras) // 5: 找到Navigator，导航到对应位置
}
```
###### 3: 删除backStackStates中对应的entry
看一下backStackStates的数据结构
```kotlin
private val backStackStates = mutableMapOf<String, ArrayDeque<NavBackStackEntryState>>()
```
###### 4: 更新backStackState中的
```kotlin
private fun instantiateBackStack(
    backStackState: ArrayDeque<NavBackStackEntryState>?
): List<NavBackStackEntry> {
    val backStack = mutableListOf<NavBackStackEntry>()
    var currentDestination = backQueue.lastOrNull()?.destination ?: graph
    backStackState?.forEach { state ->
        val node = currentDestination.findDestination(state.destinationId)
        checkNotNull(node) {
            val dest = NavDestination.getDisplayName(
                context, state.destinationId
            )
            "Restore State failed: destination $dest cannot be found from the current " +
                "destination $currentDestination"
        }
        backStack += state.instantiate(context, node, hostLifecycleState, viewModel)
        currentDestination = node
    }
    return backStack
}
```
- 创建一个空的backStack，然后遍历backStackState
- 找到当前栈最后一个entry的destination
- 从currentDestination中找到`state.destinationId`对应的node
- 根据node重新创建state对象，添加到backStack中，返回该backStack
###### 5: 找到Navigator，导航到对应位置
```kotlin
private fun executeRestoreState(
    entries: List<NavBackStackEntry>,
    args: Bundle?,
    navOptions: NavOptions?,
    navigatorExtras: Navigator.Extras?
): Boolean {
    // Split up the entries by Navigator so we can restore them as an atomic operation
    val entriesGroupedByNavigator = mutableListOf<MutableList<NavBackStackEntry>>()
    entries.filterNot { entry ->
        // Skip navigation graphs - they'll be added by addEntryToBackStack()
        entry.destination is NavGraph
    }.forEach { entry ->
        val previousEntryList = entriesGroupedByNavigator.lastOrNull()
        val previousNavigatorName = previousEntryList?.last()?.destination?.navigatorName
        if (previousNavigatorName == entry.destination.navigatorName) {
            // Group back to back entries associated with the same Navigator together
            previousEntryList += entry
        } else {
            // Create a new group for the new Navigator
            entriesGroupedByNavigator += mutableListOf(entry)
        } // 1: 如果 navigatorName和前一个的相等，则添加到前一个的list中，否则添加到新建一个list中，最后会得到一个二维数组，每个数组中的元素都是具有相同NavigatorName的
    }
    var navigated = false
    // Now actually navigate to each set of entries
    for (entryList in entriesGroupedByNavigator) {
        val navigator = _navigatorProvider.getNavigator<Navigator<NavDestination>>(
            entryList.first().destination.navigatorName
        ) // 2: 每个entryList都具有相同的navigatorName，找到对应的Navigator
        var lastNavigatedIndex = 0
        navigator.navigateInternal(entryList, navOptions, navigatorExtras) { entry ->
            navigated = true
            // If this destination is part of the restored back stack,
            // pass all destinations between the last navigated entry and this one
            // to ensure that any navigation graphs are properly restored as well
            val entryIndex = entries.indexOf(entry)
            val restoredEntries = if (entryIndex != -1) {
                entries.subList(lastNavigatedIndex, entryIndex + 1).also {
                    lastNavigatedIndex = entryIndex + 1
                }
            } else {
                emptyList()
            }
            addEntryToBackStack(entry.destination, args, entry, restoredEntries)
        } // 执行导航操作
    }
    return navigated
}
```

```kotlin
 private fun Navigator<out NavDestination>.navigateInternal(
    entries: List<NavBackStackEntry>,
    navOptions: NavOptions?,
    navigatorExtras: Navigator.Extras?,
    handler: (backStackEntry: NavBackStackEntry) -> Unit = {}
) {
    addToBackStackHandler = handler // 先把回调放到一边，稍后由NavControllerNavigatorState的push方法调用
    navigate(entries, navOptions, navigatorExtras) // 执行导航操作
    addToBackStackHandler = null
}
```

```kotlin
public open fun navigate(
    entries: List<NavBackStackEntry>,
    navOptions: NavOptions?,
    navigatorExtras: Extras?
) {
    entries.asSequence().map { backStackEntry -> // 遍历entries，把他进行变换
        val destination = backStackEntry.destination as? D ?: return@map null
        val navigatedToDestination = navigate(
            destination, backStackEntry.arguments, navOptions, navigatorExtras
        ) // 由子类实现，执行真正的导航操作
        when (navigatedToDestination) {
            null -> null // 返回null，当前backStackEntry变成null
            destination -> backStackEntry // 返回导航结果与destination相同，backStackEntry也不变
            else -> {
                state.createBackStackEntry(
                    navigatedToDestination,
                    navigatedToDestination.addInDefaultArgs(backStackEntry.arguments)
                ) // 否则创建新的backStackEntry
            }
        }
    }.filterNotNull().forEach { backStackEntry ->
        state.push(backStackEntry)
    } // 1: 对于不为null的，重新放入state中,注意这里调用的push方法
}
```
这里面的state定义如下
```kotlin
protected val state: NavigatorState
    get() = checkNotNull(_state) {
        "You cannot access the Navigator's state until the Navigator is attached"
    }
private var _state: NavigatorState? = null
@CallSuper
public open fun onAttach(state: NavigatorState) { // 在onAttach时会初始化
    _state = state
    isAttached = true
}
```

在NavController的onGraphCreated方法中有
```kotlin
val navigatorBackStack = navigatorState.getOrPut(navigator) {
    NavControllerNavigatorState(navigator)
}
navigator.onAttach(navigatorBackStack)

// 其中navigatorState是从navigator到NavControllerNavigatorState的map
private val navigatorState =
        mutableMapOf<Navigator<out NavDestination>, NavControllerNavigatorState>()
// getOrPut方法就是当没有key时，调用后面的函数插入到map中并返回，有key时则返回查询到的value
public inline fun <K, V> MutableMap<K, V>.getOrPut(key: K, defaultValue: () -> V): V {
    val value = get(key)
    return if (value == null) {
        val answer = defaultValue()
        put(key, answer)
        answer
    } else {
        value
    }
}
```

所以上面`1:`出调用的push方法，就是NavControllerNavigatorState的push方法
```kotlin
override fun push(backStackEntry: NavBackStackEntry) {
    val destinationNavigator: Navigator<out NavDestination> =
        _navigatorProvider[backStackEntry.destination.navigatorName]
    if (destinationNavigator == navigator) {
        val handler = addToBackStackHandler // 还记得前面存起来的回调吗，就会在这里调用
        if (handler != null) {
            handler(backStackEntry)
            addInternal(backStackEntry)
        } else {
            // TODO handle the Navigator calling add() outside of a call to navigate()
            Log.i(
                TAG,
                "Ignoring add of destination ${backStackEntry.destination} " +
                    "outside of the call to navigate(). "
            )
        }
    } else {
        val navigatorBackStack = checkNotNull(navigatorState[destinationNavigator]) {
            "NavigatorBackStack for ${backStackEntry.destination.navigatorName} should " +
                "already be created"
        }
        navigatorBackStack.push(backStackEntry)
    }
}
```

> 疑问，他跳转那么多干什么？

#### 3: singleTop的情况

```kotlin
public class NavOptions internal constructor(
    private val singleTop: Boolean,
    // ...
) {
    public fun shouldLaunchSingleTop(): Boolean {
        return singleTop
    }
    // ...
}
```
shouldLaunchSingleTop返回的值是其构造时的一个标志位

在分析`launchSingleTopInternal`方法前，先看一下NavController中维护的一个父子关系

```kotlin
private val childToParentEntries = mutableMapOf<NavBackStackEntry, NavBackStackEntry>()
private val parentToChildCount = mutableMapOf<NavBackStackEntry, AtomicInteger>()
```
看起来NavBackStackEntry之间存在一个父子关系，可能是一张图的形式，一个map存储这种父子关系，一个map存储子节点的个数
> 后面看了`NavDestination`和`NavBackStackEntry`后就知道，这里维护的就是`NavDestination`之间的父子关系。

```kotlin
private fun linkChildToParent(child: NavBackStackEntry, parent: NavBackStackEntry) {
    childToParentEntries[child] = parent
    if (parentToChildCount[parent] == null) {
        parentToChildCount[parent] = AtomicInteger(0)
    }
    parentToChildCount[parent]!!.incrementAndGet()
}

internal fun unlinkChildFromParent(child: NavBackStackEntry): NavBackStackEntry? {
    val parent = childToParentEntries.remove(child) ?: return null
    val count = parentToChildCount[parent]?.decrementAndGet()
    if (count == 0) {
        val navGraphNavigator: Navigator<out NavGraph> =
            _navigatorProvider[parent.destination.navigatorName]
        navigatorState[navGraphNavigator]?.markTransitionComplete(parent)
        parentToChildCount.remove(parent)
    }
    return parent
}
```
> 这两个函数用于维护NavBackStackEntry之间的父子关系
当一个NavBackStackEntry的child个数为0时，会调用markTransitionComplete，具体干啥的继续挖坑吧！
> // todo : markTransitionComplete

```kotlin
private fun launchSingleTopInternal(
    node: NavDestination,
    args: Bundle?
): Boolean {
    val currentBackStackEntry = currentBackStackEntry
    val nodeId = if (node is NavGraph) node.findStartDestination().id else node.id
    if (nodeId != currentBackStackEntry?.destination?.id) return false

    val tempBackQueue: ArrayDeque<NavBackStackEntry> = ArrayDeque()
    // pop from startDestination back to original node and create a new entry for each
    backQueue.indexOfLast { it.destination === node }.let { nodeIndex -> // 找到queue中最后一个destination和node相等的index
        while (backQueue.lastIndex >= nodeIndex) { // 如果queue中最后一个index大于nodeIndex，就删掉他，并创建一个新的entry，放到tempBackQueue中，直到lastIndex小于nodeIndex为止
            val oldEntry = backQueue.removeLast() 
            unlinkChildFromParent(oldEntry) // 删除父子关系
            val newEntry = NavBackStackEntry(
                oldEntry,
                oldEntry.destination.addInDefaultArgs(args)
            ) // 创建新的entry
            tempBackQueue.addFirst(newEntry) // 添加到tempBackQueue中
        }
    }

    // add each new entry to backQueue starting from original node to startDestination
    tempBackQueue.forEach { newEntry ->
        val parent = newEntry.destination.parent
        if (parent != null) {
            val newParent = getBackStackEntry(parent.id)
            linkChildToParent(newEntry, newParent) // 更新entry之间的父子关系
        }
        backQueue.add(newEntry)
    }

    // we replace NavState entries here only after backQueue has been finalized
    tempBackQueue.forEach { newEntry ->
        val navigator = _navigatorProvider.getNavigator<Navigator<*>>(
            newEntry.destination.navigatorName
        )
        navigator.onLaunchSingleTop(newEntry) // 拿到对应的Navigator，执行onLaunchSingleTop
    }

    return true
}
```

```kotlin
@Suppress("UNCHECKED_CAST")
public open fun onLaunchSingleTop(backStackEntry: NavBackStackEntry) {
    val destination = backStackEntry.destination as? D ?: return
    navigate(destination, null, navOptions { launchSingleTop = true }, null) // 这个navigate执行真正的导航操作，老演员了，上面见过就不说了
    state.onLaunchSingleTop(backStackEntry) // 这个state在前面也介绍过，下面看看他的onLaunchSingleTop方法干了什么
}
```

```kotlin
public open fun onLaunchSingleTop(backStackEntry: NavBackStackEntry) {
    // We update the back stack here because we don't want to leave it to the navigator since
    // it might be using transitions.
    backStackLock.withLock {
        val tempStack = backStack.value.toMutableList()
        tempStack.indexOfLast { it.id == backStackEntry.id }.let { idx ->
            tempStack[idx] = backStackEntry
        }
        _backStack.value = tempStack
    }
}
```
> 其实就是更新当前的返回栈
> 找到最后一个id与backStackEntry的id相等的index，将这个位置的entry替换为backStackEntry

#### 其他情况
在没有开启LaunchSingleTop的情况，或launchSingleTopInternal没有成功的情况那，就会走到这个代码分支

```kotlin
if (!launchSingleTop) {
    // Not a single top operation, so we're looking to add the node to the back stack
    val backStackEntry = NavBackStackEntry.create(
        context, node, finalArgs, hostLifecycleState, viewModel
    )
    val navigator = _navigatorProvider.getNavigator<Navigator<NavDestination>>(
        node.navigatorName
    )
    navigator.navigateInternal(listOf(backStackEntry), navOptions, navigatorExtras) {
        navigated = true
        addEntryToBackStack(node, finalArgs, it)
    }
}
```

创建新的backStackEntry条目，找到对应的Navigator，执行导航操作，如果成功了，就将其加入到返回栈中


## NavigatorProvider

### 数据结构

```kotlin
private val _navigators: MutableMap<String, Navigator<out NavDestination>> = mutableMapOf()
@get:RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public val navigators: Map<String, Navigator<out NavDestination>>
    get() = _navigators.toMap()
```
- 以上就是`NavigatorProvider`的全部数据结构了，就是一个`String to Navigator`的`Map`
- 回想[核心的navigate方法](#核心的navigate方法)中多次使用`NavDestination#navigatorName`从`NavigatorProvider`中获取`Navigator`，所以`NavigatorProvider`的就是一个用来保存`navigatorName`到`Navigator`实例的`Map`

### 获取Navigator
```kotlin
public fun <T : Navigator<*>> getNavigator(navigatorClass: Class<T>): T {
    val name = getNameForNavigator(navigatorClass)
    return getNavigator(name)
}

/**
* Retrieves a registered [Navigator] by name.
*
* @param name name of the navigator to return
* @return the registered navigator with the given name
*
* @throws IllegalStateException if the Navigator has not been added
*
* @see NavigatorProvider.addNavigator
*/
@Suppress("UNCHECKED_CAST")
@CallSuper
public open fun <T : Navigator<*>> getNavigator(name: String): T {
    require(validateName(name)) { "navigator name cannot be an empty string" }
    val navigator = _navigators[name]
        ?: throw IllegalStateException(
            "Could not find Navigator with name \"$name\". You must call " +
                "NavController.addNavigator() for each navigation type."
        )
    return navigator as T
}
```

#### getNameForNavigator
```kotlin
internal companion object {
    private val annotationNames = mutableMapOf<Class<*>, String?>()
    internal fun validateName(name: String?): Boolean {
        return name != null && name.isNotEmpty()
    }

    @JvmStatic
    internal fun getNameForNavigator(navigatorClass: Class<out Navigator<*>>): String {
        var name = annotationNames[navigatorClass]
        if (name == null) {
            val annotation = navigatorClass.getAnnotation(
                Navigator.Name::class.java
            )
            name = annotation?.value
            require(validateName(name)) {
                "No @Navigator.Name annotation found for ${navigatorClass.simpleName}"
            }
            annotationNames[navigatorClass] = name
        }
        return name!!
    }
}
```
- 发现获取的name是一个运行时注解，所以需要先看看`Navigator.Name`这个注解
- `Navigator.Name`是`Navigator`中的一个运行时注解
```kotlin
@kotlin.annotation.Retention(AnnotationRetention.RUNTIME)
@Target(AnnotationTarget.ANNOTATION_CLASS, AnnotationTarget.CLASS)
public annotation class Name(val value: String)
```
- 我们观察几个`Navigator`，发现他们都有`@Navigator.Name`注解，并传入了对应的参数
```kotlin
// 1. FragmentNavigator
@Navigator.Name("fragment")
public open class FragmentNavigator(
    private val context: Context,
    private val fragmentManager: FragmentManager,
    private val containerId: Int
) : Navigator<Destination>() {
    // ...
}

// 2. ActivityNavigator
@Navigator.Name("activity")
public open class ActivityNavigator(
    /** @suppress */
    @get:RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    public val context: Context
) : Navigator<ActivityNavigator.Destination>() {
    // ...
}

// 3. NavGraphNavigator
@Navigator.Name("navigation")
public open class NavGraphNavigator(
    private val navigatorProvider: NavigatorProvider
) : Navigator<NavGraph>() {
    // ...
}
```
- 这样就可以明确了，`Navigator`的`name`就是注解时的`value`
- `FragmentNavigator`的`name`是`"fragment"`
- `ActivityNavigator`的`name`是`"activity"`
- ...

### addNavigator

```kotlin
public fun addNavigator(
    navigator: Navigator<out NavDestination>
): Navigator<out NavDestination>? {
    return addNavigator(getNameForNavigator(navigator.javaClass), navigator)
}

/**
* Register a navigator by name. [destinations][NavDestination] may refer to any
* registered navigator by name for inflation. If a navigator by this name is already
* registered, this new navigator will replace it.
*
* @param name name for this navigator
* @param navigator navigator to add
* @return the previously added Navigator for the given name, if any
*/
@CallSuper
public open fun addNavigator(
    name: String,
    navigator: Navigator<out NavDestination>
): Navigator<out NavDestination>? {
    require(validateName(name)) { "navigator name cannot be an empty string" }
    val previousNavigator = _navigators[name]
    if (previousNavigator == navigator) {
        return navigator
    }
    check(previousNavigator?.isAttached != true) {
        "Navigator $navigator is replacing an already attached $previousNavigator"
    }
    check(!navigator.isAttached) {
        "Navigator $navigator is already attached to another NavController"
    }
    return _navigators.put(name, navigator)
}
```

- `addNavigator`时，首先取出对应`name`的`Navigator`
  - 如果`Navigator`和要放入的`Navigator`相同，则直接返回
  - 如果前一个`Navigator`不空且没有被`attach`，则抛出异常
    - 这里判断方法为`previousNavigator?.isAttached != true`, `null`或者`bool`和`true`比较，十分简洁，值得学习！
  - 检查确认要放入的`Navigator`没有被`attach`，否则抛出异常
  - 最后将`Navigator`放入`_navigators`中，并返回前一个`Navigator`
- 被替换的`Navigator`如果不空的话，不能是已经Attach的
- 想要放入的`Navigator`也不能被`attach`

### 扩展get和set方法
```kotlin
@Suppress("NOTHING_TO_INLINE")
public inline operator fun <T : Navigator<out NavDestination>> NavigatorProvider.get(
    name: String
): T = getNavigator(name)

@Suppress("NOTHING_TO_INLINE")
public inline operator fun <T : Navigator<out NavDestination>> NavigatorProvider.get(
    clazz: KClass<T>
): T = getNavigator(clazz.java)

@Suppress("NOTHING_TO_INLINE")
public inline operator fun NavigatorProvider.set(
    name: String,
    navigator: Navigator<out NavDestination>
): Navigator<out NavDestination>? = addNavigator(name, navigator)
```

很简单

### 扩展的`+=`运算符

```kotlin
@Suppress("NOTHING_TO_INLINE")
public inline operator fun NavigatorProvider.plusAssign(navigator: Navigator<out NavDestination>) {
    addNavigator(navigator)
}
```
也很简单
## NavBackStackEntry

### 先看注释
```kotlin
Representation of an entry in the back stack of a androidx.navigation.NavController.
The Lifecycle, ViewModelStore, and SavedStateRegistry provided via this object are valid for the lifetime of this destination on the back stack: when this destination is popped off the back stack, the lifecycle will be destroyed, state will no longer be saved, and ViewModels will be cleared.
```

- 介绍了两件事情
  - 这个类代表的是`NavController`中返回栈的一个`entry`
  - 他能提供`Lifecycle, ViewModelStore, and SavedStateRegistry`
    - 当这个`NavBackStackEntry`存在于返回栈时，他们的生命周期时有效的，当这个`NavBackStackEntry`被pop掉时，他们的生命周期会被销毁，状态会被清除，ViewModel会被清除

### 类定义和数据结构
#### lifeCycle部分
```kotlin
public class NavBackStackEntry private constructor(
    private val context: Context?,
    /**
     * The destination associated with this entry
     * @return The destination that is currently visible to users
     */
    @set:RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    public var destination: NavDestination,
    private val immutableArgs: Bundle? = null,
    private var hostLifecycleState: Lifecycle.State = Lifecycle.State.CREATED,
    private val viewModelStoreProvider: NavViewModelStoreProvider? = null,
    /**
     * The unique ID that serves as the identity of this entry
     * @return the unique ID of this entry
     */
    public val id: String = UUID.randomUUID().toString(),
    private val savedState: Bundle? = null
) : LifecycleOwner,
    ViewModelStoreOwner,
    HasDefaultViewModelProviderFactory,
    SavedStateRegistryOwner {
    
    private var _lifecycle = LifecycleRegistry(this)

    override val lifecycle: Lifecycle
        get() = _lifecycle

    @get:RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    @set:RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    public var maxLifecycle: Lifecycle.State = Lifecycle.State.INITIALIZED
        set(maxState) {
            field = maxState
            updateState()
        }
    // ...
}
```

- 很简单实现了`lifeCycle`
- `maxLifecycle`是`Lifecycle.State`，保存当前的状态，默认是`Lifecycle.State.INITIALIZED`
- 调用`maxLifecycle`的`set`属性时，会调用`updateState`方法
```kotlin
@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public fun updateState() {
    if (!savedStateRegistryAttached) {
        savedStateRegistryController.performAttach()
        savedStateRegistryAttached = true
        if (viewModelStoreProvider != null) {
            enableSavedStateHandles()
        }
        // Perform the restore just once, the first time updateState() is called
        // and specifically *before* we move up the Lifecycle
        savedStateRegistryController.performRestore(savedState)
    }
    if (hostLifecycleState.ordinal < maxLifecycle.ordinal) {
        _lifecycle.currentState = hostLifecycleState
    } else {
        _lifecycle.currentState = maxLifecycle
    }
}
```
- 首先判断`savedStateRegistry`是否被`attach`, 如果没有，就执行`attach`,并回复状态
- 然后就是更新`lifeCycle`的状态，取`hostLifecycleState`和`maxLifecycle`之中较小的那一个

这里看到一个`ordinal`不太熟悉，这个属于`java`基础
> 继续挖坑
> // todo: enum, ordinal

#### ViewModel部分
```kotlin
public class NavBackStackEntry private constructor(
    private val context: Context?,
    /**
     * The destination associated with this entry
     * @return The destination that is currently visible to users
     */
    @set:RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    public var destination: NavDestination,
    private val immutableArgs: Bundle? = null,
    private var hostLifecycleState: Lifecycle.State = Lifecycle.State.CREATED,
    private val viewModelStoreProvider: NavViewModelStoreProvider? = null,
    /**
     * The unique ID that serves as the identity of this entry
     * @return the unique ID of this entry
     */
    public val id: String = UUID.randomUUID().toString(),
    private val savedState: Bundle? = null
) : LifecycleOwner,
    ViewModelStoreOwner,
    HasDefaultViewModelProviderFactory,
    SavedStateRegistryOwner {
    
    private val defaultFactory by lazy {
        SavedStateViewModelFactory((context?.applicationContext as? Application), this, arguments)
    }

    /**
     * The [SavedStateHandle] for this entry.
     */
    public val savedStateHandle: SavedStateHandle by lazy {
        check(savedStateRegistryAttached) {
            "You cannot access the NavBackStackEntry's SavedStateHandle until it is added to " +
                "the NavController's back stack (i.e., the Lifecycle of the NavBackStackEntry " +
                "reaches the CREATED state)."
        }
        check(lifecycle.currentState != Lifecycle.State.DESTROYED) {
            "You cannot access the NavBackStackEntry's SavedStateHandle after the " +
                "NavBackStackEntry is destroyed."
        }
        ViewModelProvider(
            this, NavResultSavedStateFactory(this)
        ).get(SavedStateViewModel::class.java).handle
    }
    
    override val defaultViewModelProviderFactory: ViewModelProvider.Factory = defaultFactory

    override val defaultViewModelCreationExtras: CreationExtras
        get() {
            val extras = MutableCreationExtras()
            (context?.applicationContext as? Application)?.let { application ->
                extras[ViewModelProvider.AndroidViewModelFactory.APPLICATION_KEY] = application
            }
            extras[SAVED_STATE_REGISTRY_OWNER_KEY] = this
            extras[VIEW_MODEL_STORE_OWNER_KEY] = this
            arguments?.let { args ->
                extras[DEFAULT_ARGS_KEY] = args
            }
            return extras
        }

    override val savedStateRegistry: SavedStateRegistry
        get() = savedStateRegistryController.savedStateRegistry

    private class NavResultSavedStateFactory(
        owner: SavedStateRegistryOwner
    ) : AbstractSavedStateViewModelFactory(owner, null) {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(
            key: String,
            modelClass: Class<T>,
            handle: SavedStateHandle
        ): T {
            return SavedStateViewModel(handle) as T
        }
    }

    private class SavedStateViewModel(val handle: SavedStateHandle) : ViewModel()
    // ...
}
```

- 这里保留了`savedStateHandle`，和`viewModel`有一定的耦合
- 我们使用的`viewModel`就存了一个`SavedStateHandle`
- 提供了默认的`ViewModelProvider.Factory`和`Extras`
- 基本都是和`savedState`相关的，所以先不看了
- `viewModel`的作用
  - 提供`handle`
  - 提供`viewModelStore`(就是`viewModelName`到`viewModel`的`map`)
- // todo: 学习saveState后再看
- // 疑问，为啥非要通过`viewModel`来获取`handle`呢？
#### savedState部分

```kotlin
public class NavBackStackEntry private constructor(
    private val context: Context?,
    /**
     * The destination associated with this entry
     * @return The destination that is currently visible to users
     */
    @set:RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    public var destination: NavDestination,
    private val immutableArgs: Bundle? = null,
    private var hostLifecycleState: Lifecycle.State = Lifecycle.State.CREATED,
    private val viewModelStoreProvider: NavViewModelStoreProvider? = null,
    /**
     * The unique ID that serves as the identity of this entry
     * @return the unique ID of this entry
     */
    public val id: String = UUID.randomUUID().toString(),
    private val savedState: Bundle? = null
) : LifecycleOwner,
    ViewModelStoreOwner,
    HasDefaultViewModelProviderFactory,
    SavedStateRegistryOwner {
    private val savedStateRegistryController = SavedStateRegistryController.create(this)
    private var savedStateRegistryAttached = false

    /**
     * The [SavedStateHandle] for this entry.
     */
    public val savedStateHandle: SavedStateHandle by lazy {
        check(savedStateRegistryAttached) {
            "You cannot access the NavBackStackEntry's SavedStateHandle until it is added to " +
                "the NavController's back stack (i.e., the Lifecycle of the NavBackStackEntry " +
                "reaches the CREATED state)."
        }
        check(lifecycle.currentState != Lifecycle.State.DESTROYED) {
            "You cannot access the NavBackStackEntry's SavedStateHandle after the " +
                "NavBackStackEntry is destroyed."
        }
        ViewModelProvider(
            this, NavResultSavedStateFactory(this)
        ).get(SavedStateViewModel::class.java).handle
    }

    override val savedStateRegistry: SavedStateRegistry
        get() = savedStateRegistryController.savedStateRegistry
    // ...
}
```
- // todo: 学习saveState后再看

#### 其他部分

```kotlin
public class NavBackStackEntry private constructor(
    private val context: Context?,
    /**
     * The destination associated with this entry
     * @return The destination that is currently visible to users
     */
    @set:RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    public var destination: NavDestination,
    private val immutableArgs: Bundle? = null,
    private var hostLifecycleState: Lifecycle.State = Lifecycle.State.CREATED,
    private val viewModelStoreProvider: NavViewModelStoreProvider? = null,
    /**
     * The unique ID that serves as the identity of this entry
     * @return the unique ID of this entry
     */
    public val id: String = UUID.randomUUID().toString(),
    private val savedState: Bundle? = null
) : LifecycleOwner,
    ViewModelStoreOwner,
    HasDefaultViewModelProviderFactory,
    SavedStateRegistryOwner {
    public val arguments: Bundle?
        get() = if (immutableArgs == null) {
            null
        } else {
            Bundle(immutableArgs)
        }
}
```

- id: public的一个随机unique的id，应该是用于标识一个`NavBackStackEntry`
- arguments: 在前面的`defaultViewModelCreationExtras`和`defaultFactory`中有使用，将args提供给`extras`和`factory`

#### 构造函数
```kotlin
@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
constructor(entry: NavBackStackEntry, arguments: Bundle? = entry.arguments) : this(
    entry.context,
    entry.destination,
    arguments,
    entry.hostLifecycleState,
    entry.viewModelStoreProvider,
    entry.id,
    entry.savedState
) {
    hostLifecycleState = entry.hostLifecycleState
    maxLifecycle = entry.maxLifecycle
}
```
对外暴露的构造函数仅这一个，除了`arguments`其他都是从另一个`NavBackStackEntry`中获取的

```kotlin
public companion object {
    @RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
    public fun create(
        context: Context?,
        destination: NavDestination,
        arguments: Bundle? = null,
        hostLifecycleState: Lifecycle.State = Lifecycle.State.CREATED,
        viewModelStoreProvider: NavViewModelStoreProvider? = null,
        id: String = UUID.randomUUID().toString(),
        savedState: Bundle? = null
    ): NavBackStackEntry = NavBackStackEntry(
        context, destination, arguments,
        hostLifecycleState, viewModelStoreProvider, id, savedState
    )
}
```

通过create方法暴露了另外一个私有的构造函数，猜测这么做的目的是为了限制该构造函数仅在`navigation`库的范围内使用吧？

### 总结
- 总的来说，这个类作为`NavController`返回栈的一个`entry`，同时提供了一些变量
  - destination
  - id
  - arguments
  - savedStateHandle
  - maxLifecycle
  - viewModelStore

## NavDestination

### 先看注释
```kotlin
NavDestination represents one node within an overall navigation graph.
Each destination is associated with a Navigator which knows how to navigate to this particular destination.
Destinations declare a set of actions that they support. These actions form a navigation API for the destination; the same actions declared on different destinations that fill similar roles allow application code to navigate based on semantic intent.
Each destination has a set of arguments that will be applied when navigating to that destination. Any default values for those arguments can be overridden at the time of navigation.
NavDestinations should be created via Navigator.createDestination.
```
- `NavDestination`代表一个导航图中的一个节点
- 每个`NavDestination`都关联一个`Navigator`，`Navigator`知道如何导航到这个`NavDestination`
- 保存一组`action`
  - 后半句有点难懂，不同`destinations`中相同的`action`发挥相同的作用，可以允许应用代码基于语义intent导航
- 每个destination都有一组args，在导航到这个destination时可能会被覆盖
- `NavDestinations`应该通过`Navigator.createDestination`创建

### 类定义和数据结构
```kotlin
public open class NavDestination(
    /**
     * The name associated with this destination's [Navigator].
     */
    public val navigatorName: String
) {
    @kotlin.annotation.Retention(AnnotationRetention.BINARY)
    @Target(AnnotationTarget.ANNOTATION_CLASS, AnnotationTarget.CLASS)
    public annotation class ClassType(val value: KClass<*>) // 1. 注解
    public var parent: NavGraph? = null // 2. partent
        /** @suppress */
        @RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
        public set
    private var idName: String? = null 
    public var label: CharSequence? = null
    private val deepLinks = mutableListOf<NavDeepLink>() // 3. deepLinks
    private val actions: SparseArrayCompat<NavAction> = SparseArrayCompat() // 4. actions

    private var _arguments: MutableMap<String, NavArgument> = mutableMapOf() // 5. args
    public val arguments: Map<String, NavArgument>
        get() = _arguments.toMap()
    @get:IdRes
    public var id: Int = 0 // 6. id
        set(@IdRes id) {
            field = id
            idName = null
        }
    public var route: String? = null // 7. route
        set(route) {
            if (route == null) {
                id = 0
            } else {
                require(route.isNotBlank()) { "Cannot have an empty route" }
                val internalRoute = createRoute(route)
                id = internalRoute.hashCode()
                addDeepLink(internalRoute)
            }
            deepLinks.remove(deepLinks.firstOrNull { it.uriPattern == createRoute(field) })
            field = route
        }

    public open val displayName: String
        @RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
        get() = idName ?: id.toString()

    public companion object {
        @JvmStatic
        public val NavDestination.hierarchy: Sequence<NavDestination> // 8. hierarchy
            get() = generateSequence(this) { it.parent }
        // ...
    }
    // ...
```

#### `1. 注解`
在子类中使用，在`XXXNavigator`中会有内部类`Destination`继承`NavDestination`，并使用该注解标注其导航的`class`

如，在`FragmentNavigator`中
```kotlin
@NavDestination.ClassType(Fragment::class)
public open class Destination
public constructor(fragmentNavigator: Navigator<out Destination>) :
    NavDestination(fragmentNavigator) {
    // ...
}
```
暂时没有找到获取并使用这个注解的代码
```kotlin
This optional annotation allows tooling to offer auto-complete for the android:name attribute. This should match the class type passed to parseClassFromName when parsing the android:name attribute.
```
看起来是xml自动补全的时候会用到

#### `2. parent`
parent是`NavGraph`，表示当前`NavDestination`的父节点，同时剧透一下, `NavGraph`是`NavDestination`的子类
#### `8. hierarchy`
`hierarchy`是一个扩展属性，从当前`NavDestination`开始，生成一个父节点的sequence
#### `3. deepLinks`
deepLinks是一个list, 在`matchDeepLink`时会遍历该list，寻找到最佳match的`NavDeepLink`
#### `4. actions`
action是一个SparseArrayCompat，也就是一个`Int`到`Object`的`Map`
#### `7. route`
代表当前Destination的route字符串，可以看到他也调用了`addDeepLink`

### addDeepLink

```kotlin
public fun addDeepLink(uriPattern: String) {
    addDeepLink(NavDeepLink.Builder().setUriPattern(uriPattern).build())
}

public fun addDeepLink(navDeepLink: NavDeepLink) {
    val missingRequiredArguments = _arguments.missingRequiredArguments { key ->
        key !in navDeepLink.argumentsNames
    }
    require(missingRequiredArguments.isEmpty()) {
        "Deep link ${navDeepLink.uriPattern} can't be used to open destination $this.\n" +
            "Following required arguments are missing: $missingRequiredArguments"
    }

    deepLinks.add(navDeepLink)
}
```

第一个函数是给`route`使用的，将route字符串变成一个`NavDeepLink`
第二个函数很简单，就是将`NavDeepLink`添加到`deepLinks`中，在放入之前会检查一下，保证`_arguments`中的key全部存在于`deepLink`的`argumentsNames`中

### route转换成NavDeepLinkRequest
```kotlin
@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public fun createRoute(route: String?): String =
    if (route != null) "android-app://androidx.navigation/$route" else ""

// NavDeepLinkRequest.Builder#build
public fun build(): NavDeepLinkRequest {
    return NavDeepLinkRequest(uri, action, mimeType)
}
```

就是把route根据特定格式转换成一个uri，存到`NavDeepLinkRequest`这个类中，这个类也很简单

```kotlin
public open class NavDeepLinkRequest {
    public open val uri: Uri?
    public open val action: String?
    public open val mimeType: String?
    // ...
}
```
就是用来存这三个东西的

### matchDeepLink

```kotlin
@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public fun matchDeepLink(route: String): DeepLinkMatch? {
    val request = NavDeepLinkRequest.Builder.fromUri(createRoute(route).toUri()).build()
    val matchingDeepLink = if (this is NavGraph) {
        matchDeepLinkExcludingChildren(request)
    } else {
        matchDeepLink(request)
    }
    return matchingDeepLink
}
```

这个函数是用来通过route来匹配DeepLink的，如果当前`NavDestination`是子类`NavGraph`，则会调用子类的函数`matchDeepLinkExcludingChildren`，否则调用`matchDeepLink`。`matchDeepLinkExcludingChildren`在后面介绍

```kotlin
@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public open fun matchDeepLink(navDeepLinkRequest: NavDeepLinkRequest): DeepLinkMatch? {
    if (deepLinks.isEmpty()) {
        return null
    }
    var bestMatch: DeepLinkMatch? = null
    for (deepLink in deepLinks) {
        val uri = navDeepLinkRequest.uri
        // includes matching args for path, query, and fragment
        val matchingArguments =
            if (uri != null) deepLink.getMatchingArguments(uri, _arguments) else null
        val matchingPathSegments = deepLink.calculateMatchingPathSegments(uri)
        val requestAction = navDeepLinkRequest.action
        val matchingAction = requestAction != null && requestAction ==
            deepLink.action
        val mimeType = navDeepLinkRequest.mimeType
        val mimeTypeMatchLevel =
            if (mimeType != null) deepLink.getMimeTypeMatchRating(mimeType) else -1
        if (matchingArguments != null || ((matchingAction || mimeTypeMatchLevel > -1) &&
                hasRequiredArguments(deepLink, uri, _arguments))
        ) { // 2. match的条件
            val newMatch = DeepLinkMatch(
                this, matchingArguments,
                deepLink.isExactDeepLink, matchingPathSegments, matchingAction,
                mimeTypeMatchLevel
            )
            if (bestMatch == null || newMatch > bestMatch) { // 1. 比较match, 选择最好的一个match
                bestMatch = newMatch
            }
        }
    }
    return bestMatch
}
```
- 就是遍历所有deepLinks数组，找到最match的一个
- // todo: 2. match的条件

### id
```kotlin
// 每个destination的唯一id，必须是资源id
@get:IdRes
public var id: Int = 0
    set(@IdRes id) {
        field = id
        idName = null
    }
```
这里就有疑问了，这里的id应该是导航图xml的id，如下所示，id在onInflate的时候被赋值。
```kotlin
@CallSuper
public open fun onInflate(context: Context, attrs: AttributeSet) {
    context.resources.obtainAttributes(attrs, R.styleable.Navigator).use { array ->
        route = array.getString(R.styleable.Navigator_route)

        if (array.hasValue(R.styleable.Navigator_android_id)) {
            id = array.getResourceId(R.styleable.Navigator_android_id, 0)
            idName = getDisplayName(context, id)
        }
        label = array.getText(R.styleable.Navigator_android_label)
    }
}
```
但在Compose中，并不使用xml的导航图，如何初始化这个id呢？
```kotlin
public var route: String? = null
    set(route) {
        if (route == null) {
            id = 0
        } else {
            require(route.isNotBlank()) { "Cannot have an empty route" }
            val internalRoute = createRoute(route)
            id = internalRoute.hashCode()
            addDeepLink(internalRoute)
        }
        deepLinks.remove(deepLinks.firstOrNull { it.uriPattern == createRoute(field) })
        field = route
    }
```
可以看到这里，如果是compose的route字符串，createRoute后，会使用hashCode为id赋值



### addInDefaultArgs


### 总结
大概作用就是
- 保存action对象，维护了一个map，保存action的resId到action对象
- 提供navigatorName，方便NavController根据name找到对应的Navigator
- 维护deeplink列表，提供deeplink匹配的方法
- 提供parent和hierarchy，提供嵌套图的支持
- 提供route到deeplinkRequest的转换


## NavGraph

### 先看注释
```kotlin
NavGraph is a collection of NavDestination nodes fetchable by ID.
A NavGraph serves as a 'virtual' destination: while the NavGraph itself will not appear on the back stack, navigating to the NavGraph will cause the starting destination to be added to the back stack.
Construct a new NavGraph. This NavGraph is not valid until you add a destination and set the starting destination.
Params:
navGraphNavigator - The NavGraphNavigator which this destination will be associated with. Generally retrieved via a NavController'sNavigatorProvider.getNavigator method.
```

- 存储了图中所有的节点，可以通过id获取各个节点
  - 这里的节点就是上面介绍的`NavDestination`
- 导航图本身是一个虚拟的destination，但是他不会出现在栈中，如果试图导航到NavGraph，将会导航到这个导航图的`startDest`中

### 数据结构
```kotlin
public open class NavGraph(navGraphNavigator: Navigator<out NavGraph>) :
    NavDestination(navGraphNavigator), Iterable<NavDestination> {
    public val nodes: SparseArrayCompat<NavDestination> = SparseArrayCompat<NavDestination>()
        /** @suppress */
        @RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
        get
    private var startDestId = 0
    @get:IdRes
    public var startDestinationId: Int
        get() = startDestId
        private set(startDestId) {
            require(startDestId != id) {
                "Start destination $startDestId cannot use the same id as the graph $this"
            }
            if (startDestinationRoute != null) {
                startDestinationRoute = null
            }
            this.startDestId = startDestId
            startDestIdName = null
        }
    public var startDestinationRoute: String? = null
        private set(startDestRoute) {
            startDestId = if (startDestRoute == null) {
                0
            } else {
                require(startDestRoute != route) {
                    "Start destination $startDestRoute cannot use the same route as the graph $this"
                }
                require(startDestRoute.isNotBlank()) {
                    "Cannot have an empty start destination route"
                }
                val internalRoute = createRoute(startDestRoute)
                internalRoute.hashCode()
            }
            field = startDestRoute
        }
}
```
- nodes，存储所有destination的map，key时destination的id
- startDestId，startDestinationRoute起始destination的id、route
  - 如果startDestinationRoute不空，和id的情况相同，createRoute后，使用hashCode作为startDestId

### onInflate
```kotlin
override fun onInflate(context: Context, attrs: AttributeSet) {
    super.onInflate(context, attrs)
    context.resources.obtainAttributes(
        attrs,
        R.styleable.NavGraphNavigator
    ).use {
        startDestinationId = it.getResourceId(R.styleable.NavGraphNavigator_startDestination, 0)
        startDestIdName = getDisplayName(context, startDestId)
    }
}
```

解析xml时，从xml中获取startDestination的id

### matchDeepLink

```kotlin
@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public override fun matchDeepLink(navDeepLinkRequest: NavDeepLinkRequest): DeepLinkMatch? {
    // First search through any deep links directly added to this NavGraph
    val bestMatch = super.matchDeepLink(navDeepLinkRequest)
    // Then search through all child destinations for a matching deep link
    val bestChildMatch = mapNotNull { child ->
        child.matchDeepLink(navDeepLinkRequest)
    }.maxOrNull()

    return listOfNotNull(bestMatch, bestChildMatch).maxOrNull()
}

@RestrictTo(RestrictTo.Scope.LIBRARY_GROUP)
public fun matchDeepLinkExcludingChildren(request: NavDeepLinkRequest): DeepLinkMatch? =
    super.matchDeepLink(request)

```

- navGraph本身也可以作为一个destination，拥有deeplink，所以先搜索他自身的match，然后搜索所有子节点的match，最后返回最match的一个
- 这个函数只有在使用route字符串匹配时会使用，通过route匹配时就不考虑子节点，为什么呢？

### 总结

- 其实本质上也是一个保存子节点的map
- 提供matchDeepLink方法，用于匹配子子节点和自己本身deeplink

## NavigatorState

## NavControllerNavigatorState

## NavControllerViewModel

## FragmentNavigator

## ActivityNavigator



## 总结中的总结

### 需要一个NavHostFragment
想要使用`navigation`库，需要有一个`NavHostFragment`。`navigation`库为`Fragment`, `View`, `Acivity`都添加了扩展函数`findNavController`，用来找到`navController`，查找时都需要一个`NavHostFragment`的存在。
- 对于`Fragment`来说，需要它本身，或者所有上级`Fragment`中存在一个`NavHostFragment`
- 对于View来说，需要他本身，或者所有上级view的tag中，存在`R.id.nav_controller_view_tag`,这个tag下可以获得NavController。NavHostFragment的[onViewCreated](#onviewcreated)方法中,会对`Fragment`的`rootView`设置这个`tag`
- 对于`activity`来说，需要指定一个`viewId`，通过`findView`找到这个`view`后，寻找过程和`View`相同

这个`NavHostFragment`的`graphId`不能通过用户传入，因为这个变量是`private`的。`NavHostFragment`通过`xml`获取这个导航图的`id`，或者使用`KEY_GRAPH_ID`从`savedState`或`Fragment`的`mArguments`中获取，而这个`KEY_GRAPH_ID`也是仅在`navigation`库中可用的。

`NavHostFragment`实现了`NavHost`，拥有了一个`NavController`，通过它的`navigate`方法可以进行跳转。
`NavHostFragment`实现`NavController`的实现类是`NavHostController`,这个类中没有任何函数实现，只是将父类的几个函数变成`final`的

### 导航图

- 导航图可以通过`xml`和`kotlin DSL`描述。
- 导航图可以包含多个子节点，每个子节点都是一个`destination`。
  - 每个`destination`可以是`fragment`，`activity`，`dialog`，或者一个`NavGraph`作为子图。每个`destination`可以包含多个`action`
    - 每个`action`包含它本身的`id`和导航目的地的`destinationId`，用于确定导航的目的地。
  - 每个`destination`也可以包含多个`deeplink`
    - `NavController`通过`deeplink`进行导航时，会搜索导航图，以及导航图中的`destination`的`deeplink`，找到匹配度最高的一个，进行导航。
    - 在`Compose`中使用`route`字符串进行导航时，实际上会将其包装为一个`uri`类型的`deeplink`，然后进行匹配。
    - 每个`deeplink`包含其`uri`，`action`字符串，`mimeType`字符串，用于匹配。
- 导航图本身也是一个`destination`，导航到一个`NavGraph`是，会导航到`startDestination`。
  - 在`xml`中，给根节点`<navigation>`添加`startDestination`参数，填写一个`destinationId`，作为`startDestination`。
  - 在`kotlin DSL`中，通过`startDestination`指定一个`route`字符串，作为`startDestination`

### NavController
- 这个类是整个`navigation`库的核心
  - 提供多种`navigate`方法，可以通过`destination`的`resId`，`route`字符串和`deepLink`进行导航
  - 这个类维护了导航图`NavGraph`，返回栈`_currentBackStack`等数据结构
  - 这个类并承担具体的跳转任务，具体的跳转任务由`Navigator`的各个子类完成
    - 上面说到导航目的地有很多种类，`NavController`会根据导航目的地的类型，选择不同的`Navigator`来完成跳转任务，比如`FragmentNavigator`，`ActivityNavigator`，`DialogNavigator`
    - 每个`Navigator`都有`name`，是通过一个注解`Navigator.Name`指定的。
    - `NavController`中因此也维护了`_navigatorProvider`，他的作用类似于一个`map`,存储`Navigator`的`name`和`Navigator`的映射关系。