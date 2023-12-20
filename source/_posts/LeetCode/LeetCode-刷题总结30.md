---
title: LeetCode-30
date: 2023-12-19 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## [162. 寻找峰值](https://leetcode.cn/problems/find-peak-element/description/?envType=daily-question&envId=2023-12-18)

```c++
class Solution {
public:
    int findPeakElement(vector<int>& nums) {
        int index = 0;
        int n = nums.size();
        while(index < n-1 && nums[index] < nums[index+1]) index++;
        return index;
    }
};
```

## [1901. 寻找峰值 II](https://leetcode.cn/problems/find-a-peak-element-ii/description/?envType=daily-question&envId=2023-12-19)

```c++
class Solution {
public:
    vector<int> findPeakGrid(vector<vector<int>>& mat) {
        int x = 0, y = 0;
        int m = mat.size(), n = mat[0].size();
        bool findPoint = true;
        while(findPoint) {
            findPoint = false;
            if(x + 1 < m && mat[x+1][y] > mat[x][y]) {
                findPoint = true;
                x++;
            } else if(x - 1 >= 0 && mat[x-1][y] > mat[x][y]) {
                findPoint = true;
                x--;
            } else if(y + 1 < n && mat[x][y+1] > mat[x][y]) {
                findPoint = true;
                y++;
            } else if(y - 1 >= 0 && mat[x][y-1] > mat[x][y]) {
                findPoint = true;
                y--;
            }

        }
        return {x, y};
    }
};
```

贪心，从某一点开始，如果上下左右存在比当前点大的数，移动过去，直到无法移动

## [746. 使用最小花费爬楼梯](https://leetcode.cn/problems/min-cost-climbing-stairs/description/?envType=daily-question&envId=2023-12-17)

```c++
class Solution {
public:
    int minCostClimbingStairs(vector<int>& cost) {
        int n = cost.size();
        vector<int> vecc(n+1, INT_MAX);
        vecc[0] = vecc[1] = 0;
        for(int i = 0; i < n-1; i++) {
            vecc[i+1] = min(vecc[i+1], vecc[i] + cost[i]);
            vecc[i+2] = min(vecc[i+2], vecc[i] + cost[i]);
        }
        vecc[n] = min(vecc[n], vecc[n-1] + cost[n-1]);
        return vecc[n];
    }
};
```

```c++
class Solution {
public:
    int minCostClimbingStairs(vector<int>& cost) {
        int n = cost.size();
        int a = cost[0], b = cost[1];
        for(int i = 2; i < n; i++) {
            int t = cost[i] + min(a, b);
            a = b;
            b = t;
        }
        return min(a, b);
    }
};
```

## [2415. 反转二叉树的奇数层](https://leetcode.cn/problems/reverse-odd-levels-of-binary-tree/description/?envType=daily-question&envId=2023-12-15)

```c++
class Solution {
public:
    TreeNode* reverseOddLevels(TreeNode* root) {
        queue<TreeNode *> q;
        if(root) q.push(root);
        int n = 1;
        bool rev = false;
        while(!q.empty()) {
            int cnt = n;
            vector<TreeNode *> tmp;
            while(n--) {
                TreeNode *node = q.front();
                q.pop();
                if(rev) tmp.push_back(node);
                if(node->left && node->right) {
                    q.push(node->left);
                    q.push(node->right);
                }
            }
            if(rev) {
                for(int i = 0; i < cnt / 2; i++) {
                    swap(tmp[i]->val, tmp[cnt - 1 - i]->val);
                }
            }
            rev = !rev;
            n = cnt << 1;
        }
        return root;
    }
};
```

## [1631. 最小体力消耗路径](https://leetcode.cn/problems/path-with-minimum-effort/description/?envType=daily-question&envId=2023-12-11)

### 超时
```c++
class Solution {
public:
    int minimumEffortPath(vector<vector<int>>& heights) {
        int row = heights.size(), col = heights[0].size();
        if(row <= 1 && col <= 1) return 0;
        vector<int> len(row*col, INT_MAX / 2);
        vector<bool> visited(row*col, false);
        len[0] = 0;
        for(int i = 0; i < row*col - 1; i++) {
            int min_dis = 0;
            int node = -1;
            for(int j = 0; j < row*col; j++) {
                if(!visited[j] && (node == -1 || len[j] < len[node])) {
                    node = j;
                }
            }
            int x = node / col, y = node % col;
            if(x < row - 1 && !visited[node+col]) len[node+col] = min(len[node+col], max(len[node], abs(heights[x][y] - heights[x+1][y])));
            if(y < col - 1 && !visited[node+1]) len[node+1] = min(len[node+1], max(len[node], abs(heights[x][y] - heights[x][y+1])));
            if(x > 0 && !visited[node-col]) len[node-col] = min(len[node-col], max(len[node], abs(heights[x][y] - heights[x-1][y])));
            if(y > 0 && !visited[node-1]) len[node-1] = min(len[node-1], max(len[node], abs(heights[x][y] - heights[x][y-1])));

            visited[node] = true;
        }
        return len[row*col-1];
    }
};
```

## 优化
dijkstra需要用优先队列优化一下
```c++
class Solution {
    static constexpr int dirs[4][2] = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}};
public:
    int minimumEffortPath(vector<vector<int>>& heights) {
        int row = heights.size(), col = heights[0].size();
        if(row <= 1 && col <= 1) return 0;
        vector<int> len(row*col, INT_MAX / 2);
        vector<bool> visited(row*col, false);
        len[0] = 0;
        int min_dis = 0;
        int node = -1;
        auto tupleCmp = [](const auto& e1, const auto& e2) {
            auto&& [x1, d1] = e1;
            auto&& [x2, d2] = e2;
            return d1 > d2;
        };
        priority_queue<pair<int, int>, vector<pair<int, int>>, decltype(tupleCmp)> q(tupleCmp);
        q.emplace(0, 0);
        while(!q.empty()) {
            auto [node, dis] = q.top();
            q.pop();
            int x = node / col, y = node % col;
            for(int i = 0; i < 4; i++) {
                int nx = x + dirs[i][0];
                int ny = y + dirs[i][1];
                if(nx >= 0 && ny >= 0 && nx < row && ny < col && max(dis, abs(heights[x][y] - heights[nx][ny])) < len[node + col * dirs[i][0] + dirs[i][1]]) {
                    len[node + col * dirs[i][0] + dirs[i][1]] = max(dis, abs(heights[x][y] - heights[nx][ny]));
                    q.emplace(node + col * dirs[i][0] + dirs[i][1], len[node + col * dirs[i][0] + dirs[i][1]]);
                }
            }
            visited[node] = true;
        }
        return len[row*col-1];
    }
};
```