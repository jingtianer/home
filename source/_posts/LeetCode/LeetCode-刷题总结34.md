---
title: LeetCode-34
date: 2024-3-14 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## [2789. 合并后数组中的最大元素](https://leetcode.cn/problems/largest-element-in-an-array-after-merge-operations/description/?envType=daily-question&envId=2024-03-14)

```c++
class Solution {
public:
    long long maxArrayValue(vector<int>& nums) {
        int n = nums.size();
        long long ans = nums[n-1];
        long long curSum = nums[n-1];
        for(int i = n - 2; i >= 0; i--) {
            if(nums[i] <= curSum) {
                curSum += nums[i];
            } else {
                curSum = nums[i];
            }
            ans = max(ans, curSum);
        }
        return ans;
    }
};
```

## [2864. 最大二进制奇数](https://leetcode.cn/problems/maximum-odd-binary-number/description/?envType=daily-question&envId=2024-03-13)

- 一次遍历原地算法

```c++
class Solution {
public:
    string maximumOddBinaryNumber(string& s) {
        int len = s.length();
        int index = 0;
        for(int i = 0; i < len; i++) {
            if(s[i] == '1') {
                s[i] = '0';
                s[index++] = '1';
            }
        }
        s[index-1] = '0';
        s[len-1] = '1';
        return s;
    }
};
```

## [1261. 在受污染的二叉树中查找元素](https://leetcode.cn/problems/find-elements-in-a-contaminated-binary-tree/description/?envType=daily-question&envId=2024-03-12)

### 不要额外存储，不用恢复节点值
- 用对应满二叉树的标号标记index
- 判断要查的树在第几层，将标号转为0,1,2,3,...
- 二进制位就是搜索方向，找到null就是不存在，找到节点就是存在

```c++
class FindElements {
    TreeNode* root;
    // set<int> s;
    // void dfs(TreeNode * root) {
        // s.insert(root->val);
        // if(root->left) {
        //     root->left->val = (root->val << 1) + 1;
        //     dfs(root->left);
        // }
        // if(root->right) {
        //     root->right->val = (root->val << 1) + 2;
        //     dfs(root->right);
        // }
    // }
public:
    FindElements(TreeNode* root) : root(root) {
        // if(!root) return;
        // root->val = 0;
        // dfs(root);
    }
    
    bool find(int target) {
        // return s.count(target) != 0;
        int mask = 1, x = target + 1;
        while(x) {
            x >>= 1;
            mask <<= 1;
        }
        mask >>= 1;
        TreeNode *node = root;
        int n = target - mask + 1;
        mask >>= 1;
        while(mask && node) {
            if((mask & n) != 0) {
                node = node->right;
            } else {
                node = node->left;
            }
            mask >>= 1;
        }
        if(node) cout << node->val << endl;
        return node != nullptr;
    }
};
```

## [2129. 将标题首字母大写](https://leetcode.cn/problems/capitalize-the-title/description/?envType=daily-question&envId=2024-03-11)

```c++
class Solution {
    bool isLowercase(char c) {
        return c >= 'a' && c <= 'z';
    }
    bool isUppercase(char c) {
        return c >= 'A' && c <= 'Z';
    }
    char toLowercase(char c) {
        return isUppercase(c) ? c - 'A' + 'a' : c;
    }
    char toUppercase(char c) {
        return isLowercase(c) ? c - 'a' + 'A' : c;
    }
public:
    string capitalizeTitle(string title) {
        int len = title.length();
        int i = 0;
        while(i < len) {
            int start = i;
            while(i < len && title[i] != ' ') {
                title[i] = toLowercase(title[i]);
                i++;
            }
            if(i - start > 2) {
                title[start] = toUppercase(title[start]);
            }
            while(i < len && title[i] == ' ') {
                i++;
            }
        }
        return title;
    }
};
```

## [310. 最小高度树](https://leetcode.cn/problems/minimum-height-trees/description/?envType=daily-question&envId=2024-03-17)

```c++
class Solution {
public:
    vector<int> findMinHeightTrees(int n, vector<vector<int>>& edges) {
        if(n == 1) return {0};
        vector<int> ans, deg(n);
        vector<vector<int>> g(n);
        for(auto & edge : edges) {
            g[edge[0]].push_back(edge[1]);
            g[edge[1]].push_back(edge[0]);
            deg[edge[0]]++;
            deg[edge[1]]++;
        }
        queue<int> q;
        for(int i = 0; i < n; i++) {
            if(deg[i] == 1) q.push(i);
        }
        while(!q.empty()) {
            int q_size = q.size();
            ans.clear();
            while(q_size--) {
                int node = q.front();
                q.pop();
                deg[node]--;
                for(int child : g[node]) {
                    deg[child]--;
                    if(deg[child] == 1) q.push(child);
                }
                ans.push_back(node);
            }
        }
        return ans;
    }
};
```

- 看了答案，拓扑排序，最后一批就是根

## [2684. 矩阵中移动的最大次数](https://leetcode.cn/problems/maximum-number-of-moves-in-a-grid/description/?envType=daily-question&envId=2024-03-16)

- 暴力！暴力！
- 记忆优化搜索

```c++
class Solution {
    int ans = 0;
    int m, n;
    bool checkBounds(int i, int j) {
        return i >= 0 && j >= 0 && i < m && j < n;
    }
    vector<vector<int>> mem;
    int dfs(int i, int j, int len, vector<vector<int>>& grid) {
        if(checkBounds(i-1, j+1) && grid[i][j] < grid[i-1][j+1]) {
            mem[i][j] = max(mem[i][j], 1 + (mem[i-1][j+1] == 0 ? (mem[i-1][j+1] = dfs(i-1, j+1, len+1, grid)) : mem[i-1][j+1]));
        }
        if(checkBounds(i+1, j+1) && grid[i][j] < grid[i+1][j+1]) {
            mem[i][j] = max(mem[i][j], 1 + (mem[i+1][j+1] == 0 ? (mem[i+1][j+1] = dfs(i+1, j+1, len+1, grid)) : mem[i+1][j+1]));
        }
        if(checkBounds(i, j+1) && grid[i][j] < grid[i][j+1]) {
            mem[i][j] = max(mem[i][j], 1 + (mem[i][j+1] == 0 ? (mem[i][j+1] = dfs(i, j+1, len+1, grid)) : mem[i][j+1]));
        }
        return mem[i][j];
    }
public:
    int maxMoves(vector<vector<int>>& grid) {
        m = grid.size(), n = grid[0].size();
        mem = vector<vector<int>>(m, vector<int>(n));
        for(int i = 0; i < m; i++) {
            ans = max(ans, dfs(i, 0, 0, grid));
        }
        return ans;
    }
};
```