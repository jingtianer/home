---
title: LeetCode-20
date: 2022-11-28 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## [1758. 生成交替二进制字符串的最少操作数](https://leetcode.cn/problems/minimum-changes-to-make-alternating-binary-string/)

```c++
class Solution {
public:
    int minOperations(string s) {
        int len = s.size();
        return min(cal(s, len, true), cal(s, len, false));
    }
    int cal(const string& s, int len, bool flag) {
        int count = 0;
        for(int i = 0; i < len; i++) {
            if(flag && s[i] == '0' || !flag && s[i] == '1') {
                count++;
            }
            flag = !flag;
        }
        return count;
    }
};
```



## [813. 最大平均值和的分组](https://leetcode.cn/problems/largest-sum-of-averages/)


### 超时暴搜
```c++
class Solution {
public:
    int len = 0;
    vector<int> sum;
    double largestSumOfAverages(vector<int>& nums, int k) {
        len = nums.size();
        sum = vector<int>(len+1, 0);
        for(int i = 1; i <= len; i++) {
            sum[i] = nums[i-1] + sum[i-1];
        }
        return search(nums, k, 1, 1, 0, 0);
    }
    double search(vector<int>& nums, int k, int i, int K, double left_value, int last_j) {
        if(k == K || i == len) {
            return left_value + (sum[len] - sum[last_j] + 0.0) / (len - last_j);
        }
        return max(search(nums, k, i+1, K+1, left_value + (sum[i] - sum[last_j] + 0.0)/(i-last_j), i), search(nums, k,i+1, K, left_value, last_j));
    }

    double max(double a, double b) {
        return a > b ? a : b;
    }
};
```

> 昨天第一个思路是用排序，找出最大的m个数，这m个数恰好将数组分成k个部分，发现不可行。
> 然后暴力搜索，超时了，暴搜时考虑添加隔板，其中left_value表示当前搜索下标i之前的分组平均值

### 类似背包
```c++
class Solution {
public:
    double largestSumOfAverages(vector<int>& nums, int k) {
        int len = nums.size();
        vector<int> sum(len+1, 0);
        vector<vector<double>> left_avg(k-1, vector<double>(len, 0));
        for(int i = 1; i <= len; i++) {
            sum[i] = nums[i-1] + sum[i-1];
        }
        double maxx = sum[len] / (len + 0.0);
        if(k <= 1) return maxx;
        for(int i = 1; i < len; i++) {
            left_avg[0][i] = double(sum[i])/i;
            maxx = max(maxx, left_avg[0][i] + double(sum[len] - sum[i])/(len-i));
        }
        for(int i = 0; i < k-2; i++) { //第几个隔板
            for(int j = i+1; j < len; j++) { // 前一个隔板的位置
                for(int p = j+1; p < len; p++) { // 现在隔板的位置
                    maxx = max(left_avg[i][j] + double(sum[p] - sum[j])/(p-j) + double(sum[len] - sum[p])/(len-p), maxx);
                    // left_avg + 当前隔板与上一个隔板的avg， 最后一个数到当前隔板的avg
                    left_avg[i+1][p] = max(left_avg[i][j] + double(sum[p] - sum[j])/(p-j), left_avg[i+1][p]);
                    // 更新avg
                }
            }
        }
        return maxx;
    }
};
```


> 今天考虑用类似背包的想法，结合暴力搜索的left_avg，用$ left_avg[i][j] $ ，表示添加i个隔板，在j之前的最大left_avg
> 从第二个隔板开始，假设第i个隔板分别在位置 $j = i+1,i+2,i+3 ...$ 时，第 $i+1$个隔板可以在 $p = j+1, j+2, ...$
> 计算前后两个隔板各种情况的最大值，更新left_avg，更新maxx

### 优化

