---
title: PAT-Basic-1079
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> 给定一个 k+1 位的正整数 N，写成 ak⋯a1a0 的形式，其中对所有 i 有 0≤ai<10 且 ak>0。N 被称为一个**回文数**，当且仅当对所有 i 有 ai=ak−i。零也被定义为一个回文数。

> 非回文数也可以通过一系列操作变出回文数。首先将该数字逆转，再将逆转数与该数相加，如果和还不是一个回文数，就重复这个逆转再相加的操作，直到一个回文数出现。如果一个非回文数可以变出回文数，就称这个数为**延迟的回文数**。（定义翻译自 [https://en.wikipedia.org/wiki/Palindromic_number](https://en.wikipedia.org/wiki/Palindromic_number) ）

> 给定任意一个正整数，本题要求你找到其变出的那个回文数。

#### 输入格式：

> 输入在一行中给出一个不超过1000位的正整数。

#### 输出格式：

> 对给定的整数，一行一行输出其变出回文数的过程。每行格式如下

```
A + B = C
```

> 其中 `A` 是原始的数字，`B` 是 `A` 的逆转数，`C` 是它们的和。`A` 从输入的整数开始。重复操作直到 `C` 在 10 步以内变成回文数，这时在一行中输出 `C is a palindromic number.`；或者如果 10 步都没能得到回文数，最后就在一行中输出 `Not found in 10 iterations.`。

#### 输入样例 1：

```
97152
```

#### 输出样例 1：

```
97152 + 25179 = 122331
122331 + 133221 = 255552
255552 is a palindromic number.
```

### 输入样例 2：

```
196
```

#### 输出样例 2：

```
196 + 691 = 887
887 + 788 = 1675
1675 + 5761 = 7436
7436 + 6347 = 13783
13783 + 38731 = 52514
52514 + 41525 = 94039
94039 + 93049 = 187088
187088 + 880781 = 1067869
1067869 + 9687601 = 10755470
10755470 + 07455701 = 18211171
Not found in 10 iterations.
```

## 通过代码

```java
import java.util.*;
import java.math.*;
class Main {
	static BigInteger getReverseNum(BigInteger a) {
		StringBuffer bf = new StringBuffer(a.toString());
		bf.reverse();
		BigInteger b = new BigInteger(bf.toString());
		return b;
	}
	static boolean isPalindromicNumber(BigInteger a) {
		String n = a.toString();
		int len = n.length();
		for (int i = 0; i < len / 2; i++)
			if (n.charAt(i) != n.charAt(len - i - 1)) return false;
		return true;
	}
	public static void main (String[] args) {
		Scanner sc = new Scanner(System.in);
		boolean ok = false;
		BigInteger a = sc.nextBigInteger();
		for (int i = 0; i < 10; i++) {
			if (isPalindromicNumber(a)) {
				System.out.println(a + " is a palindromic number.");
				ok = true;
				break;
			}
			BigInteger b = getReverseNum(a);
			BigInteger c = a.add(b);
			System.out.println(a + " + " + b + " = " + c);
			a = c;
		}
		if (!ok) System.out.println("Not found in 10 iterations.");
	}
}
```

## 思路与注意

1.  题目中说是1000位的整数，所以一般的long解决不了，要用到java.math.*;中的BigInteger类
    
2.  根据题目要求计算就好
    
3.  要在10步内出结果，适合用for循环
    
4.  循环的时候要先判断是否为`Palindromic Number`，有可能输入的第一个数就是`Palindromic Number`。
    

## 反思与评价

-   选择语言很重要，Java提供的BigInteger完美解决
    
-   c++写的话可以在网上找一份大整型的模板来用
