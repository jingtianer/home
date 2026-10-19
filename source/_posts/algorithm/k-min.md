---
title: k-min 第 k 小元素查找
date: 2022-10-05 23:11:15 +0800
tags: 算法
categories: 算法
toc: true
language: zh-CN
---

## 算法内容

本文件实现基于快速选择思想的第 k 小元素查找。输入阶段会先用布尔数组去重，再在去重后的数组中查找第 k 小值。

`partition` 使用类似快速排序的双指针划分，把基准元素放到最终位置；`searchK` 根据基准位置和目标下标 `k` 的关系，只递归进入包含目标的半边区间，而不是完整排序。平均时间复杂度为 O(n)，最坏情况下为 O(n^2)。代码中会打印每次划分后的数组和基准位置，方便观察快速选择过程。

## 算法实现

```c++
#include<iostream>
#include<vector>
#include<algorithm>

using namespace std;

int partition(vector<int>& v, int l, int r) {
    int i = l;
    while(l<r) {
        while(r > l && v[r] >= v[i]) {
            r--;
        }
        swap(v[i], v[r]);
        i = r;
        while(r > l && v[l] <= v[i]) {
            l++;
        }
        swap(v[i], v[l]);
        i = l;
    }
    return i;
}

void searchK(vector<int>& v, int k, int l, int r) {
    //partition
    int n = partition(v,l,r);
    for(int i = 0; i < v.size(); i++) {
        cout << v[i] << " ";
    }
    cout << endl<< n;
    cout << endl;
    //search
    if(n > k) {
        searchK(v, k, l, n-1);
    } else if(n < k) {
        searchK(v, k, n+1, r);
    }
}
int main() {
    int n,k;
    cin >> n;
    vector<int> v;
    vector<bool> has(1001, false);
    for(int i = 0; i < n; i++) {
        int x;
        cin >> x;
        if(!has[x]) {
            has[x] = true;
            v.push_back(x);
        }
    }
    cin >> k;
    k--;
    searchK(v, k, 0, v.size()-1);
    cout << v[k];
    return 0;
}
```
