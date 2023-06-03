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

## <font color="orange">[Medium] </font>[1079. 活字印刷](https://leetcode.cn/problems/letter-tile-possibilities/)

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

## <font color="orange">[Medium] </font>[1091. 二进制矩阵中的最短路径](https://leetcode.cn/problems/shortest-path-in-binary-matrix/description/)


### 分析

一眼BFS，但是一直超时

### 超时

```c++
class Solution {
public:
    int shortestPathBinaryMatrix(vector<vector<int>>& grid) {
        int n = grid.size();
        queue<pair<int, int>> q;
        if(!grid[0][0] && !grid[n-1][n-1])
            q.push(make_pair(0, 1));
        vector<bool> visited = vector<bool>(n * n, false);
        while(!q.empty()) {
            auto [pos, len] = q.front();
            q.pop();
            if(len > n*n) continue;
            visited[pos] = true;
            int x = pos / n, y = pos % n;
            if(x == n-1 & y == n-1) {
                return len;
            }
            for(int dx = -1; dx <= 1; dx++) {
                for(int dy = -1; dy <= 1; dy++) {
                    pos = pos2int(x + dx, y + dy, n);
                    if(!checkpos(x+dx, y+dy, n) || grid[x+dx][y+dy] || visited[pos]) continue;
                    q.push({pos, len+1});
                }
            }
        }
        return -1;
    }
    inline bool checkpos(int x, int y, int n) {
        return x >= 0 && y >= 0 && x < n && y < n;
    }
    inline int pos2int(int x, int y, int n) {
        return x*n + y;
    }
};
```

在入队时就应该吧visited置为true

### 代码

```c++
class Solution {
public:
    int shortestPathBinaryMatrix(vector<vector<int>>& grid) {
        int n = grid.size();
        vector<bool> visited = vector<bool>(n * n, false);
        queue<pair<int, int>> q;
        if(!grid[0][0] && !grid[n-1][n-1]){
            q.push(make_pair(0, 1));
            visited[0] = true;
        }
        while(!q.empty()) {
            auto [pos, len] = q.front();
            q.pop();
            int x = pos / n, y = pos % n;
            if(x == n-1 & y == n-1) {
                return len;
            }
            for(int dx = -1; dx <= 1; dx++) {
                for(int dy = -1; dy <= 1; dy++) {
                    pos = pos2int(x + dx, y + dy, n);
                    if(!checkpos(x+dx, y+dy, n) || grid[x+dx][y+dy] || visited[pos]) continue;
                    q.push({pos, len+1});
                    visited[pos] = true;
                }
            }
        }
        return -1;
    }
    inline bool checkpos(int x, int y, int n) {
        return x >= 0 && y >= 0 && x < n && y < n;
    }
    inline int pos2int(int x, int y, int n) {
        return x*n + y;
    }
};
```

> 时间 44 ms 击败 91.20%
> 内存 18.8 MB 击败 68.63%

## <font color="orange">[Medium] </font>[1073. 负二进制数相加](https://leetcode.cn/problems/adding-two-negabinary-numbers/description/)

### 分析

#### 找规律
首先分析其相加的规律
```c

// 1 + 1 = 110

// 00 + 00 = 00,00
// 10 + 10 = 11,00
// 11 + 11 = 00,10
// 10 + 00 = 00,10
// 00 + 10 = 00,10
// 11 + 00 = 00,11
// 11 + 10 = 11,01
// 10 + 11 = 11,01
// 01 + 11 = 00,00

// 100 + 100 = 11000
// 101 + 101 = 11000 + 110 = 11110
// 110 + 110 = 100
// 111 + 111 = 11010
// 1111 + 1111 = 1010
```

发现，1位，3位的结果相当于前面补0后偶数位的结果

#### 总结转换矩阵
以相邻两位为单位，有如下转换关系
```c++
vector<vector<int>> transform = {
    {0b0000, 0b0001, 0b0010, 0b0011}, // 00 + xx
    {0b0001, 0b0110, 0b0011, 0b0000}, // 01 + xx
    {0b0010, 0b0011, 0b1100, 0b1101}, // 10 + xx
    {0b0011, 0b0000, 0b1101, 0b0010}  // 11 + xx
};
```

将多出来的高两位视为进位，低两位视为相加结果

#### 进位
考虑到进位，以及进位的进位，需要比最长数字多四位

