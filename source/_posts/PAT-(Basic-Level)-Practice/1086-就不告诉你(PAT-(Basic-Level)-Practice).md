---
title: PAT-Basic-1086
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---


## 题目

> 做作业的时候，邻座的小盆友问你：“五乘以七等于多少？”你应该不失礼貌地围笑着告诉他：“五十三。”本题就要求你，对任何一对给定的正整数，倒着输出它们的乘积。
![来自PAT官网原题](https://upload-images.jianshu.io/upload_images/16086048-f1f46b1a599e283e.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
#### 输入格式：
> 输入在第一行给出两个不超过 1000 的正整数 A 和 B，其间以空格分隔。
#### 输出格式：
> 在一行中倒着输出 A 和 B 的乘积。
#### 输入样例：
```
5 7
```
#### 输出样例：
```
53
```
## 通过代码（极致压行版）
```c++
#include <stdio.h>
int main () {
	int a, b;
	scanf ("%d%d", &a, &b);
	int c = a * b;
	while (c && c % 10 == 0)c /= 10;//忽略前导0，ab == 0则不循环
	do printf ("%d", c % 10); while (c /= 10);//do-while，先输出，再除10，ab == 0则只输出一个0
	return 0;
}
```
## 通过代码（正常版）
```c++
#include <stdio.h>
int main () {
	int a, b;
	scanf ("%d%d", &a, &b);
	int c = a * b;
	while (c && c % 10 == 0) {
		c /= 10;
	}//忽略前导0，ab == 0则不循环
	do {
		printf ("%d", c % 10);
		c /= 10;
	} while (c);//do-while，先输出，再除10，ab == 0则只输出一个0
	return 0;
}
```
## 思路与注意
*   简单
## 反思与评价
*   简单
