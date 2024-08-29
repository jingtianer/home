---
title: OI KIWI 01-倍增
date: 2024-8-23 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

[OI KIWI 倍增](https://oi-wiki.org/basic/binary-lifting/)

## 思想

![](./images/lifting_alogrithm.jpeg)

> [图片来源](https://blog.csdn.net/bei2002315/article/details/126235995)

## 查找小于limit的最大数字

```c++
int maxValueInVecSmallerThenLimit(vector<int>& vec, int limit) {
    int n = vec.size();
    int l = 0;
    int p = 1;
    while(p) {
        if(l + p < n && vec[l + p] < limit) {
            l += p;
            p <<= 1;
        } else {
            p >>= 1;
        }
    }
    return vec[l];
}
```

- 和二分一样，需要在有序数组上查找
- 对于查找区间`[l, l + p)`
  - 如果`vec[l+p] >= limit`， 则最大值就在`[l, l + p)`区间上,下一步查询`[l, l + p / 2)`
  - 如果`vec[l+p] < limit`， 则最大值不在`[l, l + p)`区间上,下一步查询`[l + p, l + 3*p)`
  - 如果`l+p >= n`, 则缩小查找范围

- 我们把上面的逻辑迭代两次
  - 如果`vec[l+p] >= limit`， 则最大值就在`[l, l + p)`区间上,下一步查询`[l, l + p / 2)`
    - 如果`vec[l+p/2] >= limit`， 则最大值就在`[l, l + p/2)`区间上,下一步查询`[l, l + p / 4)`
    - 如果`vec[l+p/2] < limit`， 则最大值不在`[l, l + p/2)`区间上,下一步查询`[l + p/2, l + p/2 + p)`
  - 如果`vec[l+p] < limit`， 则最大值不在`[l, l + p)`区间上,下一步查询`[l + p, l + 3*p)`
    - 如果`vec[l+3*p] >= limit`， 则最大值就在`[l + p, l + 3*p)`区间上,下一步查询`[l + p, l + 2*p)`
    - 如果`vec[l+3*p] < limit`， 则最大值不在`[l + p, l + 3*p)`区间上,下一步查询`[l + 3 * p, l + 7 * p)`

## RMQ区间最值

Range Maximum/Minimum Query

### 单调栈
用单调栈找到两个数组`left`和`right`
- `left[i]`代表`arr[i]`在`[left[i], i]`的区间上是最小值
- `right[i]`代表`arr[i]`在`[i, right[i]]`的区间上是最小值
- 对于一个查询`[l, r]`
  - 如果`left[r] <= l`, `arr[r]`是区间最小值
  - 如果`right[l] >= r`, `arr[l]`是区间最小值
  - 否则`l = right[l] + 1`, `r = left[r] - 1`，缩小查找范围

```c++
vector<int> RangeMinimumQuery(vector<int>& arr, vector<vector<int>>& queries) {
    stack<int> monoStack;
    int len = arr.size();
    int res = 0;
    vector<int> left(len), right(len, len - 1);
    for(int i = 0; i < len; i++) {
        left[i] = right[i] = i;
        int top = -1;
        while(!monoStack.empty() && arr[monoStack.top()] >= arr[i]) {
            top = monoStack.top();
            monoStack.pop();
        }
        if(top != -1) left[i] = left[top];
        monoStack.push(i);
    }
    monoStack = stack<int>();
    for(int i = len - 1; i >= 0; i--) {
        int top = -1;
        while(!monoStack.empty() && arr[monoStack.top()] > arr[i]) {
            top = monoStack.top();
            monoStack.pop();
        }
        if(top != -1) right[i] = right[top];
        monoStack.push(i);
    }
    vector<int> ans;
    for(const auto& query : queries) {
        int l = query[0], r = query[1];
        while(right[l] < r && left[r] > l) { 
            // 有可能循环n/2次，退化成O(n), 如5,4,3,2,1,2,3,4,5
            l = min(len - 1, right[l] + 1);
            r = max(0, left[r] - 1);
        }
        ans.push_back(min(arr[l], arr[r]));
    }
    return ans;
}
```

### ST表

参考这里：[https://oi-wiki.org/ds/sparse-table/](https://oi-wiki.org/ds/sparse-table/)

适用范围：可重复贡献问题
- op(x, x) = x, 一个操作重复计算等于其本身
- 比如max, min, gcd等操作
- 这样可以允许我们划分子问题时，即使子问题之间存在重叠，也可以获得正确的结果

$ ST[i][j] = min(arr[i...(i + 2^j - 1)]) $ (闭区间)

```c++
/*
6,5,1,4,6,1,5,3
稀疏表
0 1 3 7
0 1 2 3
———————
6 5 4 1
5 1 1 1
1 1 1 1
4 4 5 1
6 1 1 1
1 1 1 1
5 3 3 3
3 3 3 3
*/
```
可见构造的时间为O(nlogn)

```c++
/*
0...1 1...2 2...3 3...4 4...5 5...6 6...7
0...3 1...4 2...5 3...6 4...7 5...7 6...7
0...7 1...7 2...7 3...7 4...7 5...7 6...7

0...2 -> 0...1, 1...2
0...4 -> 0...3, 1...4
0...5 -> 0...3, 2...5
0...6 -> 0...3, 3...6
*/
```
一个查询有可拆成同一行的两个子数组


因为 $ ST[i][j] = min(arr[i...(i + 2^j - 1)]) $

$ start = i $ , $end = i + 2^j - 1$

解得
$j = log(end - start + 1)$

要查 $ 0 ... 6 $，查询 $ (0, log(6-0+1)) $ = $ (0, 2) $ = $ 0 ... 3 $
下面查 $ 3 ... 6 $，查询 $ (3, 2) $ = $ (6 - 2^2 + 1, 2) $
公式是这么来的：
$a...b$ = $(a, a + 2^j - 1)$ = $(b - 2^j + 1, b)$

要查$0 ... 5$，查询$(0, log(5-0+1))$ = $(0, 2)$ = $0 ... 3$
下面查$ 2 ... 5 $, 查询$(2, 2)$ = $(5 - 2^2 + 1, 2)$
也就是说，要查询$ a...b $ 
相当于$ min(a...(a+2^j-1), (b - 2^j + 1)...b) $
$ min(ST[a][j], ST[b-2^j+1][j]), j = log2(b-a+1)$

如何构造ST表：
$ (i, i + 2^j - 1) = (i, i + 2^{j-1} - 1), (i + 2^{j-1}, i + 2^j - 1) $
$ ST[i][j] = min(ST[i][j-1], ST[i+j][j-1]) $ 

```c++
vector<int> RMQ(vector<int>& array, vector<pair<int, int>>& query) {
    int n = array.size();
    int log_n = log2(n);
    vector<vector<int>> ST(n);
    vector<int> ans;
    for(int i = 0; i < n; i++) {
        ST[i].push_back(array[i]);
    }
    // sum[p=1...log2(n)](n-p) = n*log2(n) - (log2(n)+1)*log2(n)/2
    for(int j = 1; j <= log_n + 1; j++) {
        int off = 1 << (j - 1);
        for(int i = 0; i + off < n; i++) { // n - j
            ST[i].push_back(min(ST[i][j-1], ST[i+off][j-1]));
        }
    }
    for(auto [start, end] : query) {
        int pos = log2(end - start + 1);
        ans.push_back(min(ST[start][pos], ST[end - (1 << pos) + 1][pos]));
    }
    return ans;
}
```

## 快速幂
对指数进行二进制分解
$ n $ = 22 = 10110 = $2^4 + 2^2 + 2^1$
$ a^{n} = a^{2^4} \times a^{2^2} \times a^{2^1}$
```c++
int fastPow(int base, int pow, int mod) {
    int ans = 1 % mod; // 注意要在最初或最后对ans取mod，以应对pow = 0, mod = 1的情况
    while(pow) {
        if(pow & 1) ans = (ans * base) % mod;
        base = (base * base) % mod;
        pow >>= 1;
    }
    return ans;
}
```
## LCA最近公共祖先

### 遍历二叉树
```c++
class Solution {
public:
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        if(!root) return nullptr;
        if(root == p || root == q) return root;
        TreeNode *l = lowestCommonAncestor(root->left, p, q);
        TreeNode *r = lowestCommonAncestor(root->right, p, q);
        if(l != nullptr && r != nullptr) return root; // p和q分别在左右子树中找到
        return l == nullptr ? r : l;
    }
};
```

复杂度为$ O(n) $
对于$m$次查询,复杂度为$O(m \times n)$

### ST表

当查找两个节点node0和node1的最近公共祖先时
- 如果node0和node1在同一层，深度为`d`
  - 如果两个节点在深度`d-k`层处的祖先是同一个
    - 那么说明最近公共祖先在`[d-k, d+1]`
    - `k`偏大了，需要减小
  - 如果两个节点在深度`d-k`层处的祖先不是同一个
    - 那么说明最近公共祖先在`[0, d-k]`
    - 将两个节点移动到各自`d-k`层处的祖先处

如此迭代，就可以将区间不断缩小，最后定位到最近公共祖先
如果`k`取当前深度的一半，就可以达到`log(depth)`的复杂度

`ST[i][j]`表示节点`i`向上`2^j`层的祖先节点
$ 2^j < depth, j=0...floor(log2(depth))$
转移方程为:
```c++
ST[i][j] = ST[ST[i][j-1]][j-1]
```
这里就用到了倍增的思想

- 如果node0和node1在不同一层，可以先将深度较深的节点向上移动
假设高度差为5=101
则
```c++
node = ST[node][0] // j = 0, 2^0
node = ST[node][2] // j = 2, 2^2
```
将高度差的二进制分解，即可以`log(dep1 - dep2)`的复杂度将两个节点放到同一层

```c++
class LCA {
    vector<vector<int>>& tree; // tree[i][j]代表节点i的第j个孩子在tree中的索引
    int N; // 节点总数
    vector<vector<int>> ST; // ST[i][j]表示节点i向上2^j层的祖先节点
    vector<int> depth; // depth[i]代表节点的深度
    int maxDepth = 0; // 树的深度
    void dfsInit(int root, int dep) {
        depth[root] = dep; // 每个节点的深度
        maxDepth = max(maxDepth, dep);
        for(int child : tree[root]) {
            dfsInit(child, dep + 1);
            ST[child][0] = root;// child节点向上2^0=1层的父节点
        }
    }
    void initST() { // i向上2^j层的父节点 = i向上向上2^(j-1)层父节点再向上2^(j-1)层的父节点
        for(int j = 1; (1 << j) <= maxDepth; j++) {
            for(int i = 0; i < N; i++) {
                ST[i].push_back(ST[ST[i][j-1]][j-1]);
            }
        }
    }
    LCA(vector<vector<int>>& tree, int N): 
        tree(tree), N(N), depth(N), ST(N, vector<int>(1)) {
        dfsInit(0, 0);
        initST();
    }
    public:
    LCA(vector<vector<int>>& tree):LCA(tree, tree.size()) {}
    int lca(int node0, int node1) {
        if(depth[node0] > depth[node1]) {
            swap(node0, node1); // node1为深度更深的节点
        }
        int depDiff = depth[node1] - depth[node0];
        for(int i = 0; depDiff; depDiff >>= 1, i++) {
            if(depDiff & 1) {
                node1 = ST[node1][i]; // 向上移动node1，两者depth相同
            }
        }
        if(node1 == node0) return node0;
        for(int i = log2(maxDepth); i >= 0; i--) { // 每次向上查询的深度减半
            if(ST[node0][i] != ST[node1][i]) { // 向上的祖先节点不同，移动到各自祖先节点上
                node0 = ST[node0][i];
                node1 = ST[node1][i];
            } // else 向上的祖先节点相同，继续减小深度
        }
        return ST[node0][0]; // node0或node1的父节点就是lca
    }
};
```

- 每次查询的复杂度为
  - $O(log(depth))$
- 预处理的时间复杂度为
  - $O(log(n \times log(depth)))$
- $ m $ 次查询的复杂度为
  - $ O((m + n) \times log(depth)) $