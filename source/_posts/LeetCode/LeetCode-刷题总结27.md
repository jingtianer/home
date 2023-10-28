---
title: LeetCode-27
date: 2023-10-28 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## <font color="orange">[Medium] </font>[29. 两数相除](https://leetcode.cn/problems/divide-two-integers/description/)

### 分析
- 只能用加减法，最朴素的方法是循环相减/加，直到小于0/大于0，计算加/减的次数
- 这样算法是o(n)，考虑到`i+=i`或者`i<<=1`相当于`i*=2`,`i>>=1`相当于`i/=2`
- 只考虑divisor, divident都大于0的情况，先找到整数p，使得 $divisor*2^p <= divident$，$divident-=divisor*2^p, ratio+=2^p$若divident为0，则商为ratio，否则重复上面的过程，直到divident为0。
- 考虑divisor, divident到可能正，可能负，而负数的范围大于正数，直接将所有整数变成负数，并记录符号
- 注意取相反数的时候要用位运算`~x+1`
- 
### 代码
```c++
class Solution {
public:
    int divide(int dividend, int divisor) {
        if(dividend < divisor && dividend > 0) return 0;
        if(dividend > divisor && dividend < 0) return 0;
        if((dividend == INT_MIN) && (divisor == -1)) return INT_MAX;
        if((dividend == INT_MIN) && (divisor == 1)) return INT_MIN;
        if(dividend == divisor) return 1;
        if(dividend < 0 && divisor > 0 && dividend == ~divisor+1) return -1;
        if(dividend > 0 && divisor < 0 && ~dividend+1 == divisor) return -1;
        bool sign = false;
        if(dividend < 0) {
            sign = !sign;
        } else {
            dividend = ~dividend+1;
        }
        if(divisor < 0) {
            sign = !sign;
        } else {
            divisor = ~divisor+1;
        }
        int res = 0;
        int i = -1;
        while(dividend < divisor && divisor >= (INT_MIN >> 1)) {
            divisor += divisor;
            i+=i;
        }
        while(true) {
            while(dividend > divisor) {
                if(i == -1) {
                    return sign ? (res) : (~res+1);
                }
                divisor >>= 1;
                i>>=1;
            }
            dividend -= divisor;
            res+=i;
        }
    }
};
```