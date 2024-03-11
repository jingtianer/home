---
title: LeetCode-32
date: 2024-3-4 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## [232. 用栈实现队列](https://leetcode.cn/problems/implement-queue-using-stacks/description/)
- 两个栈倒腾一下可以得到队列
- 一个栈用来入队
- 一个栈用来出队，如果出队栈空，将另一个栈全倒腾过来，如果不空，就出栈一个元素

```c++
class MyQueue {
    stack<int> inStk, outStk;
public:
    MyQueue() {

    }
    
    void push(int x) {
        inStk.push(x);
    }
    
    int pop() {
        if(outStk.empty()) {
            while(!inStk.empty()) {
                outStk.push(inStk.top());
                inStk.pop();
            }
        }
        int top = outStk.top();
        outStk.pop();
        return top;
    }
    
    int peek() {
        if(outStk.empty()) {
            while(!inStk.empty()) {
                outStk.push(inStk.top());
                inStk.pop();
            }
        }
        int top = outStk.top();
        return top;
    }
    
    bool empty() {
        return inStk.empty() && outStk.empty();
    }
};
```

## [1976. 到达目的地的方案数](https://leetcode.cn/problems/number-of-ways-to-arrive-at-destination/?envType=daily-question&envId=2024-03-05)

### dijkstra
- 数据范围很大，枚举所有路径是不现实的
- 由于我们只要求两点之间的最短路，所以用dijkstra就好
- 应该是dp吧，每次选取最小路径的点更新邻接节点
  - 若使其路径变小了，则到达该节点最短路径数等于根节点到达当前节点的最短路径数
  - 若路径长度等于该节点，则到达该节点最短路径数在原来数量上加上根节点到达当前节点的最短路径数


```c++
class Solution {
public:
    int countPaths(int n, vector<vector<int>>& roads) {
        vector<bool> visited(n, false);
        int ans = 0;
        vector<vector<pair<int, int>>> g(n);
        for(auto& road : roads) {
            g[road[0]].emplace_back(road[1], road[2]);
            g[road[1]].emplace_back(road[0], road[2]);
        }
        vector<long long> minCostArr(n, 0x7fffffffffffffff);
        vector<int> costCnt(n, 0);
        minCostArr[0] = 0;
        costCnt[0] = 1;
        for(int i = 0; i < n; i++) {
            int node = -1;
            for(int j = 0; j < n; j++) {
                if(!visited[j] && (node == -1 || minCostArr[j] < minCostArr[node])) {
                    node = j;
                }
            }
            if(node == -1) break;
            visited[node] = true;
            for(auto [child, childCost] : g[node]) {
                if(minCostArr[child] > minCostArr[node] + childCost) {
                    costCnt[child] = costCnt[node];
                    minCostArr[child] = minCostArr[node] + childCost;
                } else if (minCostArr[child] == minCostArr[node] + childCost) {
                    costCnt[child] = (costCnt[node] + costCnt[child]) % 1000000007;
                }
            }
        }
        return costCnt[n-1];
    }
};
```

## [2917. 找出数组中的 K-or 值](https://leetcode.cn/problems/find-the-k-or-of-an-array/description/)

```java
class Solution {
    public int findKOr(int[] nums, int k) {
        int[] bitCnt = new int[32];
        int ans = 0;
        for(int i = 0, mask = 1; i < 32; i++, mask <<= 1) {
            for(int n : nums) {
                if((mask & n) != 0)bitCnt[i]++;
            }
            if(bitCnt[i] >= k) ans |= mask;
        }
        return ans;
    }
}
```


## [2575. 找出字符串的可整除数组](https://leetcode.cn/problems/find-the-divisibility-array-of-a-string/description/?envType=daily-question&envId=2024-03-07)
- 题解

```c++
class Solution {
public:
    vector<int> divisibilityArray(string word, int m) {
        int len = word.length();
        vector<int> res(len, 0);
        long long number = 0;
        for(int i = 0; i < len; i++) {
            number = (number * 10 + word[i] - '0') % m;
            if(number == 0) {
                res[i] = 1;
            }
        }
        return res;
    }
};
```

## [299. 猜数字游戏](https://leetcode.cn/problems/bulls-and-cows/description/?envType=daily-question&envId=2024-03-10)

```c
char* getHint(char* secret, char* guess) {
    int ACnt = 0, ABCnt = 0;
    int cntSecret[10] = {0}, cntGuess[10] = {0};
    while(*secret) {
        if(*secret == *guess) ACnt++;
        cntSecret[*secret - '0']++;
        cntGuess[*guess - '0']++;
        secret++;
        guess++;
    }
    for(int i = 0; i < 10; i++) {
        ABCnt += (cntSecret[i] > cntGuess[i] ? cntGuess[i] : cntSecret[i]);
    }
    int len = snprintf(NULL, 0, "%dA%dB", ACnt, ABCnt - ACnt) + 1;
    char *ret = malloc(sizeof(char) * (len));
    snprintf(ret, len, "%dA%dB", ACnt, ABCnt - ACnt);
    return ret;
}
```