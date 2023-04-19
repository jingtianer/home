---
title: LeetCode-19
date: 2022-11-15 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## [1710. 卡车上的最大单元数](https://leetcode.cn/problems/maximum-units-on-a-truck/)

```c++
class Solution {
public:
    int maximumUnits(vector<vector<int>>& boxTypes, int truckSize) {
        sort(boxTypes.begin(), boxTypes.end(), [](vector<int>& x, vector<int>& y)->bool {
            return x[1] > y[1];
        });
        int n = boxTypes.size();
        int ret = 0;
        for(int i = 0; i < n; i++) {
            if(truckSize) {
                ret += min(truckSize, boxTypes[i][0])*boxTypes[i][1];
                truckSize -= min(truckSize, boxTypes[i][0]);
            } else {
                break;
            }
        }
        return ret;
    }
};
// 50 + 27 + 14 = 91
```

> 简单题，排个序就行

## [775. 全局倒置与局部倒置](https://leetcode.cn/problems/global-and-local-inversions/)

```c++
class Solution {
public:
    bool isIdealPermutation(vector<int>& nums) {
        for (int i = 0; i < nums.size(); i++) {
            if (abs(nums[i] - i) > 1) {
                return false;
            }
        }
        return true;
    }
};
```

> 最开始想复杂了，想用差分数组统计个数

## [39. 组合总和](https://leetcode.cn/problems/combination-sum/)
```c++
class Solution {
public:
    int n;
    int target;
    vector<vector<int>> res;
    vector<vector<int>> combinationSum(vector<int>& candidates, int target) {
        this->target = target;
        n = candidates.size();
        vector<int> vec;
        search(0, 0, vec, move(candidates));
        return res;
    }
    void search(int index, int sum, vector<int> & vec, vector<int>&& candidates) {
        if(sum == target) {
            res.push_back(vec);
            return;
        }
        if(sum > target) return;
        vec.push_back(candidates[index]);
        search(index, sum+candidates[index], vec, move(candidates));
        vec.pop_back();
        if(index+1 < n) {
            search(index+1, sum, vec, move(candidates));
        }
    }
};
```
> 硬搜，不要重复就好了

## [792. 匹配子序列的单词数](https://leetcode.cn/problems/number-of-matching-subsequences/)

### 超时1
```c++
class Solution {
public:
int n;
    int numMatchingSubseq(string s, vector<string>& words) {
        n = s.size();
        int count = 0;
        int len = words.size();
        for(int i = 0; i < len; i++) {
            if(isSubstr(move(s), move(words[i]))) {
                count++;
            }
        }
        return count;
    }
    bool isSubstr(string&& s, string&& word) {
        int nw = word.size();
        vector<vector<int>> dp(n, vector<int>(nw, 0));
        dp[0][0]=(word[0]==s[0]);
        for(int i=1;i<n;i++) {
            dp[i][0] = max(dp[i-1][0], int(word[0]==s[i]));
        }
        for(int i=1;i<nw;i++){
            dp[0][i] = max(dp[0][i-1], int(s[0]==word[i]));
        }
        for(int j = 1; j < nw; j++) {
            for(int i = 1; i < n; i++) {
                dp[i][j] = max(dp[i-1][j-1] + int(s[i] == word[j]),max(dp[i-1][j],dp[i][j-1]));
            }
        }
        //cout << dp[n-1][nw-1] << endl;
        return dp[n-1][nw-1]==nw;
    }
};
```

### 超时2
```c++
class Solution {
public:
int n;
    int numMatchingSubseq(string s, vector<string>& words) {
        n = s.size();
        int count = 0;
        int len = words.size();
        unordered_map<string, bool> m;
        for(int i = 0; i < len; i++) {
            if(m.count(words[i])) {
                count++;
            } else if(isSubstr(move(s), move(words[i]))) {
                m[words[i]] = true;
                count++;
            }
        }
        return count;
    }
    bool isSubstr(string&& s, string&& word) {
        int nw = word.size();
        for(int i = 0, j = 0; i < nw; i++) {
            for(;j<n && word[i] != s[j]; j++);
            if(j == n) return false;
            j++;
        }
        return true;
    }
};
```