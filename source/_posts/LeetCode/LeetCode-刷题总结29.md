---
title: LeetCode-29
date: 2023-12-1 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## [2661. 找出叠涂元素](https://leetcode.cn/problems/first-completely-painted-row-or-column/description/?envType=daily-question&envId=2023-12-01)
```c++
class Solution {
public:
    int firstCompleteIndex(vector<int>& arr, vector<vector<int>>& mat) {
        int m = mat.size(), n = mat[0].size();
        vector<int> cnt_row(m, 0), cnt_col(n, 0);
        vector<int> index(m*n+1);
        for(int i = 0; i < m; i++) {
            for(int j = 0; j < n; j++) {
                index[mat[i][j]] = i*n+j;
            }
        }
        int len = arr.size();
        for(int i = 0; i < len; i++) {
            int x = index[arr[i]]/n, y = index[arr[i]]%n;
            cnt_row[x]++;
            cnt_col[y]++;
            if(cnt_row[x] == n || cnt_col[y] == m) return i;
        }
        return -1;
    }
};
```

## [1657. 确定两个字符串是否接近](https://leetcode.cn/problems/determine-if-two-strings-are-close/description/?envType=daily-question&envId=2023-11-30)

```c++
class Solution {
public:
    inline bool logicXor(bool a, bool b) {
        return (a && !b) || (b && !a);
    }
    bool closeStrings(string word1, string word2) {
        vector<int> word1_cnt(26, 0), word2_cnt(26, 0);
        for(char c : word1) {
            word1_cnt[c - 'a']++;
        }
        for(char c : word2) {
            word2_cnt[c - 'a']++;
        }
        for(int i = 0; i < 26; i++) {
            if(logicXor(word1_cnt[i] == 0, word2_cnt[i] == 0)) return false;
        }
        sort(word1_cnt.begin(), word1_cnt.end());
        sort(word2_cnt.begin(), word2_cnt.end());
        for(int i = 0; i < 26; i++) {
            if(word1_cnt[i] != word2_cnt[i]) return false;
        }
        return true;
    }
};
```

## [2336. 无限集中的最小数字](https://leetcode.cn/problems/smallest-number-in-infinite-set/description/?envType=daily-question&envId=2023-11-29)

```c++
class SmallestInfiniteSet {
    vector<pair<unsigned, unsigned>> s;
public:
    SmallestInfiniteSet() {
        s.emplace_back(1, -1);
    }
    
    int popSmallest() {
        int smallest = s[0].first++;
        if(s[0].first == s[0].second) {
            s.erase(s.begin());
        }
        return smallest;
    }
    
    void addBack(int num) {
        // cout << "add\n";
        int n = s.size();
        int i = 0;
        while(i < n && s[i].second <= num) i++;
        if(i >= n) {
            s.emplace_back(num, num + 1);
            return;
        }
        if(s[i].first <= num) {
            return;
        } else {
            if(s[i].first-1 == num) {
                s[i].first--;
                // 检查前面的，拼接
                if(i-1 >= 0 && s[i-1].second == s[i].first) {
                    s[i-1].second = s[i].second;
                    s.erase(s.begin() + i);
                }
            } else {
                if(i - 1 >= 0 && s[i-1].second == num) {
                    s[i-1].second++;
                } else {
                    s.insert(s.begin() + i, make_pair(num, num+1));
                }
            }
        }
    }
};

/**
 * Your SmallestInfiniteSet object will be instantiated and called as such:
 * SmallestInfiniteSet* obj = new SmallestInfiniteSet();
 * int param_1 = obj->popSmallest();
 * obj->addBack(num);
 */
```

## [1670. 设计前中后队列](https://leetcode.cn/problems/design-front-middle-back-queue/description/?envType=daily-question&envId=2023-11-28)

