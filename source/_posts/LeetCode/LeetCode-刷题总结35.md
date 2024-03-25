---
title: LeetCode-35
date: 2024-3-25 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## [518. 零钱兑换 II](https://leetcode.cn/problems/coin-change-ii/description/?envType=daily-question&envId=2024-03-25)

```c++
class Solution {
public:
    int change(int amount, vector<int>& coins) {
        int n = coins.size();
        vector<int> dp(amount+1);
        dp[0] = 1;
        for(int i = 1; i <= n; i++) {
            for(int j = coins[i-1]; j <= amount; j++) {
                dp[j] += dp[j-coins[i-1]];
            }
        }
        return dp[amount];
    }
};
```

## [322. 零钱兑换](https://leetcode.cn/problems/coin-change/description/?envType=daily-question&envId=2024-03-24)

```c++
class Solution {
public:
    int coinChange(vector<int>& coins, int amount) {
        int n = coins.size();
        vector<int> dp(amount + 1, INT_MAX);
        dp[0] = 0;
        for(int i = 1; i <= n; i++) {
            for(int j = coins[i-1]; j <= amount; j++) {
                if(dp[j - coins[i-1]] != INT_MAX)
                    dp[j] = min(dp[j], dp[j - coins[i-1]] + 1);
            }
        }
        return dp[amount] == INT_MAX ? -1 : dp[amount];
    }
};
```

## [25. K 个一组翻转链表](https://leetcode.cn/problems/reverse-nodes-in-k-group/description/)

> 啊？真的是困难吗

```c++
class Solution {
    int listLen(ListNode *head) {
        int n = 0;
        while(head) {
            n++;
            head = head->next;
        }
        return n;
    }
public:
    ListNode* reverseKGroup(ListNode* head, int k) {
        ListNode dummy, *move = &dummy, *next = head;
        int n = listLen(head);
        for(int j = 0; j + k <= n; j+=k) {
            next = head;
            for(int i = 0; i < k; i++) {
                ListNode *tmp = head;
                head = head->next;
                tmp->next = move->next;
                move->next = tmp;
            }
            move = next;
        }
        while(head) {
            move->next = head;
            move = head;
            head = head->next;
        }
        return dummy.next;
    }
};
```