---
title: PAT-Basic-1095
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> PAT 准考证号由 4 部分组成：
> 
> -   第 1 位是级别，即 `T` 代表顶级；`A` 代表甲级；`B` 代表乙级；
>     
> -   第 2~4 位是考场编号，范围从 101 到 999；
>     
> -   第 5~10 位是考试日期，格式为年、月、日顺次各占 2 位；
>     
> -   最后 11~13 位是考生编号，范围从 000 到 999。
>     

> 现给定一系列考生的准考证号和他们的成绩，请你按照要求输出各种统计信息。

#### 输入格式：

> 输入首先在一行中给出两个正整数 N（≤104）和 M（≤100），分别为考生人数和统计要求的个数。

> 接下来 N 行，每行给出一个考生的准考证号和其分数（在区间 [0,100] 内的整数），其间以空格分隔。

> 考生信息之后，再给出 M 行，每行给出一个统计要求，格式为：`类型 指令`，其中
> 
> `类型` 为 1 表示要求按分数非升序输出某个指定级别的考生的成绩，对应的 `指令` 则给出代表指定级别的字母；
> 
> `类型` 为 2 表示要求将某指定考场的考生人数和总分统计输出，对应的 `指令` 则给出指定考场的编号；
> 
> `类型` 为 3 表示要求将某指定日期的考生人数分考场统计输出，对应的 `指令` 则给出指定日期，格式与准考证上日期相同。

#### 输出格式：

> 对每项统计要求，首先在一行中输出 `Case #: 要求`，其中 `#` 是该项要求的编号，从 1 开始；`要求` 即复制输入给出的要求。随后输出相应的统计结果：
> 
> -   `类型` 为 1 的指令，输出格式与输入的考生信息格式相同，即 `准考证号 成绩`。对于分数并列的考生，按其准考证号的字典序递增输出（题目保证无重复准考证号）；
>     
> -   `类型` 为 2 的指令，按 `人数 总分` 的格式输出；
>     
> -   `类型` 为 3 的指令，输出按人数非递增顺序，格式为 `考场编号 总人数`。若人数并列则按考场编号递增顺序输出。
>     

> 如果查询结果为空，则输出 `NA`。

#### 输入样例：

```
8 4
B123180908127 99
B102180908003 86
A112180318002 98
T107150310127 62
A107180908108 100
T123180908010 78
B112160918035 88
A107180908021 98
1 A
2 107
3 180908
2 999
```

#### 输出样例：

```
Case 1: 1 A
A107180908108 100
A107180908021 98
A112180318002 98
Case 2: 2 107
3 260
Case 3: 3 180908
107 2
123 2
102 1
Case 4: 2 999
NA
```

