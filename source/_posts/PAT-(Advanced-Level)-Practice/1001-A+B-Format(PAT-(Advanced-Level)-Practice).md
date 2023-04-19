---
title: PTA-Advance-1001
date: 2019-07-13 21:15:36
tags: PAT-(Advanced-Level)-Practice
categories: PAT-(Advanced-Level)-Practice
toc: true
language: zh-CN
---

## PROBLEM

Calculate a+b and output the sum in standard format -- that is, the digits must be separated into groups of three by commas (unless there are less than four digits).

#### Input Specification:

Each input file contains one test case. Each case contains a pair of integers a and b where $−10^6≤a,b≤10^6$. The numbers are separated by a space.

#### Output Specification:

For each test case, you should output the sum of a and b in one line. The sum must be written in the standard format.

#### Sample Input:

```
-1000000 9
```

#### Sample Output:

```
-999,991
```

## ACCEPTED CODE
```c++
#include <iostream>
using namespace std;
int main () {
	int a, b;
	string ans;
	char temp[32] = {0};
	scanf ("%d%d", &a, &b);
	int c = a + b;
	sprintf(temp, "%d", c);
	ans = temp;
	for (int i = ans.length() - 1, count = 1; i > 0; i--, count++)
		if (count % 3 == 0 && ans[i - 1] != '-')
			ans.insert(i, 1, ',');
	printf ("%s", ans.data());
	return 0;
}
```
## THINKING AND NOTICE

1.  Insert a comma every 3 character.
    
2.  Traversal the string from the end of it.
    
3.  If the result of `a+b` is negative, check that there are no negative sign `-` before inserting a comma`,`.
    

## REFLECTION AND COMMENTS

-   Relatively easy.
-  Hope that I can stick to using English to write articles.
