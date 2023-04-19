---
title: LeetCode-24
date: 2023-3-18 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## 1616. 分割两个字符串得到回文串

### ac代码
```c++
class Solution {
public:
    bool checkPalindromeFormation(string a, string b) {
        int len = a.length();
        if(len == 1) return true;
        bool flaga = true, flagb = true;
        int i = 0;
        for(; i < len; i++) {
            if(a[i] == b[len-1-i]) {
            } else {
                break;
            }
        }
        for(int j = i; j < len-1-i; j++) {
            if(b[j] != b[len-1-j]) {
                flagb = false;
                break;
            }
        }
        for(int j = i; j < len-1-i; j++) {
            if(a[j] != a[len-1-j]) {
                flaga = false;
                break;
            }
        }
        if(flaga || flagb) return true;
        flaga = flagb = true;
        for(i = 0; i < len; i++) {
            if(a[len-1-i] == b[i]) {
            } else {
                break;
            }
        }
        for(int j = i; j < len-1-i; j++) {
            if(a[j] != a[len-1-j]) {
                flaga = false;
                break;
            }
        }
        for(int j = i; j < len-1-i; j++) {
            if(b[j] != b[len-1-j]) {
                flagb = false;
                break;
            }
        }
        return flaga || flagb;
    }
};
```

> ab两个字符串在同一个位置分隔开，若 $ pre_a + suf_b $ 或 $ pre_b + suf_a $ 是回文串，则返回true，否则返回false
> 这个规则相当于ab截取相同且任意长的前缀并交换，看交换后是否存在回文
> 我的思路是先比较a的第i位与b的倒数第i位是否想等，找到第一次不相等的位置i，此时可以从第i位分割，判断b的剩余部分是否是回文，或者从len-i-1处分割，判断a的剩余部分是否是回文
> 若都不是，再比较b的第i位与a的倒数i位，找到第一个不满足的i，再比较a，b的剩余部分

### 优化行数
```c++
class Solution {
public:
    bool checkPalindromeFormation(string a, string b) {
        int len = a.length();
        int paliA = len/2-1, paliB = len/2;
        while(paliA > 0 && a[paliA] == a[len-1-paliA]) paliA--;
        while(paliB > 0 && b[paliB] == b[len-1-paliB]) paliB--;
        int i, j;
        for(i = 0; i < len/2; i++) {
            if(a[i] != b[len-1-i]) {
                break;
            }
        }
        
        for(j = 0; j < len/2; j++) {
            if(b[j] != a[len-1-j]) {
                break;
            }
        }
        return min(paliA, paliB) < max(i, j);
    }
};
```

> 最大的情况下执行$2*len$次
>

## [2389. 和有限的最长子序列](https://leetcode.cn/problems/longest-subsequence-with-limited-sum/description/)
### 艺术就是派大星
```c++
class Solution {
public:
    vector<int> answerQueries(vector<int>& nums, vector<int>& queries) {
        vector<int> answer;
        int n = nums.size(), m = queries.size();
        sort(nums.begin(), nums.end());
        for(int i = 0; i < m; i++) {
            int sum = 0;
            int count = 0;
            for(int j = 0; j < n; j++) {
                if(sum + nums[j] <= queries[i]) {
                    count ++;
                    sum += nums[j];                }
            }
            answer.push_back(count);
        }
        return answer;
    }
};
```

### 二分查找
```c++
class Solution {
public:
    vector<int> answerQueries(vector<int>& nums, vector<int>& queries) {
        vector<int> answer;
        int n = nums.size(), m = queries.size();
        sort(nums.begin(), nums.end());
        for(int j = 1; j < n; j++) {
            nums[j] += nums[j-1];
        }
        for(int i = 0; i < m; i++) {
            int count = upper_bound(nums.begin(), nums.end(), queries[i]) - nums.begin();
            answer.push_back(count);
        }
        return answer;
    }
};
```

### 手写upper_bound()
```c++
class Solution {
public:
    vector<int> answerQueries(vector<int>& nums, vector<int>& queries) {
        vector<int> answer;
        int n = nums.size(), m = queries.size();
        sort(nums.begin(), nums.end());
        for(int j = 1; j < n; j++) {
            nums[j] += nums[j-1];
        }
        for(int i = 0; i < m; i++) {
            int l = 0, r = n;
            while(l < r) {
                int mid = l + (r - l) / 2;
                if(nums[mid] > queries[i]) {
                    r = mid;
                } else {
                    l = mid+1;
                }
            }
            answer.push_back(l);
        }
        return answer;
    }
};
```

## [1615. 最大网络秩](https://leetcode.cn/problems/maximal-network-rank/description/)


### 暴力
```c++
class Solution {
public:
    int maximalNetworkRank(int n, vector<vector<int>>& roads) {
        vector<vector<bool>> mat(n, vector<bool>(n, false));
        vector<int> count(n);
        for(auto& r : roads) {
            mat[r[0]][r[1]] = true;
            mat[r[1]][r[0]] = true;
        }
        int max_a = 0, max_b = 0;
        int max_i = 0, max_j = 0;
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                if(mat[i][j]) {
                    count[i]++;
                }
            }
            if(count[i] >= max_a) {
                max_b = max_a;
                max_a = count[i];
                max_j = max_i;
                max_i = i;
            } else if(count[i] > max_b){
                max_b = count[i];
                max_j = i;
            }
        }
        for(int i = 0; i < n; i++) {
            for(int j = i+1; j < n; j++) {
                if(((max_a == count[i] && max_b == count[j])||(max_b == count[i] && max_a == count[j])) && !mat[i][j]) {
                    return max_a + max_b;
                }
            }
        }
        return max_a + max_b - 1;
    }
};
```

