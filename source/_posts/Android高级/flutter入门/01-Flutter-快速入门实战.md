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
> 标准小组件
Container：向小部件添加填充、边距、边框、背景颜色或其他装饰。
GridView：将小部件布置为可滚动网格。
ListView：将小部件布置为可滚动列表。
Stack：将一个小部件重叠在另一个小部件之上。
> material布局小组件
Card：将相关信息组织到带有圆角和阴影的框中。
ListTile：将最多 3 行文本以及可选的前导和尾随图标组织成一行。