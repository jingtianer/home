---
title: PAT-Basic-1040
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> 字符串 `APPAPT` 中包含了两个单词 `PAT`，其中第一个 `PAT` 是第 2 位(`P`)，第 4 位(`A`)，第 6 位(`T`)；第二个 `PAT` 是第 3 位(`P`)，第 4 位(`A`)，第 6 位(`T`)。

> 现给定字符串，问一共可以形成多少个 `PAT`？

#### 输入格式：

> 输入只有一行，包含一个字符串，长度不超过105，只包含 `P`、`A`、`T` 三种字母。

#### 输出格式：

> 在一行中输出给定字符串中包含多少个 `PAT`。由于结果可能比较大，只输出对 1000000007 取余数的结果。

#### 输入样例：

```
APPAPT
```

#### 输出样例：

```
2
```

## 通过代码
```c
#include <stdio.h>
#include <string.h>
int main() {
	char n[100100] = {0};
	scanf("%s", n);
	int len = strlen(n);
	long long pat = 0, at = 0, t = 0;
	for (int i = len - 1; i >= 0; i--) {
		if (n[i] == 'T') t++;
		if (n[i] == 'A') at = (at + t) % 1000000007;
		if (n[i] == 'P') pat = (pat + at) % 1000000007;
	}
	printf("%lld\n", pat % 1000000007);
}
```
## 思路与注意

1.  题目限制150ms，应该只有O(N)的算法才可以
    
2.  没思路
    
3.  [有几个PAT（25）](https://blog.csdn.net/qq_39304201/article/details/79481662)看这里
    

## 反思与评价

-   这题挺好
    
-   这道题没思路，看题目要求150ms就知道这题用O(N)的方法才行，果断问度娘找了思路。[有几个PAT（25）](https://blog.csdn.net/qq_39304201/article/details/79481662)
    
-   可能是自己脑子不够用吧
