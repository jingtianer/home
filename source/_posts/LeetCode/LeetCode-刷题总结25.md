---
title: LeetCode-25
date: 2023-5-24 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---
<audio controls autoplay>
  <source src="/home/audio/不怕_赵蕾.mp3" type="audio/mpeg">
Your browser does not support the audio element.
</audio>

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

## <font color="green">[Easy] </font>[2451. 差值数组不同的字符串](https://leetcode.cn/problems/odd-string-difference/description/)

### 分析

依次对所有字符串计算相邻两个字符之间的差值，找到差值不同的那一个

- 计算第一个字符串的差值，寻找第一个与其不同的字符串
  - 若第一个与其不一样的字符串下标大于1，则[0, j-1]是相同的，j为与其他不同的字符串
  - 若等于1
    - words总长度为2，则0，1两串不同，返回任意一个即可
    - 总长度大于2，查看字符串2的差值，若与1相同则返回0，否则返回1

### 代码
```c++
class Solution {
public:
    string oddString(vector<string>& words) {
        int len = words[0].size();
        int n = words.size();
        for(int i = 1; i < len; i++) {
            int diff = words[0][i] - words[0][i-1];
            int j = 1;
            while(j < n && words[j][i] - words[j][i-1] == diff) {
                j++;
            }
            if(j == n) {
                continue;
            }
            if(j > 1 || n == 2) {
                return words[j];
            } else {
                if(words[2][i] - words[2][i-1] == diff) {
                    return words[1];
                } else {
                    return words[0];
                }
            }
        }
        return words[0];
    }
};
```

## <font color="green">[Easy] </font> [LCP 33. 蓄水](https://leetcode.cn/problems/o8SXZn/)

### 分析

实际难度应该是hard吧，好难

直接抄答案

### 代码
```c++
class Solution {
public:
    int storeWater(vector<int>& bucket, vector<int>& vat) {
        int n = bucket.size();
        int maxx = 0;
        for(int i = 0; i < n; i++) {
            maxx = max(maxx, vat[i]);
        }
        if(maxx == 0) return 0;
        int res = INT_MAX;
        for(int k = 1; k <= maxx && k < res; k++) {
            int t = 0;
            for(int i = 0; i < n; i++) {
                t += max(0, (vat[i] + k - 1) / k - bucket[i]);
            }
            res = min(res, t+k);
        }
        return res;
    }
};
```

## <font color="red">[Hard] </font> [1373. 二叉搜索子树的最大键值和](https://leetcode.cn/problems/maximum-sum-bst-in-binary-tree/description/)

### 分析
对于每个节点 $ node $， 首先要判断其是否为bst，如果是bst计算以node为根的子树之和

用bst函数的返回值返回是否为bst，三个参数分别返回子树之和，子树的最大值，子树的最小值

子树的最大值即，左子树的子树最大值，右子树子树最大值，根节点的值三者最大值

子树最小值即，左子树的子树最小值，右子树子树最小值，根节点的值三者最小值

- 题目中的不合理：

```c
输入：root = [-4,-2,-5]
输出：0
解释：所有节点键值都为负数，和最大的二叉搜索树为空。
```

这个输入的输出应该是-2，而非0。定义中只要求左子树小于根，右子树大于根，并未要求正负。

```c
输入：root = [4,3,null,1,2]
输出：2
解释：键值为 2 的单节点子树是和最大的二叉搜索树。
```

根据这个输入知道，单节点也算是二叉搜索树，那2算最大子树，-2也应该算最大子树

