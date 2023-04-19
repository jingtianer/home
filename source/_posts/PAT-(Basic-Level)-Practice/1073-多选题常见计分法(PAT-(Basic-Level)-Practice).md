---
title: PAT-Basic-1073
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> 批改多选题是比较麻烦的事情，有很多不同的计分方法。有一种最常见的计分方法是：如果考生选择了部分正确选项，并且没有选择任何错误选项，则得到 50% 分数；如果考生选择了任何一个错误的选项，则不能得分。本题就请你写个程序帮助老师批改多选题，并且指出哪道题的哪个选项错的人最多。

#### 输入格式：

> 输入在第一行给出两个正整数 N（≤1000）和 M（≤100），分别是学生人数和多选题的个数。随后 M 行，每行顺次给出一道题的满分值（不超过 5 的正整数）、选项个数（不少于 2 且不超过 5 的正整数）、正确选项个数（不超过选项个数的正整数）、所有正确选项。注意每题的选项从小写英文字母 a 开始顺次排列。各项间以 1 个空格分隔。最后 N 行，每行给出一个学生的答题情况，其每题答案格式为 `(选中的选项个数 选项1 ……)`，按题目顺序给出。注意：题目保证学生的答题情况是合法的，即不存在选中的选项数超过实际选项数的情况。

#### 输出格式：

> 按照输入的顺序给出每个学生的得分，每个分数占一行，输出小数点后 1 位。最后输出错得最多的题目选项的信息，格式为：`错误次数 题目编号（题目按照输入的顺序从1开始编号）-选项号`。如果有并列，则每行一个选项，按题目编号递增顺序输出；再并列则按选项号递增顺序输出。行首尾不得有多余空格。如果所有题目都没有人错，则在最后一行输出 `Too simple`。

#### 输入样例 1：

```
3 4 
3 4 2 a c
2 5 1 b
5 3 2 b c
1 5 4 a b d e
(2 a c) (3 b d e) (2 a c) (3 a b e)
(2 a c) (1 b) (2 a b) (4 a b d e)
(2 b d) (1 e) (1 c) (4 a b c d)
```

#### 输出样例 1：

```
3.5
6.0
2.5
2 2-e
2 3-a
2 3-b
```

#### 输入样例 2：

```
2 2 
3 4 2 a c
2 5 1 b
(2 a c) (1 b)
(2 a c) (1 b)
```

#### 输出样例 2：

```
5.0
5.0
Too simple
```

## 通过代码

