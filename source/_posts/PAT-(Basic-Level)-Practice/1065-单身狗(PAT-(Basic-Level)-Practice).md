---
title: PAT-Basic-1065
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> “单身狗”是中文对于单身人士的一种爱称。本题请你从上万人的大型派对中找出落单的客人，以便给予特殊关爱。

#### 输入格式：

> 输入第一行给出一个正整数 N（≤ 50 000），是已知夫妻/伴侣的对数；随后 N 行，每行给出一对夫妻/伴侣——为方便起见，每人对应一个 ID 号，为 5 位数字（从 00000 到 99999），ID 间以空格分隔；之后给出一个正整数 M（≤ 10 000），为参加派对的总人数；随后一行给出这 M 位客人的 ID，以空格分隔。题目保证无人重婚或脚踩两条船。

#### 输出格式：

> 首先第一行输出落单客人的总人数；随后第二行按 ID 递增顺序列出落单的客人。ID 间用 1 个空格分隔，行的首尾不得有多余空格。

#### 输入样例：

```
3
11111 22222
33333 44444
55555 66666
7
55555 44444 10000 88888 22222 11111 23333
```

#### 输出样例：

```
5
10000 23333 44444 55555 88888
```

## 通过代码

```c++
#include <iostream>
#include <algorithm>
#include <iomanip>
using namespace std;

struct people {
	int id;
	bool pair;
} c[10100];

bool cmp (people&a, people& b) {
	return a.id < b.id;
}

int p[100100], x, y, n, num;

int main() {
	cin >> n;
	for (int i = 0; i < n; i++) {
		cin >> x >> y;
		p[x] = y;
		p[y] = x;
	}
	cin >> num;
	for (int i = 0; i < num; i++) {
		cin >> c[i].id;
		c[i].pair = false;
	}
	int count = 0;
	for (int i = 0; i < num; i++) {
		for (int j = 0; j < num; j++) {
			if (p[c[i].id] == c[j].id) {
				c[i].pair = true;
				count++;
			}
		}
	}
	cout << num - count << endl;
	sort(c, c + num, cmp);
	int i = 0;
	while (c[i++].pair && i <= num);
	if (i <= num)//这里是i<=num
		cout << setw(5) << setfill('0') << c[i - 1].id; //注意这里是i-1
	for (; i < num; i++) {
		if (!c[i].pair) {
			cout << " " << setw(5) << setfill('0') << c[i].id;
		}
	}
}
```

## 思路与注意

1.  因为给的数很小，所以可以列一个表格，把两个id一个作为值，一个作为引索
    
2.  两层for循环，第一层固定要判断的对象，第二次逐个遍历其他人，比较id
    
3.  输出，注意要五位数输出，不足前面补0
    

## 反思与评价

-   最后输出的条件是i<=num 不是 i<num, 因为我把i++写在了while的括号里面
    
-   输出第一个的时候下标要i-1,因为我把i++写在了while的括号里面
