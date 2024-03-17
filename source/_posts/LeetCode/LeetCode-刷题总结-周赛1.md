---
title: LeetCode-32
date: 2024-3-10 11:14:34
tags: 
    - LeetCode
    - LeetCode周赛
categories: 
    - LeetCode
    - LeetCode周赛
toc: true
language: zh-CN
---

## [第 388 场周赛](https://leetcode.cn/contest/weekly-contest-388/)

### [100233. 重新分装苹果](https://leetcode.cn/problems/apple-redistribution-into-boxes/description/)

- 贪心

```c++
class Solution {
public:
    int minimumBoxes(vector<int>& apple, vector<int>& capacity) {
        int need = accumulate(apple.begin(), apple.end(), 0);
        sort(capacity.begin(), capacity.end());
        int ans = 0, total = 0;
        for(int i = capacity.size() - 1; i >= 0; i--) {
            if(total < need) {
                total += capacity[i];
                ans++;
            } else {
                break;
            }
        }
        return ans;
    }
};
```

### [100247. 幸福值最大化的选择方案](https://leetcode.cn/problems/maximize-happiness-of-selected-children/description/)

- 贪心

```c++
class Solution {
public:
    long long maximumHappinessSum(vector<int>& happiness, int k) {
        long long ans = 0;
        int len = happiness.size();
        sort(happiness.begin(), happiness.end());
        for(int i = 0; i < k; i++) {
            ans += max(happiness[len - 1 - i] - i, 0);
        }
        return ans;
    }
};
```

### [100251. 数组中的最短非公共子字符串](https://leetcode.cn/problems/shortest-uncommon-substring-in-an-array/description/)

- 暴力

```c++
class Solution {
    string min(string &a, string& b) {
        int len_a = a.length();
        int len_b = b.length();
        if(len_a != len_b) return len_a < len_b ? a : b;
        return std::min(a, b);
    }
public:
    vector<string> shortestSubstrings(vector<string>& arr) {
        int len = arr.size();
        vector<string> res(len);
        for(int i = 0; i < len; i++) {
            int strlen_i = arr[i].length();
            string min_substri = arr[i];
            bool find_min = false;
            for(int sub_strlen = strlen_i; sub_strlen > 0; sub_strlen--) {
                for(int start_index = 0; start_index <= strlen_i - sub_strlen; start_index++) {
                    bool flag = true;
                    string substri = arr[i].substr(start_index, sub_strlen);
                    for(int j = 0; j < len; j++) {
                        if(i == j) continue;
                        if(arr[j].find(substri) != string::npos) {
                            flag = false;
                            break;
                        }
                    }
                    if(flag) {
                        min_substri = min(min_substri, substri);
                        find_min = true;
                    }
                }
            }
            if(find_min) res[i] = min_substri;
        }
        return res;
    }
};
```

### [100216. K 个不相交子数组的最大能量值](https://leetcode.cn/problems/maximum-strength-of-k-disjoint-subarrays/description/)


### 超时

```c++
class Solution {
public:
    long long maximumStrength(vector<int>& nums, int k) {
        int len = nums.size();
        vector<vector<long long>> dp(k+1, vector<long long>(len+1, LLONG_MIN));
        vector<long long> prefix_sum(len+1, 0);
        for(int i = 1; i <= len; i++) {
            prefix_sum[i] = prefix_sum[i-1] + nums[i-1];
        }
        long long sign = 1;
        fill(dp[0].begin(), dp[0].end(), 0);
        for(int seperator = 1; seperator <= k; seperator++) {
            dp[seperator][0] = 0;
            for(int i = 1; i <= len; i++) {
                for(int j = seperator-1; j < i; j++) {
                    dp[seperator][i] = max(dp[seperator][i], dp[seperator-1][j] + (k - seperator + 1) * sign * (prefix_sum[i] - prefix_sum[j]));
                }
                // cout << dp[seperator][i] << ",";
            }
            sign *= -1;
            // cout << endl;
        }
        return *max_element(dp[k].begin() + k, dp[k].end());
    }
};
```

