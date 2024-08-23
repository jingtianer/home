---
title: OI KIWI 01-倍增
date: 2024-8-23 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

[OI KIWI 倍增](https://oi-wiki.org/basic/binary-lifting/)

## 思想

![](https://i-blog.csdnimg.cn/blog_migrate/9f5a2ca762ccf594a9bc5ea7d3851359.jpeg)

> [图片来源](https://blog.csdn.net/bei2002315/article/details/126235995)

## 查找小于limit的最大数字

```c++
int maxValueInVecSmallerThenLimit(vector<int>& vec, int limit) {
    int n = vec.size();
    int l = 0;
    int p = 1;
    while(p) {
        if(l + p < n && vec[l + p] < limit) {
            l += p;
            p <<= 1;
        } else {
            p >>= 1;
        }
    }
    return vec[l];
}
```

- 和二分一样，需要在有序数组上查找
- 对于查找区间`[l, l + p)`
  - 如果`vec[l+p] >= limit`， 则最大值就在`[l, l + p)`区间上,下一步查询`[l, l + p / 2)`
  - 如果`vec[l+p] < limit`， 则最大值不在`[l, l + p)`区间上,下一步查询`[l + p, l + 3*p)`
  - 如果`l+p >= n`, 则缩小查找范围

- 我们把上面的逻辑迭代两次
  - 如果`vec[l+p] >= limit`， 则最大值就在`[l, l + p)`区间上,下一步查询`[l, l + p / 2)`
    - 如果`vec[l+p/2] >= limit`， 则最大值就在`[l, l + p/2)`区间上,下一步查询`[l, l + p / 4)`
    - 如果`vec[l+p/2] < limit`， 则最大值不在`[l, l + p/2)`区间上,下一步查询`[l + p/2, l + p/2 + p)`
  - 如果`vec[l+p] < limit`， 则最大值不在`[l, l + p)`区间上,下一步查询`[l + p, l + 3*p)`
    - 如果`vec[l+3*p] >= limit`， 则最大值就在`[l + p, l + 3*p)`区间上,下一步查询`[l + p, l + 2*p)`
    - 如果`vec[l+3*p] < limit`， 则最大值不在`[l + p, l + 3*p)`区间上,下一步查询`[l + 3 * p, l + 7 * p)`

## RMQ区间最值

Range Maximum/Minimum Query

### 单调栈

```c++
vector<int> RangeMinimumQuery(vector<int>& arr, vector<vector<int>>& queries) {
    stack<int> monoStack;
    int len = arr.size();
    int res = 0;
    vector<int> left(len), right(len, len - 1);
    for(int i = 0; i < len; i++) {
        left[i] = right[i] = i;
        while(!monoStack.empty() && arr[monoStack.top()] >= arr[i]) {
            int top = monoStack.top();
            left[i] = left[top];
            monoStack.pop();
        }
        monoStack.push(i);
    }
    monoStack = stack<int>();
    for(int i = len - 1; i >= 0; i--) {
        while(!monoStack.empty() && arr[monoStack.top()] > arr[i]) {
            int top = monoStack.top();
            right[i] = right[top];
            monoStack.pop();
        }
        monoStack.push(i);
    }
    vector<int> ans;
    for(const auto& query : queries) {
        int l = query[0], r = query[1];
        while(right[l] < r && left[r] > l) {
            l = min(len - 1, right[l] + 1);
            r = max(0, left[r] - 1);
        }
        ans.push_back(min(arr[l], arr[r]));
    }
    return ans;
}
```

### ST表

参考这里：[https://oi-wiki.org/ds/sparse-table/](https://oi-wiki.org/ds/sparse-table/)

## LCA最近公共祖先