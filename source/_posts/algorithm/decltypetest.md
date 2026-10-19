---
title: decltypetest
date: 2022-10-05 23:11:15 +0800
tags: 算法
categories: 算法
toc: true
language: zh-CN
---

## 算法内容

本文件是 C++ `decltype`、引用折叠和数组形参退化的学习代码。

`f` 对比 `decltype(++i)`、`decltype(i++)` 和 `decltype(&i)` 的推导结果：前置自增表达式得到左值引用类型，后置自增表达式得到值类型，取地址得到指针类型。`f1` 观察数组作为函数参数时会退化为指针。`f2` 则通过左值引用、右值引用和 `move` 展示引用变量在 `decltype` 中的类型保持规则。这个文件重点不是算法题，而是验证 C++ 类型推导行为。

## 算法实现

```c++
#include<iostream>
#include<iomanip>
using namespace std;


int i = 0;
void f(decltype(++i) a, decltype(i++) b, decltype(&i) c) {
    a++;
    b++;
    (*c)++;
}
int arr[5] = {0};
void f1(decltype(arr) a) {
    cout << ios::hex << a << " " << a+1 <<  endl;
}

int &j = i;
int &n = j;
int &&k = move(i);
int &&m  = move(k);
void f2(decltype(j) a, decltype(k) b, decltype(m) c, decltype(n) d) {
    a++;
    b++;
    c++;
    d++;
    cout << a << " " << b << " " << c << " " << d << endl;

}

int main() {
    int a = 0, b = 0,c = 0, d = 0;
    f(a, b, &c);
    cout << a << " " << b << " " << c <<  endl;
    int brr[6] = {0};
    f1(brr);
    f2(a,move(b),move(c),d);
    cout << a << " " << b << " " << c << " " << d << endl;
    return 0;
}
```
