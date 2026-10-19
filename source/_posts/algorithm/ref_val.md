---
title: C++ 析构函数中delete this
date: 2022-10-05 23:11:15 +0800
tags: 算法
categories: 算法
toc: true
language: zh-CN
---

## 算法内容

本文件是 C++ 对象传值、指针对象生命周期和析构行为的学习代码。

代码定义类 `A` 和结构体 `B`，并尝试通过函数传值修改对象副本。`main` 中使用 `new A` 创建堆对象，再通过 `delete a` 触发析构。需要特别注意：`A` 的析构函数内部又执行 `delete this`，这会导致递归析构或重复释放，是未定义行为。这个例子可以作为理解对象生命周期风险的反面案例：析构函数里通常不应该 `delete this`。

## 算法实现

```c++
#include<iostream>
using namespace std;
class A {
    public:
    int a;
    int b;
    A(int a0, int b0) : a(a0), b(b0) {}
    ~A() {
        cout << "delete this" << endl;
        delete this;
    }
};

struct B
{
    int a;
    int b;
    B(int a0, int b0) : a(a0), b(b0) {}
};

void f1(A a, B b) {
    a.a = 5, a.b = 6;
    b.a = 5, b.b = 6;
}

int main() {
    A *a = new A(1,2);
    B b(1,2);
    // f1(a, b);
    cout << a->a << " " << a->b << endl;
    // cout << b.a << " " << b.b << endl;
    delete a;
    return 0;
}
```
