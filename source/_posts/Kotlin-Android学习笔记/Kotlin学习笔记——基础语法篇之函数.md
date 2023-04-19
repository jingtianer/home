---
title: Kotlin学习笔记——基础语法篇之函数
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

## 函数的一般形式
```kotlin
    fun mathodName(/*para list*/) : String/*return value type*/ {
        /*
            function body
        */
    }
```
### 与C、C++或java的不同
1. 如果要重载，在fun前面加`override`
2. 如果想让子类重载，要加`open`关键词（类也一样）
3. 可以定义全局函数，函数不是必须写在类里
4. 可以有默认参数，且默认参数不必放在最后几个
```kotlin
    fun TextView.println(str:CharSequence) {
        append("\n${str}")
    }
    fun TextView.print(str:CharSequence) {
        append(str)
    }//这个东西是扩展函数，后面说
    fun func(str:String = "哈哈哈",i:Int, j:Double) {//str的默认参数"哈哈哈"
        val text:TextView = findViewById(R.id.text)
        text.print("$str")
        text.println("$i")
        text.println("$j")
    }
```
- 此时，在调用时，如果第一个不采用默认参数，则按照顺序传递三个参数，否则按照以下形式传递参数
```kotlin
    func(i = 10, j = 20.5)
```
5. 可变参数，在参数列表中，参数名称前用vararg（var = varable, arg = 参数）修饰
```kotlin 
    fun appendString(tag:String, vararg info:String?) : String {
        var str:String = "${tag}"
        for (item in info) {
            str = "${str}\n${item}"
        }
        return str
    }
```
## Kotlin的特殊函数
### 泛型函数/内联函数
#### 例子
```kotlin
    fun<T> appendString(tag:String, vararg info:T?) : String {
        var str:String = "${tag}"
        for (item in info) {
            str = "${str}\n${item.toString()}"
        }
        return str
    }
```
- 在`fun`后面加入`<泛型列表>`,表示泛型函数
#### 调用方法
```kotlin
    btn.setOnClickListener {
        text.text = appendString<Int>("转化", 1,2,3,4,5,6,7,8,9)
    }
```
#### 注意
1. 只有泛型类才拥有成员泛型函数，或者可以把泛型函数作为全局函数
2. Kotlin是强类型的语言，如果需要即传递Number类继承的类对象，而不继承其他类对象，不能写`<Number>` 要写成`<reified T : Number>`,这个写法等价于java的`<T extends Number>`
### 简化函数
Kotlin中，函数的定义形式和变量十分相似，这是因为函数也是一种特殊变量，可以对他赋值
#### 例子
```kotlin
    fun factorial(n:Int):Int = if(n <= 1) n else n*factorial(n-1)
```
### 尾递归函数
在`fun`之前加上关键字`tailrec`(tail——尾巴，rec——不知道)，告诉编译器这是一个尾递归函数，编译器可以自动优化成循环
#### 例子
```kotlin
    tailrec fun findFixPoint(x:Double = 1.0) : Double 
        = if (x == Math.cos(x)) x else findFixPoint(Math.cos(x))
```
### 高阶函数
传入的参数是一个函数，个人认为相当于C/C++的函数指针，或者说传递了一个函数变量
#### 例子
```kotlin
    fun<T> maxCustom(array:Array<T>, greater:(T,T) -> Boolean) : T? {
        /*
        这个地方
        greater(T, T) -> Boolean
        表示一个函数名为greater，参数为两个T类型，返回值的Boolean的函数
        */
        var max:T? = null
        for (item in array) {
            if (max == null || greater(item, max)) {
                max = item
            }
        }
        return max
    }
```
#### 调用
```kotlin
    val arr:Array<Int> = arrayOf(1,2,3)
    btn.setOnClickListener {
        text.text = "最大值为${maxCustom<Int>(arr, {a,b ->  a > b}).toString()}"
    }//使用lambad表达式
```
## 系统增强函数
### 扩展函数
可以给已有的类中添加函数，作为成员函数
#### 例子
```kotlin
    fun TextView.println(str:CharSequence) {
        append("${str}\n")
    }
    fun TextView.print(str:CharSequence) {
        append(str)
    }
```
#### 调用
和正常成员函数一样调用
```kotlin
    val text:TextView = findViewById(R.id.text)
    val btn:Button = findViewById(R.id.btn)
    btn.setOnClickListener {
        text.println("123")
        text.print("demo")
    }
```
### 单例对象
用object替换class，这样其中的所有函数都是静态成员函数了

相当于static修饰符