```c++
class Solution {
public:
    double largestSumOfAverages(vector<int>& nums, int k) {
        int len = nums.size();
        vector<int> sum(len+1, 0);
        for(int i = 1; i <= len; i++) {
            sum[i] = nums[i-1] + sum[i-1];
        }
        if(k <= 1) return sum[len] / (len + 0.0);
        vector<vector<double>> left_avg(k-1, vector<double>(len, 0));
        for(int i = 1; i < len; i++) {
            left_avg[0][i] = double(sum[i])/i;
        }
        for(int i = 0; i < k-2; i++) {
            for(int j = i+1; j < len-1; j++) {
                for(int p = j+1; p < len; p++) {
                    left_avg[i+1][p] = max(left_avg[i][j] + double(sum[p] - sum[j])/(p-j), left_avg[i+1][p]);
                }
            }
        }
        double maxx = 0;
        for(int i = 0; i < k-1; i++) {
            for(int j = 0; j < len; j++) {
                maxx = max(left_avg[i][j]+double(sum[len] - sum[j])/(len-j), maxx);
            }
        }
        return maxx;
    }
};
```

> 减少maxx计算次数

## [1752. 检查数组是否经排序和轮转得到](https://leetcode.cn/problems/check-if-array-is-sorted-and-rotated/)

```c++
class Solution {
public:
    bool check(vector<int>& nums) {
        int i = 1, j = 0;
        int len = nums.size();
        while(i < len && nums[i-1] <= nums[i]) i++;
        if(i == len) return true;
        j = i+1;
        while(j < len && nums[j-1] <= nums[j]) j++;
        return j == len && nums[len-1] <= nums[0];
    }
};
```

## [882. 细分图中的可到达节点](https://leetcode.cn/problems/reachable-nodes-in-subdivided-graph/)

## 暴搜超时
```c++
class Solution {
public:
    vector<vector<int>> graph;
    vector<bool> global_visited;
    int res = 0;
    vector<vector<int>> copy_edges;
    int reachableNodes(vector<vector<int>>& edges, int maxMoves, int n) {
        int edge_size = edges.size();
        graph = vector<vector<int>>(n);
        global_visited = vector<bool>(n, false);
        copy_edges = vector<vector<int>>(2,vector<int>(edge_size, 0));
        for(int i = 0; i < edge_size; i++) {
            graph[edges[i][0]].push_back(i);
            graph[edges[i][1]].push_back(i);
        }
        dfs(std::move(edges), 0, maxMoves);
        for(int i = 0; i < edge_size; i++) {
            res += min(edges[i][2], copy_edges[0][i] + copy_edges[1][i]);
        }
        for(int i = 0; i < n; i++) {
            if(global_visited[i]) {
                res++;
            }
        }
        return res;
    }
    void dfs(vector<vector<int>>&& edges, int node, int move) {
        global_visited[node] = true;
        if(move <= 0) return;
        for(int e : graph[node]) {
            int w = edges[e][2];
            int next = edges[e][0] == node ? edges[e][1] : edges[e][0];
            int direction = edges[e][0] == node ? 0 : 1;
            copy_edges[direction][e] = max(min(w, move), copy_edges[direction][e]);
            if(move > w) {
                dfs(std::move(edges), next, move-w-1);
            }
        }
    }
};
```

## djikstra-题解
```c++
class Solution {
public:
    int encode(int u, int v, int n) {
        return u * n + v;
    }

    int reachableNodes(vector<vector<int>>& edges, int maxMoves, int n) {
        vector<vector<pair<int, int>>> adList(n);
        for (auto &edge : edges) {
            int u = edge[0], v = edge[1], nodes = edge[2];
            adList[u].emplace_back(v, nodes);
            adList[v].emplace_back(u, nodes);
        }

        unordered_map<int, int> used;
        unordered_set<int> visited;
        int reachableNodes = 0;
        priority_queue<pair<int, int>, vector<pair<int, int>>, greater<pair<int, int>>> pq;
        pq.emplace(0, 0);
        while (!pq.empty() && pq.top().first <= maxMoves) {
            auto [step, u] = pq.top();
            pq.pop();
            if (visited.count(u)) {
                continue;
            }
            visited.emplace(u);
            reachableNodes++;
            for (auto [v, nodes] : adList[u]) {
                if (nodes + step + 1 <= maxMoves && !visited.count(v)) {
                    pq.emplace(nodes + step + 1, v);
                }
                used[encode(u, v, n)] = min(nodes, maxMoves - step);
            }
        }

        for (auto &edge : edges) {
            int u = edge[0], v = edge[1], nodes = edge[2];
            reachableNodes += min(nodes, used[encode(u, v, n)] + used[encode(v, u, n)]);
        }
        return reachableNodes;
    }
};
```