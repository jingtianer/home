---
title: PAT-Basic-1084
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---



## 题目

> 外观数列是指具有以下特点的整数序列：

```
d, d1, d111, d113, d11231, d112213111, ...
```

> 它从不等于 1 的数字 `d` 开始，序列的第 n+1 项是对第 n 项的描述。比如第 2 项表示第 1 项有 1 个 `d`，所以就是 `d1`；第 2 项是 1 个 `d`（对应 `d1`）和 1 个 1（对应 11），所以第 3 项就是 `d111`。又比如第 4 项是 `d113`，其描述就是 1 个 `d`，2 个 1，1 个 3，所以下一项就是 `d11231`。当然这个定义对 `d` = 1 也成立。本题要求你推算任意给定数字 `d` 的外观数列的第 N 项。

#### 输入格式：

> 输入第一行给出 [0,9] 范围内的一个整数 `d`、以及一个正整数 N（≤ 40），用空格分隔。

#### 输出格式：

> 在一行中给出数字 `d` 的外观数列的第 N 项。

#### 输入样例：

```
1 8
```

#### 输出样例：

```
1123123111
```

## 通过代码

```cpp
#include <iostream>
using namespace std;
void add(string& str, char c, int& n) {
	char toNum[1024] = {0};
	str.append(&c, 1);//这样可以“骗”append函数c是只有一个字符的字符串
	sprintf(toNum, "%d", n);
	str.append(toNum);
	n = 0;
}
int main () {
	string d;
	int n;
	cin >> d >> n;
	string& temp = d;//建立一个对字符串的引用，循环的时候可以避免拷贝
	for (int i = 0, count = 1; i < n - 1; i++, count = 1) {
		string next = "";
		for (int j = 1; j < temp.length(); j++, count++)
			if (temp[j - 1] != temp[j])
				add(next, temp[j - 1], count);
		add(next, temp[temp.length() - 1], count);
		temp = next;
	}
	cout << temp << endl;
	return 0;
}
```

## 思路和注意

-   读懂题很关键`第n+1项是对第n项的描述`
    
-   就是遍历前一项，数出连续的某个字符`c`有几个，然后自己就变成了`c` + `c的个数`
    
-   这道题的核心算法和[PAT乙级题--1078 字符串压缩与解压](https://www.jianshu.com/p/3c197355fecf)的压缩部分的算法类似