```c++
#include <iostream>
#include <vector>
#include <algorithm>
#include <iomanip>
using namespace std;
class Option {//用于统计正确选项的信息
public:
    double score = 0;int optionNum = 0, corOptionNum = 0, num = 0, maxFalseNum = -1, FalseNum[6] = {0};
    //正确选项的分数,选项个数,正确选项的个数,题目的编号，从1开始,错误次数的最大值,每一个选项的错误次数
    vector<char> correctOption, FalseMostOp;//记录正确选项,记录错误次数最多的选项
    int check(vector<char> select) {  //0错，1对，2半对
        bool want1 = false, want2 = false;
        for (int i = 0; i < select.size(); i++) {//第一次查找，有没有多选的
            bool found = false;
            for (int j = 0; j < correctOption.size(); j++) {
                if (correctOption[j] == select[i]) {
                    found = true; break;
                }
            }
            if (!found) {  //学生选了，不是正确选项
                want1 = true; FalseNum[select[i]-'a']++;
            }
        }
        for (int i = 0; i < correctOption.size(); i++) {//第二次查找，有没有漏选的
            bool found = false;
            for (int j = 0; j < select.size(); j++) {
                if (correctOption[i] == select[j]) {
                    found = true; break;
                }
            }
            if (!found) {  //本身是正确选项，学生没选
                want2 = true; FalseNum[correctOption[i]-'a']++;
            }
        }
        if (want1) return 0;//学生的选择有正确选择中没有的，错！
        //学生的选择是正确选项的子集
        if (want2) return 2;//学生的选择正确选项都有，但是正确选项中有学生没选的，半对！
        //正确选项是学生选择的子集
        return 1;//两个互为子集，则选择相同，对！
    }
    friend istream &operator>>(istream &file, Option &object);
    void caculate () {//计算错误次数的最大值，并记录错的多的选项
        maxFalseNum = FalseNum[0];
        for (int i = 0; i < optionNum; i++)
            if (FalseNum[i] > maxFalseNum)
                maxFalseNum = FalseNum[i];
        for (int i = 0; i < optionNum; i++)
            if (FalseNum[i] == maxFalseNum)
                FalseMostOp.push_back(i + 'a');
    }
    int getAllFalseNum() { return maxFalseNum; }
};
istream &operator>>(istream &file, Option &object) {//正确选项信息
    file >> object.score >> object.optionNum >> object.corOptionNum;
    for (int i = 0; i < object.corOptionNum; i++) {
        file.ignore();
        char temp; file >> temp;
        object.correctOption.push_back(temp);
    }
    return file;
}
class choose {//记录某个题学生的选择信息
public:
    int num = 0;
    vector<char> option;
    friend istream &operator>>(istream &file, choose &object);
    void clear() { option.clear(); num = 0; }
};
istream &operator>>(istream &file, choose &object) {//输入学生的选择
    char x; cin >> x; file >> object.num;
    for (int i = 0; i < object.num; i++) {
        file.ignore();
        char temp; file >> temp;
        object.option.push_back(temp);
    }
    file.ignore();
    return file;
}
struct Stu { vector<choose> cho; double score = 0; };
//记录学生选择和得分
int main() {
    int n, m;
    cin >> n >> m;
    Stu student[n];
    Option op[m];
    choose choTemp;//用于暂时储存输入，由于用了vector，每次要clear()
    for (int i = 0; i < m; i++) {
        cin >> op[i];
        op[i].num = i + 1;
    }
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            choTemp.clear();
            cin >> choTemp;
            cin.ignore();
            student[i].cho.push_back(choTemp);
        }//一个学生的选择输入完成
        for (int j = 0; j < m; j++) {//对刚刚输入的这个学生进行判分
            int n = op[j].check(student[i].cho[j].option);
            if (n == 1) student[i].score += op[j].score;
            else if (n == 2) student[i].score += op[j].score*0.5;
        }
    }
    for (int i = 0; i < n; i++)//输出分数
        cout << fixed << setprecision(1) << student[i].score << endl;
    for (int i = 0; i < m; i++)//计算错的最多的选项
        op[i].caculate();
    int max = 0;
    for (int i = 0; i < m; i++)//查找最大值
        if (max < op[i].getAllFalseNum()) max = op[i].getAllFalseNum();
    if (max > 0) {//输出
        for (int i = 0; i < m; i++)
            if (op[i].getAllFalseNum() == max)
                for (int j = 0; j < op[i].FalseMostOp.size(); j++)
                    cout << max << ' ' << op[i].num << '-' << op[i].FalseMostOp[j] << endl;
    }
    else { cout << "Too simple" << endl; }
    return 0;
}
```
## 思路与注意
 1.  这道题是题目：[PAT乙级题--1058 选择题](https://www.jianshu.com/p/0685d9a43a2c)，的升级版，其中输入一样，只是给分方式变成了：全对给全分，部分对给一半分，有错不得分
 2.  判分方式
     1.  判分思想：`a是b的子集，且b是a的子集，那么a，b两个集合相等`
     2.  定义一个判分函数，属于Option类，全对返回1，有错返回0，半对返回2。
     3.  两次遍历查找，第一遍查找学生的选择中有没有不是正确选项的，如果有，记录这个选项错了一次。第二次查找正确选项中是否存在学生没有选的，如果有记录这个选项错了一次
     4.  第一次查找就有错，返回0。（如果没错，说明：`学生的选择是正确选项的子集`）
     5.  如果第二次查找有错而第一次没有，说明学生没选全，返回2。（如果没错，说明：`正确选项是学生的子集`）
     6.  如果两次遍历都没错，说明学生选择就是正确答案，返回1。（说明：`两个集合互为子集，两个集合相等`）
 3.  统计错误选项
     1.  定义了一个`calculate()`函数，用于统计那个题错的最多，最多的选项有哪些
     2.  在所有学生的题判完以后，所有选项的错误次数也就统计`完整`了，这时调用计算一下
 4.  注意
     1.  不能一边找最大值一边计算，我也不知道为啥，一定要先计算一边错误最多的选项，再找最大值。    
## 反思与评价
-   这道题其实不用写这么多类，运算符重载，构造函数什么的，代码可以更加精简。但是这样写的好处有：
> 1.  数据处理方便，不会导致main函数里面定义过多变量导致代码可读性变差。
> 2.  main函数更加简洁，可以把思路放在逻辑算法上而不是数据的处理上，就像我们使用vector，set，map等模板时，并不需要知道其内部如何实现，使得编码效率提高。
-   这道题很努力的在压行，如果用Astyle风格format一下的话能有200行
