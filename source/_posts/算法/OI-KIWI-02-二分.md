---
title: OI KIWI 02-二分
date: 2024-9-1 11:14:34
tags: 
    - OI KIWI
    - 算法
categories: 
    - OI KIWI
    - 算法
toc: true
language: zh-CN
---

## 二分查找

### 左闭右闭
```c++
int binarySearch(vector<int>& vec, int target) {
    int len = vec.size();
    int l = 0, r = len - 1; // 
    while(l <= r) {
        int mid = (r - l) / 2 + l;
        if(vec[mid] == target) {
            return mid;
        } else if(vec[mid] > target) {
            r = mid - 1;
        } else {
            l = mid + 1;
        }
    }
    return -1;
}
```

### 左闭右开

```c++
class Solution {
public:
    int search(vector<int>& nums, int target) {
        int len = nums.size();
        int l = 0, r = len;
        while(l < r) {
            int mid = (r - l) / 2 + l;
            if(nums[mid] == target) {
                return mid;
            } else if(nums[mid] > target) {
                r = mid;
            } else {
                l = mid + 1;
            }
        }
        return -1;
    }
};
```

### 总结
- l和r代表区间，当区间内没有元素时查找结束
  - 对于闭区间，是l > r, 所以循环条件是 l <= r
  - 对于左闭右开区间，是l >= r, 所以循环条件是 l < r
- 区间左/右边界移动，移动到最小的查找区间，也就是区间不包括另一半区间和当前mid值
  - 对于闭区间，r = mid - 1，不包括当前mid值`[l, mid - 1]`
  - 对于左闭右开区间，r = mid，不包括当前mid值`[l, mid)`

## 左侧边界

### 闭区间

如果target在vec中，则找到最后一个target的下标
如果target不在vec中，则找到target应该插入在哪个元素后面

```c++
int binarySearch(vector<int>& vec, int target) {
    int len = vec.size();
    int l = 0, r = len - 1;
    while(l <= r) {
        int mid = (r - l) / 2 + l;
        if(vec[mid] == target) {
            l = mid - 1;
        } else if(vec[mid] > target) {
            r = mid - 1;
        } else {
            l = mid + 1;
        }
    }
    return l;
}
```
- mid != target的情况，正常二分查找
- mid == target， 找target的前驱，所以l = mid - 1（为啥不是mid）