---
title: PAT-Basic-1088
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目
>子曰：“三人行，必有我师焉。择其善者而从之，其不善者而改之。”

>本题给定甲、乙、丙三个人的能力值关系为：甲的能力值确定是 2 位正整数；把甲的能力值的 2 个数字调换位置就是乙的能力值；甲乙两人能力差是丙的能力值的 X 倍；乙的能力值是丙的 Y 倍。请你指出谁比你强应“从之”，谁比你弱应“改之”。
### 输入格式：
>输入在一行中给出三个数，依次为：M（你自己的能力值）、X 和 Y。三个数字均为不超过 1000 的正整数。
### 输出格式：
>在一行中首先输出甲的能力值，随后依次输出甲、乙、丙三人与你的关系：如果其比你强，输出 Cong；平等则输出 Ping；比你弱则输出 Gai。其间以 1 个空格分隔，行首尾不得有多余空格。

    注意：如果解不唯一，则以甲的最大解为准进行判断；如果解不存在，则输出 No Solution。

#### 输入样例 1：
    48 3 7
#### 输出样例 1：
    48 Ping Cong Gai
#### 输入样例 2：
    48 11 6
#### 输出样例 2：
    No Solution

```java
import java.util.*;

class Main {
	static Scanner sc;
	static {
		sc = new Scanner(System.in);
	}

	static String print(double a, double b) {
		if (a < b) {
			return "Cong";
		} else if (a == b) {
			return "Ping";
		} else {
			return "Gai";
		}
	}

	public static void main(String[] args) {
		int m = sc.nextInt();
		int x = sc.nextInt();
		int y = sc.nextInt();
		boolean find = false;
		for (int a = 99; a >= 10; a--) {
			double b = a % 10 * 10 + a / 10;
			double c = b / y;
			if (c != Math.abs((a - b) / x)) {
				continue;
			} else {
				find = true;
				System.out.print(a + " " + Main.print(m, a) + " " + Main.print(m, b) + " " + Main.print(m, c));
				break;
			}
		}
		if (!find) {
			System.out.println("No Solution");
		}
	}
}

/*
 * a b c 
 * c/x = a-b 
 * c/y = b 
 * c(1/x+1/y) = a
 * 
 */
```
## 思路与注意
1. abc三个变量代表甲乙丙，由于a已知是两位数，且需要解中甲最大的情况，所以就for循环从99到10

2. 注意b，c要的是精确值，不是整型取商的结果

## 反思与评价
### 反思
&#160; &#160; &#160; &#160;好像是一遍过的吧？
### 评价
&#160; &#160; &#160; &#160;无
