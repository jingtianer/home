---
title: PAT-Basic-1085
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目
> 每次 PAT 考试结束后，考试中心都会发布一个考生单位排行榜。本题就请你实现这个功能。
#### 输入格式：
> 输入第一行给出一个正整数 N（≤10^5），即考生人数。随后 N 行，每行按下列格式给出一个考生的信息：
```
准考证号 得分 学校
```
> 其中`准考证号`是由 6 个字符组成的字符串，其首字母表示考试的级别：`B`代表乙级，`A`代表甲级，`T`代表顶级；`得分`是 [0, 100] 区间内的整数；`学校`是由不超过 6 个英文字母组成的单位码（大小写无关）。注意：题目保证每个考生的准考证号是不同的。
#### 输出格式：
> 首先在一行中输出单位个数。随后按以下格式非降序输出单位的排行榜：
```
排名 学校 加权总分 考生人数
```
> 其中`排名`是该单位的排名（从 1 开始）；`学校`是全部按小写字母输出的单位码；`加权总分`定义为`乙级总分/1.5 + 甲级总分 + 顶级总分*1.5`的**整数部分**；`考生人数`是该属于单位的考生的总人数。
> 学校首先按加权总分排行。如有并列，则应对应相同的排名，并按考生人数升序输出。如果仍然并列，则按单位码的字典序输出。
#### 输入样例：
```
10
A57908 85 Au
B57908 54 LanX
A37487 60 au
T28374 67 CMU
T32486 24 hypu
A66734 92 cmu
B76378 71 AU
A47780 45 lanx
A72809 100 pku
A03274 45 hypu
```
#### 输出样例：
```
5
1 cmu 192 2
1 au 192 3
3 pku 100 1
4 hypu 81 2
4 lanx 81 2
```
## 通过代码
```cpp
#include <algorithm>
#include <cmath>
#include <iostream>
#include <map>
#include <vector>
using namespace std;
struct data {
    int count;
    double score;
};
typedef pair<string, data> PAIR;
bool cmp(PAIR &a, PAIR &b) { //比较，三个排序关键词
    if (a.second.score != b.second.score) return a.second.score > b.second.score;
    else if (a.second.count != b.second.count) return a.second.count < b.second.count;
    else return a.first < b.first;
}
void input(map<string, data> &m) { //输入并计算分数
    int n;
    cin >> n;
    for (int i = 0; i < n; i++) {
        string id, school;
        int score;
        cin >> id >> score >> school;
        transform(school.begin(), school.end(), school.begin(), ::tolower); //变成小写
        if (id[0] == 'B') m[school].score += score / 1.5;
        else if (id[0] == 'A') m[school].score += score;
        else if (id[0] == 'T') m[school].score += score * 1.5;
        m[school].count++;
    }
}
void mapToVector(map<string, data> &m, vector<PAIR> &v) { //放进vector来利用sort排序
    for (map<string, data>::iterator ite = m.begin(); ite != m.end(); ite++) {
        ite->second.score = floor(ite->second.score); //根据题意要floor向左取整
        v.push_back(*ite);
    }
}
void print(vector<PAIR> &v) { //按要求排名并输出数据
    cout << v.size() << endl;
    int now = v[0].second.score, r = 1;
    for (int i = 0; i < v.size(); i++) {
        if (v[i].second.score != now) r = i + 1;
        cout << r << " " << v[i].first << " " << v[i].second.score << " " << v[i].second.count << endl;
        now = v[i].second.score;
    }
}
int main() {
    map<string, data> m;
    vector<PAIR> v;
    input(m);                      //输入并计算分数
    mapToVector(m, v);             //放进vector来利用sort排序
    sort(v.begin(), v.end(), cmp); //排序
    print(v);                      //按要求排名并输出数据
    return 0;
}
```
## 思路与注意
-   这道题不用考虑同一人参与多场考试
-   由于不想太多变量，所以只有一个`总分`变量，所以要用double，最后要floor向左取整。
-   map是关联容器不能sort排序，要放进vector里面再排序
    -   详见[PAT乙级题--1080 MOOC期终成绩](https://www.jianshu.com/p/7e3bebf86f6c)，里面有对`map`排序的笔记
-   排序的时候注意有三个关键词，分数（降序）、人数（升序）和学校名称（ASCII升序）
-   利用引用传递变量，浅拷贝，避免深拷贝
-   关于排名，思想是：先排序，排序后，令一个值`now`为第一个数，循环只要是和第一个数相同的就还是这个排名，一旦不等，说明后一名出现了，这是让`now`为当前这个数，然后让`排名 = i+1`（根据需要，有时是`排名++`）。后来为了压行，进一步提炼，每次循环让`now = v[i].second.score`，即让`now`记录上一次循环的值，比较与上次循环的分数是否相同，相同则排名相同，不同则排名按照需要改变
## 反思与评价
-   很好的利用了STL，希望能尽快用纯C写出来
## 开心
![当前PAT乙级题排名](https://upload-images.jianshu.io/upload_images/16086048-b953416eda3bcbb1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
嘿嘿，终于进入前1000了，加油！这个寒假刷完乙级题！