### AC
- 把含下标j的和含下标seperator分开，可以减少一次循环

```c++
class Solution {
public:
    long long maximumStrength(vector<int>& nums, int k) {
        int len = nums.size();
        vector<vector<long long>> dp(k+1, vector<long long>(len+1, 0));
        vector<long long> prefix_sum(len+1, 0);
        for(int i = 1; i <= len; i++) {
            prefix_sum[i] = prefix_sum[i-1] + nums[i-1];
        }
        long long sign = 1;
        fill(dp[0].begin(), dp[0].end(), 0);
        for(int seperator = 1; seperator <= k; seperator++) {
            dp[seperator][seperator-1] = LLONG_MIN;
            long long mx = LLONG_MIN;
            for(int i = seperator; i <= len - k + seperator; i++) {
                // for(int j = seperator-1; j < i; j++) {
                mx = max(mx, dp[seperator - 1][i - 1] - prefix_sum[i - 1] * (k - seperator + 1) * sign);
                dp[seperator][i] = max(dp[seperator][i - 1], prefix_sum[i] * (k - seperator + 1) * sign + mx);
                // }
                // cout << dp[seperator][i] << ",";
            }
            sign *= -1;
            // cout << endl;
        }
        return *max_element(dp[k].begin() + k, dp[k].end());
    }
};
```

## [第 387 场周赛](https://leetcode.cn/contest/weekly-contest-387/)

### [3069. 将元素分配到两个数组中 I](https://leetcode.cn/problems/distribute-elements-into-two-arrays-i/description/)

```c++
class Solution {
public:
    vector<int> resultArray(vector<int>& nums) {
        int len = nums.size(), arr1 = 0;
        vector<int> arr2;
        arr2.push_back(nums[1]);
        for(int i = 2; i < len; i++) {
            if(nums[arr1] > arr2.back()) {
                nums[++arr1] = nums[i];
            } else {
                arr2.push_back(nums[i]);
            }
        }
        arr1++;
        for(int i = arr1; i < len; i++) {
            nums[i] = arr2[i - arr1];
        }
        // cout << arr1 << endl;
        return nums;
    }
};
```

### [3070. 元素和小于等于 k 的子矩阵的数目](https://leetcode.cn/problems/count-submatrices-with-top-left-element-and-sum-less-than-k/description/)

```c++
class Solution {
public:
    int countSubmatrices(vector<vector<int>>& grid, int k) {
        int m = grid.size(), n = grid[0].size();
        int ans = 0;
        if(grid[0][0] <= k) ans++;
        for(int i = 1; i < m; i++) {
            grid[i][0] += grid[i-1][0];
            if(grid[i][0] <= k) ans++;
        }
        for(int j = 1; j < n; j++) {
            grid[0][j] += grid[0][j-1];
            if(grid[0][j] <= k) ans++;
        }
        for(int i = 1; i < m; i++) {
            for(int j = 1; j < n; j++) {
                grid[i][j] += grid[i-1][j] + grid[i][j-1] - grid[i-1][j-1];
                if(grid[i][j] <= k) ans++;
                else break;
            }
        }
        return ans;
        // grid[i][j] - grid[a][j] - grid[i][b] + grid[a][b];
    }
};
```

### [3071. 在矩阵上写出字母 Y 所需的最少操作次数](https://leetcode.cn/problems/minimum-operations-to-write-the-letter-y-on-a-grid/description/)

