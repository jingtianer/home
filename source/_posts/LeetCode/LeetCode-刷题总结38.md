---
title: LeetCode-38
date: 2024-9-9 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## 2181. 合并零之间的节点

```c++
class Solution {
public:
    ListNode* mergeNodes(ListNode* head) {
        int sum = 0;
        ListNode dummy;
        ListNode *move_dummy = &dummy;
        ListNode *move = head;
        while(move->next) {
            sum = 0;
            while(move->next && move->next->val != 0) {
                sum += move->next->val;
                move = move->next;
            }
            move->val = sum;
            move_dummy->next = move;
            move_dummy = move_dummy->next;
            move = move->next;
            move_dummy->next = nullptr;
        }
        return dummy.next;
    }
};
```

## 977. 有序数组的平方

```c++
class Solution {
public:
    vector<int> sortedSquares(vector<int>& nums) {
        int len = nums.size();
        vector<int> merged_array(len);
        int i = 0, j = len - 1;
        for(int k = len - 1; k >= 0; k--) {
            if(abs(nums[i]) > abs(nums[j])) {
                merged_array[k] = nums[i] * nums[i];
                i++;
            } else {
                merged_array[k] = nums[j] * nums[j];
                j--;
            }
        }
        return merged_array;
    }
};
```

- 按照绝对值归并
- 双指针，从左右两端开始移动，

## 3174. 清除数字

```c++
class Solution {
public:
    string clearDigits(string s) {
        string res;
        for(char c : s) {
            if(!(c >= '0' && c <= '9')) {
                res.push_back(c);
            } else {
                res.pop_back();
            }
        }
        return res;
    }
};
```

- 模拟

## 2860. 让所有学生保持开心的分组方法数

```c++
class Solution {
public:
    int countWays(vector<int>& nums) {
        map<int, int> cnt;
        for(int n : nums) {
            cnt[n]++;
        }
        vector<int> arr;
        int len = 0;
        for(auto [num, total] : cnt) {
            arr.push_back(num);
            len++;
        }
        int i = 0;
        int ans = 0;
        int preSum = 0;
        while(i < len - 1) {
            preSum += cnt[arr[i]];
            if(preSum < arr[i+1] && preSum > arr[i]) {
                ans++;
            }
            i++;
        }
        return ans + 1 + (arr[0] == 0 ? 0 : 1);
    }
};
```

### 思路
- 假设选择了第i个学生，他的开心条件是`cnt > nums[i]`，那么
  - 所有满足`nums[j] <= nums[i]`的学生都必须被选择
  - 如果存在学生`j`，`nums[j] == nums[i] + 1`，`nums[k] == nums[j]`那么满足的学生k都必须被选择
  - 其他情况都不需要考虑，是一定无法满足条件的
- 只要统计每个num对应多少学生，按照num排序，
- 对于第i个num，如果选择他，他之前的学生必须选择
  - 如果num[i+1] == num[i] + 1，那么无法满足，是空集
  - 如果num[i+1] > num[i] + 1，那么只要累计学生足够条件，就能满足，满足的情景+1
- 利用前缀和，记录num以及小于num的学生数，学生数大于num


## 3176. 求出最长好子序列 I

### 二维dp

```c++
class Solution {
public:
    int maximumLength(vector<int>& nums, int k) {
        int len = nums.size();
        vector<vector<int>> dp(len, vector<int>(k + 1));
        int maxLen = 0;
        for(int i = 0; i < len; i++) {
            dp[i][0] = 1;
            for(int j = 0; j < i; j++) {
                if(nums[i] == nums[j]) {
                    dp[i][0] = max(dp[i][0], dp[j][0] + 1);
                }
            }
            maxLen = max(maxLen, dp[i][0]);
        }
        for(int i = 0; i < len; i++) {
            for(int j = 1; j <= k; j++) {
                for(int m = 0; m < i; m++) {
                    if(nums[i] == nums[m]) {
                        dp[i][j] = max(dp[i][j], dp[m][j] + 1);
                    } else {
                        dp[i][j] = max(dp[i][j], dp[m][j - 1] + 1);
                    }
                }
                maxLen = max(maxLen, dp[i][j]);
            }
        }
        return maxLen;
    }
};
```

- `dp[i][j]`代表到第`i`个数为止，恰好有`j`个不同的数的长度
- 转移方程
  - 如果`nums[i] == nums[m]`，不同的数相同，`j`相同, `dp[i][j] = max(dp[i][j], dp[m]p[j])`
  - 如果`nums[i] != nums[m]`，不同的数相同，`j`不同，相差1, `dp[i][j] = max(dp[i][j], dp[m][j-1])`