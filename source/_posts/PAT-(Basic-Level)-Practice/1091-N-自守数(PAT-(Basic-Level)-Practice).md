---
title: PAT-Basic-1091
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目
>如果某个数 K 的平方乘以 N 以后，结果的末尾几位数等于 K，那么就称这个数为“N-自守数”。例如 3×92
2 = 25392，而 25392 的末尾两位正好是 92，所以 92 是一个 3-自守数。

>本题就请你编写程序判断一个给定的数字是否关于某个 N 是 N-自守数。
#### 输入格式：
>输入在第一行中给出正整数 M（≤20），随后一行给出 M 个待检测的、不超过 1000 的正整数。
#### 输出格式：
>对每个需要检测的数字，如果它是 N-自守数就在一行中输出最小的 N 和 NK^2
  的值，以一个空格隔开；否则输出 No。注意题目保证 N<10。
#### 输入样例：
    3
    92 5 233
#### 输出样例：
    3 25392
    1 25
    No
## 通过代码
```java
import java.util.*;

class Main {
	static Scanner sc;
	static {
		sc = new Scanner(System.in);
	}

	public static void main(String[] args) {
		int n = sc.nextInt();
		int arr = 0;
		for (int i = 0; i < n; i++) {
			arr = sc.nextInt();
			Integer temp = arr;
			int len = temp.toString().length();
			boolean find = false;
			for (int j = 1; j < 10; j++) {
				temp = arr * arr * j;
				String y = temp.toString().substring(temp.toString().length() - len, temp.toString().length());
				temp = arr;
				if (y.equals(temp.toString())) {
					System.out.println(j + " " + arr * arr * j);
					find = true;
					break;
				}
			}
			if (!find) {
				System.out.println("No");
			}

		}

	}
}
```
## 错误反思与代码评价

### 错误反思
好像是一遍过的吧？
### 代码评价
java的类都有一个toString方法真的超级方便哦，直接平方，赋值给Integer调用toString再截取后面一段，跟原来的数比较，So easy!
