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

![](https://i-blog.csdnimg.cn/blog_migrate/9f5a2ca762ccf594a9bc5ea7d3851359.jpeg)

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
    monoStack = move(stack<int>());
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
        while(right[l] < r && left[r] > l) { // 有可能循环n/2次，退化成O(n)
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
```c++
/*
6,5,1,4,6,1,5,3
稀疏表
0 1 3 7
0 1 2 3
———————
6 5 4 1
5 1 1
1 1 1
4 4 5
6 1 1
1 1
5 3
3
可见构造的时间为O(nlogn)

0...1 1...2 2...3 3...4 4...5 5...6 6...7
0...3 1...4 2...5 3...6 4...7 5...7 6...7
0...7 1...7 2...7 3...7 4...7 5...7 6...7

0...2 -> 0...1, 2...2
0...4 -> 0...3, 4...4
0...5 -> 0...3, 4...5
0...6 -> 0...3, 4...6
可见一个查询可以拆成两个查询

因为ST[i][j] = i...(i + 2^j - 1)
所以log(end - start + 1)就可以找到可以拆分的最大数组

要查0...6，查询(0, log(6-0+1)) = (0, 2) = 0...3
下面查3...6，查询(3, 2) = (6 - 2^2 + 1, 2)
公式是这么来的：a...b = (a, a + 2^j -1) = (b - 2^j + 1, b)

要查0...5，查询(0, log(5-0+1)) = (0, 2) = 0...3
下面查2...5, 查询(2, 2) = (5 - 2^2 + 1, 2)
*/
```

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
    for(int p = 1; p <= log_n; p++) {
        for(int i = 0; i + p < n; i++) { // n - p
            int minValue = min(ST[i][p-1], ST[i+p][p-1]);
            ST[i].push_back(minValue);
        }
    }
    for(auto [start, end] : query) {
        int pos = log2(end - start + 1);
        int minValue = min(ST[start][pos], ST[end - (1 << pos) + 1][end]);
        ans.push_back(minValue);
    }
    return ans;

}
```

## 快速幂

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

### 递归
```c++
class Solution {
public:
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        if(!root) return nullptr;
        if(root == p || root == q) return root;
        TreeNode *l = lowestCommonAncestor(root->left, p, q);
        TreeNode *r = lowestCommonAncestor(root->right, p, q);
        if(l != nullptr && r != nullptr) return root;
        return l == nullptr ? r : l;
    }
};
```

### 转数组后，用index
```c++
class Solution {
    vector<TreeNode*> toList(TreeNode *root) {
        vector<TreeNode*> list;
        queue<TreeNode *> q;
        q.push(root);
        while(!q.empty()) {
            int len = q.size();
            bool flag = false;
            while(len--) {
                TreeNode *node = q.front();
                q.pop();
                list.push_back(node);
                if(node) {
                    q.push(node->left);
                    q.push(node->right);
                    flag |= node->left != nullptr || node->right != nullptr;
                } else {
                    q.push(nullptr);
                    q.push(nullptr);
                }
            }
            if(!flag) break;
        }
        return list;
    }
public:
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        vector<TreeNode*> tree = toList(root);
        int index0 = 0, index1 = 0;
        int len = tree.size();
        while(index0 < len && tree[index0] != p && tree[index0] != q) {
            index0++;
        }
        index1 = index0+1;
        while(index1 < len && tree[index1] != p && tree[index1] != q) {
            index1++;
        }
        index0++;
        index1++;
        while(index0 != index1) {
            if(index0 > index1) {
                index0 >>= 1;
            } else {
                index1 >>= 1;
            }
        }
        return tree[index0-1];
    }
};
```

- 节点多时内存爆炸

### 