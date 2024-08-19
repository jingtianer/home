---
title: 01-layout
date: 2024-5-20 21:15:36
tags: Android-官方文档
categories: Android
toc: true
language: zh-CN
---

## ID

创建 RelativeLayout 时，请务必为视图对象定义 ID。在相对布局中，同级视图可以定义其相对于通过唯一 ID 引用的另一个同级视图的布局。

### findViewById

ID 不必在整个树状结构中具有唯一性，但在您搜索的树状结构部分中必须是唯一的。它通常可能是整个树，因此最好尽可能使其具有唯一性。

- `findViewById`是View的方法

```java
/**
 * Finds the first descendant view with the given ID, the view itself if
 * the ID matches {@link #getId()}, or {@code null} if the ID is invalid
 * (< 0) or there is no matching view in the hierarchy.
 * <p>
 * <strong>Note:</strong> In most cases -- depending on compiler support --
 * the resulting view is automatically cast to the target class type. If
 * the target class type is unconstrained, an explicit cast may be
 * necessary.
 *
 * @param id the ID to search for
 * @return a view with given ID if found, or {@code null} otherwise
 * @see View#requireViewById(int)
 */
@Nullable
public final <T extends View> T findViewById(@IdRes int id) {
    if (id == NO_ID) {
        return null;
    }
    return findViewTraversal(id);
}
```

- 在Activity中，`findViewById`是调用window的`findViewById`

```java
/**
 * Finds a view that was identified by the {@code android:id} XML attribute
 * that was processed in {@link #onCreate}.
 * <p>
 * <strong>Note:</strong> In most cases -- depending on compiler support --
 * the resulting view is automatically cast to the target class type. If
 * the target class type is unconstrained, an explicit cast may be
 * necessary.
 *
 * @param id the ID to search for
 * @return a view with given ID if found, or {@code null} otherwise
 * @see View#findViewById(int)
 * @see Activity#requireViewById(int)
 */
@Nullable
public <T extends View> T findViewById(@IdRes int id) {
    return getWindow().findViewById(id);
}
```

Window调用DecorView

```java
/**
 * Finds a view that was identified by the {@code android:id} XML attribute
 * that was processed in {@link android.app.Activity#onCreate}.
 * <p>
 * This will implicitly call {@link #getDecorView} with all of the associated side-effects.
 * <p>
 * <strong>Note:</strong> In most cases -- depending on compiler support --
 * the resulting view is automatically cast to the target class type. If
 * the target class type is unconstrained, an explicit cast may be
 * necessary.
 *
 * @param id the ID to search for
 * @return a view with given ID if found, or {@code null} otherwise
 * @see View#findViewById(int)
 * @see Window#requireViewById(int)
 */
@Nullable
public <T extends View> T findViewById(@IdRes int id) {
    return getDecorView().findViewById(id);
}
```

## 布局参数

每个 ViewGroup 类都会实现一个扩展 ViewGroup.LayoutParams 的嵌套类。此子类包含的属性类型会根据需要为视图组定义每个子视图的尺寸和位置。如图 2 所示，父视图组会为每个子视图（包括子视图组）定义布局参数。

所有视图组都使用 layout_width 和 layout_height 包含宽度和高度，并且每个视图都必须定义它们。许多 LayoutParams 包含可选的外边距和边框。

您可以指定具有确切尺寸的宽度和高度，但您可能不希望经常这样做。更常见的情况是，您会使用以下某个常量来设置宽度或高度：
- wrap_content：告知视图将其大小调整为内容所需的尺寸。
- match_parent：告知视图尽可能采用其父视图组允许的最大尺寸。

> 最好使用dp，密度无关像素

## 布局位置

`getLeft()`, `getTop()`, `getRight()`, `getBottom()`表示获取相对于其父view的位置坐标

`getRight()` `-` `getLeft()` `==` `getWidth()`
`getBottom()` `-` `getTop()` `==` `getHeight()`

## 尺寸, 内外边距

margin(外边距)和padding(内边距)的区别
- margin指的是在view的边界之外的额外空间，用于分隔父布局，或父布局中其他相邻view
- margin的颜色不受view的影响
- padding是在view边界内部的额外空间
- padding的颜色受view的背景的影响
  
## 自适应布局

- 使用ConstraintLayout
- 对列表-详情界面使用 SlidingPaneLayout
  - 根据设备尺寸自动决定菜单和content是并排显示还是层叠显示


### 备用资源

