---
title: LeetCode-37
date: 2024-8-26 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## 698. 划分为k个相等的子集

```c++
class Solution {
    class Solve {
        vector<int>& nums;
        int k;
        int n;
        vector<int> bucket;
        int target;
        int sum;
        bool canPartition;
        bool dfs(int index) {
            if(index >= n) { // 所有数都放进来了，且没有超过target
                // 说明一定全等于target
                // 如果有桶<target, 则一定有桶>target，所以所有桶一定>=target
                // 如果有桶>target, 则一定有桶<target，所以所有桶一定<=target
                // 所以所有桶一定==target
                return true;
            }
            for(int i = 0; i < k; i++) {
                if(i>0 && bucket[i] == bucket[i-1]) continue;
                if(bucket[i] + nums[index] <= target) {
                    bucket[i] += nums[index];
                    if(dfs(index+1)) {
                        return true;
                    }
                    bucket[i] -= nums[index];
                }
            }
            return false;
        }
        public:
        Solve(vector<int>& nums, int k):nums(nums), k(k), bucket(k) {
            n = nums.size();
            sum = accumulate(nums.begin(), nums.end(), 0);
            target = sum / k;
            sort(nums.begin(), nums.end(), greater<int>());
            if(sum % k != 0) {
                canPartition = false;
                return;
            }
            canPartition = dfs(0);
        }
        bool solve() {
            return canPartition;
        }
    };
public:
    bool canPartitionKSubsets(vector<int>& nums, int k) {
        return Solve(nums, k).solve();
    }
};
```

硬搜

## 690. 员工的重要性
```c++
class Solution {
public:
    int getImportance(vector<Employee*> employees, int id) {
        int len = employees.size();
        unordered_map<int, Employee*> id2Node;
        for(Employee *employee : employees) {
            id2Node[employee->id] = employee;
        }
        function<int(int)> dfs = [&](int currentId) {
            Employee *node = id2Node[currentId];
            int ans = node->importance;
            for(int child : node->subordinates) {
                ans += dfs(child);
            }
            return ans;
        };
        return dfs(id);
    }
};
```

## 699. 掉落的方块

```c++
class Solution {
public:
    vector<int> fallingSquares(vector<vector<int>>& positions) {
        int len = positions.size();
        vector<int> height(len);
        vector<int> right(len);
        for(int i = 0; i < len; i++) {
            right[i] = positions[i][0] + positions[i][1];
        }
        for(int i = 0; i < len; i++) {
            int maxHeight = 0;
            int lefti = positions[i][0];
            int righti = right[i];
            for(int j = 0; j < i; j++) {
                int leftj = positions[j][0];
                int rightj = right[j];
                if(lefti >= rightj) continue;
                if(righti <= leftj) continue;
                maxHeight = max(maxHeight, height[j]);
            }
            height[i] = maxHeight + positions[i][1];
        }
        for(int i = 1; i < len; i++) {
            height[i] = max(height[i-1], height[i]);
        }
        return height;
    }
};
```

- 数据规模略小，直接暴力

## 1186. 删除一次得到子数组最大和

