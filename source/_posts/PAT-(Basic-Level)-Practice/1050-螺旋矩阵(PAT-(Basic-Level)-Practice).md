---
title: PAT-Basic-1050
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目
> 本题要求将给定的 N 个正整数按非递增的顺序，填入“螺旋矩阵”。所谓“螺旋矩阵”，是指从左上角第 1 个格子开始，按顺时针螺旋方向填充。要求矩阵的规模为 m 行 n 列，满足条件：m×n 等于 N；m≥n；且 m−n 取所有可能值中的最小值。

#### 输入格式：

> 输入在第 1 行中给出一个正整数 N，第 2 行给出 N 个待填充的正整数。所有数字不超过 104，相邻数字以空格分隔。

#### 输出格式：

> 输出螺旋矩阵。每行 n 个数字，共 m 行。相邻数字以 1 个空格分隔，行末不得有多余空格。

#### 输入样例：

```
12
37 76 20 98 76 42 53 95 60 81 58 93
```

#### 输出样例：

```
98 95 93
42 37 81
53 20 76
58 60 76
```
## 通过代码
```c++
#include <iostream>
#include <cmath>
#include <vector>
#include <algorithm>

using namespace std;

void get_mn(int* m, int* n, int N) {
	int i = 0;
	do {
		*n = sqrt(N) - i;
		*m = N / (*n);
		i++;
	} while ((*m) * (*n) != N);
}

int main() {
	int n;
	int t;
	vector<int> arr;
	cin >> n;
	for (int i = 0; i < n; i++) {
		cin >> t;
		arr.push_back(t);
	}
	sort(arr.begin(), arr.end());
	int count = n - 1;
	int N, M;
	get_mn(&M, &N, n);
	vector<vector<int> > a;
	vector<int> temp(N);
	for (int i = 0; i < M; i++) {
		a.push_back(temp);
	}
	int i = 0;
	while (count >= 0) {
		for (int j = i; j < N - 1 - i && i < M; j++)//①从下标i开始，直到N - 1 - i
			a[i][j] = arr[count--];
		for (int j = i; j < M - i && i < N; j++)//②从下标i开始，直到M - i
			a[j][N - 1 - i] = arr[count--];
		for (int j = N - 1 - i - 1; j > i - 1 && i < M; j--)//①的倒序
			a[M - 1 - i][j] = arr[count--];
		if (N - 1 - i > i)
			for (int j = M - 1 - i - 1; j > i && i < N; j--)//②的倒序
				a[j][i] = arr[count--];
		i++;
	}
	for (int i = 0; i < M; i++) {
		cout << a[i][0];
		for (int j = 1; j < N; j++) cout << " " << a[i][j];
		cout << endl;
	}
}
```

## 思路与注意

1.  先把数储存，再顺序输出
    
    1.  以一圈为单位，4个循环填好一圈
        
    2.  记录第几圈，以这个数确定每次从哪里开始填数
        
2.  最后要判断( N - 1 - i > i )
    
3.  计算MN时要注意(n/N)*N 不一定等于 n
    

## 反思与评价

-   一直没有考虑到判断( N - 1 - i > i )
    
-   计算MN的时候想的太简单
