---
title: 01-Flutter-快速入门实战
date: 2024-4-24 21:15:36
tags: Flutter
categories: Android
toc: true
language: zh-CN
---

## flutter
- everything is a widget

## widget

在flutter中，所有看得见的看不见的东西都是widget

## 目录结构

- android:
- ios:
- lib: dart文件，业务逻辑
- lib/main.dart: 入口
- pubspec.yaml: 工程信息以及依赖

## 依赖声明
pubspec.yaml中

```yaml
dependencies:
    package_name: [version_code]
    package_name: ^[version_code]
    # ^的作用是让系统选择更高且与version_code相兼容的版本
    packge_name: [git_url]
    packge_name: [local path]
dev_dependencies:
    # 仅在开发时依赖，在release时不打包
    package_name: param
```

## 布局
本节内容来自[fluuter docs/ui/layout](https://docs.flutter.dev/ui/layout)
### 简介

- [flutter中的layout](https://docs.flutter.dev/ui/widgets/layout)
- 常见layout
  - Center
  - Container
  - Baseline
  - Row
  - Column
  - Stack
  - Table

### 将小部件添加到布局
- child: 唯一子widget
- children: 多个列表型的子widget(如Row, Column, Stack)
  
### build方法
大多数widgets都有build方法,flutter app本身也是一个widget,通过build方法实例化并返回一个widget就会显示该widget

### App
- CupertinoApp: ios风格的app
  - theme传入CupertinoThemeData
  - home属性用CupertinoPageScaffold
  - [全部Cupertino lib](https://api.flutter.dev/flutter/cupertino/cupertino-library.html)
- MaterialApp: Material风格的app
  - home用Scaffold
  - 可以使用ActionButton, SneakBar
- Container: 如果不需要Material风格或ios风格，直接返回Container

### Row和Colum

![row主轴交叉轴](https://docs.flutter.dev/assets/images/docs/ui/layout/row-diagram.png)
![column主轴交叉轴](https://docs.flutter.dev/assets/images/docs/ui/layout/column-diagram.png)

#### 主轴和交叉轴(main axis, cross axis)
- row的主轴和交叉轴分别是水平的和垂直的
- column的主轴和交叉轴反过来
- `MainAxisAlignment`和`CrossAxisAlignment`提供了控制对齐方式的常量
#### 多个children的大小
- 使用Expanded: 让子widget适应row/column的大小，使用Expanded的属性flex制定其大小的权重
- 使用`mainAxisSize: MainAxisSize.min`控制大小，让其紧凑的贴在一起
### 常用布局小组件

> **标准小组件**
Container：向小部件添加填充、边距、边框、背景颜色或其他装饰。
GridView：将小部件布置为可滚动网格。
ListView：将小部件布置为可滚动列表。
Stack：将一个小部件重叠在另一个小部件之上。


> **material布局小组件**
Card：将相关信息组织到带有圆角和阴影的框中。
ListTile：将最多 3 行文本以及可选的前导和尾随图标组织成一行。

### 约束Constraints
[Understanding constraints](https://docs.flutter.dev/ui/layout/constraints)
Flutter的布局引擎被设计为一次通过的过程。这意味着Flutter可以非常有效地布局其小部件，但也存在一些限制: 
 
- 小部件只能在父部件给它的约束范围内决定自己的大小。这意味着一个小部件通常不能有它想要的大小。 
- 小部件不能知道也不能决定它自己在屏幕上的位置，因为决定小部件位置的是小部件的父组件。 
- 因为父元素的大小和位置也依赖于它自己的父元素，所以不考虑整个树，就不可能精确地定义任何小部件的大小和位置。 
- 如果子元素想要与父元素不同的大小，并且父元素没有足够的信息来对齐它，那么子元素的大小可能会被忽略。在定义alignment时要明确。


#### 特性
- 若屏幕是父布局，无论该widget是否定义其大小、宽度，该widget会强制铺满屏幕
- 对于Align, Center, 子widget的大小不能超过父widget的情况下，子widget可以拥有任意的大小
- 如果父widget没有大小，他的大小由子widget决定
- ConstrainedBox
  - 如果ConstrainedBox（可以指定子widget的宽度高度的范围）的父widget是屏幕。
    - 屏幕会约束widget大小正好等于屏幕
  - ConstrainedBox只能从父widget的约束中施加约束。也就是如果子widget的约束不在父widget的约束范围内，那么就只能依照父widget的约束
  - 如果子widget要求的大小超过了ConstrainedBox的限制，只能取限制的最大值，若小于最低限制，则只能是最小值
- UnconstrainedBox
  - 允许子widget拥有任何大小，如果子widget大小超过UnconstrainedBox，则会在屏幕上显示"overflow warning"
  - 如果子widget要求大小为`double.infinity`，则不会显示任何内容，且会在console中提示error信息
- OverflowBox
  - 允许子widget拥有任何大小，如果子widget大小超过UnconstrainedBox，则会尽量显示子widget的内容，不会出现"overflow warning"
- LimitedBox
  - 限制子widget的大小范围，但仅在子widget设置为`double.infinity`时生效，如果设置不是`double.infinity`也不在LimitedBox限制的范围内，则显示子widget要求的大小而不应用LimitedBox的限制
- FittedBox
  - 父widget是screen,子widget是Text
    - Text根据字体大小，字符，长度计算出宽度(intrinsic)后，根据自身宽度缩放Text填充空白，超过则缩小
  - 父widget是Center（允许子widget有自己的大小）,子widget是Text
    - Text根据字体大小，字符，长度计算出宽度(intrinsic)后，如果可以，FittedBox先让自己的大小适应Text，若不行，则缩放Text
  - 只能缩放有边界的，长宽不是无穷的widget，否则什么都不会显示，且在console中报告错误。
- Center+Text
  - 不缩放，文字太长就break line
- Row
  - 类似于UnconstrainedBox
  - widget由Expanded包裹，则不允许子widget自定义宽度，由其他children决定宽度
  - 如果所有children都被Expanded包裹，那么大家都按照Expand中分配的比例决定其宽度
  - Flexible允许它的子控件具有与Flexible相同或更小的宽度，而Expanded则强制它的子控件具有与Expanded完全相同的宽度
- Scaffold
  - 通过`SizedBox.expand`包裹子widget，可以让子widget与Scaffold有相同的大小

#### 松紧约束(Tight Loose Constraints)
- Tight Constraints
  - 最大宽度=最小宽度, 最大长度=最小长度
- Losse Constraints
  - 最小宽度 = 0, 最小长度 = 0
  - 最大宽度 != 0, 最大长度 != 0
  - > Center就是把收到的tight约束转换成loose约束
#### 无限约束(unbounded constraint)
- 最大宽度 = double.infinite, 最大长度 = double.infinite
- 一般情况下会导致console中出现error
- 用于ListView等ScrollView的子类
  - 滑动方向上的长/宽无限
#### Flex
- Flex Box(Row 或 Column)
- 若主轴上拥有有限约束，则经可能的大
- 若主轴上拥有无限约束，每个孩子的flex值必须为0，也就是不能在可滑动widget或flex box中使用Expand
- 交叉轴方向不能无限，否则无法align children

### Stack
- 常见属性
  - alignment
    - 传入坐标值
      - 原点在widget中心
      - 水平向右为x轴，x=[-1, 1] 从左到右
      - 竖直向下为y轴，y=[-1, 1] 从上到下
  - fit
    - 传入StackFit
    - 值有: loose, expand, passthrough
  - overflow
    - 空间溢出的操作: clip / visible

- position
  - 一个widget, 和stack搭配使用
  - 确定stack中子widget的位置

> Container包括了: SizedBox, Center, Padding, DecoratedBox, ConstrainedBox的功能

## StateFull/StateLess

- didUpdatedWidget
  - widget参数发生改变时触发
## Animation

## InheritedWidget
- of方法，从当前widget向上查找，直到找到该类型的个Widget
  - 不允许在initState调用of方法


### 自上而下传递状态
#### 在父widget中
- updateShouldNotify
  - 是否向下传递变化
#### 在子widget中
- didChangeDepandencies
  - 状态同步
  - 若一个子widget通过of获取过我的属性，那么我的属性变化时，都会重新build这些子widget
  - 在重新build之前，会触发didChangeDepandencies
  - initState后也会调用一次didChangeDepandencies

### 自下而上的消息传递
父widget用`NotificationListener<XXXNotification>`包装
子widget中需要传递消息时，创建一个`XXXNotification`，并调用dispatch

## 页面跳转
Navigator
- push(Widget)
  - widget栈中加入一个widget
- pop
  - 弹出一个widget