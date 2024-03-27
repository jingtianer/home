---
title: LeetCode-35
date: 2024-3-25 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## [518. 零钱兑换 II](https://leetcode.cn/problems/coin-change-ii/description/?envType=daily-question&envId=2024-03-25)

```c++
class Solution {
public:
    int change(int amount, vector<int>& coins) {
        int n = coins.size();
        vector<int> dp(amount+1);
        dp[0] = 1;
        for(int i = 1; i <= n; i++) {
            for(int j = coins[i-1]; j <= amount; j++) {
                dp[j] += dp[j-coins[i-1]];
            }
        }
        return dp[amount];
    }
};
```

## [322. 零钱兑换](https://leetcode.cn/problems/coin-change/description/?envType=daily-question&envId=2024-03-24)

```c++
class Solution {
public:
    int coinChange(vector<int>& coins, int amount) {
        int n = coins.size();
        vector<int> dp(amount + 1, INT_MAX);
        dp[0] = 0;
        for(int i = 1; i <= n; i++) {
            for(int j = coins[i-1]; j <= amount; j++) {
                if(dp[j - coins[i-1]] != INT_MAX)
                    dp[j] = min(dp[j], dp[j - coins[i-1]] + 1);
            }
        }
        return dp[amount] == INT_MAX ? -1 : dp[amount];
    }
};
```

## [25. K 个一组翻转链表](https://leetcode.cn/problems/reverse-nodes-in-k-group/description/)

> 啊？真的是困难吗

```c++
class Solution {
    int listLen(ListNode *head) {
        int n = 0;
        while(head) {
            n++;
            head = head->next;
        }
        return n;
    }
public:
    ListNode* reverseKGroup(ListNode* head, int k) {
        ListNode dummy, *move = &dummy, *next = head;
        int n = listLen(head);
        for(int j = 0; j + k <= n; j+=k) {
            next = head;
            for(int i = 0; i < k; i++) {
                ListNode *tmp = head;
                head = head->next;
                tmp->next = move->next;
                move->next = tmp;
            }
            move = next;
        }
        while(head) {
            move->next = head;
            move = head;
            head = head->next;
        }
        return dummy.next;
    }
};
```

## [2642. 设计可以求最短路径的图类](https://leetcode.cn/problems/design-graph-with-shortest-path-calculator/description/?envType=daily-question&envId=2024-03-26)

```c++
class Graph {
    int n;
    vector<vector<int>> dist;
public:
    Graph(int n, vector<vector<int>>& edges) 
        : n(n), dist(n, vector<int>(n, INT_MAX >> 1)) {
        for(auto& edge : edges) {
            dist[edge[0]][edge[1]] = edge[2];
        }
        for(int w = 0; w < n; w++) {
            dist[w][w] = 0;
            for(int i = 0; i < n; i++) {
                for(int j = 0; j < n; j++) {
                    dist[i][j] = min(dist[i][j], dist[i][w] + dist[w][j]);
                }
            }
        }
    }
    
    void addEdge(vector<int> edge) {
        if(dist[edge[0]][edge[1]] <= edge[2]) return;
        dist[edge[0]][edge[1]] = edge[2];
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                dist[i][j] = min(dist[i][j], dist[i][edge[0]] + dist[edge[0]][j]);
            }
        }
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                dist[i][j] = min(dist[i][j], dist[i][edge[1]] + dist[edge[1]][j]);
            }
        }
    }
    
    int shortestPath(int node1, int node2) {
        return dist[node1][node2] == (INT_MAX >> 1) ? -1 : dist[node1][node2];
    }
};
```

- 用边更新

