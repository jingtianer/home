---
title: Kotlin学习笔记——基础语法篇之类和对象
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

## 类的构造
### Kotlin类的写法
1. Kotlin类的构造函数分为主构造函数和二级构造函数
1. 主构造函数的特点——函数名为init，参数要写在类名后面（下面举例），一般用于初始化
4. 如果要在java中调用kotlin的类，要在类名前面加上`@JvmOverloads`（让java能够识别默认参数），并且补充`constructor`关键字
2. 主构造函数的参数写在类名后，如果没有`@JvmOverloads`修饰，`constructor`关键字可省略（不是指二级构造函数的`constructor`，是类名后面的）
3. 二级构造函数用`constructor`关键字
4. 二级构造函数的特点——可有可无，相互独立，如果有主构造函数，先调用主构造函数
#### 例子
```kotlin
    class Animal (type:String = "动物", name:String) {
        //没有@JvmOverloads修饰，可以省略constructor
        //等价以下写法
    //class Animal constructor(type:String = "动物", name:String) {
        var Type:String = ""
        var Name:String = ""
        var Age:Int = 0
        var Sex:String = ""
        init {
            Type = type
            Name = name
        }
        constructor(type:String = "动物", name:String, age:Int, sex:String) : this(type, name){
            Age = age
            Sex = sex
        }

    }
```
## 类的成员
### 类的成员属性
观察上述代码，构造函数传入的参数和成员变量一一对应，对于这些变量，Kotlin提供简便写法，在参数名之前加上`val`或`var`
#### 例子
```kotlin
    class Animal (var type:String = "动物", var name:String) {
        //只有主构造函数中才可以有成员属性
        var sex:Int = 0
        var age = 0
        constructor(type:String = "动物", name:String, age:Int, sex:Int) : this(type, name){
            this.sex = sex
            this.age = age
        }

    }
    //到时候可以直接调用成员变量type，name等
```
### 伴生对象和静态属性
想要让类具有类似java中静态成员函数和静态成员变量，要用到伴生对象，相当于java中的static代码块儿
#### 例子
```kotlin
class Animal (var type:String = "动物", var name:String) {
    var sex:Int = 0
    var age = 0
    constructor(type:String = "动物", name:String, age:Int, sex:Int) : this(type, name){
        this.sex = sex
        this.age = age
    }
    companion object StaticMembers {
        val MALE:Int = 0
        val FEMALE:Int = 1
        val UNKNOWNSEX:Int = 2
        val UNDIFINEDSEX:Int = 3
        fun sexToString(sex:Int):String {
            return when(sex) {
                MALE -> "Male"
                FEMALE -> "Female"
                UNKNOWNSEX -> "UnKnownSex"
                UNDIFINEDSEX -> "UnDefindSex"
                else -> "Invalid input"
            }
        }
    }
}
```

## 类的继承
在Kotlin中，默认情况下，类是不允许被继承的，成员函数也是不允许重写的，只有加上`open`修饰符，被修饰的类才可以被继承，被修饰的函数才可以被重写，Kotlin的类和函数默认相当于java的final类和方法
### Kotlin中的开放性修饰符
| 开放性修饰符 | 说明                                                     |
|--------------|----------------------------------------------------------|
| public       | 对所有人开放，Kotlin的类、函数变量不加修饰全部都是public |
| internal     | 对于本模块开放                                           |
| protected    | 对于自己和子类开放                                       |
| private      | 私有，不能和open一起使用                                 |
### 抽象类
写法：
```kotlin
    abstract class demo() {
        abstract fun func1():Int
    }
```
### 接口
```kotlin
    interface interDemo {
        fun func1():String
        fun func2():String {
            return "I'm tired"
        }
    }
```
### 注意
1. Kotlin不允许多继承，通过接口来间接实现多继承
2. 抽象类不能定义对象
3. kotlin允许在接口内部实现某个方法
4. 接口内部的所有方法默认都是`open`类型默认是抽象的
5. 继承的时候，基类的成员属性不用加`val`或`var`

## 几种特殊的类
### 嵌套类
#### 注意
1. 嵌套类就是在类里面再写一个类
1. 普通的嵌套类不能访问外部类的数据
#### 例子
```kotlin
    class outerClass(var otrName:String = "outer name") {
        class innerClass(var inrName:String = "inner name") {
            fun getInfo():String {
                return "我的名字是：${inrName}"
            }
        }
    }
```
### 内部类
1. 可以访问外部类数据的嵌套类
```kotlin
    class outerClass(var otrName:String = "outer name") {
        inner class innerClass(var inrName:String = "inner name") {
            fun getInfo():String {
                return "内部类的名字是：${inrName}\n外部类的名字是：${otrName}"
            }
        }
    }
```
### 枚举类和密封类
先不学
### 数据类
在类名前加上`data`修饰
#### 特点
1. 这种类自动生成每个字段的get和set方法
2. equals方法，比较每一个数据
3. 提供copy方法，用于复制数据对象
4. 提供toSting方法

#### 注意
1. 必须有主构造函数，且至少一个参数
2. 输入参数前面必须要加`val`或`var`
3. 数据类不能是基类，不能是子类，不能是抽象类，不能是内部类，不能是密封类

### 模板类
类名后面添加`</*泛型列表*/>`，表示这是一个模板类
#### 例子
```kotlin
    class MyArray<T> (var arr:Array<T>) {
        
    }
```
