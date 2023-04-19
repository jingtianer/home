---
title: PAT-Basic-1055
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> 拍集体照时队形很重要，这里对给定的 N 个人 K 排的队形设计排队规则如下：
> 
> -   每排人数为 N/K（向下取整），多出来的人全部站在最后一排；
>     
> -   后排所有人的个子都不比前排任何人矮；
>     
> -   每排中最高者站中间（中间位置为 m/2+1，其中 m 为该排人数，除法向下取整）；
>     
> -   每排其他人以中间人为轴，按身高非增序，先右后左交替入队站在中间人的两侧（例如5人身高为190、188、186、175、170，则队形为175、188、190、186、170。这里假设你面对拍照者，所以你的左边是中间人的右边）；
>     
> -   若多人身高相同，则按名字的字典序升序排列。这里保证无重名。
>     

> 现给定一组拍照人，请编写程序输出他们的队形。

#### 输入格式：

> 每个输入包含 1 个测试用例。每个测试用例第 1 行给出两个正整数 N（≤104，总人数）和 K（≤10，总排数）。随后 N 行，每行给出一个人的名字（不包含空格、长度不超过 8 个英文字母）和身高（[30, 300] 区间内的整数）。

#### 输出格式：

> 输出拍照的队形。即K排人名，其间以空格分隔，行末不得有多余空格。注意：假设你面对拍照者，后排的人输出在上方，前排输出在下方。

#### 输入样例：

```
10 3
Tom 188
Mike 170
Eva 168
Tim 160
Joe 190
Ann 168
Bob 175
Nick 186
Amy 160
John 159
```

#### 输出样例：

```
Bob Tom Joe Nick
Ann Mike Eva
Tim Amy John
```

## 通过代码
```c++
#include <iostream>
#include <algorithm>
using namespace std;
struct data { string name; int hight; };
bool cmp(data& a, data& b) {
	if (a.hight != b.hight) return a.hight > b.hight;
	else return a.name < b.name;
}
int main () {
	int n, k;
	cin >> n >> k;
	int cmin = n / k;
	int cmax = n % k + cmin;
	data arr[k][cmax], in[n];
	for (int i = 0; i < n; i++) {
		cin >> in[i].name >> in[i].hight;
	}
	sort(in, in + n, cmp);
	int i = 0, c = cmax;
	for (int K = 0; K < k; K++) {
		arr[K][c / 2] = in[i++];
		for (int j = 0; j < c / 2; j++) {
			if (c / 2 - j - 1 >= 0) arr[K][c / 2 - j - 1] = in[i++];
			if (c / 2 + j + 1 < c) arr[K][c / 2 + j + 1] = in[i++];
		}
		c = cmin;
	}
	c = cmax;
	for (int i = 0; i < k; i++) {
		cout << arr[i][0].name;
		for (int j = 1; j < c; j++) cout << " " << arr[i][j].name;
		cout << endl;
		c = cmin;
	}
}
```
## 思路与注意

1.  输入，排序（按身高降序，身高一样按名字的ASCII值升序）
    
2.  计算每排人数`cmin`，最后一排人数`cmax`。然后往里面存。
    
3.  存和输出时，最后一排和其他排人数不一样，所以令列数`c = cmax`，每次循环完令`c = cmin`
    
4. 由于把最后一排和其他排都统一起来考虑，所以每次存的时候要判断下标有没有越界

## 反思与评价

-   开心，题目越做越顺手
