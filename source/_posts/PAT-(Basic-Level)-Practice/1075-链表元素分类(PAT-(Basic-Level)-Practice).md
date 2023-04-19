---
title: PAT-Basic-1075
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> 给定一个单链表，请编写程序将链表元素进行分类排列，使得所有负值元素都排在非负值元素的前面，而 [0, K] 区间内的元素都排在大于 K 的元素前面。但每一类内部元素的顺序是不能改变的。例如：给定链表为 18→7→-4→0→5→-6→10→11→-2，K 为 10，则输出应该为 -4→-6→-2→7→0→5→10→18→11。

#### 输入格式：

> 每个输入包含一个测试用例。每个测试用例第 1 行给出：第 1 个结点的地址；结点总个数，即正整数N (≤105)；以及正整数K (≤103)。结点的地址是 5 位非负整数，NULL 地址用 −1 表示。

> 接下来有 N 行，每行格式为：

```
Address Data Next
```

> 其中 `Address` 是结点地址；`Data` 是该结点保存的数据，为 [−105,105] 区间内的整数；`Next` 是下一结点的地址。题目保证给出的链表不为空。

#### 输出格式：

> 对每个测试用例，按链表从头到尾的顺序输出重排后的结果链表，其上每个结点占一行，格式与输入相同。

#### 输入样例：

```
00100 9 10
23333 10 27777
00000 0 99999
00100 18 12309
68237 -6 23333
33218 -4 00000
48652 -2 -1
99999 5 68237
27777 11 48652
12309 7 33218
```

#### 输出样例：

```
33218 -4 68237
68237 -6 48652
48652 -2 12309
12309 7 00000
00000 0 99999
99999 5 23333
23333 10 00100
00100 18 27777
27777 11 -1
```

## 通过代码

```cpp
#include <iostream>

using namespace std;

struct node {
	int add;
	int next;
	int data;
};

int first, num, k;
node v[100005];
node x[100005];
node a[100005], b[100005], c[100005];
void print(node* m, int size) {
	for (int i = 0; i < size - 1; i++)
		printf ("%05d %d %05d\n", m[i].add, m[i].data, m[i + 1].add);
	printf ("%05d %d -1\n", m[size - 1].add, m[size - 1].data);
}

int get() {
	scanf ("%d%d%d", &first, &num, &k);
	node temp;
	for (int i = 0; i < num; i++) {
		scanf ("%d%d%d", &temp.add, &temp.data, &temp.next);
		v[temp.add] = temp;
	}
	int find = first;
	int c = 0;
	while (find != -1) {
		x[c++] = (v[find]);
		find = v[find].next;
	}
	return c;
}

int main () {
	int real = get();
	int an = 0, bn = 0, cn = 0;
	for (int i = 0; i < real; i++) {
		if (x[i].data < 0)  a[an++] = (x[i]);
		else if (x[i].data > k)  c[cn++] = (x[i]);
		else  b[bn++] = (x[i]);
	}
	int count = 0;
	for (int i = 0; i < an; i++) x[count++] = a[i];
	for (int i = 0; i < bn; i++) x[count++] = b[i];
	for (int i = 0; i < cn; i++) x[count++] = c[i];
	print(x, real);
	return 0;
}
```

## 思路与注意

1.  输入数据（由于后面要还原链表，为了降低复杂度，把addr当做引索）
    
2.  把链表先还原，同时返回还原后的节点个数（因为有可能某些节点不在链表上）
    
3.  分类统计，最后再重新排回去
    
4.  输出（输出的时候最好把它变成一个整体，不要分块输出（可能存在某一部分空的情况））
    

## 反思与评价

-   这道题就是改了改反转链表
    
-   思想实际上是德才论和反转链表的综合，简单题
    
-   反转链表用vector可以过，但是这个题用vector就会段错误，所以用普通数组
