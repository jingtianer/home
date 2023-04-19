---
title: Kotlin学习笔记——RadioButton和RadioGroup
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

## RadioButton的使用
拖拽出RadioButton，和RadioGroup，把RadioButton拖到RadioGroup的子部件下
## RadioGroup的使用
|方法|使用|备注|
|-|-|-|
|android:orientation|设置RadioGroup中RadioButton的排列方式|"vertical"为垂直，"horizontal"为水平|
|setOnCheckedChangeListener|设置选择改变时的操作|无|
## 特定效果
### RadioButton多行多列显示
#### 解决方案1
多个ButtonGroup，当一个group的按钮被选择后，清除其他按钮的选择
#### 解决方案2
重写 RadioGroup 的 onMeasure、onLayout 实现 RadioButton 多行多列排列
参考教程（来自csdn）
[图片编辑器--重写 RadioGroup 的 onMeasure、onLayout 实现 RadioButton 多行多列排列](https://blog.csdn.net/xwdoor/article/details/80511600)