先了解[Maximum Subarray Sum - Kadane's Algorithm](https://www.geeksforgeeks.org/largest-sum-contiguous-subarray/)

```c++
class Solution {
public:
    int maximumSum(vector<int>& arr) {
        int n = arr.size();
        int dp0 = arr[0], dp1 = 0;
        int maxx = arr[0];
        for(int i = 1; i < n; i++) {
            dp1 = max(dp1 + arr[i], dp0);
            dp0 = max(dp0, 0) + arr[i];
            maxx = max(maxx, dp0);
            maxx = max(maxx, dp1);
        }
        return maxx;
    }
};
```

## 3144. 分割字符频率相等的最少子字符串
```c++
class Solution {
    bool allEqualsExceptZero(int *arr, int len) {
        if(len <= 0) return true;
        int i = 0;
        while(i < len && arr[i] == 0) i++;
        if(i == len) return true;
        const int val = arr[i];
        for(; i < len; i++) {
            if(0 != arr[i] && val != arr[i]) return false;
        }
        return true;
    }
    int bfs(const vector<vector<bool>>& balance, int n) {
        queue<int> q;
        q.push(0);
        int level = 0;
        vector<bool> visited(n, false);
        while(!q.empty()) {
            level++;
            int len = q.size();
            while(len--) {
                int node = q.front();
                q.pop();
                for(int i = node; i < n; i++) {
                    if(balance[node][i]) {
                        if(i + 1 == n) {
                            return level;
                        } else if(!visited[i+1]) {
                            q.push(i + 1);
                            visited[i + 1] = true;
                        }
                    }
                }
            }
        }
        return level;
    }
public:
    int minimumSubstringsInPartition(string s) {
        int len = s.length();
        vector<vector<bool>> balance(len, vector<bool>(len, false));
        for(int i = 0; i < len; i++) {
            int charCnt[26] = {0};
            for(int j = i; j < len; j++) {
                charCnt[s[j] - 'a']++;
                balance[i][j] = allEqualsExceptZero(charCnt, 26);
            }
        }
        return bfs(balance, len);
    }
    void test() {
        // cout << minimumSubstringsInPartition("ababcc") << " == 1"<< endl;
        // cout << minimumSubstringsInPartition("fabccddg") << " == 3" << endl;
        // cout << minimumSubstringsInPartition("abababaccddb") << " == 2" << endl;
        cout << minimumSubstringsInPartition("fabccddg") << " == 3" << endl;
    }
};
```

- 找出任意区间`(i...j)`是否为平衡字符串，从0开始bfs搜索，直到第一个达到`n`的节点

## 3142. 判断矩阵是否满足条件
```c++
class Solution {
public:
    bool satisfiesConditions(vector<vector<int>>& grid) {
        int m = grid.size();
        int n = grid[0].size();
        for(int i = 0; i < m - 1; i++) {
            for(int j = 0; j < n - 1; j++) {
                if(grid[i][j] != grid[i+1][j] || grid[i][j] == grid[i][j+1]) {
                    return false;
                }
            }
        }
        for(int i = 0; i < m - 1; i++) {
            if(grid[i][n-1] != grid[i+1][n-1]) {
                return false;
            }
        }
        for(int j = 0; j < n - 1; j++) {
            if(grid[m-1][j] == grid[m-1][j+1]) {
                return false;
            }
        }
        return true;
    }
};
```

这种题请一次性给让我答10张

## 3144. 分割字符频率相等的最少子字符串

这次用dp哦

```c++
class Solution {
    bool allEqualsExceptZero(int *arr, int len) {
        if(len <= 0) return true;
        int i = 0;
        while(i < len && arr[i] == 0) i++;
        if(i == len) return true;
        const int val = arr[i];
        for(; i < len; i++) {
            if(0 != arr[i] && val != arr[i]) return false;
        }
        return true;
    }
public:
    int minimumSubstringsInPartition(string s) {
        int n = s.length();
        vector<vector<bool>> isBalance(n, vector<bool>(n));
        for(int i = 0; i < n; i++) {
            int charCnt[26] = {0};
            for(int j = i; j < n; j++) {
                charCnt[s[j] - 'a']++;
                isBalance[i][j] = allEqualsExceptZero(charCnt, 26);
            }
        }
        vector<int> dp(n, INT_MAX);
        dp[0] = 1;
        for(int i = 1; i < n; i++) {
            if(isBalance[0][i])
                dp[i] = min(dp[i], 1);
            for(int j = 1; j <= i; j++) {
                if(isBalance[j][i])
                    dp[i] = min(dp[i], dp[j-1] + 1);
            }
        }
        return dp[n-1];
    }
};
```

## [3127. 构造相同颜色的正方形](https://leetcode.cn/problems/make-a-square-with-the-same-color/description/?envType=daily-question&envId=2024-08-31)

```c++
class Solution {
public:
    bool canMakeSquare(vector<vector<char>>& grid) {
        function<int(int, int)> gridValue = [&](int i, int j) {
            return grid[i][j] == 'W' ? 1 : 0;
        };
        function<bool(int, int)> judge = [&](int i, int j) {
            return 2 != gridValue(i, j) + gridValue(i + 1, j) + gridValue(i, j + 1) + gridValue(i + 1, j + 1);
        };
        return judge(0, 0) || judge(0, 1) || judge(1, 0) || judge(1, 1);
    }
};
```

## [3153. 所有数对中数位差之和](https://leetcode.cn/problems/sum-of-digit-differences-of-all-pairs/description/?envType=daily-question&envId=2024-08-30)

```c++
class Solution {
public:
    long long sumDigitDifferences(vector<int>& nums) {
        int len = nums.size();
        vector<vector<int>> digitCnt(10, vector<int>(10)); // digitCnt[i][j], nums中第i位为j的数的个数
        auto cntDigitNumPerPos = [&]() {
            for(int index = 0; index < len; index++) {
                int n = nums[index];
                for(int i = 0; n; i++, n /= 10) {
                    digitCnt[i][n % 10]++;
                }
            }
        };
        cntDigitNumPerPos();
        auto cntDiffsAndAdd = [&]() {
            long long diffCnt = 0;
            for(int index = 0; index < len; index++) {
                int n = nums[index];
                for(int i = 0; n; i++, n /= 10) {
                    diffCnt += len - digitCnt[i][n % 10]; // 数出有多少数和当前数的第i位不同
                }
            }
            return diffCnt;
        };
        return cntDiffsAndAdd() / 2;
    }
};
```

## [89. 格雷编码](https://leetcode.cn/problems/gray-code/description/)

```c++
class Solution {
public:
    vector<int> grayCode(int n) {
        int len = 1 << n;
        vector<int> ans(len);
        for(int i = 1; i < len; i++) {
            ans[i] = (i >> 1) ^ i;
        }
        return ans;
    }
};
```

### 证明
推导一下公式为什么时正确的

要证明公式 $ a_i = (i >> 1) \oplus i $ 是格雷码，就要证明 $ a_{i+1} \oplus a_{i} = 2^{k_i} $ , 其中 $ k_i $ 是整数

设 $ i $的二进制从低位到高位第一个$ 0 $的位置是$ n $, 则 $ i \oplus (i + 1) = 2^{n+1} - 1$，原因参考[二进制自增计数器](https://blog.csdn.net/gengduc/article/details/131425911)的原理

$ a_{i+1} \oplus a_{i} $
$ = (i >> 1) \oplus i \oplus ((i + 1) >> 1) \oplus (i + 1) $
$ = (i \oplus (i + 1)) \oplus ((i \oplus (i + 1)) >> 1)$
$ = (2^{n+1} - 1) \oplus (2^{n} - 1) $
$ = 2^{n+1} $
