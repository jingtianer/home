---
title: PAT-Basic-1058
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目
>批改多选题是比较麻烦的事情，本题就请你写个程序帮助老师批改多选题，并且指出哪道题错的人最多。
##### 输入格式：
>输入在第一行给出两个正整数 N（≤ 1000）和 M（≤ 100），分别是学生人数和多选题的个数。随后 M 行，每行顺次给出一道题的满分值（不超过 5 的正整数）、选项个数（不少于 2 且不超过 5 的正整数）、正确选项个数（不超过选项个数的正整数）、所有正确选项。注意每题的选项从小写英文字母 a 开始顺次排列。各项间以 1 个空格分隔。最后 N 行，每行给出一个学生的答题情况，其每题答案格式为 (选中的选项个数 选项1 ……)，按题目顺序给出。注意：题目保证学生的答题情况是合法的，即不存在选中的选项数超过实际选项数的情况。
#### 输出格式：
>按照输入的顺序给出每个学生的得分，每个分数占一行。注意判题时只有选择全部正确才能得到该题的分数。最后一行输出错得最多的题目的错误次数和编号（题目按照输入的顺序从 1 开始编号）。如果有并列，则按编号递增顺序输出。数字间用空格分隔，行首尾不得有多余空格。如果所有题目都没有人错，则在最后一行输出 Too simple。
#### 输入样例：
    3 4 
    3 4 2 a c
    2 5 1 b
    5 3 2 b c
    1 5 4 a b d e
    (2 a c) (2 b d) (2 a c) (3 a b e)
    (2 a c) (1 b) (2 a b) (4 a b d e)
    (2 b d) (1 e) (2 b c) (4 a b c d)
#### 输出样例：
    3
    6
    5
    2 2 3 4
## 通过代码
```c++
#include <iostream>
#include <string>
#include <vector>

using namespace std;

class Option {
  public:
    int score;
    int optionNum;
    int corOptionNum;
    int FalseNum;
    int num;
    vector<char> correctOption;
    Option() {
        score = 0;
        optionNum = 0;
        corOptionNum = 0;
        FalseNum = 0;
        num = 0;
    }
    Option(Option &other) {
        score = other.score;
        optionNum = other.optionNum;
        corOptionNum = other.corOptionNum;
        correctOption = other.correctOption;
    }
    friend istream &operator>>(istream &file, Option &object);
};

istream &operator>>(istream &file, Option &object) {
    file >> object.score >> object.optionNum >> object.corOptionNum;
    for (int i = 0; i < object.corOptionNum; i++)
    {
        file.ignore();
        char temp;
        file >> temp;
        object.correctOption.push_back(temp);
    }
    return file;
}

class choose {
  public:
    int num;
    vector<char> option;
    friend istream &operator>>(istream &file, choose &object);
    friend ostream &operator<<(ostream &file, choose &object);
    void clear()
    {
        option.clear();
        num = 0;
    }
};

istream &operator>>(istream &file, choose &object) {
    char x;
    cin >> x;
    file >> object.num;
    for (int i = 0; i < object.num; i++)
    {
        file.ignore();
        char temp;
        file >> temp;
        object.option.push_back(temp);
    }
    file.ignore();
    return file;
}

class Stu {
  public:
    vector<choose> cho;
    int score;
    Stu() { score = 0; }
    Stu(Stu &other)
    {
        cho = other.cho;
        score = other.score;
    }
};

int main() {
    int n, m;
    cin >> n >> m;
    Stu student[n];
    Option op[m];
    choose choTemp;
    bool hasFalse = false;
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
        }
        for (int j = 0; j < m; j++) {
            if (student[i].cho[j].option == op[j].correctOption) {
                student[i].score += op[j].score;
            }
            else {
                hasFalse = true;
                op[j].FalseNum++;
            }
        }
    }
    for (int i = 0; i < n; i++) {
        cout << student[i].score << endl;
    }
    if (hasFalse) {
        int max = op[0].FalseNum;
        for (int i = 0; i < m; i++) {
            if (max < op[i].FalseNum) {
                max = op[i].FalseNum;
            }
        }
        cout << max;
        for (int i = 0; i < m; i++) {
            if (op[i].FalseNum == max)
            {
                cout << ' ' << op[i].num;
            }
        }
        cout << endl;
    }
    else {
        cout << "Too simple" << endl;
    }
    return 0;
}
```

## 思路与注意
>1. 利用类来储存信息，注意构造函数里初始化变量。
>2. 注意输入字符类型时，利用ignore()等函数跳过空白符
>3. 最后一行的输出是**最大值 最大值的序号列表**，不是**最大值+序号+最大值+序号**。在这里被坑住了。
>4. 输入choose类的时候用了一个choTemp输入，choose类内部采用了vector，那么每次输入完成要清空一次。
## 反思与评价
这道题其实不用写这么多类，运算符重载，构造函数什么的，代码可以更加精简。但是这样写的好处有：
>1. 数据处理方便，不会导致main函数里面定义过多变量导致代码可读性变差。
>2. main函数更加简洁，可以把思路放在逻辑算法上而不是数据的处理上，就像我们使用vector，set，map等模板时，并不需要知道其内部如何实现，使得编码效率提高。
