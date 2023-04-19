---
title: PAT-Basic-1068
date: 2019-07-13 21:15:36
tags: PAT-(Basic-Level)-Practice
categories: PAT-(Basic-Level)-Practice
toc: true
language: zh-CN
---

## 题目

> 对于计算机而言，颜色不过是像素点对应的一个 24 位的数值。现给定一幅分辨率为 M×N 的画，要求你找出万绿丛中的一点红，即有独一无二颜色的那个像素点，并且该点的颜色与其周围 8 个相邻像素的颜色差充分大。

#### 输入格式：

> 输入第一行给出三个正整数，分别是 M 和 N（≤ 1000），即图像的分辨率；以及 TOL，是所求像素点与相邻点的颜色差阈值，色差超过 TOL 的点才被考虑。随后 N 行，每行给出 M 个像素的颜色值，范围在 [0,224) 内。所有同行数字间用空格或 TAB 分开。

#### 输出格式：

> 在一行中按照 `(x, y): color` 的格式输出所求像素点的位置以及颜色值，其中位置 `x` 和 `y` 分别是该像素在图像矩阵中的列、行编号（从 1 开始编号）。如果这样的点不唯一，则输出 `Not Unique`；如果这样的点不存在，则输出 `Not Exist`。

#### 输入样例 1：

```
8 6 200
0      0       0        0        0          0           0        0
65280      65280    65280    16711479 65280    65280    65280    65280
16711479 65280    65280    65280    16711680 65280    65280    65280
65280      65280    65280    65280    65280    65280    165280   165280
65280      65280       16777015 65280    65280    165280   65480    165280
16777215 16777215 16777215 16777215 16777215 16777215 16777215 16777215
```

#### 输出样例 1：

```
(5, 3): 16711680
```

#### 输入样例 2：

```
4 5 2
0 0 0 0
0 0 3 0
0 0 0 0
0 5 0 0
0 0 0 0
```

#### 输出样例 2：

```
Not Unique
```

#### 输入样例 3：

```
3 3 5
1 2 3
3 4 5
5 6 7
```

#### 输出样例 3：

```
Not Exist
```

## 通过代码
```c++
#include <iostream>
#include <cmath>
#include <map>
using namespace std;
int main () {
	int m, n, t;
	cin >> n >> m >> t;
	int dot[1005][1005] = {0};
	map<int, int> check;
	for (int i = 0; i < m; i++) {
		for (int j = 0; j < n; j++) {
			cin >> dot[i][j];
			check[dot[i][j]]++;
		}
	}
	int count = 0, x, y;
	for (int i = 0; i < m && count <= 1; i++)
		for (int j = 0; j < n && count <= 1; j++)
			if (abs(dot[i][j] - dot[i + 1][j]) > t && abs(dot[i][j] - dot[i][j + 1]) > t && abs(dot[i][j] - dot[i - 1][j]) > t && abs(dot[i][j] - dot[i][j - 1]) > t)
				if (abs(dot[i][j] - dot[i + 1][j + 1]) > t && abs(dot[i][j] - dot[i + 1][j - 1]) > t && abs(dot[i][j] - dot[i - 1][j + 1]) > t && abs(dot[i][j] - dot[i - 1][j - 1]) > t)
					if (check[dot[i][j]] == 1) {
						count++;
						x = i; y = j;
					}
	if (count > 1) cout << "Not Unique" << endl;
	else if (count == 1) cout << "(" << y + 1 << ", " << x + 1 << "): " << dot[x][y] << endl;
	else cout << "Not Exist" << endl;
	return 0;
}
```
## 注意

-   注意，满足题目条件的点出来要和周围8个差距大于tol以外，这个点的数值只能出现一次
    
-   由于数字最大2^24，int足够
    
-   数组要大于输入的m，n，最后一个测试点和倒数第二个测试点容易挂