```c++
class Graph {
    int n;
    vector<vector<int>> dist;
public:
    Graph(int n, vector<vector<int>>& edges) 
        : n(n), dist(n, vector<int>(n, INT_MAX >> 2)) {
        for(auto& edge : edges) {
            dist[edge[0]][edge[1]] = edge[2];
        }
        for(int w = 0; w < n; w++) {
            dist[w][w] = 0;
            for(int i = 0; i < n; i++) {
                for(int j = 0; j < n; j++) {
                    dist[i][j] = min(dist[i][j], dist[i][w] + dist[w][j]);
                }
            }
        }
    }
    
    void addEdge(vector<int> edge) {
        if(dist[edge[0]][edge[1]] <= edge[2]) return;
        dist[edge[0]][edge[1]] = edge[2];
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                dist[i][j] = min(dist[i][j], dist[i][edge[0]] + dist[edge[1]][j] + edge[2]);
            }
        }
    }
    
    int shortestPath(int node1, int node2) {
        return dist[node1][node2] == (INT_MAX >> 2) ? -1 : dist[node1][node2];
    }
};

/**
 * Your Graph object will be instantiated and called as such:
 * Graph* obj = new Graph(n, edges);
 * obj->addEdge(edge);
 * int param_2 = obj->shortestPath(node1,node2);
 */
```

> 最快的还是每次求最短路时dijkstra现算

## [93. 复原 IP 地址](https://leetcode.cn/problems/restore-ip-addresses/description/)

- 用dots数组表示在字符串位置i后面加点`.`，加入四个点后，且第四个点在最好一个字符后面，就是合法的
- 如果遇到0，只能在其后加一个点，不考虑有前导0

```c++
class Solution {
public:
    vector<string> restoreIpAddresses(string s) {
        vector<string> ans;
        int dots[4] = {-1};
        int len = s.length();
        function<void(int, int)> dfs = [&](int i, int n) {
            if(n == 4) {
                if(dots[3] == len - 1)
                    ans.push_back(
                        s.substr(0, dots[0] + 1) + "." 
                        + s.substr(dots[0] + 1, dots[1] - dots[0]) + "." 
                        + s.substr(dots[1] + 1, dots[2] - dots[1]) + "." 
                        + s.substr(dots[2] + 1, len - dots[2] - 1));
                return;
            }
            if(s[i] == '0') {
                dots[n] = i;
                dfs(i+1, n+1);
                return;
            }
            int x = 0;
            for(int j = i; j < len; j++) {
                x *= 10;
                x += s[j] - '0';
                if(s[j] > '9' || s[j] < '0') break;
                if(x > 255  || x < 0) break;
                dots[n] = j;
                dfs(j+1, n+1);
            }
        };
        dfs(0, 0);
        return ans;
    }
};
```

## [96. 不同的二叉搜索树](https://leetcode.cn/problems/unique-binary-search-trees/description/)

> 假设i为当前根节点，将数组分成两部分，一部分是左子树，一部分是右子树
> 子树重复上面的操作
> 再加上记忆优化



```c++
class Solution {
    vector<vector<int>> mem;
    int numTrees(int l, int r) {
        if(mem[l][r] != -1) return mem[l][r];
        if(l >= r) return 1;
        int ans = 0;
        for(int i = l; i < r; i++) {
            ans += numTrees(l, i) * numTrees(i+1, r);
        }
        mem[l][r] = ans;
        return ans;
    }
public:
    int numTrees(int n) {
        mem = vector<vector<int>>(n+1, vector<int>(n+1, -1));
        return numTrees(0, n);
    }
};
```

## [95. 不同的二叉搜索树 II](https://leetcode.cn/problems/unique-binary-search-trees-ii/description/)

> 返回值返回所有可能的树的情况

```c++
class Solution {
    vector<TreeNode*> findAllBST(int l, int r) {
        if(l >= r) return { nullptr };
        vector<TreeNode*> trees;
        for(int i = l; i < r; i++) {
            vector<TreeNode*> leftTree = findAllBST(l, i);
            vector<TreeNode*> rightTree = findAllBST(i+1, r);
            for(TreeNode *left : leftTree) {
                for(TreeNode *right : rightTree) {
                    trees.push_back(new TreeNode(i, left, right));
                }
            }
        }
        return trees;
    }
public:
    vector<TreeNode*> generateTrees(int n) {
        return findAllBST(1, n + 1);
    }
};
```

## [97. 交错字符串](https://leetcode.cn/problems/interleaving-string/description/)

