---
title: PAT-Basic-1078
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> 文本压缩有很多种方法，这里我们只考虑最简单的一种：把由相同字符组成的一个连续的片段用这个字符和片段中含有这个字符的个数来表示。例如 `ccccc` 就用 `5c` 来表示。如果字符没有重复，就原样输出。例如 `aba` 压缩后仍然是 `aba`。

> 解压方法就是反过来，把形如 `5c` 这样的表示恢复为 `ccccc`。

> 本题需要你根据压缩或解压的要求，对给定字符串进行处理。这里我们简单地假设原始字符串是完全由英文字母和空格组成的非空字符串。

#### 输入格式：

> 输入第一行给出一个字符，如果是 `C` 就表示下面的字符串需要被压缩；如果是 `D` 就表示下面的字符串需要被解压。第二行给出需要被压缩或解压的不超过 1000 个字符的字符串，以回车结尾。题目保证字符重复个数在整型范围内，且输出文件不超过 1MB。

#### 输出格式：

> 根据要求压缩或解压字符串，并在一行中输出结果。

#### 输入样例 1：

```
C
TTTTThhiiiis isssss a   tesssst CAaaa as
```

#### 输出样例 1：

```
5T2h4is i5s a3 te4st CA3a as
```

#### 输入样例 2：

```
D
5T2h4is i5s a3 te4st CA3a as10Z
```

#### 输出样例 2：

```
TTTTThhiiiis isssss a   tesssst CAaaa asZZZZZZZZZZ
```
## 通过代码（极致压行版）
```cpp
#include <iostream>
#include <ctype.h>
using namespace std;
void Cprint(int& count, char a) {//注意count是引用变量
	if (count != 1) cout << count;
	cout << a;
	count = 0;
}
int main () {
	string str, c;
	int i = 0, count = 1;//i是解码的循环变量，控制下标。count是压缩过程中记录重复字符出现次数的
	getline(cin, c); getline(cin, str);//输入
	if (c == "C") {
		for (int j = 1; j < str.length(); j++, count++)//每次循环count++
			if (str[j - 1] != str[j]) Cprint(count, str[j - 1]);//如果遇到一个字符和前一个不一样，输出，让count归零
		Cprint(count, str[str.length() - 1]);//输出最末尾的一个或一串
	} else if (c == "D") {
		if (!isdigit(str[i])) cout << str[i++];//第一个不是数字，直接输出，i++访问下一个字符
		for (int n = 0; i < str.length(); n = 0, i++) {//n为每个字符前的数字
			for (; i < str.length() && isdigit(str[i]); n *= 10, n += (str[i++] - '0'));//如果是数字，就把数字字符转换成数，这里不是双层for循环嵌套，这个for循环后有一个分号
			for (int j = 0; j < (n == 0 ? 1 : n); j++) cout << str[i];//循环输出字符，如果没有遇到数字，n为0，就输出一次
		}
	}
	return 0;
}
```
## 通过代码

```cpp
#include <iostream>
#include <algorithm>
#include <ctype.h>
using namespace std;
struct out { char c; int n; };
void C () {
	string str;
	getline(cin, str);
	int n = str.length();
	out data[n] = {0};
	char last = -1;
	int count = -1;
	for (int i = 0; i < n; i++) {
		if (str[i] != last)
			data[++count].c = str[i];
		data[count].n++;
		last = str[i];
	}
	for (int i = 0; i < count + 1; i++) {
		if (data[i].n != 1)
			cout << data[i].n;
		cout << data[i].c;
	}
}
void D () {
	string str;
	getline(cin, str);
	int i = 0;
	if (!isdigit(str[i]))
		cout << str[i++];
	while (i < str.length()) {
		int n = 0;
		while (i < str.length() && isdigit(str[i])) {
			n *= 10;
			n += str[i++] - '0';
		}
		for (int j = 0; j < n; j++)
			cout << str[i];
		i++;
		while ( i < str.length() && !isdigit(str[i]))
			cout << str[i++];
	}
}
int main () {
	char c;
	scanf("%c%*c", &c);
	if (c == 'C') C();
	else D();
	return 0;
}
```

## 思路与注意

1.  coding（压缩）一个函数，decoding（解压）一个函数分别处理
    
2.  两个函数统一使用getline，main函数里面要吃掉第一行的换行符
    
3.  对于coding过程
    
    1.  定义一个结构体数组，储存字符与个数。数组长度为输入string的长度（如果输入的string不能压缩，正好够用）
        
    2.  遍历一遍string，如果字符和前一个字符一样，那么当前结构体（变量）的字符个数++，一旦改变，存到下一个结构体中。
        
    3.  输出结构体，先输出个数（大于1才输出），再输出这个字符
        
4.  对于decoding过程
    
    1.  先判断第一个字符，如果是字母直接输出这个字母，然后字符串的“指针”向后移。
        
    2.  进入循环，循环的操作为，得到数字，输出数字后的字母，然后输出后面的单个字母，直到遇到下一个数字，进入下一次循环，或者遇到字符串结束，那就结束。
        
    3.  注意不要用isalpha()函数（考虑空格的存在）
        

## 反思与评价

-   嗯