> 先统计每个城市的道路数，找到最大的两个，然后查找在所有等于最大两个道路数的城市组合中，有无没有边的组合，否则就减一

### 优化后续查找
```c++
class Solution {
public:
    int maximalNetworkRank(int n, vector<vector<int>>& roads) {
        vector<vector<bool>> mat(n, vector<bool>(n, false));
        vector<int> count(n), index(n);
        for(auto& r : roads) {
            mat[r[0]][r[1]] = true;
            mat[r[1]][r[0]] = true;
        }
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                if(mat[i][j]) {
                    count[i]++;
                }
            }
            index[i] = i;
            mat[i][i] = true;
        }
        sort(index.begin(), index.end(), [&](int a, int b)->bool{return count[a] < count[b];});
        int x = n-1,y = n-2;
        while(x >= 0 && count[index[x]] == count[index[n-1]]) {
            y = x-1;
            while(y >= 0 && count[index[y]] == count[index[n-2]]) {
                if(!mat[index[x]][index[y]]) {
                    return count[index[n-1]] + count[index[n-2]];
                }
                y--;
            }
            x--;
        }
        return count[index[n-1]] + count[index[n-2]] - 1;
    }
};
```

## [1605. 给定行和列的和求可行矩阵](https://leetcode.cn/problems/find-valid-matrix-given-row-and-column-sums/)
```c++
class Solution {
public:
    vector<vector<int>> restoreMatrix(vector<int>& rowSum, vector<int>& colSum) {
        int m = rowSum.size(),n = colSum.size();
        vector<vector<int>> res = vector<vector<int>>(m, vector<int>(n));
        for(int i = 0; i < m; i++) {
            for(int j = 0; j < n; j++) {
                int x = min(rowSum[i], colSum[j]);
                res[i][j] = x;
                rowSum[i] -= x;
                colSum[j] -= x;
            }
        }
        return res;
    }
};
```

> 根据行列和的要求，当前方格中可以填入的最大值是两个要求的最小值，直接填入该值，并更新对应位置的要求

## [2383. 赢得比赛需要的最少训练时长](https://leetcode.cn/problems/minimum-hours-of-training-to-win-a-competition/description/)
```c++
class Solution {
public:
    int minNumberOfHours(int initialEnergy, int initialExperience, vector<int>& energy, vector<int>& experience) {
        int eng = 1, expLeft = 0, len = energy.size();
        int exp = 0;
        for(int i = 0; i < len; i++) {
            eng += energy[i];
            exp = max(exp, experience[i] - expLeft+1);
            expLeft += experience[i];
        }
        return (eng > initialEnergy ? eng - initialEnergy : 0) + (exp > initialExperience ? exp - initialExperience : 0);
    }
};
```

> 能量是从左到右消耗的，所以初始能量大于能量总和就可以
> 经验是可以从左到右累积的，所以初始经验大于当前对手的经验减去累积的经验就可以了

## [1625. 执行操作后字典序最小的字符串](https://leetcode.cn/problems/lexicographically-smallest-string-after-applying-operations/description/)

### 过于暴力
```c++
class Solution {
public:
    map<string, bool> visited;
    int len, a, b;
    void add(string& s) {
        for(int i = 1; i < len; i+=2) {
            s[i] = (s[i] + a)%10;
        }
    }
    string rotate(string s) {
        string ret;
        for(int i = 0; i < len; i++) {
            ret.push_back(s[(i+b)%len]);
        }
        return ret;
    }
    void search(string s) {
        if(visited.count(s) != 0) {
            return;
        }
        visited[s] = true;
        search(rotate(s));
        add(s);
        search(s);
    }
    string findLexSmallestString(string s, int a, int b) {
        this->len = s.size();
        this->a = a;
        this->b = b;
        for(int i = 0; i < len; i++) {
            s[i] -= '0';
        }
        search(s);
        string ret = visited.begin()->first;
        for(int i = 0; i < len; i++) {
            ret[i] += '0';
        }
        return ret;
    }
};

```

> 暴力，硬搜，把所有可能情况都算出来

## [面试题 17.05. 字母与数字](https://leetcode.cn/problems/find-longest-subarray-lcci/description/)

```c++
class Solution {
public:
    vector<string> findLongestSubarray(vector<string>& array) {
        int len = array.size();
        vector<int> sum(len);
        sum[0] = isalpha(array[0][0]) ? 1 : -1;
        for(int i = 1; i < len; i++) {
            sum[i] = sum[i-1] + (isalpha(array[i][0]) ? 1 : -1);
        }
        unordered_map<int, int> m;
        int left = 0, right = -1;
        for(int i = 0; i < len; i++) {
            if(sum[i] == 0) {
                if(i > right - left) {
                    left = 0;
                    right = i;
                }
            } else {
                if(!m.count(sum[i])) {
                    m[sum[i]] = i + 1;
                } else {
                    if(i - m[sum[i]] > right - left) {
                        right = i;
                        left = m[sum[i]];
                    }
                }
            }
        }
        return {array.begin() + left, array.begin() + right + 1};
    }
};
```
> 使用前缀和，sum表示字母比数字多多少，如果是0，则说明区间[0,i]上是字母数字平衡的
> 对于不是0的情况，若[0,a]字母比数字多n个，[0,b]字母比数字也多n个，则[a+1,b]中，数字字母一样多
> 由于求最长子串，则存每个n第一次出现的位置即可