- dp
```c++
class Solution {
public:
    bool isInterleave(string s1, string s2, string s3) {
        int n1 = s1.length(), n2 = s2.length();
        if(s3.length() != n1 + n2) return false;
        vector<vector<bool>> dp(n1+1, vector<bool>(n2+1, false));
        dp[0][0] = true;
        for(int i = 1; i <= n1; i++) {
            dp[i][0] = dp[i-1][0] && s1[i-1] == s3[i-1];
        }
        for(int i = 1; i <= n2; i++) {
            dp[0][i] = dp[0][i-1] && s2[i-1] == s3[i-1];
        }
        for(int i = 1; i <= n1; i++) {
            for(int j = 1; j <= n2; j++) {
                dp[i][j] = dp[i][j] || (s1[i-1] == s3[i + j - 1] && dp[i-1][j]) || (s2[j-1] == s3[i + j - 1] && dp[i][j-1]);
            }
        }
        return dp[n1][n2];
    }
};
```

## [98. 验证二叉搜索树](https://leetcode.cn/problems/validate-binary-search-tree/description/)


```c++
class Solution {
    bool isValidBST(TreeNode* root, long long l, long long r) {
        if(!root) return true;
        if(root->val <= l || root->val >= r) return false;
        return isValidBST(root->left, l, root->val) && isValidBST(root->right, root->val, r);
    }
public:
    bool isValidBST(TreeNode* root) {
        return isValidBST(root, LLONG_MIN, LLONG_MAX);
    }
};
```

## [99. 恢复二叉搜索树](https://leetcode.cn/problems/recover-binary-search-tree/description/)

```c++
class Solution {
    vector<TreeNode*> arr;
    void midOrder(TreeNode *root) {
        if(!root) return;
        midOrder(root->left);
        arr.push_back(root);
        midOrder(root->right);
    }
public:
    void recoverTree(TreeNode* root) {
        midOrder(root);
        int n = arr.size();
        int x = 0;
        for(int i = 0; i < n - 1; i++) {
            if(arr[i]->val > arr[i+1]->val) {
                x = i;
                break;
            }
        }
        for(int i = n-1; i > 0; i--) {
            if(arr[i]->val < arr[i-1]->val) {
                swap(arr[i]->val, arr[x]->val);
                break;
            }
        }
    }
};
```

- `O(1)`空间

```c++
class Solution {
    TreeNode* prev = nullptr;
    TreeNode* node1 = nullptr;
    TreeNode* node2 = nullptr;
    void midOrder(TreeNode *root) {
        if(!root) return;
        midOrder(root->left);
        if(prev && root->val < prev->val) {
            if(node1 == nullptr && node2 == nullptr) {
                node1 = prev;
                node2 = root;
            } else {
                node2 = root;
                return;
            }
        }
        prev = root;
        midOrder(root->right);
    }
public:
    void recoverTree(TreeNode* root) {
        midOrder(root);
        swap(node1->val, node2->val);
    }
};
```


## [51. N 皇后](https://leetcode.cn/problems/n-queens/description/)

- 递归，用四个数组表示当前行列主对角线上是否有皇后
- 挑选四个方向都没有皇后的格子放置皇后

```c++
class Solution {
public:
    vector<vector<string>> solveNQueens(int n) {
        vector<vector<string>> res;
        vector<string> cur(n, string(n, '.'));
        vector<bool> col(n, false), row(n, false), main_diag((n << 1) - 1, false), sub_diag((n << 1) - 1, false);
        function<void(int)> dfs = [&](int i) {
            if(i == n) {
                res.push_back(cur);
                return;
            }
            for(int j = 0; j < n; j++) {
                if(!row[i] && !col[j] && !main_diag[i - j + n - 1] && !sub_diag[i + j]) {
                    cur[i][j] = 'Q';
                    row[i] = col[j] = main_diag[i - j + n - 1] = sub_diag[i + j] = true;
                    dfs(i+1);
                    row[i] = col[j] = main_diag[i - j + n - 1] = sub_diag[i + j] = false;
                    cur[i][j] = '.';
                }
            }
        };
        dfs(0);
        return res;
    }
};
```

## [52. N 皇后 II](https://leetcode.cn/problems/n-queens-ii/description/)