## 通过代码
```c++
#define map unordered_map
#include <iostream>
#include <map>
#include <vector>
#include <algorithm>
using namespace std;
struct POS {
	int Num = 0;
	int Score = 0;
};
struct STU {
	string id;
	int score;
};
typedef pair<string, POS> PAIR;
map<string, POS> Pos;
map<char, vector<STU>> type;
map<string, POS> PosWithTime;
vector<PAIR> vPosWithTime;
void update(STU* ob) {
	string pos = ob->id.substr(1, 3);
	Pos[pos].Num++;
	Pos[pos].Score += ob->score;
	pos = ob->id.substr(1, 9);
	PosWithTime[pos].Num++;
	PosWithTime[pos].Score++;
	type[ob->id[0]].push_back(*ob);
}
bool cmp1(STU& a, STU& b) {
	return (a.score != b.score ? a.score > b.score : a.id < b.id);
}
bool cmp2(PAIR& a, PAIR& b) {
	return (a.second.Num != b.second.Num ? a.second.Num > b.second.Num : a.first < b.first);
}
void final() {
	for (map<char, vector<STU>>::iterator ite = type.begin(); ite != type.end(); ite++)
		sort(ite->second.begin(), ite->second.end(), cmp1);
	for (map<string, POS>::iterator ite = PosWithTime.begin(); ite != PosWithTime.end(); ite++)
		vPosWithTime.push_back(*ite);
	sort(vPosWithTime.begin(), vPosWithTime.end(), cmp2);
}
int one(int num) {
	char grade;
	cin >> grade;
	printf("Case %d: 1 %c\n", num, grade);
	vector<STU>& temp = type[grade];
	if (!temp.size()) return 1;
	for (int i = 0; i < temp.size(); i++)
		printf("%s %d\n", temp[i].id.data(), temp[i].score);
	return 0;
}
int two(int num) {
	string pos;
	cin >> pos;
	printf("Case %d: 2 %s\n", num, pos.data());
	POS& temp = Pos[pos];
	if (!temp.Num) return 1;
	printf("%d %d\n", temp.Num, temp.Score);
	return 0;
}
int three(int num) {
	string date;
	cin >> date;
	printf("Case %d: 3 %s\n", num, date.data());
	int n = 0;
	for (vector<PAIR>::iterator ite = vPosWithTime.begin(); ite != vPosWithTime.end(); ite++) {
		if (ite->first.substr(3, 6) == date) {
			printf("%s %d\n", ite->first.substr(0, 3).data(), ite->second.Num);
			n++;
		}
	}
	if (!n) return 1;
	return 0;
}
int main() {
	int n, m;
	scanf("%d%d", &n, &m);
	STU temp;
	for (int i = 0; i < n; i++) {
		char str[1024];
		scanf ("%s%d", str, &temp.score);
		temp.id = str;
		update(&temp);
	}
	final();
	for (int i = 0; i < m; i++) {
		int ins, result;
		scanf ("%d", &ins);
		getchar();
		if (ins == 1) result = one(i + 1);
		else if (ins == 2) result = two(i + 1);
		else result = three(i + 1);
		if (result) printf("NA\n");
	}
	return 0;
}
```
## 思路与注意
1.  建立两个结构体
    1.  考场`POS`，储存考场人数`Num`，所有人的总分`Score`
    2.  学生`STU`，储存考号`id`，分数`score`
2.  建立三个映射map
    1.  `Pos`考场号（string）`->`考场（POS），给第二个功能用的，引索是考场号
    2.  `type`等级（char）`->`学生（STU）向量（vector），每个等级对应一个vector
    3.  `PosWithTime`考场号+时间（string）`->`考场（POS），引索是考场+时间，这样可以保证是某一天的某教室的人数。
3.  不单独创建vector储存学生信息，每次输入后，利用updata()函数，向以上三个映射map中更新数据（增加`POS` 的`Score`、某一等级的学生信息）
4.  最后一次性把所有数据全部排好序（利用final()函数）（`vPosWithTime`就是为了给`PosWithTime`排序的）（type这个map中的所有vector按照要求排序），防止数据反复拷贝、遍历。
5.  每个功能一个函数，计算输出
6.  使用printf和scanf，防止后两个测试点超时
## 反思与评价
这道题写了一下午，主要犯了以下错误
-   逻辑问题。对于类型二的输出，没有考虑到一间考场可以对应多场考试。刚开始想要用类，搞一个类的静态变量（从考场号到考场结构体变量的map映射），在一遍输入，一边构造了对象，就利用该对象的数据进行分析，然后统计。这时犯了逻辑错误，认为这个map统计的考生数就是某一天的考生数。本地运行的时候也没注意检查。
-   阅读问题。这两道题的最后两个测试点一直超时（之前使用cin，cout的时候），然后去看了csdn上一位大佬的代码。没发现跟自己的算法的区别。后来仔细读了TA的文章后，才反应过来是由于`cin`和`cout`的巴拉巴拉巴拉的原因。然后我把所有的`cin`和`cout`换成`printf`和`scanf`，就不超时了。
# 真·真开心！（不认识“真”了）
