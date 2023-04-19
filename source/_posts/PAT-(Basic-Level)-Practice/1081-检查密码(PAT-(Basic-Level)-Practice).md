---
title: PAT-Basic-1081
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> 本题要求你帮助某网站的用户注册模块写一个密码合法性检查的小功能。该网站要求用户设置的密码必须由不少于6个字符组成，并且只能有英文字母、数字和小数点 `.`，还必须既有字母也有数字。

#### 输入格式：

> 输入第一行给出一个正整数 N（≤ 100），随后 N 行，每行给出一个用户设置的密码，为不超过 80 个字符的非空字符串，以回车结束。

#### 输出格式：

> 对每个用户的密码，在一行中输出系统反馈信息，分以下5种：
> 
> -   如果密码合法，输出`Your password is wan mei.`；
>     
> -   如果密码太短，不论合法与否，都输出`Your password is tai duan le.`；
>     
> -   如果密码长度合法，但存在不合法字符，则输出`Your password is tai luan le.`；
>     
> -   如果密码长度合法，但只有字母没有数字，则输出`Your password needs shu zi.`；
>     
> -   如果密码长度合法，但只有数字没有字母，则输出`Your password needs zi mu.`。
>     

#### 输入样例：

```
5
123s
zheshi.wodepw
1234.5678
WanMei23333
pass*word.6
```

#### 输出样例：

```
Your password is tai duan le.
Your password needs shu zi.
Your password needs zi mu.
Your password is wan mei.
Your password is tai luan le.
```

## 通过代码
```c++
#include <iostream>
using namespace std;
int main () {
	string pwd;
	getline(cin, pwd);
	while (getline(cin, pwd)) {
		if (pwd.length() >= 6) {
			bool alpha = false, num = false, dot = false, other = false;
			for (int i = 0; i < pwd.length(); i++) {
				if (isalpha(pwd[i])) alpha = true;
				else if (isdigit(pwd[i])) num = true;
				else if (pwd[i] == '.') dot = true;
				else other = true;
			}
			if (!other && alpha && num) cout << "Your password is wan mei." << endl;
			else if (other) cout << "Your password is tai luan le." << endl;
			else if (!num && alpha) cout << "Your password needs shu zi." << endl;
			else if (num && !alpha) cout << "Your password needs zi mu." << endl;
		} else { cout << "Your password is tai duan le." << endl; }
	}
	return 0;
}
```