```c++
class Solution {
    int const static constexpr MAX_N = 10;
    int const static constexpr MAX_DIAG = (MAX_N << 1) - 1;
public:
    int totalNQueens(int n) {
        int res = 0;
        bool col[MAX_N] = {false}, row[MAX_N] = {false}, main_diag[MAX_DIAG] = {false}, sub_diag[MAX_DIAG] = {false};
        function<void(int)> dfs = [&](int i) {
            if(i == n) {
                res++; 
                return;
            }
            for(int j = 0; j < n; j++) {
                if(!row[i] && !col[j] && !main_diag[i - j + n - 1] && !sub_diag[i + j]) {
                    row[i] = col[j] = main_diag[i - j + n - 1] = sub_diag[i + j] = true;
                    dfs(i+1);
                    row[i] = col[j] = main_diag[i - j + n - 1] = sub_diag[i + j] = false;
                }
            }
        };
        dfs(0);
        return res;
    }
};
```

## [2580. 统计将重叠区间合并成组的方案数](https://leetcode.cn/problems/count-ways-to-group-overlapping-ranges/description/)

- 要求将区间分成两组，且相互重叠的区间在同一组
- 数一下按照是否重叠区分，一共能分成多少组
- 然后就是对这些组排列组合
- 对区间排序，若重叠则不断扩大当前分组范围，否则遇到新的不与之前重叠的区间

```c++
class Solution {
    const static int MOD = 1000000000 + 7;
    int fastPow2(int n) {
        long long base = 2;
        long long ans = 1;
        while(n) {
            if(n & 1) ans = (ans * base) % MOD;
            base = (base * base) % MOD;
            n >>= 1;
        }
        return ans;
    }
public:
    int countWays(vector<vector<int>>& ranges) {
        sort(ranges.begin(), ranges.end(), [](const vector<int>& x, const vector<int>& y) {
            if(x[0] != y[0]) return x[0] < y[0];
            return x[1] < y[1];
        });
        int rangesCnt = 0;
        pair<int, int> curRange = make_pair(ranges[0][0], ranges[0][1]);
        for(const vector<int>& v : ranges) {
            if(v[0] >= curRange.first && v[0] <= curRange.second) {
                curRange.second = max(v[1], curRange.second);
            } else if(v[1] >= curRange.first && v[1] <= curRange.second) {
                curRange.first = max(v[0], curRange.first);
            } else if(v[0] >= curRange.first && v[1] <= curRange.second) {
            } else if (v[0] <= curRange.first && v[1] >= curRange.second) {
                curRange.first = v[0];
                curRange.second = v[1];
            } else {
                rangesCnt++;
                curRange = make_pair(v[0], v[1]);
            }
        }
        return fastPow2(++rangesCnt);
    }
};
```

## [40. 组合总和 II](https://leetcode.cn/problems/combination-sum-ii/description/)
[39. 组合总和](https://leetcode.cn/problems/combination-sum/)是每个数不限制使用次数，数字不重复，这道题是数字可能重复但是每个数只能用一次

用相同的方法暴搜，但是要加上个数上限

```c++
class Solution {
public:
    int n;
    int target;
    vector<vector<int>> res;
    unordered_map<int, int> cnt;
    vector<vector<int>> combinationSum2(vector<int>& candidates, int target) {
        this->target = target;
        n = 0;
        for(int candidate : candidates) {
            cnt[candidate]++;
        }
        candidates = vector<int>();
        for(auto ite : cnt) {
            candidates.push_back(ite.first);
            n++;
        }
        vector<int> vec;
        search(0, 0, vec, candidates);
        return res;
    }
    void search(int index, int sum, vector<int> & vec, const vector<int>& candidates) {
        if(sum == target) {
            res.push_back(vec);
            return;
        }
        if(index >= n || sum > target) return;
        vec.push_back(candidates[index]);
        cnt[candidates[index]]--;
        if(cnt[candidates[index]] >= 0) search(index, sum+candidates[index], vec, candidates);
        cnt[candidates[index]]++;
        vec.pop_back();
        if(index + 1 < n) {
            search(index+1, sum, vec, candidates);
        }
    }
};
```

