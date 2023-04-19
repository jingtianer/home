---
title: PAT-Basic-1014
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目
>大侦探福尔摩斯接到一张奇怪的字条：**我们约会吧！ 3485djDkxh4hhGE 2984akDfkkkkggEdsb s&hgsfdk d&Hyscvnm**。大侦探很快就明白了，字条上奇怪的乱码实际上就是约会的时间**星期四 14:04**，因为前面两字符串中第 1 对相同的大写英文字母（大小写有区分）是第 4 个字母 **D**，代表星期四；第 2 对相同的字符是 **E** ，那是第 5 个英文字母，代表一天里的第 14 个钟头（于是一天的 0 点到 23 点由数字 **0** 到 **9**、以及大写字母 **A** 到 **N** 表示）；后面两字符串第 1 对相同的英文字母 **s** 出现在第 4 个位置（从 0 开始计数）上，代表第 4 分钟。现给定两对字符串，请帮助福尔摩斯解码得到约会的时间。
#### 输入格式：
>输入在 4 行中分别给出 4 个非空、不包含空格、且长度不超过 60 的字符串。
#### 输出格式：
>在一行中输出约会的时间，格式为 **DAY HH:MM**，其中 **DAY** 是某星期的 3 字符缩写，即 **MON** 表示星期一，**TUE** 表示星期二，**WED** 表示星期三，**THU** 表示星期四，**FRI** 表示星期五，**SAT** 表示星期六，**SUN** 表示星期日。题目输入保证每个测试存在唯一解。
#### 输入样例：
    3485djDkxh4hhGE 
    2984akDfkkkkggEdsb 
    s&hgsfdk 
    d&Hyscvnm
#### 输出样例：
    THU 14:04
## 通过代码
```c++
#include <iostream>
using namespace std;

int main() {
    string clue[4];
    int day, hour, minute;
    string week[7] = {"MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"};
    for (int i = 0; i < 4; i++) {
        cin >> clue[i];
    }
    int count = -1;
    int y = 0;
    char c[2];
    for (int i = 0; i < min(clue[0].length(), clue[1].length()); i++) {
        if (count == -1 && clue[0][i] == clue[1][i] && (clue[0][i] >= 'A' && clue[0][i] <= 'G')) {
            c[++count] = clue[0][i];
        }
        if (count == 0 && clue[0][i] == clue[1][i]) {
            if ((clue[0][i] >= '0' && clue[0][i] <= '9') || (clue[0][i] >= 'A' && clue[0][i] <= 'N')) {
                y++;
            }
            if (y == 2) {
                c[++count] = clue[0][i];
            }
        }
        if (count == 1) {
            break;
        }
    }
    day = c[0] - 'A' + 1;
    if (c[1] >= '0' && c[1] <= '9') {
        hour = c[1] - '0';
    }
    else {
        hour = c[1] - 'A' + 10;
    }
    int pos = 0;
    for (int i = 0; i < min(clue[2].length(), clue[3].length()); i++) {
        if (clue[2][i] == clue[3][i] && ((clue[2][i] >= 'a' && clue[2][i] <= 'z') || (clue[2][i] >= 'A' && clue[2][i] <= 'Z'))) {
            pos = i;
            break;
        }
    }
    minute = pos;
    printf("%s %02d:%02d\n", week[day - 1].data(), hour, minute);
    return 0;
}
```
## 思路与注意
> 这道题实在是太咬文嚼字了！！
>1. 第一个线索必须是'A' 到 'G' 相同，因为一周只有7天
>2. 第二个线索必须是第二个相同的字符，而且必须是'0'-'9'或'A'-'N'的，因为一天只有24个小时（感觉题目自己和自己矛盾，题目不太严谨）
>3. 第二个线索必须在第一个线索的位置后面开始找（？？？反正我从题里面很难读出来）
## 反思与评价
>* 很讨厌的一道题，纯属浪费人时间，做不出来也不纠结它也可以的。
