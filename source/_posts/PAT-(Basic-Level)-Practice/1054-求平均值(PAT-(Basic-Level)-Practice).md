---
title: PAT-Basic-1054
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> 本题的基本要求非常简单：给定 N 个实数，计算它们的平均值。但复杂的是有些输入数据可能是非法的。一个“合法”的输入是 [−1000,1000] 区间内的实数，并且最多精确到小数点后 2 位。当你计算平均值的时候，不能把那些非法的数据算在内。

#### 输入格式：

> 输入第一行给出正整数 N（≤100）。随后一行给出 N 个实数，数字间以一个空格分隔。

#### 输出格式：

> 对每个非法输入，在一行中输出 `ERROR: X is not a legal number`，其中 `X` 是输入。最后在一行中输出结果：`The average of K numbers is Y`，其中 `K` 是合法输入的个数，`Y` 是它们的平均值，精确到小数点后 2 位。如果平均值无法计算，则用 `Undefined` 替换 `Y`。如果 `K` 为 1，则输出 `The average of 1 number is Y`。

#### 输入样例 1：

```
7
5 -3.2 aaa 9999 2.3.4 7.123 2.35
```

#### 输出样例 1：

```
ERROR: aaa is not a legal number
ERROR: 9999 is not a legal number
ERROR: 2.3.4 is not a legal number
ERROR: 7.123 is not a legal number
The average of 3 numbers is 1.38
```

#### 输入样例 2：

```
2
aaa -9999
```

#### 输出样例 2：

```
ERROR: aaa is not a legal number
ERROR: -9999 is not a legal number
The average of 0 numbers is Undefined
```

## 通过代码

```c++
#include <iostream>
#include <cmath>
#include <iomanip>
using namespace std;

bool check(string t, double* x) {
	int dot = -1;
	int dotNum = 0;
	bool ok = true;
	int i = 0;
	if (t[i] == '-')i++;
	for ( ; i < t.length(); i++) {
		if (!(t[i] >= '0' && t[i] <= '9')) {
			if (t[i] == '.') {
				dotNum++;
				if (dotNum == 1) dot = i;
			} else {
				ok = false;
				break;
			}
		}
	}
	if (dotNum > 1) ok = false;
	if (dot != -1 && t.length() - dot - 1 > 2)ok = false;
	if (ok) {
		*x = atof(t.data());
		if (fabs(*x) > 1000) ok = false;
	}
	return ok;
}

int main() {
	int n;
	cin >> n;
	int count = 0;
	double sum = 0;
	string str;
	for (int j = 0; j < n; j++) {
		double StrToNum = 0;
		cin >> str;
		if (check(str, &StrToNum)) {
			sum += StrToNum;
			count++;
		} else { cout << "ERROR: " << str << " is not a legal number" << endl; }
	}

	if (count == 1) {
		cout << "The average of " << count << " number is " << fixed << setprecision(2) << sum / count << endl;
	} else if (count == 0) {
		cout << "The average of 0 numbers is Undefined" << endl;
	} else {
		cout << "The average of " << count << " numbers is " << fixed << setprecision(2) << sum / count << endl;
	}
}
```

## 思路与注意

1.  判断输入是否符合题目要求
    
2.  利用成员函数data()把string转为char*， 再利用atof()转化为实数
    
3.  统计并计算
    

## 反思与评价

-   没有考虑没有小数点的时候，不用计算小数点位数，一直错。
