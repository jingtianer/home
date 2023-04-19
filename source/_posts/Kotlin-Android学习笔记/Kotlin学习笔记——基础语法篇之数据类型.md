---
title: Kotlin学习笔记——基础语法篇之数据类型
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

## 一、基本数据类型
### Kotlin的数据类型
| 数据类型名称 | Kotlin的数据类型 |
|--------------|------------------|
| 整型         | Int              |
| 长整型       | Long             |
| 浮点型       | Float            |
| 双精度浮点型 | Double           |
| 布尔型       | Boolean          |
### 声明变量
```kotlin
    var integer:Int//一般用法var/val + 标识符 + : + 类型名，var表示变量
    val integer1:Int = 0//val表示常量，相当于java中的final，c++中的const
    var str = "this is a string"
    //没有":String"，此时只要保证编译器可以知道变量的类型，则编译器可以完成类型推断
    var flt:Float = 5f//f表示数据为float类型
    var tobar:Toolbar? = findViewById<Toolbar>(R.id.toolbar)
    /*
    类型名后+'?'表示该变量为可空变量，kotlin为了防止java中NullPointerException，
    默认所有的变量都是不可空（不能为null的），如果要让变量为空，需要+'?'，
    此时，编译器会强制程序员对所有可空变量进行非空判断
    */
```
### Kotlin的类型转换
#### 强制类型转换
```kotlin
    var double:Double = 16.0
    val dbl2Int:Int = (double as Int)
```
#### 数据转换函数
在kotlin的世界中，一切都是类和对象，基本数据类型也是，其中用于数据转换的成员函数
| Kotlin的数据类型转换函数 |
|--------------------------|
| toInt                    |
| toLong                   |
| toFloat                  |
| toDouble                 |
| toChar                   |
| toString                 |
## 二、字符串
### 字符串与其他基本数据类型转换
| String的成员函数 | 备注                              |
|------------------|-----------------------------------|
| toInt            |                                   |
| toLong           |                                   |
| toFloat          |                                   |
| toDouble         |                                   |
| toBoolean        |                                   |
| toCharArray      | 返回的是CharArray不是Array\<Char> |
### 字符串的常用方法
| String的成员函数 | 解释                                      |
|------------------|-------------------------------------------|
| indexOf          | 查找子串                                  |
| substring        | 获取子串                                  |
| replace          | 替换子串                                  |
| split            | 按特定字符分隔子串，返回值是List\<String> |
### 字符串拼接
```kotlin
    val str1:String = "我刘景天宇宙第一帅！"
    val integer:Int = 8848
    val text:TextView = findViewById<TextView>(R.id.text)
    val strCat:String = "str1 = ${str1} integer = $integer, 当前text中显示的内容是：${text.text}"
    /*
    $变量名
    ${表达式}
    */
```
## 三、数组
### Kotlin的数组类型
| 数组名称     | 初始化方法     | 数组名称        | 初始化方法 |
|--------------|----------------|-----------------|------------|
| IntArray     | intArrayOf     | Array\<Int>     | ArrayOf    |
| LongArray    | longArrayOf    | Array\<Long>    | ArrayOf    |
| FloatArray   | floatArrayOf   | Array\<Float>   | ArrayOf    |
| DoubleArray  | doubleArrayOf  | Array\<Double>  | ArrayOf    |
| BooleanArray | booleanArrayOf | Array\<Boolean> | ArrayOf    |
| CharArray    | charArrayOf    | Array\<Char>    | ArrayOf    |
| null         | null           | Array\<String>  | ArrayOf    |
### 数组常用方法
| 成员              | 解释       |
|-------------------|------------|
| size              | 数组长度   |
| get(index)        | 获取元素   |
| set(index, value) | 修改元素值 |
>ps:kotlin也可以通过下标引用元素和修改元素
## 四、容器
### Kotlin的容器
| Kotlin容器 | 名称       | 初始化方法    |
|------------|------------|---------------|
| 只读集合   | Set        | setOf         |
| 可变集合   | MutableSet | mutableSetOf  |
| 只读队列   | Set        | listOf        |
| 可变队列   | MutableSet | mutableListOf |
| 只读映射   | Set        | mapOf         |
| 可变映射   | MutableSet | mutableMapOf  |
#### 容器的通用常用方法
| 方法名          | 返回值       | 解释                       |
|-----------------|--------------|----------------------------|
| isEmpty()       | Boolean      | 判断是否为空               |
| isNotEmpty()    | Boolean      | 判断是否为非空             |
| clear()         | Unit（猜测） | 清空容器（找不到这个方法） |
| contains(value) | Boolean      | 查找有没有这个元素         |
| iterator()      | 对应的迭代器 | 返回容器的迭代器           |
| count()         | Int          | 获取元素个数               |
| size            | Int          | 获取元素个数               |
> ps:只读容器初始化后就不可更改了
#### 容器的迭代器的常用方法
| 方法名    | 解释                           |
|-----------|--------------------------------|
| hasNext() | 类似java的Scanner的hasNext方法 |
| next()    | 类似java的Scanner的Next方法    |
### 集合
#### Kotlin集合的特性
1. 集合内部元素不按照顺序排列，无法下标访问
2. 集合内部元素具有唯一性
#### MutableSet的元素变更方法
| 方法            | 解释         |
|-----------------|--------------|
| add(element)    | 添加元素     |
| remove(element) | 移除某个元素 |
### 映射
#### 初始化方法
```kotlin
    var map1:map<String, int> = mapOf("1" to 1, "2" to 2, "3" to 3)
    var map2:mutableMap<String, Boolean> = mutableMapOf(Pair("a", true), Pair("b", false))
    /*
    不论是map还是mutableMap，
    都可以使用 key to value和Pair(Key, Value)
    */
```
#### Map和MutableMap的常用方法
| 方法                 | 返回值  | 解释                   | Map | MutableMap |
|----------------------|---------|------------------------|-----|------------|
| containsKey(key)     | Boolean | 判断是否有指定键的元素 | √   | √          |
| containsValue(value) | Boolean | 判断是否有指定值的元素 | √   | √          |
| put(key, value)      | String? | 添加元素               | ×   | √          |
| remove(key)          | String? | 移除元素               | ×   | √          |
| remove(key， value)  | Boolean | 移除元素               | ×   | √          |
### 队列
#### 队列的常用方法
| 方法                       | 返回值      | 解释                 | List | MutableList |
|----------------------------|-------------|----------------------|------|-------------|
| get(index)                 | ElementType | 返回对应位置的元素   | √    | √           |
| [index]                    | ElementType | 下标运算             | √    | √           |
| add(element)               | Unit        | 向队尾添加元素       | ×    | √           |
| set(index, element)        | ElementType | 修改指定位置的元素   | ×    | √           |
| removeAt(index)            | Int         | 移除指定位置的元素   | ×    | √           |
| sortBy{排序条件}           | Unit        | 按照排序条件升序排列 | ×    | √           |
| sortByDescending{排序条件} | Unit        | 按照排序条件降序排列 | ×    | √           |
| sort()                     | Unit        | 排序                 | ×    | √           |
## 五、类型判断
### 例子
```kotlin
    if (varable is String) {
        //Do something，
    } else if (varable is Int) {
        //or you will do something
    }
```
### 例子
```kotlin
    when (varable) {
        is String -> //Do something
        is Int ->  //or you will do something
        else -> //nothing
    }
```
## 六、空安全
```kotlin
    var i:Int = 0
    //Kotlin默认的变量是不可为空(null)的
    var str:String? = null
    //如果想让一个变量为空，要在类型名后面加'?'
    i = str?.length 
    //可空变量在调用方法时，在后面加上'?'，一旦可空变量str的值为空，返回null
    try {
        i = str!!.length
    } catch(e: Exception) {
        Toast.makeText(this, "遇到${e}错误", Toast.LENGTH_SHORT).show()
    }
    //可空变量加!!，表示如果为空，抛出异常
    i = str?.length : -1
    //表示如果str为空，则值为0
```
