---
title: PAT-Basic-1093
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> 给定两个字符串 A 和 B，本题要求你输出 A+B，即两个字符串的并集。要求先输出 A，再输出 B，但**重复的字符必须被剔除**。

#### 输入格式：

> 输入在两行中分别给出 A 和 B，均为长度不超过 106的、由可见 ASCII 字符 (即码值为32~126)和空格组成的、由回车标识结束的非空字符串。

#### 输出格式：

> 在一行中输出题面要求的 A 和 B 的和。

#### 输入样例：

```
This is a sample test
to show you_How it works
```

#### 输出样例：

```
This ampletowyu_Hrk
```

## 通过代码

```cpp
#include <stdio.h>
#include <string.h>

int main () {
	char arr[128] = {0};
	memset(arr, -1, sizeof(arr));
	char c;
	while ((c = getchar()) != -1) {
		if (c == '\n') continue;
		if (arr[c] == -1) {
			putchar(c);
			arr[c] = 1;
		}
	}
}
```

## 思路与注意

1.  观察输入与输出
    
    1.  换行不输出
        
    2.  某个字符如果前面出现过，就不输出
        
2.  搞一个数组，ASCII值为引索，初始化为-1，每打一个字，把对应的值改成非-1的值
    
3.  注意要让程序结束，通过第二个回车判断，或者EOF 的-1判断