### 代码
```c++
class Solution {
public:
    int maxx = INT_MIN;
    int maxSumBST(TreeNode* root) {
        int sum = 0, lmax, rmin;
        bool ok = bst(root, sum, lmax, rmin);
        if(ok) {
            maxx = max(maxx, sum);
        }
        return max(0, maxx);
    }
    bool bst(TreeNode *root, int& sum, int& leftMax, int& rightMin) {
        if(root == nullptr) return true;
        int lsum = 0, rsum = 0;
        int llMax = INT_MIN, lrMin = INT_MAX;
        int rlMax = INT_MIN, rrMin = INT_MAX;
        bool lok = bst(root->left, lsum, llMax, lrMin);
        bool rok = bst(root->right, rsum, rlMax, rrMin);
        leftMax = max(root->val, max(llMax, rlMax));
        rightMin = min(root->val, min(lrMin, rrMin));
        if(lok && rok) {
            bool ok = (!root->left || llMax < root->val) && (!root->right || rrMin > root->val);
            if(ok) {
                sum += root->val + lsum + rsum;
                maxx = max(maxx, sum);
            }
            return ok;
        }
        return false;
    }
};
```

## 1079. 活字印刷

### 分析

状态压缩+bfs
总长度最大只有7，最多7个不同字符，直接暴力枚举所有情况

需要记录当前有哪些位使用了，哪些没有使用，用int的最后7位表示

不需要真的生成字符串，只要对每个字符编码，计算一个8进制数就好了

### code

```c++
class Solution {
public:
    set<int> strset;
    vector<int> tiles_int;
    int n;
    int numTilePossibilities(string tiles) {
        this->n = tiles.length();
        tiles_int = vector<int>(n, 0);
        int tile_count = 1;
        tiles_int[0] = 1;
        sort(tiles.begin(), tiles.end());
        for(int i = 1; i < n; i++) {
            if(tiles[i] == tiles[i-1]) {
                tiles_int[i] = tile_count;
            } else {
                tiles_int[i] = ++tile_count;
            }
        }
        dfs(0, 0);
        return strset.size();
    }
    void dfs(int state, int s) {
        int mask = 1;
        for(int i = 0; i < n; i++) {
            if(!(mask & state)) {
                int next_str = (s << 3) + tiles_int[i];
                strset.insert(next_str);
                dfs(state | mask, next_str);
            }
            mask <<= 1;
        }
    }

};
```

> 时间 40 ms 击败 27.67%
> 内存 12.1 MB 击败 32.56%

### 优化

既然排序了，那相同字符就不用重复考虑了
```c++
class Solution {
public:
    set<int> strset;
    vector<int> tiles_int;
    int n;
    int numTilePossibilities(string tiles) {
        int len = tiles.length();
        int tile_count = 1;
        n = 1;
        sort(tiles.begin(), tiles.end());
        for(int i = 1; i < len; i++) {
            if(tiles[i] != tiles[i-1]) {
                tiles_int.push_back(tile_count);
                tile_count = 1;
                n++;
            } else {
                ++tile_count;
            }
        }
        tiles_int.push_back(tile_count);
        dfs(0);
        return strset.size();
    }
    void dfs(int s) {
        for(int i = 0; i < n; i++) {
            if(tiles_int[i]) {
                int next_str = (s << 3) + i + 1;
                strset.insert(next_str);
                tiles_int[i]--;
                dfs(next_str);
                tiles_int[i]++;
            }
        }
    }
};
```

### 继续优化

参考题解，同时结合上面的分析，既然排序后不存在重复了，那可以直接计数，不需要set了
```c++
class Solution {
public:
    vector<int> tiles_int;
    int n;
    int numTilePossibilities(string tiles) {
        int len = tiles.length();
        int tile_count = 1;
        n = 1;
        sort(tiles.begin(), tiles.end());
        for(int i = 1; i < len; i++) {
            if(tiles[i] != tiles[i-1]) {
                tiles_int.push_back(tile_count);
                tile_count = 1;
                n++;
            } else {
                ++tile_count;
            }
        }
        tiles_int.push_back(tile_count);
        return dfs(0);
    }
    int dfs(int s) {
        int ret = 0;
        for(int i = 0; i < n; i++) {
            if(tiles_int[i]) {
                int next_str = (s << 3) + i + 1;
                tiles_int[i]--;
                ret += dfs(next_str) + 1;
                tiles_int[i]++;
            }
        }
        return ret;
    }
};
```