$$
\begin{equation*}
\begin{aligned}
&&&&&&x_1&x_0&\\
+&&&&&&y_1&y_0&\\
=&&&&t_{13}&t_{12}&t_{11}&t_{10}&\\
+&&&&&&c_{1}&c_{0}&\\
=&&&&t_{23}&t_{22}&t_{21}&t_{20}&\\
+&&&&t_{13}&t_{12}&&&&\\
=&&t_{33}&t_{32}&t_{31}&t_{30}&t_{21}&t_{20}&\\
\end{aligned}
\end{equation*}
$$

c代表进位，t代表相加后的结果

### 代码

```c++
class Solution {
public:
    vector<vector<int>> transform = {
        {0b0000, 0b0001, 0b0010, 0b0011}, // 00 + xx
        {0b0001, 0b0110, 0b0011, 0b0000}, // 01 + xx
        {0b0010, 0b0011, 0b1100, 0b1101}, // 10 + xx
        {0b0011, 0b0000, 0b1101, 0b0010}  // 11 + xx
    };
    vector<int> addNegabinary(vector<int>& arr1, vector<int>& arr2) {
        int len1 = arr1.size() - 1, len2 = arr2.size() - 1;
        if(len1 % 2 == 0) {
            arr1.insert(arr1.begin(), 0);
            len1++;
        }
        if(len2% 2 == 0) {
            arr2.insert(arr2.begin(), 0);
            len2++;
        }
        // 补成偶数
        vector<int> summ = vector<int>(max(len1, len2) + 5, 0); //多分配四位
        int len_res = max(len1, len2) + 5 - 1;
        for(int i = 0; len1 > 0 || len2 > 0; len1-=2, len2-=2, i+=2) {
            int x = len1 > 0 ? (arr1[len1-1]<<1) + (arr1[len1]) : 0;
            int y = len2 > 0 ? (arr2[len2-1]<<1) + (arr2[len2]) : 0;
            int carry = (summ[i+1]<<1) + (summ[i]);
            
            int trans1 = transform[x][y]; // x + y
            int trans2 = transform[trans1&0b0011][carry]; // 低二位(x + y) + carry
            int trans3 = transform[(trans1&0b1100) >> 2][(trans2&0b1100) >> 2]; // 高二位

            summ[i]   =  trans2&0b0001;
            summ[i+1] = (trans2&0b0010) >> 1;
            summ[i+2] = (trans3&0b0001);
            summ[i+3] = (trans3&0b0010) >> 1;
            summ[i+4] = (trans3&0b0100) >> 2;
            summ[i+5] = (trans3&0b1000) >> 3;
        } //计算
        while(!summ.empty() && summ.back() == 0) summ.pop_back();
        if(summ.size() == 0) summ = {0};
        // 删除前导0
        reverse(summ.begin(), summ.end());
        return summ;
    }
};
```

> 时间 4 ms 击败 90.75%
> 内存 19.3 MBn 击败 5.2%

## <font color="orange">[Medium] </font> [1093. 大样本统计](https://leetcode.cn/problems/statistics-from-a-large-sample/description/)

### 分析


看起来很简单的题目，还是错了两次

1. 计算总数偶数个中位数，且中位数两个数不相等时，没有考虑到两个数直接相差可能大于1，既第 $ summ/2 $ 与 $ summ/2 + 1 $ 之间有很多数为0的情况

2. 对`0-255`加权求和时，右边应该先转`double`再计算，防止`int`溢出

### 代码
```c++
class Solution {
public:
    vector<double> sampleStats(vector<int>& count) {
        int minmum = 255;
        int maximum = 0;
        double mean = 0;
        double mode  = 0;
        double medium = 0;
        int summ = 0;
        for(int i = 0; i < 256; i++) {
            if(count[i] > 0) {
                minmum = min(minmum, i);
                maximum = max(maximum, i);
                summ += count[i];
                mean += 1.0*i*count[i];
            }
            if(count[i] > count[mode]) {
                mode = i;
            }
        }
        mean /= summ;
        {   
            int i = 0, c = count[0];
            for(; c<summ/2; c+=count[++i])continue;
            if(summ%2 == 0) medium = i;
            for(; c<=summ/2; c+=count[++i])continue;
            medium += i;
            if(summ%2 == 0) {
                medium /= 2;
            }
        }
        return {(double)minmum, (double)maximum, mean, medium, mode};
    }
};