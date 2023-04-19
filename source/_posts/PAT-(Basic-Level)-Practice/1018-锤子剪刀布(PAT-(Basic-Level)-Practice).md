---
title: PAT-Basic-1018
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目
>大家应该都会玩“锤子剪刀布”的游戏：两人同时给出手势，胜负规则如图所示：
>![](https://upload-images.jianshu.io/upload_images/16086048-c64f41977fee95f3.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

>现给出两人的交锋记录，请统计双方的胜、平、负次数，并且给出双方分别出什么手势的胜算最大。
#### 输入格式：
>输入第 1 行给出正整数 N（≤10^5），即双方交锋的次数。随后 N 行，每行给出一次交锋的信息，即甲、乙双方同时给出的的手势。C 代表“锤子”、J 代表“剪刀”、B 代表“布”，第 1 个字母代表甲方，第 2 个代表乙方，中间有 1 个空格。
#### 输出格式：
>输出第 1、2 行分别给出甲、乙的胜、平、负次数，数字间以 1 个空格分隔。第 3 行给出两个字母，分别代表甲、乙获胜次数最多的手势，中间有 1 个空格。如果解不唯一，则输出按字母序最小的解。
#### 输入样例：
    10
    C J
    J B
    C B
    B B
    B C
    C C
    C B
    J B
    B C
    J J
#### 输出样例：
    5 3 2
    2 3 5
    B B
```c++
#include <iostream>

using namespace std;

class Player {
  private:
    int win; int equal; int lose; int cw;
    int jw; int bw; char op;
  public:
    Player() {
        win = 0; lose = 0; equal = 0;
        cw = 0; jw = 0; bw = 0; op = 'n';
    }
    void setOp(char a) { op = a; }
    static void game(Player &a, Player &b) {
        if (a.op == 'C') {
            if (b.op == 'C') { a.equal++; b.equal++; }
            else if (b.op == 'J') { a.win++; a.cw++; b.lose++; }
            else if (b.op == 'B') { a.lose++; b.win++; b.bw++; }
        } else if (a.op == 'J') {
            if (b.op == 'C') { a.lose++; b.win++; b.cw++; }
            else if (b.op == 'J') { a.equal++; b.equal++; }
            else if (b.op == 'B') { a.win++; a.jw++; b.lose++; }
        } else if (a.op == 'B') {
            if (b.op == 'C') { a.win++; b.lose++; a.bw++; }
            else if (b.op == 'J') { a.lose++; b.win++; b.jw++; }
            else if (b.op == 'B') { a.equal++; b.equal++; }
        }
    }
    void showCondition() { cout << win << " " << equal << " " << lose << endl; }
    char showMost() {
        if (jw > cw) {
            if (jw > bw) return 'J'; 
            else  return 'B'; 
        } else if (jw == cw) {
            if (jw > bw) return 'C'; 
            else return 'B'; 
        } else {
            if (cw <= bw) return 'B'; 
            else return 'C'; 
        }
    }
};

int main()
{
    int n;
    cin >> n;
    cin.ignore();
    Player a, b;
    for (int i = 0; i < n; i++) {
        char aop, bop;
        cin >> aop; cin.ignore();
        cin >> bop; cin.ignore();
        a.setOp(aop); b.setOp(bop);
        Player::game(a, b);
    }
    a.showCondition(); b.showCondition();
    cout << a.showMost() << " " << b.showMost() << endl;
    return 0;
}
```
## 思路与注意
>* 没什么好主意的，简单题
## 反思与评价
>* 没什么好反思的
>* 非要反思的话，压行是门技术活