对资源目录/布局文件的文件名后添加限定符，可规定自愿限制应用的屏幕尺寸，语言，屏幕方向，如有多种限制，需要按照[表格](https://developer.android.com/guide/topics/resources/providing-resources?hl=zh-cn#table2)中的顺序给出。

在[表格](https://developer.android.com/guide/topics/resources/providing-resources?hl=zh-cn#table2)中越靠前的优先级越高

系统选择合适的资源时，首先排除与设备配置相冲突的资源文件（如语言、像素密度），然后按照[表格](https://developer.android.com/guide/topics/resources/providing-resources?hl=zh-cn#table2)的顺序依次寻找是否有目录包含该限定符，如果有，则把不含有限定符的目录排除

### fragment

使用 fragment 将界面组件模块化

- 对于折叠屏、大尺寸设备，可以用fragment将ui模块化，避免重复的ui加载

### activity 嵌入

使用Activity嵌入，可在大尺寸设备上在屏幕上并排显示Activity，在小尺寸屏幕上层叠显示

## 线性布局

### 均等分布
若要创建线性布局，让每个子项在屏幕上占据相同大小的空间
- `android:layout_height="0dp"` or `android:layout_width="0dp"`
- `android:layout_weight="1"`

### 不等分布

- weight为0,则只占据所需的大小
- 不为0，每个占据剩余空间的 $ weight_i / \sum_{j=1}^{N}{weight_j} $

## 优化布局

- 减少布局层次
  - 合并
  - 使用ConstraintLayout
- 通过include标签重复使用布局
  - 子布局的根布局可以使用merge标签，与父布局合并
- 使用ViewStub
  - 动态将ViewStub替换为对应的view
  - 通过ViewStub.inflate替换view

## 自定义组件

### 自定义属性

- 创建`res/values/attrs.xml`
- 描述属性以及属性的取值
- 获取属性值
```kotlin
init {
    context.theme.obtainStyledAttributes(
            attrs,
            R.styleable.PieChart,
            0, 0).apply {

        try {
            mShowText = getBoolean(R.styleable.PieChart_showText, false)
            textPos = getInteger(R.styleable.PieChart_labelPosition, 0)
        } finally {
            recycle()
        }
    }
}
```

### onMeasure

- 获取parent限制的大小
```java
int widthMode = MeasureSpec.getMode(widthMeasureSpec);
int widthSize = MeasureSpec.getSize(widthMeasureSpec);
int heightMode = MeasureSpec.getMode(heightMeasureSpec);
int heightSize = MeasureSpec.getSize(heightMeasureSpec);
```
> Mode是MeasureSpec

- 调用child的measure, 参数表示对child大小的限制

```java
/**
 * <p>
 * This is called to find out how big a view should be. The parent
 * supplies constraint information in the width and height parameters.
 * </p>
 *
 * <p>
 * The actual measurement work of a view is performed in
 * {@link #onMeasure(int, int)}, called by this method. Therefore, only
 * {@link #onMeasure(int, int)} can and must be overridden by subclasses.
 * </p>
 *
 *
 * @param widthMeasureSpec Horizontal space requirements as imposed by the
 *        parent
 * @param heightMeasureSpec Vertical space requirements as imposed by the
 *        parent
 *
 * @see #onMeasure(int, int)
 */
public final void measure(int widthMeasureSpec, int heightMeasureSpec) {
```

### onLayout

遍历child，调用child的layout方法，参数表示其布局相对于父布局的位置
```java
/**
 * Assign a size and position to a view and all of its
 * descendants
 *
 * <p>This is the second phase of the layout mechanism.
 * (The first is measuring). In this phase, each parent calls
 * layout on all of its children to position them.
 * This is typically done using the child measurements
 * that were stored in the measure pass().</p>
 *
 * <p>Derived classes should not override this method.
 * Derived classes with children should override
 * onLayout. In that method, they should
 * call layout on each of their children.</p>
 *
 * @param l Left position, relative to parent
 * @param t Top position, relative to parent
 * @param r Right position, relative to parent
 * @param b Bottom position, relative to parent
 */
@SuppressWarnings({"unchecked"})
public void layout(int l, int t, int r, int b) {
```

### onDraw

给你Canvas去绘图

## 沉浸模式

### 系统边衬区
- 系统栏边衬区：状态栏+导航条/按钮
- 系统手势边衬区：手势导航区

### 圆角

- 获取设备圆角的圆心和半径
```kotlin
// 在一个view中
val insets = rootWindowInsets
val topRight = insets.getRoundedCorner(RoundedCorner.POSITION_TOP_RIGHT) ?: return
// 在activity中
val rootWindowInsets = rootView.rootWindowInsets
```