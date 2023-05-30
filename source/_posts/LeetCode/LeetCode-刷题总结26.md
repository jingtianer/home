---
title: LeetCode-26
date: 2023-5-30 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## <font color="orange">[Medium] </font>[1110. 删点成林](https://leetcode.cn/problems/delete-nodes-and-return-forest/description/)

### 分析

1. 使用什么样的数据结构
   1. 直接用数组
   2. 用孩子兄弟表示法
2. 使用什么样的遍历方法？


### 代码

```c++
class Solution {
public:
    vector<TreeNode*> forest;
    vector<TreeNode*> delNodes(TreeNode* root, vector<int>& to_delete) {
        if(root){
            if(del(root, to_delete)) {
                push_forest(root);
            } else {
                forest.push_back(root);
            }
        }
        return forest;
    }
    bool del(TreeNode* root, vector<int>& to_delete) {
        if(root->left && del(root->left, to_delete)) {
            push_forest(root->left);
            root->left = nullptr;
        }
        if(root->right && del(root->right, to_delete)) {
            push_forest(root->right);
            root->right = nullptr;
        }
        for(int d : to_delete) {
            if(d == root->val) {
                return true;
            }
        }
        return false;
    }
    void push_forest(TreeNode *root) {
        if(root->left) {
            forest.push_back(root->left);
        }
        if(root->right) {
            forest.push_back(root->right);
        }
    }
};
```

### 结果


- 若使用孩子兄弟表示法，需要将二叉树转换为孩子兄弟，处理好后在转换回来，同时将根节点及其兄弟变成数组，不如直接用数组
- 若使用先序，若不知道孩子是否应该被删除，而直接放入最终结果中，若子节点也需要被删除，那么处理将会变得复杂

> 时间 16 ms 击败 92.74% 
> 内存 24.6 MB 击败 85.48%

## <font color="red">[Hard] </font> [1439. 有序矩阵中的第 k 个最小数组和](https://leetcode.cn/problems/find-the-kth-smallest-sum-of-a-matrix-with-sorted-rows/description/)

### 分析

#### 总体思路
小顶堆+n指针

我们已知mat的每一行都是非递减的，那么最小的元素一定是全部取每行第一个元素的情况。我们记录为状态`[0,0,0,0,...]`

参考bfs的思想，在初始状态的基础上移动一个指针，一定比第初始状态大

此处贪心，每次选取最小的状态（即n个指针对应元素之和最小的），将其下一步状态生成出来，生成k次后，即为第k小的状态

#### 状态转换
易知初始状态S=`[0,0,0,...,0]`的下一步为
- S1=`[1,0,0,...,0]`
- S2=`[0,1,0,...,0]`
- S3=`[0,0,1,...,0]`
- `...`
- Sn=`[0,0,0,...,1]`

然而对于状态`Si`的第`j`个子状态与`Sj`的第`i`个子状态都是`Sij=Sji=[0,0,0,...,1,...,1,...,0]`。为了防止重复，规定，Si只能从第i个指针及其后面的指针向后移动一位表示为
- `pair<int, vector<int>>(i, {0,0,0,...,1,...,0})`
此处i为该状态允许向后移动的指针第一个指针

#### 注意
```c++
输入：mat = [[1,10,10],[1,4,5],[2,3,6]], k = 7
输出：9
```

状态`[0,2,0]`小于`[1,0,0]`。也就是移动指针次数多的，其值可能反而比移动次数少的更小，这也是使用堆的原因

### 代码

```c++
class Solution {
public:
    int m, n;
    int kthSmallest(vector<vector<int>>& mat, int k) {
        m = mat.size(), n = mat[0].size();
        auto cmp = [&](pair<int, vector<int>>& a, pair<int, vector<int>>& b) {
            int suma = 0, sumb = 0;
            for(int i = 0; i < m; i++) {
                suma += mat[i][a.second[i]];
                sumb += mat[i][b.second[i]];
            }
            return suma > sumb;
        };
        priority_queue<pair<int, vector<int>>, vector<pair<int, vector<int>>>, decltype(cmp)> q(cmp);
        vector<int> state = vector<int>(m, 0);
        q.push(make_pair(0, state));
        while(k--) {
            auto tmp = q.top();
            q.pop();
            state = tmp.second;
            for(int i = tmp.first; i < m; i++) {
                if(state[i] + 1 >= n) continue;
                state[i]++;
                q.push(make_pair(i, state));
                state[i]--;
            }
        }
        return value(state, mat);
    }
    int value(const vector<int>& v, vector<vector<int>>& mat) {
        int sum = 0;
        for(int i = 0; i < m; i++) {
            sum += mat[i][v[i]];
        }
        return sum;
    }
};
```

### 优化代码

- 使用数组前两位代表原来的`i`和`value`，减少重复计算`value`
- 使用前一步状态的value计算新value，减少遍历次数
- 使用`--k`而不是`k--`，第k个无需计算其后代，后代一定不比他小
```c++
class Solution {
public:
    int kthSmallest(vector<vector<int>>& mat, int k) {
        int m = mat.size(), n = mat[0].size();
        auto cmp = [&](vector<int>& a, vector<int>& b) {
            return a[1] > b[1];
        };
        priority_queue<vector<int>, vector<vector<int>>, decltype(cmp)> q(cmp);
        vector<int> state = vector<int>(m+2, 0);
        for(int i = 0; i < m; i++) {
            state[1] += mat[i][0];
        }
        q.push(state);
        while(--k) {
            state = q.top();
            q.pop();
            int oldvalue = state[1];
            for(int i = state[0]; i < m; i++) {
                if(state[i+2] + 1 >= n) continue;
                state[1] -= mat[i][state[i+2]];
                state[i+2]++;
                state[0] = i;
                state[1] += mat[i][state[i+2]];
                q.push(state);
                state[i+2]--;
                state[1] = oldvalue;
            }
        }
        return q.top()[1];
    }
};
```

> 时间 16 ms 击败 93.5%
> 内存 14.4 MB 击败 38.35%