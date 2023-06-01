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

## <font color="orange">[Medium] </font>[1130. 叶值的最小代价生成树](https://leetcode.cn/problems/minimum-cost-tree-from-leaf-values/description/)

### 分析

#### 观察测试用例

```c++
输入：arr = [6,2,4]
输出：32
解释：有两种可能的树，第一种的非叶节点的总和为 36 ，第二种非叶节点的总和为 32 。 
```
这里一共两种方法
- 先选择arr[0]和arr[1]
- 先选择arr[1]和arr[2]

第二种最后代价最小

这里就联想到`数据结构`中`哈夫曼树`的算法。略有不同：
- 不能对数组排序，因为他对应着中序遍历
- 生成父节点时，要找到两个节点子树中叶节点的最大值

#### 构造算法

根据哈夫曼树算法，每次选取两个节点，生成一个父节点，存入数组中，此时数组多了一个空闲节点，这个节点就用来存放该父节点下的最大叶子。

初始情况下，直接选择乘积最小的两个相邻节点`node1, node2`生成父节点`node`，此时将父节点插入原来`node1`的位置，`node2`的位置用来保存`max(node1, node2)`。

此时需要一个辅助数组标记每个位置是节点还是信息，用`true`代表其是节点

后续中，每次选择两个相邻的节点（两个相邻的true或者两个true之间只有false），选择乘积最小的两对，此时有以下几种情况
- 110... //两个连续1且第二个1后面有0（第二个节点为非叶）
- 111... // 两个都叶
- 10..11.. // 第一个节点非叶，第二个为叶子
- 10..10..0 // 两个都非叶，且没有下一对节点了
- 10..10..1 // 两个都非叶，且有下一对节点了
- 11 // 两个都叶且没有下一对节点了
- 10...1 // 第一个节点非叶，第二个为叶子且没有下一对节点了

也就是需要考虑两个节点是否是叶子的情况，还有没有下一对节点的情况，不论何种情况，都将`node1`位置存放生成的父节点`node`，`node1位置+1`存放最大叶子。这样如果一个节点为后面位置为`false`，则后面这个数就是子树中的最大叶子

按照哈夫曼树算法，重复n-1次上面操作

### 代码

```c++
class Solution {
public:
    int mctFromLeafValues(vector<int>& arr) {
        int n = arr.size();
        int ret = 0;
        vector<bool> available = vector<bool>(n, true);
        for(int cnt = 0; cnt < n - 1; cnt++) {
            int i = 0, j = 0;
            int mini = 0, minj = 0;
            int minn = INT_MAX, minn1, minn2;
            while(i < n && !available[i]) i++;
            j = i+1;
            while(j < n) {
                while(j < n && !available[j]) j++;
                if(j >= n) break;
                int node = 0, node1, node2;
                if(available[i+1]) {
                    node1 = arr[i];
                } else {
                    node1 = arr[i+1];
                }
                if(j + 1 < n && !available[j+1]) {
                    node2 = arr[j+1];
                } else {
                    node2 = arr[j];
                }
                node = node1 * node2;
                if(node < minn) {
                    mini = i;
                    minj = j;
                    minn = node;
                    minn1 = node1;
                    minn2 = node2;
                }
                i = j;
                j++;
            }
            ret += minn;
            arr[mini+1] = max(minn1, minn2);
            arr[mini] = minn;
            available[mini+1] = false;
            available[minj] = false;
        }
        return ret;
    }
};
```

> 时间 4 ms 击败 77.21% 
> 内存 8.2 MB 击败 61.86%

### 优化
由于最大只有40个节点，状态也只有true, false，只需要一个long long就可以代替`available`数组

> 时间 $ O(n^2) $ 空间 $ O(1) $

参考这个[题解](https://leetcode.cn/problems/minimum-cost-tree-from-leaf-values/solutions/940411/zhen-zheng-shuang-bai-tan-xin-suan-fa-c-bb8il/)，我的思路其实与他完全相似，且没必要存储父节点的值（每次父节点的值保存起来，但是计算时都用不到），只要把较小的值删除就好

```c++
class Solution {
public:
    int mctFromLeafValues(vector<int>& arr) {
        int n = arr.size(), ret = 0;
        for(int cnt = n - 1; cnt > 0; cnt--) { // cnt恰好就是数组的size
            int min_index = 0, minn = INT_MAX;
            for(int i = 0; i < cnt; i++) {
                if(arr[i] * arr[i+1] < minn) {
                    minn = arr[i] * arr[i+1];
                    min_index = arr[i] < arr[i+1] ? i : i + 1;
                }
            }
            ret += minn;
            arr.erase(arr.begin() + min_index);
        }
        return ret;
    }
};
```