---
title: PAT-Basic-1048
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目
>本题要求实现一种数字加密方法。首先固定一个加密用正整数 A，对任一正整数 B，将其每 1 位数字与 A 的对应位置上的数字进行以下运算：

>对奇数位，对应位的数字相加后对 13 取余——这里用 J 代表 10、Q 代表 11、K 代表 12；对偶数位，用 B 的数字减去 A 的数字，若结果为负数，则再加 10。这里令个位为第 1 位。
#### 输入格式：
>输入在一行中依次给出 A 和 B，均为不超过 100 位的正整数，其间以空格分隔。
#### 输出格式：
>在一行中输出加密后的结果。
#### 输入样例：
	1234567 368782971
#### 输出样例：
	3695Q8118
## 通过代码
```java
import java.util.*;

public class Main {
	static Scanner sc;
	static { sc = new Scanner(System.in); } 
	static int max(int a, int b) { return a > b ? a : b; } 
	public static void main(String[] args) {
		// code here
		String in = sc.nextLine();
		StringBuffer a = new StringBuffer(in.substring(0, in.indexOf(' ')));
		StringBuffer b = new StringBuffer(in.substring(in.indexOf(' ') + 1, in.length()));
		StringBuffer ans = new StringBuffer();
        //字符和数字互转
		char[] num = new char[13];
		for (int i = 0; i < 10; i++) { num[i] = (char) (i + '0'); }
		num[10] = 'J'; num[11] = 'Q'; num[12] = 'K';
		int[] Char = new int[128];
		for (char i = '0'; i <= '9'; i++) {Char[i] = i - '0';}
		Char['J'] = 10;Char['Q'] = 11;Char['K'] = 12;

		int len = max(a.length(), b.length());
		StringBuffer temp = new StringBuffer();
		for (int i = 0; i < len - a.length(); i++) { temp.append('0'); }
		a.insert(0, temp.toString());
		temp = new StringBuffer();
		for (int i = 0; i < len - b.length(); i++) { temp.append('0'); }
		b.insert(0, temp.toString());

		int cmp = len % 2;
		for (int i = 0; i < len; i++) {
			char x;
			if ((i + 1) % 2 == cmp) {
				x = num[(Char[a.charAt(i)] + Char[b.charAt(i)]) % 13];
				ans.append(x);
			} else {
				int n = (Char[b.charAt(i)] - Char[a.charAt(i)]);
				x = num[n >= 0 ? n : n + 10];
				ans.append(x);
			}
		}
		System.out.println(ans);
	}
}
```
## 反思与评价
### 反思
&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;这道题是用Java写的，总体来说没有什么难度，但是题目中规定各位为第一位，我直接用for从0开始循环判断(i+1)的奇偶性，这就导致最长位数如果是奇数，那么个位就是奇数位，反之则为偶数位。
&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;为了解决这个缺陷，考虑到如果最长位数为偶数，操作跟原来互换就好，就要把0变成1，1变成0，所以我定义了一个整型cmp，它的值为len%2，这样就解决了。
### 评价
&#160;&#160;&#160;&#160;题目简单，没什么好说的，但是代码看起来还是太复杂。
