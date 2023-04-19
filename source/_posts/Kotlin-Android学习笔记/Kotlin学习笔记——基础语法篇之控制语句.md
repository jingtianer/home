---
title: Kotlin学习笔记——基础语法篇之控制语句
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

## if...else...
### 用法
Kotlin中`if...else...`基本用法与`C/C++`，`java`中相同
#### 例子
```kotlin
    button.setOnClickListener {
        if (flag) {
            text.text = "I love you, at the first sight of you."
        } else {
            text.text = "I love three things in this world.Sun, moon and you. " +
                    "Sun for morning, moon for night, and you forever."
        }
    }
```
而Kotlin的if else可以有返回值
#### 例子
```kotlin
    button.setOnClickListener {
        text.text = if (flag) {
            "I love you, at the first sight of you."
        } else {
            "I love three things in this world.Sun, moon and you. " +
                    "Sun for morning, moon for night, and you forever."
        }
    }
```
Kotlin中没有`java`，`C/C++`的三目运算符，但是可以用if...else...取代
#### 例子
```kotlin
    button.setOnClickListener {
        text.text = if (flag) (16).toString() else (153.6).toString()
        /*
        像极了三目元算符：(假装这里是C/C++或java)
        text.text = flag ? (16).toString() : (153.6).toString();
        */
    }
```
## when...else...
### 用法
Kotlin中的`when...else...`多路分支相当于`C/C++`，`java`中的`switch...case...`，但是用法稍有不同
1. Kotlin的`when...else...`和Kotlin的`if...else...`一样，允许有返回值
2. Kotlin的`when...else...`各个分支中，可以不是常量，变量也可以
3. Kotlin的`when...else...`不用写break，每个分支结束后自动退出`when...else...`语句块
#### 例子
```kotlin
    button.setOnClickListener {
        text.text = when(type) {
            1,2,3 -> "I love you, at the first sight of you."//多个值走同一个分支，用逗号隔开
            in 4..10 -> "I love three things in this world.Sun, moon and you. " +
                    "Sun for morning, moon for night, and you forever."//表示在4到10之间
            !in 1..10 -> "We don't talk anymore."//表示不在1到10之间
            else -> "error"
        }
    }
```
## 循环
### for循环
Kotlin居然取消了常见的for循环，tmd
#### 遍历循环
##### 1. for-in循环
类似C++/java中的for_each形式的循环，可以对字符串、数组、Array<>, 队列、映射、集合进行遍历
###### 例子
```kotlin
    btn.setOnClickListener {
        var str:String = "0123456789"
        for (item in str) {//item自动类型推断
            Toast.makeText(this, "${item}", Toast.Toast.LENGTH_SHORT).show()
        }
    }
```
###### 例子(下标数组遍历)
```kotlin
    btn.setOnClickListener {
        var str:String = "0123456789"
        for (i in str.indices) {//indices是下标数组
            Toast.makeText(this, "${str[i]}", Toast.Toast.LENGTH_SHORT).show()
        }
    }
```
#### 条件循环
##### 格式
```kotlin
    for(i in 11 until 66) {}
    //左闭右开区间，[11,66)
    for (i in 23..89 step 4) {}
    //每次循环，i += 4，如果条件允许，可以到89
    for (i in 50 downTo 7) {}
    //从50 递减到 7
```
### while循环
用法同java/C/C++
### do-while循环
用法同java/C/C++
### 跳出多重循环
和java类似，如果想一次性跳出多个循环，可以在循环外面加"标签"
#### 例子
```kotlin
    var i:Int = 0
    var j:Int = 0
    @outside while (i <= 10) {
        j = 10;
        while (i * j != 50) {
            j--
            if (j == 0) {
                break@outside
            }
        }
        i++
    }
```
