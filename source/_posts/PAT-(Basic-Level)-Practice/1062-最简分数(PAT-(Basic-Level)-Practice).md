---
title: PAT-Basic-1062
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> 一个分数一般写成两个整数相除的形式：N/M，其中 M 不为0。最简分数是指分子和分母没有公约数的分数表示形式。

> 现给定两个不相等的正分数 N1/M1 和 N2/M2，要求你按从小到大的顺序列出它们之间分母为 K 的最简分数。

#### 输入格式：

> 输入在一行中按 N/M 的格式给出两个正分数，随后是一个正整数分母 K，其间以空格分隔。题目保证给出的所有整数都不超过 1000。

#### 输出格式：

> 在一行中按 N/M 的格式列出两个给定分数之间分母为 K 的所有最简分数，按从小到大的顺序，其间以 1 个空格分隔。行首尾不得有多余空格。题目保证至少有 1 个输出。

#### 输入样例：

```
7/18 13/20 12
```

#### 输出样例：

```
5/12 7/12
```

## 通过代码
```c++
#include <iostream>
using namespace std;
typedef long long ll;
class Main {
private:
	ll ans1, ans2, pos;
public:
	Main(ll a, ll b) { set(a, b); }
	void set(ll a, ll b) {
		pos = 1; ans1 = a; ans2 = b;
		if (a < 0) { ans1 *= -1; pos *= -1; }
		if (b < 0) { ans2 *= -1; pos *= -1; }
	}
	void getSmall() {
		ll ta = ans1, tb = ans2;
		while (tb != 0) {
			ll temp = ta % tb;
			ta = tb;
			tb = temp;
		}
		ans1 /= ta;  ans2 /= ta;
	}
	static void swap(Main& a, Main& b) {Main temp = a; a = b; b = temp; }
	static void add(Main* a, Main* b, Main* ans) {
		ll ans1 = a->ans1 * b->ans2 * a->pos + a->ans2 * b->ans1 * b->pos;
		ll ans2 = a->ans2 * b->ans2;
		ans->set(ans1, ans2);
		ans->getSmall();
	}
	double toDouble() { return 1.0 * pos * ans1 / ans2; }
	ll getSon() { return ans1; }
	ll getMother() { return ans2; }
};
int main() {
	ll a1, a2, b1, b2, n;
	scanf("%lld/%lld %lld/%lld %lld", &a1, &a2, &b1, &b2, &n);
	Main x(a1, a2), y(b1, b2), ans(1, n), one(1, n);
	if (x.toDouble() > y.toDouble()) Main::swap(x, y);
	int count = 0;
	while (1) {
		if (ans.toDouble() > x.toDouble() && ans.toDouble() < y.toDouble()) {
			if (ans.getMother() == n) {
				if (count++ == 0) cout << ans.getSon() << "/" << n;
				else cout << " " << ans.getSon() << "/" << n;
			}
		} else if (ans.toDouble() > y.toDouble()) { break; }
		Main::add(&ans, &one, &ans);
	}
	return 0;
}
```
## 思路与注意

-   copy并精简上一次写的分数处理类（传送门[PAT乙级题--1034 有理数四则运算](https://www.jianshu.com/p/908d4b23b1c9)）
`1.  添加了转换成double（toDouble()）函数`
`2.   得到分子分母（getSon(), getMother()）函数 `
`3.   交换值的（swap()）函数。`
`4.   输入后，保证`x` <= `y` `
-   得到K(我的代码中的n)，构造两个分数`1/n`，然后循环相加
-   如果数在前两个数之间（注意为开区间，不包括区间的端点），并且分母为n(每次运算后就约分一次，只挑约分后分母还是n的)，则按照要求输出。
## 反思与评价
-   代码积累很重要
