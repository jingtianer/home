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

## 1185. 一周中的第几天

- [梦回大一](https://leetcode.cn/problems/day-of-the-week/?envType=daily-question&envId=2023-12-30)

```c++
class Solution {
public:
    string dayOfTheWeek(int day, int month, int year) {
        int week = 0;
        for(int i = 1971; i < year; i++) {
            week = (week + 31 * 7 + 30 * 4 + 28) % 7;
            if((i % 100 != 0 && i % 4 == 0) || i % 400 == 0) {
                week = (week + 1) % 7;
            }
        }
        for(int i = 1; i < month; i++) {
            if(i == 2) {
                week = (week + 28) % 7;
                if((year % 100 != 0 && year % 4 == 0) || year % 400 == 0) {
                    week = (week + 1) % 7;
                }
            } else if(i == 1 || i == 3 || i == 5 || i == 7 || i == 8 || i == 10 || i == 12) {
                week = (week + 31) % 7;
            } else {
                week = (week + 30) % 7;
            }
        }
        week = (week + day + 4) % 7;
        return vector<string>{"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}[week];
    }
};
```

## [2706. 购买两块巧克力](https://leetcode.cn/problems/buy-two-chocolates/description/?envType=daily-question&envId=2023-12-29)

```c++
class Solution {
public:
    int buyChoco(vector<int>& prices, int money) {
        int minPrice = INT_MAX / 2, secondMinPrice = INT_MAX / 2;
        for(int price : prices) {
            if(price < minPrice) {
                secondMinPrice = minPrice;
                minPrice = price;
            } else if(price < secondMinPrice) {
                secondMinPrice = price;
            }
        }
        return (minPrice + secondMinPrice <= money) ? (money - minPrice - secondMinPrice) : money;
    }
};
```

## [2735. 收集巧克力](https://leetcode.cn/problems/collecting-chocolates/description/?envType=daily-question&envId=2023-12-28)

```c++
class Solution {
public:
    long long minCost(vector<int>& nums, int x) {
        int n = nums.size();
        vector<int> f(nums);
        long long ans = accumulate(f.begin(), f.end(), 0LL);
        for (int k = 1; k < n; ++k) {
            for (int i = 0; i < n; ++i) {
                f[i] = min(f[i], nums[(i + k) % n]);
            }
            ans = min(ans, (long long)(k) * x + accumulate(f.begin(), f.end(), 0LL));
        }
        return ans;
    }
};
```

## [1599. 经营摩天轮的最大利润](https://leetcode.cn/problems/maximum-profit-of-operating-a-centennial-wheel/description/?envType=daily-question&envId=2024-01-01)

### 模拟
- 模拟经营

```c++
class Solution {
public:
    int minOperationsMaxProfit(vector<int>& customers, int boardingCost, int runningCost) {
        int wating = 0;
        int porfit = 0;
        int maxProfit = 0;
        int maxProfitI = -2;
        int len = customers.size();
        int i = 0;
        for(; i < len; i++) {
            if(customers[i] + wating > 4) {
                wating += customers[i] - 4;
                customers[i] = 4;
            } else {
                customers[i] = customers[i] + wating;
                wating = 0;
            }
            porfit += boardingCost * customers[i] - runningCost;
            if(porfit > maxProfit) {
                maxProfit = porfit;
                maxProfitI = i;
            }
        }
        while(wating > 0) {
            int onboard = 0;
            if(wating > 4) {
                onboard = 4;
                wating -= 4;
            } else {
                onboard = wating;
                wating = 0;
            }
            porfit += boardingCost * onboard - runningCost;
            if(porfit > maxProfit) {
                maxProfit = porfit;
                maxProfitI = i;
            }
            i++;
        }
        return maxProfitI+1;
    }
};
```
### 优化

- 数组遍历结束后，剩下的乘客可以不用模拟，直接/4看有几次就好
- 如果`boardingCost` `runningCost`的值恰好无论如何都无法盈利，可以不算后面的

```c++
class Solution {
public:
    int minOperationsMaxProfit(vector<int>& customers, int boardingCost, int runningCost) {
        int wating = 0;
        int porfit = 0;
        int maxProfit = 0;
        int maxProfitI = -1;
        int len = customers.size();
        int i = 1;
        for(; i <= len; i++) {
            wating += customers[i-1];
            int onboard = min(4, wating);
            wating -= onboard;
            porfit += boardingCost * onboard - runningCost;
            if(porfit > maxProfit) {
                maxProfit = porfit;
                maxProfitI = i;
            }
        }
        int fullCost = (boardingCost << 2) - runningCost;
        if(fullCost <= 0) return maxProfitI;
        if(wating > 0) {
            int ramain = wating % 4;
            int roll = wating >> 2;
            wating = ramain;
            porfit += roll * fullCost;
            i += roll;
            if(porfit > maxProfit) {
                maxProfit = porfit;
                maxProfitI = i - 1;
            }
            porfit += boardingCost * wating - runningCost;
            if(porfit > maxProfit) {
                maxProfit = porfit;
                maxProfitI = i;
            }
        }
        return maxProfitI;
    }
};
```