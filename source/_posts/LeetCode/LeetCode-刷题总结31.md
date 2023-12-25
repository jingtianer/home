---
title: LeetCode-31
date: 2023-12-25 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## [1276. 不浪费原料的汉堡制作方案](https://leetcode.cn/problems/number-of-burgers-with-no-waste-of-ingredients/description/?envType=daily-question&envId=2023-12-25)

- 解方程，判断是非负整数解就行
- 用位运算，能快一点

```c++
class Solution {
public:
    vector<int> numOfBurgers(int tomatoSlices, int cheeseSlices) {
        int jumbo = 0, small = 0;
        // jumbo + small == cheeseSlices;
        // 4*jumbo + 2*small == tomatoSlices;
        small = ((cheeseSlices << 2) - tomatoSlices);
        jumbo = (tomatoSlices - (cheeseSlices << 1));
        if(jumbo >= 0 && small >= 0 && (small & 1) == 0 && (jumbo & 1) == 0)
            return {jumbo >> 1, small >> 1};
        return {};
    }
};
```
