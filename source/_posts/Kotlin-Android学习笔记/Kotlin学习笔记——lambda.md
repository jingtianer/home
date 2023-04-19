---
title: Kotlin学习笔记——lambda
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

参考文献——[kotlin之Lambda编程](https://www.jianshu.com/p/498792258d91)
来自简书作者——[程自舟](https://www.jianshu.com/u/006580bb7d8e)
## Kotlin lambda语法
```kotlin 
    btn.setOnClickListener ((View v) -> {
        toast("click")
    })
    btn.setOnclickListener {
        toast("click")
    }
    btn.setOnLongClickListener {
        toast("Long Click")
        true//lambdda的返回值，不写return
    }
    {a:Int, b:String -> String 
        (a +  b.toDouble()).toString()
    }
```
### 完整写法
```kotlin
    {a:Int, b:String, c:Long/*输入参数列表*/ -> String/*返回值类型*/
        /*lambda body*/
        var temp:Double = a + b.toDouble()
        if (c == 0L) {
            "error"
        } else {
            (temp.toDouble() + c).toString()
        }//返回值(不要写return)
    }
```
### 省略参数的写法
```kotlin
    {
        /*
            lambda body
        */
    }
```
## lambda的使用
1. 作为高阶函数的参数，比如setOnclickListener，List的sort系列函数
2. 调用run方法
```kotlin
    run { toast("run") }
```
3. Lambda表达式也可以传递给一个高阶函数当做参数,因此上述代码中
```kotlin
view.setOnClickListener({v -> viewClicked(v) })
```
4. 在 Kotlin 中有一个约定，如果函数的最后一个参数是一个函数，并且你传递一个 lambda 表达式作为相应的参数，你可以在圆括号之外指定它
因此可以实现如下
```kotlin
view.setOnClickListener() {v -> viewClicked(v) }
```
5. 在 Kotlin中还有另外一个约定，如果一个函数的参数只有一个，并且参数也是一个函数，那么可以省略圆括号
```kotlin
view.setOnClickListener{v -> viewClicked(v) }
```
6. 使用默认参数名称（注意）
```kotlin
    //使用默认参数名称
    people.maxBy { it.age} //"it"是自动生成的参数名称
```
- 默认名称it只会在实参名称没有显示的指定时候才会生成。it能大大缩短简化代码，但是不应该滥用，尤其是在lambda嵌套情况下，最好显示声明lambda参数。否则很难搞清it引用的到底是哪个值，本末倒置。
