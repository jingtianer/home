---
title: PAT-Basic-1090
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> 集装箱运输货物时，我们必须特别小心，不能把不相容的货物装在一只箱子里。比如氧化剂绝对不能跟易燃液体同箱，否则很容易造成爆炸。
> 
> 本题给定一张不相容物品的清单，需要你检查每一张集装箱货品清单，判断它们是否能装在同一只箱子里。

#### 输入格式：

> 输入第一行给出两个正整数：N (≤104) 是成对的不相容物品的对数；M (≤100) 是集装箱货品清单的单数。
> 
> 随后数据分两大块给出。第一块有 N 行，每行给出一对不相容的物品。第二块有 M 行，每行给出一箱货物的清单，格式如下：

```
K G[1] G[2] ... G[K]
```

> 其中 `K` (≤1000) 是物品件数，`G[i]` 是物品的编号。简单起见，每件物品用一个 5 位数的编号代表。两个数字之间用空格分隔。

#### 输出格式：

> 对每箱货物清单，判断是否可以安全运输。如果没有不相容物品，则在一行中输出 `Yes`，否则输出 `No`。

#### 输入样例：

```
6 3
20001 20002
20003 20004
20005 20006
20003 20001
20005 20004
20004 20006
4 00001 20004 00002 20003
5 98823 20002 20003 20006 10010
3 12345 67890 23333
```

#### 输出样例：

```
No
Yes
Yes
```

## 通过代码

```cpp
#include <iostream>
#include <vector>
#include <map>
using namespace std;
int main() {
	int n, k;
	map<int, vector<int>> m;
	scanf("%d%d", &n, &k);
	for (int i = 0; i < n; i++) {
		int x, y;
		scanf("%d%d", &x, &y);
		m[x].push_back(y);
		m[y].push_back(x);
	}
	while (k--) {
		int K, has[100000] = {0};
		scanf("%d", &K);
		vector<int> v(K);
		for (int i = 0; i < K; i++) {
			scanf("%d", &v[i]);
			has[v[i]] = 1;
		}
		bool find = false;
		for (int i = 0; i < v.size(); i++)
			for (int j = 0; j < m[v[i]].size(); j++)
				if (has[m[v[i]][j]]) find = true;
		if (find) printf("No\n");
		else printf ("Yes\n");
	}
	return 0;
}
```

## 思路与注意

1.  搞一个数组has，用id当引索，储存是否存在这个物品
    
2.  搞一个map映射，从id到一个vector，vector为与这个物品不共存的物品编号（可能存在多个不共存物体）
    
3.  两层for循环，利用has数组，跟自己不共存的物品穿上有没有，如果有，就结束
    

## 反思与评价

-   这道题本身想用二维数组记录是否配对，这样复杂度为`n * n`，一直过不了
    
-   这道题挺有难度的，也是看了网上的大神才写出来的
