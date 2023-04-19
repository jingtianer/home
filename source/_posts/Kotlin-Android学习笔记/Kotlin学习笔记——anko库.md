---
title: Kotlin学习笔记——anko库
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

## 弹出吐司
|方法|参数|解释|备注|
|-|-|-|-|
|toast|CharSequence|弹出短吐司|相当于`Toast.makeText(this, "String", Toast.Toast.LENGTH_SHORT).show()`|
|longToast|CharSequence|弹出长吐司|相当于`Toast.makeText(this, "String", Toast.Toast.LENGTH_LONG).show()`|
## 像素转换方法
|方法|说明|
|-|-|
|dip|dip 转 px|
|sp|sp 转 px|
|px2dip|px 转 dip|
|px2sp|px 转 sp|
|dimen|dip 转 sp|
## 弹出警告窗口
```kotlin
    alert("对话框内容", "对话框标题") {
        positiveButton("确认") {
            //点按确认后执行的操作
        }
        negativeButton("取消") {
            //点按取消后执行的操作
        }
    }.show()
```
