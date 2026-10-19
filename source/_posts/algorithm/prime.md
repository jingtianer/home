---
title: d-进制反转素数
date: 2022-10-05 23:11:15 +0800
tags: 算法
categories: 算法
toc: true
language: zh-CN
---

## 算法内容

本文件实现素数判断和进制反转判断。程序持续读取 `n` 和进制 `d`，判断 `n` 是否为素数，以及 `n` 在 d 进制下反转后的数是否也为素数。

`initPrimes` 预生成前 `MAX_PRIME` 个素数；`isPrime` 在素数表中二分查找目标数；`reverse` 按 d 进制逐位取余并重新累积，得到反转后的数。主循环输出 `Yes` 或 `No`。这个写法适合数值范围受控的题目；如果输入可能超过预生成素数表覆盖范围，则需要改成按平方根试除或扩大素数表。

## 算法实现

```c++
#include<bits/stdc++.h>
#include<iostream>
using namespace std;

int reverse(int n, int d) {
    int res = 0;
    while(n != 0) {
        res *= d;
        res += n % d;
        n /= d;
    }
    return res;
}

const int MAX_PRIME = 10000;
int primes[MAX_PRIME] = {0};
int primeCount = 0;
void initPrimes() {
    primes[0] = 2;
    primes[1] = 3;
    primeCount = 2;
    for(int i = 5; primeCount < MAX_PRIME; i+=2) {
        primes[primeCount] = i;
        primeCount++;
        for(int j = 0; j < primeCount && primes[j]*primes[j] <= i; j++) {
            if(i%primes[j] == 0) {
                primeCount--;
                break;
            }
        }
    }
}

bool isPrime(int n) {
    int l = 0, r = primeCount;
    while(l <= r) {
        int mid = (r-l)/2 + l;
        if(primes[mid] == n) return true;
        else if(primes[mid] > n) r = mid-1;
        else l = mid+1;
    }
    return false;
}

int main() {
    int n, d;
    initPrimes();
    while(cin >> n >> d) {
        if(isPrime(n) && isPrime(reverse(n, d))) {
            cout << "Yes" << endl;
        } else {
            cout << "No" << endl;
        }
    }
    return 0;
}
```
