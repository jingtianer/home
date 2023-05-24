---
title: LeetCode-25
date: 2023-5-24 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## <font color="red">[hard] </font>[1377. T 秒后青蛙的位置](https://leetcode.cn/problems/frog-position-after-t-seconds/description/)

### 题目分析
题目强调为一颗无向树，每次访问未访问过的节点。也就是说，每秒若有子节点，则跳到子节点，否则呆在原地不动。

也就是根据题目构造一棵根节点为1的树，并按照层次遍历该树即可。但是题目输入的边并不一定以1为根节点。

### 代码
- 实际构造为图

```c++
class Solution {
public:
    vector<bool> visited;
    int n;
    double frogPosition(int n, vector<vector<int>>& edges, int t, int target) {
        vector<vector<int>> tree(n+1, vector<int>(n+1, 0));
        visited = vector<bool>(n+1, false);
        this->n = n;
        for(auto& e : edges) {
            if(!tree[e[0]][e[1]]) {
                tree[e[0]][0]++;
            }
            
            if(!tree[e[1]][e[0]]) {
                tree[e[1]][0]++;
            }
            tree[e[0]][e[1]] = 1;
            tree[e[1]][e[0]] = 1;
        }
        return level(tree, t, 1, target, 1);
    }
    double level(vector<vector<int>>& tree, int t, int root, int target, double prob) {
        int len = tree[root][0];
        for(int i = 1; i <= n; i++) {
            if(visited[i] && tree[root][i]) len--;
        }
        // printf("root = %d, len = %d\n", root, len);
        if(root == target) {
            if((t > 0 && len == 0) || t == 0) {
                return prob;
            } else if (t < 0){
                return 0.0;
            }
        }
        visited[root] = true;
        for(int e = 1; e <= n; e++) {
            if(!tree[root][e] || visited[e])continue;
            double ret;
            if((ret = level(tree, t-1, e, target, prob * 1.0 / len)) != 0) {
                return ret;
            }
        }
        return 0;
    }
};
```

> 时间 28ms 击败25.75%
> 空间 20MB 击败 5.30%

### 优化visited数组
考虑到输入是严格的树，在层次遍历时，不希望访问已经访问过的节点，这种节点只有双亲节点一种可能。

所以对于非根节点，子节点数，就是 $ N_{与之相邻的边}-1 $，层次遍历时只要知道其父节点，不去访问父节点即可

对于根节点，添加一条边$ <0, 1> $即可

```c++
class Solution {
public:
    int n;
    double frogPosition(int n, vector<vector<int>>& edges, int t, int target) {
        vector<vector<int>> tree(n+1, vector<int>(1, 0));
        this->n = n;
        edges.push_back({0, 1});
        for(auto& e : edges) {
            tree[e[0]][0]++;
            tree[e[1]][0]++;
            tree[e[0]].push_back(e[1]);
            tree[e[1]].push_back(e[0]);
        }
        return level(tree, t, 1, target, 1, 0);
    }
    double level(vector<vector<int>>& tree, int t, int root, int target, double prob, int parent) {
        int len = tree[root][0] - 1;
        if(root == target) {
            if((t > 0 && len == 0) || t == 0) {
                return prob;
            } else if (t < 0){
                return 0.0;
            }
        }
        for(int i = 1; i <= len+1; i++) {
            int e = tree[root][i];
            if(e == parent)continue;
            double ret;
            if((ret = level(tree, t-1, e, target, prob * 1.0 / len, root)) != 0) {
                return ret;
            }
        }
        return 0;
    }
};
```

> 时间 12 ms 击败 97.73%
> 内存 15.1 MB 击败 31.82%

## <font color="orange">[Medium] </font>[1090. 受标签影响的最大值](https://leetcode.cn/problems/largest-values-from-labels/description/)

### 分析
重量都为1的背包问题，如果把labels看作物品的分类，对每类物品的限制都相同，都至多有`useLimit`个，每类物品中其value也不尽相同

