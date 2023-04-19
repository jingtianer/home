---
title: PAT-Basic-1052
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

萌萌哒表情符号通常由“手”、“眼”、“口”三个主要部分组成。简单起见，我们假设一个表情符号是按下列格式输出的：

```
[左手]([左眼][口][右眼])[右手]
```

现给出可选用的符号集合，请你按用户的要求输出表情。

### 输入格式：

输入首先在前三行顺序对应给出手、眼、口的可选符号集。每个符号括在一对方括号 `[]`内。题目保证每个集合都至少有一个符号，并不超过 10 个符号；每个符号包含 1 到 4 个非空字符。

之后一行给出一个正整数 K，为用户请求的个数。随后 K 行，每行给出一个用户的符号选择，顺序为左手、左眼、口、右眼、右手——这里只给出符号在相应集合中的序号（从 1 开始），数字间以空格分隔。

### 输出格式：

对每个用户请求，在一行中输出生成的表情。若用户选择的序号不存在，则输出 `Are you kidding me? @\/@`。

### 输入样例：

```
[╮][╭][o][~\][/~]  [<][>]
 [╯][╰][^][-][=][>][<][@][⊙]
[Д][▽][_][ε][^]  ...
4
1 1 2 2 2
6 8 1 5 5
3 3 4 3 3
2 10 3 9 3
```

### 输出样例：

```
╮(╯▽╰)╭
<(@Д=)/~
o(^ε^)o
Are you kidding me? @\/@
```

## 通过代码
```c++
#include <iostream>
#include <vector>
using namespace std;
int main () {
	vector<string> data[3];
	string line;
	for (int j = 0; j < 3; j++) {
		getline(cin, line);
		for (int i = 0, k = 0, count = 0; i < line.length(); count++) {
			while ( i < line.length() && line[i] != '[')i++;
			while ( k < line.length() && line[k] != ']')k++;
			if (i < line.length() && k < line.length()) {
				data[j].push_back(line.substr(i + 1, k - 1 - i));
				k++;
				i = k;
			} else {
				break;
			}
		}
	}
	int n;
	cin >> n;
	for (int i = 0; i < n; i++) {
		int a[5];
		for (int j = 0; j < 5; j++) {
			cin >> a[j];
			a[j]--;
		}
		if (a[0] < data[0].size() && a[1] < data[1].size() && a[2] < data[2].size() && a[3] < data[1].size() && a[4] < data[0].size())
			cout << data[0][a[0]] << "(" << data[1][a[1]] << data[2][a[2]] << data[1][a[3]] << ")" << data[0][a[4]] << endl;
		else printf("Are you kidding me? @\\/@\n");
	}
}
```
## 思路与注意

1.  这道题其实就是分析字符串，把所有`[]`内的`字符串`全都存起来，然后用户输入序号，根据序号按照条件输出就可以了
    
2.  注意`[]`内不一定只有一个字符，而且可能是宽字符（直接保存成string就行）
    
3.  注意用户输入的序号是从1开始的
    
4.  注意输出格式（左手右边、右手左边有半角括号）
    

```
[左手]([左眼][口][右眼])[右手]
```

## 反思与评价

-   这道题思路很清晰，利用vector会很方便
    
-   写题的时候一直认为substr()函数的两个参数都是index，一直出错（手动笑哭）
