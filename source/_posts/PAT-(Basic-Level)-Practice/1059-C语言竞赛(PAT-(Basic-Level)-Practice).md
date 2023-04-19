---
title: PAT-Basic-1059
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> C 语言竞赛是浙江大学计算机学院主持的一个欢乐的竞赛。既然竞赛主旨是为了好玩，颁奖规则也就制定得很滑稽：
> 
> -   0、冠军将赢得一份“神秘大奖”（比如很巨大的一本学生研究论文集……）。
>     
> -   1、排名为素数的学生将赢得最好的奖品 —— 小黄人玩偶！
>     
> -   2、其他人将得到巧克力。
>     

> 给定比赛的最终排名以及一系列参赛者的 ID，你要给出这些参赛者应该获得的奖品。

#### 输入格式：

> 输入第一行给出一个正整数 N（≤104），是参赛者人数。随后 N 行给出最终排名，每行按排名顺序给出一位参赛者的 ID（4 位数字组成）。接下来给出一个正整数 K 以及 K 个需要查询的 ID。

#### 输出格式：

> 对每个要查询的 ID，在一行中输出 `ID: 奖品`，其中奖品或者是 `Mystery Award`（神秘大奖）、或者是 `Minion`（小黄人）、或者是 `Chocolate`（巧克力）。如果所查 ID 根本不在排名里，打印 `Are you kidding?`（耍我呢？）。如果该 ID 已经查过了（即奖品已经领过了），打印 `ID: Checked`（不能多吃多占）。

#### 输入样例：

```
6
1111
6666
8888
1234
5555
0001
6
8888
0001
1111
2222
8888
2222
```

#### 输出样例：

```
8888: Minion
0001: Chocolate
1111: Mystery Award
2222: Are you kidding?
8888: Checked
2222: Are you kidding?
```

## 通过代码

```cpp
#include <iostream>
using namespace std;

int prime[10005] = {0, 1, 2, 2, 3};

void get_prime() {
	for (int i = 5; i < 10005; i++) {
		prime[i] = 2;
		for (int j = 2; j * j <= i; j++) {
			if (i % j == 0) {
				prime[i] = 3;
				break;
			}
		}
	}
}

int main() {
	get_prime();
	int rank[10005] = {0};
	string str[4] = {"Are you kidding?", "Mystery Award", "Minion", "Chocolate"};
	string checked = "Checked";
	int has[10005] = {0};
	int n, id;
	cin >> n;
	for (int i = 0; i < n; i++) {
		cin >> id;
		rank[id] = i + 1;
	}
	cin >> n;
	for (int i = 0; i < n; i++) {
		cin >> id;
		int RANK = rank[id], HAS = has[id];
		if (!HAS || RANK == 0) {
			printf ("%04d: %s\n", id, str[prime[RANK]].data());
			has[id] = 1;
		} else {
			printf ("%04d: %s\n", id, checked.data());
		}
	}
	return 0;
}
```

## 思路与注意

1.  先把需要输出的字符串存起来，分别为0，1，2，3
    
2.  根据题意，搞一个数组，如果是0，1，则值为0，1，其他数如果是素数为2（对应million），不是素数为3，对应chocolate
    
3.  再搞一个数组，以编号为引索，记录排名
    
4.  搞一个has数组，记录是否输出过
    

## 反思与评价

-   这道题挺简单的
- 通过打表记录是否为素数，可以减少计算次数
