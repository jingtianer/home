---
title: LeetCode-31
date: 2023-2-23 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---
## [1185. 一周中的第几天](https://leetcode.cn/problems/day-of-the-week/description/?envType=daily-question&envId=2023-12-30)

- `Tomohiko Sakamoto`算法
- 虽然是简单题也有很多知识点呢
- [解释](https://www.geeksforgeeks.org/tomohiko-sakamotos-algorithm-finding-day-week/)

```c++
class Solution {
public:
    string dayOfTheWeek(int day, int month, int year) {
        // array with leading number of days values
        static int t[] = { 0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4 };
        
        // if month is less than 3 reduce year by 1
        if (month < 3)
            year -= 1;
        
        return vector<string>{"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
        [((year + year / 4 - year / 100 + year / 400 + t[month - 1] + day) % 7)];
    }
};
```


## [2583. 二叉树中的第 K 大层和](https://leetcode.cn/problems/kth-largest-sum-in-a-binary-tree/description/)

```c++
class Solution {
public:
    long long kthLargestLevelSum(TreeNode* root, int k) {
        if(!root) return -1;
        priority_queue<long long> level_sum_q;
        queue<TreeNode *> q;
        q.push(root);
        while(!q.empty()) {
            int q_size = q.size();
            long long level_sum = 0;
            while(q_size--) {
                TreeNode *node =  q.front();
                q.pop();
                level_sum += node->val;
                if(node->left) q.push(node->left);
                if(node->right) q.push(node->right);
            }
            level_sum_q.push(level_sum);
        }
        while(--k && !level_sum_q.empty()) {
            level_sum_q.pop();
        }
        return !level_sum_q.empty() ? level_sum_q.top() : -1;
    }
};
```

- 用ranges获取第k大的数

```c++
class Solution {
public:
    long long kthLargestLevelSum(TreeNode* root, int k) {
        if(!root) return -1;
        vector<long long> level_sums;
        queue<TreeNode *> q;
        q.push(root);
        int level_cnt = 0;
        while(!q.empty()) {
            int q_size = q.size();
            long long level_sum = 0;
            while(q_size--) {
                TreeNode *node =  q.front();
                q.pop();
                level_sum += node->val;
                if(node->left) q.push(node->left);
                if(node->right) q.push(node->right);
            }
            level_sums.push_back(level_sum);
            level_cnt++;
        }
        if(level_cnt < k) return -1;
        ranges::nth_element(level_sums, level_sums.end() - k);
        return level_sums[level_sums.size() - k];
    }
};
```

## [LCP 30. 魔塔游戏](https://leetcode.cn/problems/p0NxJO/description/?envType=daily-question&envId=2024-02-06)

- 当遇到HP不够的时候，考虑贪心，依次将已经遇到过的房间中最小的房间向后移动
- 移动后放入delay中，最后加上delay看HP够不够就好了

```c++
class Solution {
public:
    int magicTower(vector<int>& nums) {
        int n = nums.size();
        long long HP = 1;
        int swapCnt = 0;
        auto cmp = [&nums](int i, int j){ return nums[i] > nums[j]; };
        long long delay = 0;
        priority_queue<int, vector<int>, decltype(cmp)> q(cmp);
        for(int i = 0; i < n; i++) {
            int room = nums[i];
            if(room < 0)q.push(i);
            int chance = n - i  - 1;
            while(HP + room <= 0 && !q.empty() && chance--) {
                int minIndex = q.top();
                q.pop();
                int room_min = nums[minIndex];
                HP -= nums[minIndex];
                delay += nums[minIndex];
                swapCnt++;
            }
            HP += room;
            if(HP <= 0) break;
        }
        HP += delay;
        return HP > 0 ? swapCnt : -1;
    }
};
```

## 1696. 跳跃游戏 VI
- 看提示就会了
```c++
class Solution {
public:
    int maxResult(vector<int>& nums, int k) {
        int n = nums.size();
        vector<int> dp(n, INT_MIN);
        auto cmp = [&dp](int i, int j) {return dp[i] < dp[j];};
        priority_queue<int, vector<int>, decltype(cmp)> q(cmp);
        dp[0] = nums[0];
        q.push(0);
        for(int i = 1; i < n; i++) {
            while(q.top() < i - k) q.pop();
            int maxDp = dp[q.top()];
            dp[i] = max(dp[i], maxDp + nums[i]);
            q.push(i);
        }
        return dp.back();
    }
};

```
## [292. Nim 游戏](https://leetcode.cn/problems/nim-game/description/?envType=daily-question&envId=2024-02-04)

- 用dp[i]表示i个石头是否存在必胜策略，已知i = 1, 2, 3时，一定有必胜策略
- 那么对于4，无论我拿多少，对手都有必胜策略，那么我必输
- 对于5，6，7，我分别拿1，2，3就会得到4，对手陷入必输，那么我必胜
- 也就是前三个数全true，我就是false，前三个数有false，我就是true
- 可以证明，4的倍数一定输
  - 连续三个true后必跟一个false
  - 每个false后面一定有3个true

```c++
class Solution {
public:
    bool canWinNim(int n) {
        return n % 4 != 0; // 下面是推理过程
        vector<bool> dp(n+1);
        dp[0] = dp[1] = dp[2] = dp[3] = true;
        bool last1 = true, last2 = true, last3 = true;
        for(int i = 4; i <= n; i++) {
            dp[i] = !(last1 && last2 && last3);
            last1 = last2;
            last2 = last3;
            last3 = dp[i];
            if(!dp[i]) cout << i << ",";
        }
        return dp[n];
    }
};
```

## 