#### 优先队列
对于每个`label`，维护一个`value`由大到小的优先队列，每次从所有队列中取最大的一个数，若队列空或此类`label`已经超过`useLimit`限制，则不再考虑该`label`

- 排序优化，根据label排序，相同la

### 代码
```c++
class Solution {
public:
    int largestValsFromLabels(vector<int>& values, vector<int>& labels, int numWanted, int useLimit) {
        int n = values.size();
        vector<int> index = vector<int>(n);
        map<int, int> limit; 
        iota(index.begin(), index.end(), 0);
        sort(index.begin(), index.end(), [&](int a, int b){
            if(labels[a] != labels[b]) {
                return labels[a] > labels[b];
            } else {
                return values[a] > values[b];
            }
        });
        auto cmp = [&](int a, int b){return values[index[a]] < values[index[b]];};
        priority_queue<int, vector<int>, decltype(cmp)> q(cmp);
        q.push(0);
        limit[labels[index[0]]] = useLimit;
        for(int i = 1; i < n; i++) {
            if(labels[index[i]] != labels[index[i-1]]) {
                q.push(i);
            }
            limit[labels[index[i]]] = useLimit;
        }
        int sum = 0;
        for(int K = 0; K < numWanted && !q.empty(); K++) {
            int i = q.top();
            q.pop();
            sum += values[index[i]];
            limit[labels[index[i]]]--;
            if(i + 1 < n && labels[index[i+1]] == labels[index[i]] && limit[labels[index[i]]]) {
                q.push(i + 1);
            }
        }
        return sum;
    }
};
```

> 时间 52 ms 击败 7.94%
> 内存 19.3 MB 击败 61.22%

### 优化

想复杂了，只要按照值排序后，从大到小按照限制选择即可，并记录每个标签所选次数就好了

```c++
class Solution {
public:
    int largestValsFromLabels(vector<int>& values, vector<int>& labels, int numWanted, int useLimit) {
        int n = values.size();
        vector<int> index = vector<int>(n);
        map<int, int> limit; 
        iota(index.begin(), index.end(), 0);
        sort(index.begin(), index.end(), [&](int a, int b){
            return values[a] > values[b];
        });
        int sum = 0;
        for(int K = 0, i = 0; K < numWanted && i < n; i++) {
            if(limit[labels[index[i]]] < useLimit) {
                sum += values[index[i]];
                limit[labels[index[i]]]++;
                K++;
            }
        }
        return sum;
    }
};
```

## <font color="orange">[Medium] </font>[1080. 根到叶路径上的不足节点](https://leetcode.cn/problems/insufficient-nodes-in-root-to-leaf-paths/description/)

### 分析
按照题意，首先对二叉树遍历
- 当到达叶节点时，计算根节点到叶节点的总和
  - 如果大于等于`limit`，则该节点及其所有祖先节点都不需要删除，此时返回`true`
  - 否则返回`false`。
- 对于非叶子节点
  - 如果左右子树返回了`true`，该节点不需要被删除，向其父节点返回`true`
    - 则返回`true`的子树不需要被删除
    - 返回`false`的子节点置为`nullptr`，需要被删除
  - 如果都返回了`false`，则该节点需要被删除。向其父节点返回`false`

### 代码
```c++
class Solution {
public:
    int limit;
    TreeNode* sufficientSubset(TreeNode* root, int limit) {
        this->limit = limit;
        if(root && cal(root, 0)) {
            return root;
        } 
        return nullptr;
    }
    bool cal(TreeNode *root, int n) {
        bool ret = false;
        if(!root->left && !root->right) {
            n += root->val;
            ret = n >= limit;
        } else { 
            if(root->left && cal(root->left, root->val + n)) {
                ret = true;
            } else {
                root->left = nullptr;
            }
            if(root->right && cal(root->right, root->val + n)) {
                ret = true;
            } else {
                root->right = nullptr;
            }
        }
        return ret;
    }
};
```

> 时间 40 ms 击败 66.87% 
> 内存 32.2 MB 击败 48.64%