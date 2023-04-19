---
title: PAT-Basic-1020
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目
> 月饼是中国人在中秋佳节时吃的一种传统食品，不同地区有许多不同风味的月饼。现给定所有种类月饼的库存量、总售价、以及市场的最大需求量，请你计算可以获得的最大收益是多少。

> 注意：销售时允许取出一部分库存。样例给出的情形是这样的：假如我们有 3 种月饼，其库存量分别为 18、15、10 万吨，总售价分别为 75、72、45 亿元。如果市场的最大需求量只有 20 万吨，那么我们最大收益策略应该是卖出全部 15 万吨第 2 种月饼、以及 5 万吨第 3 种月饼，获得 72 + 45/2 = 94.5（亿元）。
#### 输入格式：
> 每个输入包含一个测试用例。每个测试用例先给出一个不超过 1000 的正整数 N 表示月饼的种类数、以及不超过 500（以万吨为单位）的正整数 D 表示市场最大需求量。随后一行给出 N 个正数表示每种月饼的库存量（以万吨为单位）；最后一行给出 N 个正数表示每种月饼的总售价（以亿元为单位）。数字间以空格分隔。
#### 输出格式：
> 对每组测试用例，在一行中输出最大收益，以亿元为单位并精确到小数点后 2 位。
#### 输入样例：
```
3 20
18 15 10
75 72 45
```
#### 输出样例：
```
94.50
```
## 通过代码
```c++
#include <iostream>
#include <algorithm>
using namespace std;
struct moonCake {double storage, money, price;};
bool cmp(moonCake& a, moonCake& b) {return a.price > b.price;}
int main () {
	int n, m, i;//月饼种类，市场需求，循环变量（压行）
	cin >> n >> m;
	moonCake data[n];
	for (int i = 0; i < n; i++) cin >> data[i].storage;//输入
	for (int i = 0; i < n; i++) {//输入
		cin >> data[i].money;
		data[i].price = data[i].money/data[i].storage;
	}
	sort(data, data + n, cmp);
	double sale = 0, temp;
	for (i = 0; i != n && m; i++, m-= temp) {//每次循环，m减去卖出去的质量
		temp = m < data[i].storage ? m : data[i].storage;
		sale += temp/data[i].storage * data[i].money;
	}
	printf("%.2lf\n", sale);
	return 0;
}
```
## 思路与注意
1.  贪心算法，在限制出售的总质量一定时，卖出的货物的`平均单价`越大，利润越高，即尽量多卖出`存量/总售价`大的月饼
2.  输入数据，计算出单价（`存量/总售价`），根据单价降序排序
3.  卖月饼，尽量多的买，如果存量小于等于m，则全部卖出，如果存量大于m，就卖出m，即卖出m与存量的最最小值
4.  计算售价，加起来
5.  输出
6.  注意：把数据全改成double，也许是int会溢出
## 反思与评价
-   这题挺好
-   刚开始还想暴力求解，还TMD写不出来n个for循环嵌套（手动笑哭）
-   原来我学会贪心算法了啊，哈哈哈
-  压行压上瘾了
