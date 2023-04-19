---
title: PAT-Basic-1060
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> 英国天文学家爱丁顿很喜欢骑车。据说他为了炫耀自己的骑车功力，还定义了一个“爱丁顿数” E ，即满足有 E 天骑车超过 E 英里的最大整数 E。据说爱丁顿自己的 E 等于87。

> 现给定某人 N 天的骑车距离，请你算出对应的爱丁顿数 E（≤N）。

#### 输入格式：

> 输入第一行给出一个正整数 N (≤105)，即连续骑车的天数；第二行给出 N 个非负整数，代表每天的骑车距离。

#### 输出格式：

> 在一行中给出 N 天的爱丁顿数。

#### 输入样例：

```
10
6 7 6 9 3 10 8 2 7 8
```

#### 输出样例：

```
6
```

## 通过代码

```cpp
#include <iostream>
#include <algorithm>
using namespace std;
int num[1001000];
int main() {
	int n;
	cin >> n;
	for (int i = 0; i < n; i++) {
		cin >> num[i];
	}
	sort(num, num + n, greater<int>());
	for (int i = 0; i < n; i++) {
		if (i + 1 >= num[i] - 1) {
			cout << num[i] - 1 << endl;
			break;
		}
	}
	return 0;
}
```

## 思路与注意

1.  不能两层循环求出所有值再倒叙找满足的值，会超时
    
2.  先排序，对于输入样例有：
```
10 9 8 8 7 7 6 6 3 2
```

3.  通过观察可知
    
    1.  第1个数代表有1天超过(10-1)
        
    2.  第2个数代表有2天超过(9-1)
        
    3.  第3个数代表有3天超过(8-1)
        
    4.  第4个数代表有4天超过(8-1)
        
    5.  第5个数代表有5天超过(7-1)
        
    6.  第6个数代表有6天超过(7-1)
        
    7.  所以答案为6
        
4.  根据以上方法模拟即可
    

## 反思与评价

-   这题挺好