```c++
class Solution {
public:
    int minimumOperationsToWriteY(vector<vector<int>>& grid) {
        int y[3] = {0}, cnt[3] = {0}, n = grid.size();
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                cnt[grid[i][j]]++;
                if((i == j && j <= n/2) || (i+j == n-1 && j >= n/2) || (j == n/2 && i >= n/2)) {
                    y[grid[i][j]]++;
                }
            }
        }
        auto cal = [&](int y_val, int noty_val, int other_val) {
            return y[noty_val] + y[other_val] + cnt[y_val] + cnt[other_val] - y[y_val] - y[other_val];
        };
        return min(
            min(cal(0, 1, 2), cal(0, 2, 1)), 
            min(
                min(cal(1, 0, 2), cal(1, 2, 0)), 
                min(cal(2, 0, 1), cal(2, 1, 0))
            )
        );
    }
};
```

### [3072. 将元素分配到两个数组中 II](https://leetcode.cn/problems/distribute-elements-into-two-arrays-ii/description/)

- 离散化 + 树状数组


## [第 381 场周赛](https://leetcode.cn/contest/weekly-contest-381)

### [3014. 输入单词需要的最少按键次数 I](https://leetcode.cn/problems/minimum-number-of-pushes-to-type-word-i/description/)

#### 思路1

- 按照字符出现次数分配按键的位置

```c++
class Solution {
public:
    int minimumPushes(string word) {
        int alpha_cnt[26] = {0};
        int key_cnt[8] = {0};
        int cur_key = 0;
        auto cmp = [&alpha_cnt](int i, int j) {
            return alpha_cnt[i] < alpha_cnt[j];
        };
        priority_queue<int, vector<int>, decltype(cmp)> q(cmp);
        for(char c : word) {
            alpha_cnt[c - 'a']++;
        }
        for(int i = 0; i < 26; i++) {
            if(alpha_cnt[i]) q.push(i);
        }
        int ans = 0;
        while(!q.empty()) {
            int top = q.top();
            q.pop();
            key_cnt[cur_key]++;
            ans += key_cnt[cur_key] * alpha_cnt[top];
            cur_key = (cur_key + 1) % 8;
        }
        return ans;
    }
};
```

#### 思路2
- 没看到题目说所有字母都是不同的，可以简化

```c++
class Solution {
public:
    int minimumPushes(string word) {
        int n = word.length();
        int div8 = n >> 3;
        int mod8 = n & 0b111;
        return (((div8 + 1) * div8) << 2) + (div8 + 1) * mod8;
    }
};
```


### [3015. 按距离统计房屋对数目 I](https://leetcode.cn/problems/count-the-number-of-houses-at-a-certain-distance-i/description/)

```c++
class Solution {
public:
    vector<int> countOfPairs(int n, int x, int y) {
        vector<int> ans(n);
        for(int i = 1; i <= n; i++) {
            for(int j = 1; j <= n; j++) {
                if(i == j) continue;
                int dis = min(abs(i - j), abs(min(i, j) - min(x, y)) + abs(max(x, y) - max(i, j)) + 1);
                ans[dis - 1]++;
            }
        }
        return ans;
    }
};
```

### [3016. 输入单词需要的最少按键次数 II](https://leetcode.cn/problems/minimum-number-of-pushes-to-type-word-ii/description/)

```c++
class Solution {
public:
    int minimumPushes(string word) {
        int alpha_cnt[26] = {0};
        int key_cnt[8] = {0};
        int cur_key = 0;
        auto cmp = [&alpha_cnt](int i, int j) {
            return alpha_cnt[i] < alpha_cnt[j];
        };
        priority_queue<int, vector<int>, decltype(cmp)> q(cmp);
        for(char c : word) {
            alpha_cnt[c - 'a']++;
        }
        for(int i = 0; i < 26; i++) {
            if(alpha_cnt[i]) q.push(i);
        }
        int ans = 0;
        while(!q.empty()) {
            int top = q.top();
            q.pop();
            key_cnt[cur_key]++;
            ans += key_cnt[cur_key] * alpha_cnt[top];
            cur_key = (cur_key + 1) % 8;
        }
        return ans;
    }
};
```

### [3017. 按距离统计房屋对数目 II](https://leetcode.cn/problems/count-the-number-of-houses-at-a-certain-distance-ii/description/)

- 想分类计算，但是没算出来