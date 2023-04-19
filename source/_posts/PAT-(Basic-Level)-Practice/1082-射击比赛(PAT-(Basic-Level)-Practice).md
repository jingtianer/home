---
title: PAT-Basic-1082
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---



## 题目

> 本题目给出的射击比赛的规则非常简单，谁打的弹洞距离靶心最近，谁就是冠军；谁差得最远，谁就是菜鸟。本题给出一系列弹洞的平面坐标(x,y)，请你编写程序找出冠军和菜鸟。我们假设靶心在原点(0,0)。

#### 输入格式：

> 输入在第一行中给出一个正整数 N（≤ 10 000）。随后 N 行，每行按下列格式给出：

```
ID x y
```

> 其中 `ID` 是运动员的编号（由 4 位数字组成）；`x` 和 `y` 是其打出的弹洞的平面坐标(`x`,`y`)，均为整数，且 0 ≤ |`x`|, |`y`| ≤ 100。题目保证每个运动员的编号不重复，且每人只打 1 枪。

#### 输出格式：

> 输出冠军和菜鸟的编号，中间空 1 格。题目保证他们是唯一的。

#### 输入样例：

```
3
0001 5 7
1020 -1 3
0233 0 -1
```

#### 输出样例：

```
0233 0001
```

## 通过代码

```c++
#include <iostream>
#include <algorithm>
#include <cmath>
using namespace std;
struct shoot { int id; double x; double y; double len; };
bool cmp(shoot& a, shoot& b) {
    return a.len < b.len;
}
int main () {
    int n;
    cin >> n;
    shoot v[n];
    for (int i = 0; i < n; i++) {
        cin >> v[i].id >> v[i].x >> v[i].y;
        v[i].len = sqrt(v[i].x * v[i].x + v[i].y * v[i].y);
    }
    sort(v, v + n, cmp);
    printf ("%04d %04d\n", v[0].id, v[n - 1].id);
    return 0;
}
```

## 思路与注意

1.  没有难度
    

## 反思与评价

-   没有难度
    

## 附（刚学C一个月时写的代码）（当时结构体都不会）

```c++
#include <stdio.h>
#include <math.h>
#include <algorithm> 

bool find_max (double, double *, int);
bool find_min (double, double *, int);

int main () {
	int n;
	scanf ("%d", &n);
	int num[n] = {0};
	double x = 0;
	double y = 0;
	double distance[n] = {0};
	for (int i = 0; i < n; i++) {
		scanf ("%d%lf%lf", &num[i], &x, &y);
		distance[i] = sqrt(x*x+ y*y);
	}
	//std::sort(distance, distance+n);
	int max_n = 0, min_n = 0;
	for (int i = 0; i < n; i++) {
		if (find_max(distance[i], distance, n)) {
			max_n = i;
		}
		if (find_min(distance[i], distance, n)) {
			min_n = i;
		}
	}
	
	printf ("%04d %04d", num[min_n], num[max_n]);
	
	return 0;
}

bool find_max (double a, double * arr, int len) {
	for (int i = 0; i < len; i++) {
		if (a >= arr[i]) {
			if (i == len - 1) {
				return true;
			}
		} else {
			break;
		}
	}
	return false;
}

bool find_min (double a, double * arr, int len) {
	
	for (int i = 0; i < len; i++) {
		if (a <= arr[i]) {
			if (i == len - 1) {
				return true;
			}
		} else {
			break;
		}
	}
	return false;
}
```
