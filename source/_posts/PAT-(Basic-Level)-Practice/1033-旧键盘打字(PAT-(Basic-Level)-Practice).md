---
title: PAT-Basic-1033
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目
>旧键盘上坏了几个键，于是在敲一段文字的时候，对应的字符就不会出现。现在给出应该输入的一段文字、以及坏掉的那些键，打出的结果文字会是怎样？
#### 输入格式：
>输入在 2 行中分别给出坏掉的那些键、以及应该输入的文字。其中对应英文字母的坏键以大写给出；每段文字是不超过 10^5个字符的串。可用的字符包括字母 [**a**-**z**, **A**-**Z**]、数字 **0**-**9**、以及下划线 **_**（代表空格）、**,**、**.**、**-**、**+**（代表上档键）。题目保证第 2 行输入的文字串非空。
>注意：如果上档键坏掉了，那么大写的英文字母无法被打出。
#### 输出格式：
>在一行中输出能够被打出的结果文字。如果没有一个字符能被打出，则输出空行。
#### 输入样例：
    7+IE.
    7_This_is_a_test.
#### 输出样例：
    _hs_s_a_tst
## 通过代码
```c++
#include <iostream>
using namespace std;
int main () {
    string err;
    string origin;
    int chart[200] = {0};
    char temp[100010] = {0};
    cin.getline(temp, sizeof(temp));
    err = temp;
    cin.getline(temp, sizeof(temp));
    origin = temp;
    bool shift = false;
    for (int i = 0; i < err.length(); i++) {
        chart[err[i]] = -1;
        if (err[i] == '+') {shift = true;} 
        else {
            if (err[i] >= 'a' && err[i] <= 'z'){
                chart[err[i] - 'a' + 'A'] = -1;
            }
            if (err[i] >= 'A' && err[i] <= 'Z') {
                chart[err[i] - 'A' + 'a'] = -1;
            }
           
        }
    }
    if (shift) {
        for (int i = 'A'; i <= 'Z'; i++) chart[i] = -1;
    }
    for (int i = 0; i < origin.length(); i++) {
        if (chart[origin[i]] != -1) cout << origin[i];
    }
    cout << endl;
    return 0;
}
```

## 思路与注意
>* 这道题又是很坑的一道题
```
    1. 输入样例后的'.'不知道是算shift键还是普通键
    2. 实际代码中只有'+'才是shift，其他都不是
```
>* 要明确如果一个键坏掉，那么它对应的大小写都不能用了，如果shift键不能用了，所有的大写字母都不能用了
>* 采用查表法，把不能用的键都变成-1，其他都是0
## 反思与评价
>* 又是坑题，很讨厌
