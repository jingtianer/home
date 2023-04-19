---
title: PAT-Basic-1080
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> 对于在中国大学MOOC（[http://www.icourse163.org/](http://www.icourse163.org/) ）学习“数据结构”课程的学生，想要获得一张合格证书，必须首先获得不少于200分的在线编程作业分，然后总评获得不少于60分（满分100）。总评成绩的计算公式为 `G=(Gmid−term×40%+Gfinal×60%)`，如果 `Gmid−term>Gfinal`；否则总评 `G` 就是 `Gfinal`。这里 `Gmid−term` 和 `Gfinal `分别为学生的期中和期末成绩。

> 现在的问题是，每次考试都产生一张独立的成绩单。本题就请你编写程序，把不同的成绩单合为一张。

#### 输入格式：

> 输入在第一行给出3个整数，分别是 `P`（做了在线编程作业的学生数）、`M`（参加了期中考试的学生数）、`N`（参加了期末考试的学生数）。每个数都不超过10000。

> 接下来有三块输入。第一块包含 `P` 个在线编程成绩 `Gp`；第二块包含 `M` 个期中考试成绩 `Gmid−term`；第三块包含` N` 个期末考试成绩 `Gfinal`。每个成绩占一行，格式为：`学生学号 分数`。其中`学生学号`为不超过20个字符的英文字母和数字；`分数`是非负整数（编程总分最高为900分，期中和期末的最高分为100分）。

#### 输出格式：

> 打印出获得合格证书的学生名单。每个学生占一行，格式为：

> `学生学号` `Gp` `Gmid−term` `Gfinal` `G`

> 如果有的成绩不存在（例如某人没参加期中考试），则在相应的位置输出“`−1`”。输出顺序为按照总评分数（四舍五入精确到整数）递减。若有并列，则按学号递增。题目保证学号没有重复，且至少存在1个合格的学生。

#### 输入样例：

```
6 6 7
01234 880
a1903 199
ydjh2 200
wehu8 300
dx86w 220
missing 400
ydhfu77 99
wehu8 55
ydjh2 98
dx86w 88
a1903 86
01234 39
ydhfu77 88
a1903 66
01234 58
wehu8 84
ydjh2 82
missing 99
dx86w 81
```

#### 输出样例：

```
missing 400 -1 99 99
ydjh2 200 98 82 88
dx86w 220 88 81 84
wehu8 300 55 84 84
```

## 通过代码

```c++
#include <iostream>
#include <map>
#include <algorithm>
#include <vector>
#include <cmath>
using namespace std;
class data {
public:
    double Gp, GmidTerm, Gfinal, G;
    string name;
    data() { G = -1; Gfinal = -1; Gp = -1; GmidTerm = -1; }
    void setGp(double a) {Gp = a;}
    void setGmidTerm(double a) {GmidTerm = a;}
    void setGfinal(double a) {Gfinal = a;}
    void setName(string n) { name = n; }
    void final() {
        if (GmidTerm > Gfinal) G = GmidTerm * 0.4 + Gfinal * 0.6;
        else G = Gfinal;
        G = round(G);
        GmidTerm = round(GmidTerm);
        Gfinal = round(Gfinal);
        Gp = round(Gp);
    }
};
typedef pair<string, data> PAIR;
bool cmp1(PAIR& a, PAIR& b) {
    if (a.second.G != b.second.G) return a.second.G > b.second.G;
    else return a.second.name < b.second.name;
}
int main () {
    map<string, data> m;
    int a, b, c;
    double score;
    string name;
    cin >> a >> b >> c;
    for (int i = 0; i < a; i++) {
        cin >> name >> score;
        m[name].setGp(score);
        m[name].setName(name);
    }
    for (int i = 0; i < b; i++) {
        cin >> name >> score;
        m[name].setGmidTerm(score);
    }
    for (int i = 0; i < c; i++) {
        cin >> name >> score;
        m[name].setGfinal(score);
        m[name].final();
    }
    vector<PAIR> v;
    int i = 0;
    for (map<string, data>::iterator ite = m.begin(); ite != m.end(); ite++, i++)
        v.push_back(*ite);
    sort(v.begin(), v.end(), cmp1);
    for (int i = 0; i < v.size(); i++)
        if (v[i].second.Gp >= 200 && v[i].second.G >= 60)
            printf ("%s %.0lf %.0lf %.0lf %.0lf\n", v[i].second.name.data(), v[i].second.Gp, v[i].second.GmidTerm, v[i].second.Gfinal, v[i].second.G);
    return 0;
}
```

## 思路与注意

1.  利用类来管理数据，比较方便
    
2.  第一个难点在于ID不是纯数字，不能把ID当做数组引索，想到使用map
    
3.  第二个难点在于对map排序，map是默认以key排序的，这道题要对map的value进行排序
    
4.  注意，数据输入并计算好以后，先四舍五入（round() 函数），再排序输出。
    

## 反思与评价

-   学到了很多关于map的知识
    
-   刚开始不用vector用普通数组的时候，最后一个测试点出现段错误，不知道是什么问题。
    

## 收获

1.  map的排序
    
    1.  map默认按照key进行升序排序，和输入的顺序无关。如果是int/double等数值型为key，那么就按照大小排列；如果是string类型，那么就按照字符串的字典序进行排列
        
    2.  我们在定义map类模板的时候不是只有两个参数吗~（`map<string, int>`）~~其实map一共有4个参数，后面省略的，或者说是默认的第三个参数就是关于排序规则的
        
    3.  具体而言，它有四个参数，其中我们比较熟悉的有两个: Key 和 Value。第三个是`class Compare = less<Key>`(排序方式)，第四个是 Allocator，用来定义存储分配模型的。
        
    4.  对key进行自定义排序
        
    5.  map不能调用sort排序，是因为：map是个关联容器，不是序列容器。像是一些序列容器list, vector都是可以排序的。
        
    6.  对map的value排序的想法
        > 1.  首先，map中的<key, value>是pair形式的，那么我们就可以把一个pair作为vector中的元素；
        > 2.  然后，调用vetor容器中的sort函数，sort函数也是可以用户指定比较类型的。

> 对key进行自定义排序
```c++
#include<iostream>
#include<string>
#include<algorithm>
#include<map>
using namespace std;

struct cmp  //自定义比较规则
{
    bool operator() (const string& str1, const string& str2)
    {
        return str1.length() < str2.length();
    }
};

int main()
{
    map<string, int, cmp > scoreMap;  //这边调用cmp
    map<string, int, cmp >::iterator iter;

    scoreMap["LiMin"] = 90;
    scoreMap["ZZihsf"] = 95;
    scoreMap["Kim"] = 100;
    scoreMap.insert(map<string, int>::value_type("Jack", 88));

    for (iter = scoreMap.begin(); iter != scoreMap.end(); iter++)
        cout << iter->first << ' ' << iter->second << endl;

    return 0;
}
```
> 根据value排序
```c++
#include<iostream>
#include<string>
#include<algorithm>
#include<map>
#include<vector>
using namespace std; 
 
typedef pair<string, int> PAIR; 
 
struct cmp  //自定义比较规则
{
	bool operator() (const PAIR& P1, const PAIR& P2)  //注意是PAIR类型，需要.firt和.second。这个和map类似
	{
		return P1.second < P2.second; 
	}
};
 
 
int main()
{
	map<string, int> scoreMap;  //这边调用cmp  
	map<string, int>::iterator iter; 
 
	scoreMap["LiMin"] = 90; 
	scoreMap["ZZihsf"] = 95; 
	scoreMap["Kim"] = 100;
	scoreMap.insert(map<string, int>::value_type("Jack", 88)); 
 
	vector<PAIR>scoreVector; 
	for(iter=scoreMap.begin(); iter!=scoreMap.end();iter++)  //这边本来是使用vector直接初始化的，当时由于vc 6.0 编译器问题，只能这样写，而且还有非法内存。。
		scoreVector.push_back(*iter); 
	//转化为PAIR的vector
	sort(scoreVector.begin(), scoreVector.end(), cmp());  //需要指定cmp
 
	for(int i=0; i<=scoreVector.size(); i++)  //也要按照vector的形式输出
		cout<< scoreVector[i].first<<' '<<scoreVector[i].second <<endl; 
 
	/*
	for(iter=scoreMap.begin(); iter!=scoreMap.end(); iter++)
		cout<<iter->first<<' '<<iter->second<<endl; 
	*/
 
	return 0; 
}
```
2.  四舍五入函数（其实早就学过，偷懒没有记）
    
    1.  round();
        
    2.  头文件 cmath
        

## 参考文献

[CSDN——STL容器（三）——对map排序](https://blog.csdn.net/puqutogether/article/details/41889579)
