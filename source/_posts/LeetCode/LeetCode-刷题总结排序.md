---
title: LeetCode-排序
date: 2024-3-17 11:14:34
tags:
    - LeetCode 
    - 排序
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

> 复习排序算法

![](./images/sort.png)

- 稳定性容易记错的是选择排序
  - 选择排序是从未排序中选择最小的，直接与未排序的第一个交换，所以不稳定
  - 选择排序是从未排序中选择最小的，插入到已排序的后面，就是稳定的

## 先手写一遍常见排序算法

- 比较排序
  - 交换排序
    - 冒泡
    - 快排
  - 插入排序
    - 简单插入
    - 希尔排序
  - 选择排序
    - 简单选择
    - 堆排序
  - 归并排序
    - 二路归并
    - 多路归并
- 非比较排序
  - 计数排序
  - 桶排序
  - 基数排序

```c++
#include <iostream>
#include <bits/stdc++.h>
#include <random>
using namespace std;

template <typename T>
void printVec(const vector<T>& vec, function<string(const T&)> toString);

template<typename T>
void bubbleSort(vector<T>& vec, function<int(const T&, const T&)> compare) {
    int len = vec.size();
    for(int i = 0; i < len; i++) {
        for(int j = 0; j < len - i - 1; j++) {
            if(compare(vec[j], vec[j+1]) > 0) {
                swap(vec[j], vec[j+1]);
            }
        }
    }
}

template<typename T>
void selectSort(vector<T>& vec, function<int(const T&, const T&)> compare) {
    int len = vec.size();
    for(int i = 0; i < len; i++) {
        int minIndex = i;
        for(int j = i+1; j < len; j++) {
            if(compare(vec[minIndex], vec[j]) > 0) {
                minIndex = j;
            }
        }
        swap(vec[i], vec[minIndex]);
    }
}

template<typename T>
void stableSelectSort(vector<T>& vec, function<int(const T&, const T&)> compare) {
    int len = vec.size();
    for(int i = 0; i < len; i++) {
        int minIndex = i;
        for(int j = i+1; j < len; j++) {
            if(compare(vec[minIndex], vec[j]) > 0) {
                minIndex = j;
            }
        }
        T t = vec[minIndex];
        for(int j = minIndex; j > i; j--) {
            vec[j] = vec[j-1];
        }
        vec[i] = t;
    }
}

template<typename T>
void insertSort(vector<T>& vec, function<int(const T&, const T&)> compare) {
    int len = vec.size();
    for(int i = 0; i < len-1; i++) { // 下面是i+1，这里要len-1
        for(int j = i+1; j > 0; j--) {
            if(compare(vec[j], vec[j-1]) < 0) {
                swap(vec[j], vec[j-1]);
            } else {
                break;
            }
        }
    }
}


template<typename T>
void mergeSort(vector<T>& vec, function<int(const T&, const T&)> compare, int start, int end) {
    if(end - start <= 1) return;
    int mid = (end - start) / 2 + start;
    mergeSort(vec, compare, start, mid);
    mergeSort(vec, compare, mid, end);
    // merge
    vector<T> tmp(end - start);
    int cur = 0, i = start, j = mid;
    while(i < mid && j < end) {
        if(compare(vec[i], vec[j]) <= 0) { // 稳定性
            tmp[cur++] = vec[i++];
        } else {
            tmp[cur++] = vec[j++];
        }
    }
    while(i < mid) {
        tmp[cur++] = vec[i++];
    }
    while(j < end) {
        tmp[cur++] = vec[j++];
    }
    for(i = start; i < end; i++) {
        vec[i] = tmp[i - start];
    }
}

template<typename T>
void mergeSort(vector<T>& vec, function<int(const T&, const T&)> compare) {
    int len = vec.size();
    mergeSort(vec, compare, 0, len);
}

template<typename T>
void quickSort(vector<T>& vec, function<int(const T&, const T&)> compare, int start, int end) {
    if(end - start <= 1) return;
    int i = start, j = end - 1;
    while(i < j) {
        while(i < j && compare(vec[i], vec[j]) <= 0) j--;
        swap(vec[j], vec[i]);
        while(i < j && compare(vec[i], vec[j]) <= 0) i++;
        swap(vec[i], vec[j]);
    }
    quickSort(vec, compare, start, i);
    quickSort(vec, compare, i+1, end); // i + 1, 已排序的枢轴就不用了
}

template<typename T>
void quickSort(vector<T>& vec, function<int(const T&, const T&)> compare) {
    int len = vec.size();
    quickSort(vec, compare, 0, len);
}


template<typename T>
void heapAdjust(vector<T>& vec, int i, int end, function<int(const T&, const T&)> compare) {
    for(int j = i; ; ) {
        int largest = j;
        if(j*2+1 < end && compare(vec[largest], vec[j*2+1]) < 0) {
            largest = j*2+1;
        }
        if(j*2+2 < end && compare(vec[largest], vec[j*2+2]) < 0) {
            largest = j*2+2;
        }
        if(j == largest) break;
        swap(vec[j], vec[largest]);
        j = largest;
    }
}

template<typename T>
void heapSort(vector<T>& vec, function<int(const T&, const T&)> compare) {
    int len = vec.size();
    // heapAdjust
//    for(int i = len-1; i > 0; i--) {
//        if(compare(vec[i], vec[(i+1)/2-1]) > 0) {
//            swap(vec[i], vec[(i+1)/2-1]);
//        }
//    } //wrong
    for(int i = len/2; i >= 0; i--) {
        heapAdjust(vec, i, len, compare);
    }
    // sort
    for(int i = len-1; i > 0; i--) {
        swap(vec[0], vec[i]);
        heapAdjust(vec, 0, i, compare);
    }
}

const int MAX_NUMBER = 1000;
const int MIN_NUMBER = -1000;
const int MAX_LEN = 2000000;

template <typename T>
int compare(const T& a, const T& b) {
    if(a == b) return 0;
    else if(a > b) return 1;
    else return -1;
}
template <typename T>
void printVec(const vector<T>& vec, function<string(const T&)> toString) {
    cout << "[";
    if(vec.size() > 0) cout << toString(vec[0]);
    for(size_t i = 1; i < vec.size(); i++) {
        cout << ", " << toString(vec[i]);
    }
    cout << "]\n";
}
clock_t execTime(const function<void(vector<pair<int, int>> &)>& f, vector<pair<int, int>> &vec) {
    clock_t start = clock();
    f(vec);
    clock_t end = clock();
    return end - start;
}

void speedTest(decltype(bubbleSort<pair<int, int>>) sort, vector<pair<int, int>> &a, vector<pair<int, int>> b) {
    auto cmp = [](const pair<int, int>& x, const pair<int, int>& y){ return compare(x.first, y.first); };
    clock_t our = execTime([&](vector<pair<int, int>> & vec) {sort(vec, cmp);}, a);
    clock_t libc = execTime([](vector<pair<int, int>> & vec) {std::sort(vec.begin(), vec.end());}, b);
    cout << "our: " << our << ", libc: " << libc << ", promoted: " << double(libc - our) / double(libc) * 100 << "%" << endl;
}

void test(decltype(bubbleSort<pair<int, int>>) sort, bool is_stable) {
    int len = rand() % MAX_LEN;
    vector<pair<int, int>> vec;
    map<int, int> cnt;
    for(int i = 0; i < len; i++) {
        int num = rand() % (MAX_NUMBER - MIN_NUMBER) + MIN_NUMBER;
        vec.emplace_back(num, ++cnt[num]);
    }

    speedTest(sort, vec, vec);

    bool stability = true, ok = true;
    for(int i = 0; i < len - 1; i++) {
        cnt[vec[i].first]--;
        if(compare(vec[i].first, vec[i+1].first) > 0) {
            ok = false;
        } else if(compare(vec[i].first, vec[i+1].first) == 0) {
            if(vec[i].second + 1 != vec[i+1].second) {
                stability = false;
            }
        }
    }
    if(len > 0) cnt[vec[len-1].first]--;
    for(auto & ite : cnt) {
        if(ite.second != 0) {
            ok = false;
            break;
        }
    }
//    cout << "ok: " << ok << ", stable: " << stability << endl;
    if(!ok) {
        printVec<pair<int, int>>(vec, [](const pair<int, int>& item) {
            stringstream ss;
            ss << "{" << item.first << ", " << item.second << "}";
            return ss.str();
        });
        throw runtime_error("sort failed!\n");
    }
    if(is_stable && !stability) {
        throw runtime_error("stability not match");
    }
}
int main() {
    srand(time(NULL));
    test(bubbleSort, true);
    test(selectSort, false);
    test(stableSelectSort, true);
    test(insertSort, true);
    test(mergeSort, true);
    test(quickSort, false);
    test(heapSort, false);
}
```