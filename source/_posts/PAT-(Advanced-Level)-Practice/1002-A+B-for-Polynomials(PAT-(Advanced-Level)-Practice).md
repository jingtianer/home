---
title: PTA-Advance-1002
date: 2019-07-13 21:15:36
tags: PAT-(Advanced-Level)-Practice
categories: PAT-(Advanced-Level)-Practice
toc: true
language: zh-CN
---

## PROBLEM

This time, you are supposed to find A+B where A and B are two polynomials.

#### Input Specification:

Each input file contains one test case. Each case occupies 2 lines, and each line contains the information of a polynomial:

K N1 aN1 N2 aN2 ... NK aNK

where K is the number of nonzero terms in the polynomial, Ni and aNi (i=1,2,⋯,K) are the exponents and coefficients, respectively. It is given that 1≤K≤10，0≤NK<⋯<N2<N1≤1000.

#### Output Specification:

For each test case you should output the sum of A and B in one line, with the same format as the input. Notice that there must be NO extra space at the end of each line. Please be accurate to 1 decimal place.

#### Sample Input:

```
2 1 2.4 0 3.2
2 2 1.5 1 0.5
```

#### Sample Output:

```
3 2 1.5 1 2.9 0 3.2
```

## ACCEPTED CODE
```c++
#include <iostream>
#include <map>
using namespace std;
int main () {
	map<int , double, greater<int>> m;
	int k, count = 0;
	cin >> k;
	for (int i = 0; i < k; i++) {
		double exp , cof;
		cin >> exp >> cof;
		m[exp] += cof;
	}
	cin >> k;
	for (int i = 0; i < k; i++) {
		double exp , cof;
		cin >> exp >> cof;
		m[exp] += cof;
		if (m[exp] == 0) count++;//if this item is zero, count++
	}
	printf ("%d", m.size() - count);//print the nonzero item num, if result is zero, print zero
	for (map<int, double>::iterator ite = m.begin(); ite != m.end(); ite++) {
		if (ite->second != 0)//if this item is zero, do not print
			printf (" %d %.1lf", ite->first, ite->second);
	}
	return 0;
}
```
## THINKING AND NOTICES

1.  Creating a map from the exponents to coefficients. Add up the two coefficients of each exponents.
    
2.  Print a zero(the total number of nonzero items) if the result of a+b is zero.
    
3.  Map will sort your data by the keys in declining order, but you should print it in increasing order, so give map the third parameter -- the class or struct name which has a member function like this:`bool operator() (const double& str1, const double& str2);`, a function (I'm not sure.) `greater<int>` ,or you can simply traversal the map from the end of it.

## REFLECTION AND COMMENT

-   Noting to reflect.