```c++
class FrontMiddleBackQueue {
    deque<int> leftHalf, rightHalf;
    int leftHalfLen = 0, rightHalfLen = 0;
public:
    FrontMiddleBackQueue() {

    }
    
    void pushFront(int val) {
        leftHalf.push_front(val);
        if(leftHalfLen - rightHalfLen > 0) {
            rightHalf.push_front(leftHalf.back());
            leftHalf.pop_back();
            rightHalfLen++;
        } else {
            leftHalfLen++;
        }
    }
    
    void pushMiddle(int val) {
        if(leftHalfLen > rightHalfLen) {
            rightHalf.push_front(leftHalf.back());
            leftHalf.pop_back();
            leftHalf.push_back(val);
            rightHalfLen++;
        } else {
            leftHalf.push_back(val);
            leftHalfLen++;
        }
    }
    
    void pushBack(int val) {
        rightHalf.push_back(val);
        if(rightHalfLen >= leftHalfLen) {
            leftHalf.push_back(rightHalf.front());
            rightHalf.pop_front();
            leftHalfLen++;
        } else {
            rightHalfLen++;
        }
    }
    
    int popFront() {
        int ret = -1;
        if(leftHalfLen <= 0) {
            if(rightHalfLen > 0) {
                ret = rightHalf.front();
                rightHalf.pop_front();
                rightHalfLen--;
            }
        } else {
            ret = leftHalf.front();
            leftHalf.pop_front();
            if(leftHalfLen <= rightHalfLen) {
                leftHalf.push_back(rightHalf.front());
                rightHalf.pop_front();
                rightHalfLen--;
            } else {
                leftHalfLen--;
            }
        }
        return ret;
    }
    
    int popMiddle() {
        int ret = -1;
        if(leftHalfLen >= rightHalfLen) {
            if(leftHalfLen == 0) return -1;
            ret = leftHalf.back();
            leftHalf.pop_back();
            leftHalfLen--;
        } else {
            ret = rightHalf.front();
            rightHalf.pop_front();
            rightHalfLen--;
        }
        return ret;
    }
    
    int popBack() {
        int ret = -1;
        if(rightHalfLen <= 0) {
            if(leftHalfLen > 0) {
                ret = leftHalf.back();
                leftHalf.pop_back();
                leftHalfLen--;
            }
        } else {
            ret = rightHalf.back();
            rightHalf.pop_back();
            if(leftHalfLen > rightHalfLen) {
                rightHalf.push_front(leftHalf.back());
                leftHalf.pop_back();
                leftHalfLen--;
            } else {
                rightHalfLen--;
            }
        }
        return ret;
    }
};

/**
 * Your FrontMiddleBackQueue object will be instantiated and called as such:
 * FrontMiddleBackQueue* obj = new FrontMiddleBackQueue();
 * obj->pushFront(val);
 * obj->pushMiddle(val);
 * obj->pushBack(val);
 * int param_4 = obj->popFront();
 * int param_5 = obj->popMiddle();
 * int param_6 = obj->popBack();
 */
```

## [1094. 拼车](https://leetcode.cn/problems/car-pooling/description/?envType=daily-question&envId=2023-12-02)

```c++
class Solution {
public:
    bool carPooling(vector<vector<int>>& trips, int capacity) {
        vector<int> max_capacity(1002, 0);
        int max_end = 0;
        int min_start = 1002;
        int len = trips.size();
        for(int i = 0; i < len; i++) {
            max_capacity[trips[i][1]] += trips[i][0];
            max_capacity[trips[i][2]] -= trips[i][0];
            max_end = max(trips[i][2], max_end);
            min_start = min(trips[i][1], min_start);
        }
        int cur_capacity = 0;
        for(int i = min_start; i <= max_end; i++) {
            cur_capacity += max_capacity[i];
            if(cur_capacity > capacity) return false;
        }
        return true;
    }
};
```

## 1423. 可获得的最大点数
```c++
class Solution {
public:
    int maxScore(vector<int>& cardPoints, int k) {
        int maxSum = 0;
        int sum = 0;
        int len = cardPoints.size();
        for(int i = 0; i < k; i++) {
            sum += cardPoints[i];
        }
        maxSum = sum;
        for(int i = 0; i < k; i++) {
            sum -= cardPoints[k - 1 - i];
            sum += cardPoints[len - 1 - i];
            maxSum = max(maxSum, sum);
        }
        return maxSum;
    }
};
```

```c++
class Solution {
public:
    int maxScore(vector<int> &cardPoints, int k) {
        int n = cardPoints.size();
        int m = n - k;
        int s = accumulate(cardPoints.begin(), cardPoints.begin() + m, 0);
        int min_s = s;
        for (int i = m; i < n; i++) {
            s += cardPoints[i] - cardPoints[i - m];
            min_s = min(min_s, s);
        }
        return accumulate(cardPoints.begin(), cardPoints.end(), 0) - min_s;
    }
};
```