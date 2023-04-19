---
title: Kotlin学习笔记——基础语法篇之特殊运算符
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---


参考文献——[Kotlin学习之运算符](https://www.jianshu.com/p/e9b5d263615d)
来自简书作者——[Hunter_Arley](https://www.jianshu.com/u/f8ee6540e874)
## 等值判断
| 运算符 | 解释                                                       | 重载函数                   |
|--------|------------------------------------------------------------|----------------------------|
| a == b | 判断ab是否结构相等，相当于java中a.equals(b)或b.equals(a)   | a?.equals(b)?:b===null     |
| a != b | 判断ab是否结构不等，相当于java中!a.equals(b)或!b.equals(a) | !(a?.equals(b)？:b===null) |
| ===    | 判断是否结构相等且引用相同                                 |                            |
- ps: Kotlin中的`==`用来比较两个元素是否相同，比如字符串的内容，整数，浮点数的值，而不比较引用是否相同，而`===`表示比较内容是否相同，且引用是否相同
## 新增运算符
| 运算符 | 解释                   | 重载函数      |
|--------|------------------------|---------------|
| is     | 判断变量是否为某个类型 |               |
| a in b | 检查元素a是否在b中     | b.contains(a) |
## 下标运算符
| 操作符           | 函数                 |
|------------------|----------------------|
| a[i]             | a.get(i)             |
| a[i,j]           | a.get(i,j)           |
| a[i_1,...,i_n]   | a.get(i_1,...,i_n)   |
| a[i]=b           | a.set(i,b)           |
| a[i,j]=b         | a.set(i,j,b)         |
| a[i_1,...,i_n]=b | a.set(i_1,...,i_n,b) |
- 与Java不同，Kotlin的这个运算符不仅可以用在数组变量后，也可以用在集合变量后，可以方便地调用和操作数组和集合中的元素。
## 位、逻辑运算符
| Java位运算符   | Kotlin   | Kotlin函数 | 描述           |
|----------------|----------|------------|----------------|
| ~a             | 无       | a.inv()    | 按位取非       |
| a&b            | a and b  | a.and(b)   | 按位与         |
| a \| b        | a or b     | a.or(b)|按位或 |
| a^b            | a xor b  | a.xor(b)   | 按位异或       |
| a<< b          | a shl b  | a.shl(b)   | 左移b位        |
| a>>b           | a shr b  | a.shr(b)   | 右移b位        |
| a>>>b          | a ushr b | a.ushr(b)  | 无符号右移b位  |
