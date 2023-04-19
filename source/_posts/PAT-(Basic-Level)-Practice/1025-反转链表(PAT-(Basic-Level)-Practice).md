---
title: PAT-Basic-1025
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目
>给定一个常数 K 以及一个单链表 L，请编写程序将 L 中每 K 个结点反转。例如：给定 L 为 1→2→3→4→5→6，K 为 3，则输出应该为 3→2→1→6→5→4；如果 K 为 4，则输出应该为 4→3→2→1→5→6，即最后不到 K 个元素不反转。
#### 输入格式：
>每个输入包含 1 个测试用例。每个测试用例第 1 行给出第 1 个结点的地址、结点总个数正整数 N (≤10^5)、以及正整数 K (≤N)，即要求反转的子链结点的个数。结点的地址是 5 位非负整数，NULL 地址用 −1 表示。
>接下来有 N 行，每行格式为：
>**Address Data Next**
其中 **Address** 是结点地址，**Data** 是该结点保存的整数数据，**Next** 是下一结点的地址。
#### 输出格式：
>对每个测试用例，顺序输出反转后的链表，其上每个结点占一行，格式与输入相同。
#### 输入样例：
    00100 6 4
    00000 4 99999
    00100 1 12309
    68237 6 -1
    33218 3 00000
    99999 5 68237
    12309 2 33218
#### 输出样例：
    00000 4 33218
    33218 3 12309
    12309 2 00100
    00100 1 99999
    99999 5 68237
    68237 6 -1
## 通过代码
```c++
#include <iostream>
#include <vector>
#include <string>

using namespace std;

struct node {
    int add;
    int next;
    int data;
};

int main () {
    int first, num, k;
    scanf ("%d%d%d", &first, &num, &k);
    vector<node> v(100005);
    node temp;
    for (int i = 0; i < num; i++) {
        scanf ("%d%d%d", &temp.add, &temp.data, &temp.next);
        v[temp.add] = temp;
    }
    int find = first;
    vector<node> x;
    while (find != -1) {
        x.push_back(v[find]);
        find = v[find].next;
    }
    num = (int)x.size();
    for (int i = 0; i < num/k; i++) {
        for (int j = (i+1)*k - 1,m = 0; m < k/2; m++) {
            temp = x[j-m];
            x[j-m] = x[j-k+1+m];
            x[j-k+1+m] = temp;
        }
    }
    for (int i = 0; i < num - 1; i++) {
        printf ("%05d %d %05d\n", x[i].add, x[i].data, x[i+1].add);
    }
    printf ("%05d %d -1\n", x[num - 1].add, x[num - 1].data);
    return 0;
}
```

## 思路与注意
>* 原来的思路是malloc创建数组，然后node结构体搞成指针的样子，搞成一个既是数组又是链表的东西，结果啊，越高越复杂。
>* 搞一个vector数组，用于查表，把地址作为引索
>* 然后根据首地址一直查找到结束，按顺序搞到一个vector里面
>* 处理反转关系
>* 输出
## 反思与评价
>* 用之前的想法写不出来很不开心，不过stl真心牛逼！
