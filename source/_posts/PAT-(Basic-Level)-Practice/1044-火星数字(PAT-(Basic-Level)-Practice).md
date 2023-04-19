---
title: PAT-Basic-1044
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> 火星人是以 13 进制计数的：
> 
> -   地球人的 0 被火星人称为 tret。
>     
> -   地球人数字 1 到 12 的火星文分别为：jan, feb, mar, apr, may, jun, jly, aug, sep, oct, nov, dec。
>     
> -   火星人将进位以后的 12 个高位数字分别称为：tam, hel, maa, huh, tou, kes, hei, elo, syy, lok, mer, jou。
>     
> 
> 例如地球人的数字 `29` 翻译成火星文就是 `hel mar`；而火星文 `elo nov` 对应地球数字 `115`。为了方便交流，请你编写程序实现地球和火星数字之间的互译。

#### 输入格式：

> 输入第一行给出一个正整数 N（<100），随后 N 行，每行给出一个 [0, 169) 区间内的数字 —— 或者是地球文，或者是火星文。

#### 输出格式：

> 对应输入的每一行，在一行中输出翻译后的另一种语言的数字。

#### 输入样例：

```
4
29
5
elo nov
tam
```

#### 输出样例：

```
hel mar
may
115
13
```

## 通过代码
```c++
#include <iostream>
#include <ctype.h>
using namespace std;
string num[2][13] = {
	{"tret", "jan", "feb", "mar", "apr", "may", "jun", "jly", "aug", "sep", "oct", "nov", "dec"},
	{"tret", "tam", "hel", "maa", "huh", "tou", "kes", "hei", "elo", "syy", "lok", "mer", "jou"}
};
void C(string& str) {
	int n = atoi(str.data());
	string ans;
	int count = 0;
	for (int tn = n; tn; tn /= 13, count++);
	if (count == 1 || count == 0) ans = num[0][n];
	else ans = num[1][n / 13] + ((n % 13 != 0) ? (" " + num[0][n % 13]) : "");
	cout << ans << endl;
}
int D(string& str) {
	if (str == "tret") return 0;
	string a, b;
	a = str.substr(0, 3);
	if (str.length() > 3) b = str.substr(4, str.length() - 3);
	if (b == "") {
		for (int i = 0; i < 13; i++)
			if (a == num[0][i]) return i;
		for (int i = 0; i < 13; i++)
			if (a == num[1][i]) return i * 13;
	} else {
		int n = 0;
		for (int i = 0; i < 13; i++)
			if (a == num[1][i]) n += i * 13;
		for (int i = 0; i < 13; i++)
			if (b == num[0][i])  n += i;
		return n;
	}
}
int main() {
	int n;
	cin >> n;
	getchar();
	for (int i = 0; i < n; i++) {
		string temp;
		getline(cin, temp);
		if (!isalpha(temp[0])) C(temp);
		else cout << D(temp) << endl;
	}
	return 0;
}
```
## 思路与注意

1.  13, 26, 39...转换为13进制后，`tret`不输出
    
2.  题目说数是属于[0,169)的，所以翻译以后最多有两位。根据这个性质，只算两位就好。
