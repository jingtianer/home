---
title: LeetCode-32
date: 2024-2-23 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---
## [1185. 一周中的第几天](https://leetcode.cn/problems/day-of-the-week/description/?envType=daily-question&envId=2023-12-30)

- `Tomohiko Sakamoto`算法
- 虽然是简单题也有很多知识点呢
- [解释](https://www.geeksforgeeks.org/tomohiko-sakamotos-algorithm-finding-day-week/)

```c++
class Solution {
public:
    string dayOfTheWeek(int day, int month, int year) {
        // array with leading number of days values
        static int t[] = { 0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4 };
        
        // if month is less than 3 reduce year by 1
        if (month < 3)
            year -= 1;
        
        return vector<string>{"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
        [((year + year / 4 - year / 100 + year / 400 + t[month - 1] + day) % 7)];
    }
};
```


## [2583. 二叉树中的第 K 大层和](https://leetcode.cn/problems/kth-largest-sum-in-a-binary-tree/description/)

```c++
class Solution {
public:
    long long kthLargestLevelSum(TreeNode* root, int k) {
        if(!root) return -1;
        priority_queue<long long> level_sum_q;
        queue<TreeNode *> q;
        q.push(root);
        while(!q.empty()) {
            int q_size = q.size();
            long long level_sum = 0;
            while(q_size--) {
                TreeNode *node =  q.front();
                q.pop();
                level_sum += node->val;
                if(node->left) q.push(node->left);
                if(node->right) q.push(node->right);
            }
            level_sum_q.push(level_sum);
        }
        while(--k && !level_sum_q.empty()) {
            level_sum_q.pop();
        }
        return !level_sum_q.empty() ? level_sum_q.top() : -1;
    }
};
```

- 用ranges获取第k大的数

```c++
class Solution {
public:
    long long kthLargestLevelSum(TreeNode* root, int k) {
        if(!root) return -1;
        vector<long long> level_sums;
        queue<TreeNode *> q;
        q.push(root);
        int level_cnt = 0;
        while(!q.empty()) {
            int q_size = q.size();
            long long level_sum = 0;
            while(q_size--) {
                TreeNode *node =  q.front();
                q.pop();
                level_sum += node->val;
                if(node->left) q.push(node->left);
                if(node->right) q.push(node->right);
            }
            level_sums.push_back(level_sum);
            level_cnt++;
        }
        if(level_cnt < k) return -1;
        ranges::nth_element(level_sums, level_sums.end() - k);
        return level_sums[level_sums.size() - k];
    }
};
```

## [LCP 30. 魔塔游戏](https://leetcode.cn/problems/p0NxJO/description/?envType=daily-question&envId=2024-02-06)

- 当遇到HP不够的时候，考虑贪心，依次将已经遇到过的房间中最小的房间向后移动
- 移动后放入delay中，最后加上delay看HP够不够就好了

```c++
class Solution {
public:
    int magicTower(vector<int>& nums) {
        int n = nums.size();
        long long HP = 1;
        int swapCnt = 0;
        auto cmp = [&nums](int i, int j){ return nums[i] > nums[j]; };
        long long delay = 0;
        priority_queue<int, vector<int>, decltype(cmp)> q(cmp);
        for(int i = 0; i < n; i++) {
            int room = nums[i];
            if(room < 0)q.push(i);
            int chance = n - i  - 1;
            while(HP + room <= 0 && !q.empty() && chance--) {
                int minIndex = q.top();
                q.pop();
                int room_min = nums[minIndex];
                HP -= nums[minIndex];
                delay += nums[minIndex];
                swapCnt++;
            }
            HP += room;
            if(HP <= 0) break;
        }
        HP += delay;
        return HP > 0 ? swapCnt : -1;
    }
};
```

## 1696. 跳跃游戏 VI
- 看提示就会了
```c++
class Solution {
public:
    int maxResult(vector<int>& nums, int k) {
        int n = nums.size();
        vector<int> dp(n, INT_MIN);
        auto cmp = [&dp](int i, int j) {return dp[i] < dp[j];};
        priority_queue<int, vector<int>, decltype(cmp)> q(cmp);
        dp[0] = nums[0];
        q.push(0);
        for(int i = 1; i < n; i++) {
            while(q.top() < i - k) q.pop();
            int maxDp = dp[q.top()];
            dp[i] = max(dp[i], maxDp + nums[i]);
            q.push(i);
        }
        return dp.back();
    }
};

```
## [292. Nim 游戏](https://leetcode.cn/problems/nim-game/description/?envType=daily-question&envId=2024-02-04)

- 用dp[i]表示i个石头是否存在必胜策略，已知i = 1, 2, 3时，一定有必胜策略
- 那么对于4，无论我拿多少，对手都有必胜策略，那么我必输
- 对于5，6，7，我分别拿1，2，3就会得到4，对手陷入必输，那么我必胜
- 也就是前三个数全true，我就是false，前三个数有false，我就是true
- 可以证明，4的倍数一定输
  - 连续三个true后必跟一个false
  - 每个false后面一定有3个true

```c++
class Solution {
public:
    bool canWinNim(int n) {
        return n % 4 != 0; // 下面是推理过程
        vector<bool> dp(n+1);
        dp[0] = dp[1] = dp[2] = dp[3] = true;
        bool last1 = true, last2 = true, last3 = true;
        for(int i = 4; i <= n; i++) {
            dp[i] = !(last1 && last2 && last3);
            last1 = last2;
            last2 = last3;
            last3 = dp[i];
            if(!dp[i]) cout << i << ",";
        }
        return dp[n];
    }
};
```

## [2476. 二叉搜索树最近节点查询](https://leetcode.cn/problems/closest-nodes-queries-in-a-binary-search-tree/description/?envType=daily-question&envId=2024-02-24)

### 中序+二分

```c++
class Solution {
    void inorder(TreeNode *root, vector<int>& ans) {
        if(!root) return;
        inorder(root->left, ans);
        ans.push_back(root->val);
        inorder(root->right, ans);
    }
public:
    vector<vector<int>> closestNodes(TreeNode* root, vector<int>& queries) {
        vector<int> v;
        vector<vector<int>> ans;
        auto miniCmp = [](int x, int y) { return x >= y;};
        auto maxiCmp = [](int x, int y) { return x <= y;};
        inorder(root, v);
        for(int query : queries) {
            auto mini = upper_bound(v.rbegin(), v.rend(), query, miniCmp);
            auto maxi = upper_bound(v.begin(), v.end(), query, maxiCmp);
            ans.push_back({mini == v.rend() ? -1 : *mini, maxi == v.end() ? -1 : *maxi});
        }
        return ans;
    }
};
```

### [235. 二叉搜索树的最近公共祖先](https://leetcode.cn/problems/lowest-common-ancestor-of-a-binary-search-tree/description/?envType=daily-question&envId=2024-02-25)

- 这道题与[236. 二叉树的最近公共祖先](https://jingtianer.github.io/home/2023/12/25/LeetCode/LeetCode-%E5%88%B7%E9%A2%98%E6%80%BB%E7%BB%9331/#236-%E4%BA%8C%E5%8F%89%E6%A0%91%E7%9A%84%E6%9C%80%E8%BF%91%E5%85%AC%E5%85%B1%E7%A5%96%E5%85%88)不同，这道题是在二叉搜索树上寻找
- 对于根节点，如果两个数分别大于等于和小于等于这个节点，说明当前根节点就是公共祖先
- 如果都大于或小于当前根节点，说明要向左子树或右子树移动，继续寻找
```c++
class Solution {
    TreeNode* _lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        if(root->val >= p->val && root->val <= q->val) return root;
        else if(root->val > p->val) {
            return lowestCommonAncestor(root->left, p, q);
        } else {
            return lowestCommonAncestor(root->right, p, q);
        }
    }
public:
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) { // p q一定在root中，root一定不空
        if(p->val > q->val) swap(p, q); //保证p < q;
        return _lowestCommonAncestor(root, p, q);
    }
};
```

## [938. 二叉搜索树的范围和](https://leetcode.cn/problems/range-sum-of-bst/description/)

- 如果当前节点大于high，则不考虑右子树和当前节点，直接转移到左子树，小于low同理
- 如果当前节点在high和low之间，则返回当前节点值加上左右两棵子树的和

```c++
class Solution {
public:
    int rangeSumBST(TreeNode* root, int low, int high) {
        if(!root) return 0;
        if(root->val > high) {
            return rangeSumBST(root->left, low, high);
        } else if(root->val < low) {
            return rangeSumBST(root->right, low, high);
        } else {
            return root->val + rangeSumBST(root->left, low, high) + rangeSumBST(root->right, low, high);
        }
    }
};
```

## [2867. 统计树中的合法路径数目](https://leetcode.cn/problems/count-valid-paths-in-a-tree/description/)

### 思路

- 首先题目说是树，所以要考虑最广泛的n叉树的情况
- 涉及到素数，所以可以先素数筛把需要用到的素数缓存起来
- 最笨的方法是，依次从所有素数出发，dfs直到遇到下一个素数或者遇到没有未访问节点位置，统计总共的路线数
  - 一个素数的所有孩子可以看成一个子树，到达每个节点的路径数就是节点数
  - 总路线数就是
    - N个子树按照上面的要求dfs时所遇到的节点数之和($\sum_{i=1}^N(A_i)$)
    - 考虑到dfs过程中遇到的都是非素数，那么任意两个子树之间的任意两点之间的路径也是题目所求路径，总数为N个子树节点数两两相乘再相加($\sum_{i=1}^N\sum_{j=i+1}^N(A_i \times A_j)$)
- 为了减少重复的统计，使用并查集，将素数节点去除得到X个子树，计算X个子树的节点个数
- 根据公式$(\sum_{i=1}^N(A_i))^2 - \sum_{i=1}^N(A_i^2) = 2 \times \sum_{i=1}^N\sum_{j=i+1}^N(A_i \times A_j)$，可以将二重循环简化为一重循环

### 代码

```c++
class Solution {
    int find(int x, vector<int>& arr) {
        return arr[x] != x ? (arr[x] = find(arr[x], arr)) : x;
    }
    void Union(int x, int y, vector<int>& arr) {
        arr[find(x, arr)] = find(y, arr);
    }
    unordered_set<int> primeSet{2};
    bool is_prime(int val) {
        return primeSet.count(val) != 0;
    }
    long long ans = 0;
public:
    long long countPaths(int n, vector<vector<int>>& edges) {
        if(n <= 1) return 0;
        for(int i = 3; i <= n; i+=2) {
            bool flag = true;
            for(int j = 3; j*j<=i; j+=2) {
                if(i % j == 0) {
                    flag = false;
                    break;
                }
            }
            if(flag) {
                primeSet.insert(i);
            }
        }
        vector<int> disjointSet(n+1), cnt(n+1);
        iota(disjointSet.begin(), disjointSet.end(), 0);
        vector<vector<int>> g(n+1);
        for(auto& edge:edges) {
            bool is_prime0 = is_prime(edge[0]), is_prime1 = is_prime(edge[1]);
            if(!is_prime0 && !is_prime1) { // 两个节点都不是素数，合并到同一个集合
                Union(edge[0], edge[1], disjointSet);
            }
            if(is_prime0 ^ is_prime1) { // 两个节点中一个素数，一个非素数，记录非素数子树
                g[edge[0]].push_back(edge[1]);
                g[edge[1]].push_back(edge[0]);
            }
        }
        for(int i = 1; i <= n; i++) {
            cnt[find(i, disjointSet)]++;
        }
        for(auto ite = primeSet.begin(); ite != primeSet.end(); ite++) {
            long long cntSum = 0, cntSquareSum = 0;
            for(int child : g[*ite]) {
                cntSum += (long long)cnt[disjointSet[child]];
                cntSquareSum += (long long)cnt[disjointSet[child]] * cnt[disjointSet[child]]; // 防止溢出
            }
            ans += (cntSum * cntSum - cntSquareSum) / 2 + cntSum;
        }
        return ans;
    }
};
```

## [2673. 使二叉树所有路径值相等的最小代价](https://leetcode.cn/problems/make-costs-of-paths-equal-in-a-binary-tree/description/)

### 思路
- 计算每个节点从根到当前节点的路径和
- 计算每个节点的子路径的最大值
- 对每个节点，计算两个子节点的子路径最大值之差，给较小的节点增加这个差值
### 代码
```c++
class Solution {
    int ans = 0;
    void solve(int n, int node, int extra, vector<int>& childMax) {
        int parentMax = childMax[(node+1)/2-1];
        ans += parentMax - childMax[node];
        extra += parentMax - childMax[node];
        if(2*(node+1)-1 < n) solve(n, 2*(node+1)-1, extra, childMax);
        if(2*(node+1) < n) solve(n, 2*(node+1), extra, childMax);
    }
public:
    int minIncrements(int n, vector<int>& cost) {
        vector<int> pathSum(n), childMax(n);
        pathSum[0] = cost[0];
        for(int i = 1; i < n; i++) {
            pathSum[i] = cost[i] + pathSum[(i+1)/2-1];
        }
        for(int i = n-1; i >= n/2; i--) {
            childMax[i] = pathSum[i]; 
        }
        for(int i = n/2 - 1; i >= 0; i--) {
            childMax[i] = max(
                (i+1)*2-1 < n ? childMax[(i+1)*2-1] : 0, 
                (i+1)*2 < n ? childMax[(i+1)*2] : 0); 
        }
        solve(n, 1, 0, childMax);
        solve(n, 2, 0, childMax);
        return ans;
    }
};
```

- 去掉不必要的判断

```c++
inline int leftChildOf(int node) { return ((node + 1) << 1) - 1; }
inline int rightChildOf(int node) { return ((node + 1) << 1); }
inline int parentOf(int node) { return ((node + 1) >> 1) - 1; }
class Solution {
    int solve(int n, int node, vector<int>& childMax) {
        int ans = childMax[parentOf(node)] - childMax[node];
        if(leftChildOf(node) < n /*&& rightChildOf(node) < n*/) {
            ans += solve(n, leftChildOf(node), childMax) + solve(n, rightChildOf(node), childMax);
        }
        return ans;
    }
public:
    int minIncrements(int n, vector<int>& cost) {
        vector<int> pathSum(n), childMax(n);
        pathSum[0] = cost[0];
        for(int i = 1; i < n; i++) {
            pathSum[i] = cost[i] + pathSum[parentOf(i)];
        }
        for(int i = n-1; i >= n/2; i--) {
            childMax[i] = pathSum[i]; 
        }
        for(int i = n/2 - 1; i >= 0; i--) {
            childMax[i] = max(childMax[leftChildOf(i)], childMax[rightChildOf(i)]); 
        }
        return solve(n, 1, childMax) + solve(n, 2, childMax);
    }
};
```

### 一行流

```c++
inline int leftChildOf(int node) { return ((node + 1) << 1) - 1; } inline int rightChildOf(int node) { return ((node + 1) << 1); } inline int parentOf(int node) { return ((node + 1) >> 1) - 1; } class Solution { int solve(int n, int node, vector<int>& childMax) { return childMax[parentOf(node)] - childMax[node] + (leftChildOf(node) < n ? solve(n, leftChildOf(node), childMax) + solve(n, rightChildOf(node), childMax) : 0);} public: int minIncrements(int n, vector<int>& cost) { vector<int> pathSum(n), childMax(n); pathSum[0] = cost[0]; for(int i = 1; i < n; i++) pathSum[i] = cost[i] + pathSum[parentOf(i)]; for(int i = n-1; i >= n/2; i--) childMax[i] = pathSum[i]; for(int i = n/2 - 1; i >= 0; i--) childMax[i] = max(childMax[leftChildOf(i)], childMax[rightChildOf(i)]); return solve(n, 1, childMax) + solve(n, 2, childMax); }};
```

## [2487. 从链表中移除节点](https://leetcode.cn/problems/remove-nodes-from-linked-list/description/?envType=daily-question&envId=2024-01-03)

### 单调栈

```c++
class Solution {
public:
    ListNode* removeNodes(ListNode* head) {
        ListNode dummy, *move = head;
        stack<ListNode*> monoStack;
        monoStack.push(&dummy);
        while(move) {
            while(!monoStack.empty() && monoStack.top()->val < move->val) {
                monoStack.pop();
            }
            monoStack.push(move);
            move = move->next;
        }
        while(!monoStack.empty()) {
            ListNode *node = monoStack.top();
            monoStack.pop();
            node->next = dummy.next;
            dummy.next = node;
        }
        return dummy.next;
    }
};
```

### 不用stack
```c++
class Solution {
public:
    ListNode* removeNodes(ListNode* head) {
        ListNode dummy, *move = head;
        int len = 0;
        while(move) {
            while(dummy.next != nullptr && dummy.next->val < move->val) {
                dummy.next = dummy.next->next;
                len--;
            }
            ListNode *tmp = move->next;
            move->next = dummy.next;
            dummy.next = move;
            move = tmp;
            len++;
        }
        move = dummy.next;
        dummy.next = nullptr;
        while(len--) {
            ListNode *node = move->next;
            move->next = dummy.next;
            dummy.next = move;
            move = node;
        }
        return dummy.next;
    }
};
```

## [2397. 被列覆盖的最多行数](https://leetcode.cn/problems/maximum-rows-covered-by-columns/description/?envType=daily-question&envId=2024-01-04)

### 状态压缩
```c++
class Solution {
    int m, n, ans = 0;
    vector<int> row;
    void checker(int x) {
        int cnt = 0;
        for(int i = 0; i < m; i++) {
            if((row[i] & ~x) == 0) cnt++;
        }
        ans = max(ans, cnt);
    }
    int toInt(vector<int>& vec, int len) {
        int x = 0;
        for(int i = 0; i < len; i++) {
            x <<= 1;
            x += vec[i];
        }
        return x;
    }
public:
    int maximumRows(vector<vector<int>>& matrix, int numSelect) {
        m = matrix.size(), n = matrix[0].size();
        vector<int> vec(n);
        fill(vec.rbegin(), vec.rbegin() + numSelect, 1);
        for(int i = 0; i < m; i++) {
            row.push_back(toInt(matrix[i], n));
        }
        for(int x = 0; x < (1 << n); x++) {
            if (__builtin_popcount(x) != numSelect) {
                continue;
            }
            checker(x);
        }
        return ans;
    }
};
```

### 全排列

```c++
class Solution {
    int toInt(vector<int>& vec, int len) {
        int x = 0;
        for(int i = 0; i < len; i++) {
            x <<= 1;
            x += vec[i];
        }
        return x;
    }
    int setZero(int x, int i) {
        return x & (~(1 << i));
    }
    int setOne(int x, int i) {
        return x | (1 << i);
    }
    int swap(int x, int i, int j) {
        int a = (x >> i) & 1;
        int b = (x >> j) & 1;
        x = a ? setOne(x, j) : setZero(x, j);
        x = b ? setOne(x, i) : setZero(x, i);
        return x;
    }
    bool swapOK(int x, int i, int n) {
        int lastBit = (x & (1 << (n-1))) >> (n-1);
        for(int j = i; j < n-1; j++) {
            if(((x & (1 << j)) >> j) == lastBit) return false;
        }
        return true;
    }
    void permutation(int x, int j, int n, function<void(int)> checker) {
        if(j == n-1) {
            checker(x);
            return;
        }
        for(int i = j; i < n; i++) {
            if(!swapOK(x, j, i+1)) continue;
            x = swap(x, i, j);
            permutation(x, j + 1, n, checker);
            x = swap(x, i, j);
        }
    }
public:
    int maximumRows(vector<vector<int>>& matrix, int numSelect) {
        int m = matrix.size(), n = matrix[0].size(), ans = 0;
        vector<int> row(m), vec(n);
        fill(vec.rbegin(), vec.rbegin() + numSelect, 1);
        for(int i = 0; i < m; i++) {
            row[i] = toInt(matrix[i], n);
        }
        auto checker = [&row, &m, &ans](int x) {
            int cnt = 0;
            for(int i = 0; i < m; i++) {
                if((row[i] & ~x) == 0) cnt++;
            }
            ans = max(ans, cnt);
        };
        permutation(toInt(vec, n), 0, n, checker);
        return ans;
    }
};
```

## [2581. 统计可能的树根数目](https://leetcode.cn/problems/count-number-of-possible-root-nodes/description/)
- 看题解的思路
- 树形dp

```c++
class Solution {
    vector<vector<int>> g;
    vector<unordered_set<int>> guessesGraph;
    vector<bool> visited;
    int k, ans = 0;
    void dfs(int root, int cnt) {
        if(cnt >= k) ans++;
        visited[root] = true;
        for(int child : g[root]) {
            if(visited[child]) continue;
            int newCnt = cnt;
            if(guessesGraph[root].count(child)) {
                newCnt--;
            }
            if(guessesGraph[child].count(root)) {
                newCnt++;
            }
            dfs(child, newCnt);
        }
    }
public:
    int rootCount(vector<vector<int>>& edges, vector<vector<int>>& guesses, int k) {
        int n = edges.size() + 1;
        this->k = k;
        g = vector<vector<int>>(n);
        guessesGraph = vector<unordered_set<int>>(n);
        for(auto& edge : edges) {
            g[edge[0]].push_back(edge[1]);
            g[edge[1]].push_back(edge[0]);
        }
        visited = vector<bool>(n, false);
        vector<int> parent(n, -1);
        queue<int> q;
        q.push(0);
        while(!q.empty()) {
            int node = q.front();
            q.pop();
            visited[node] = true;
            for(int child : g[node]) {
                if(visited[child]) continue;
                parent[child] = node;
                q.push(child);
            }
        }
        int cnt = 0;
        for(auto& guesse:guesses) {
            if(guesse[0] == parent[guesse[1]]) cnt++;
            guessesGraph[guesse[0]].insert(guesse[1]);
        }
        fill(visited.begin(), visited.end(), false);
        dfs(0, cnt);
        return ans;
    }
};
```

## [1944. 队列中可以看到的人数](https://leetcode.cn/problems/number-of-visible-people-in-a-queue/description/?envType=daily-question&envId=2024-01-05)

- 还好，就是单调栈的简单应用
```c++
class Solution {
public:
    vector<int> canSeePersonsCount(vector<int>& heights) {
        int n = heights.size();
        vector<int> ans(n);
        stack<int> monoStack;
        for(int i = 0; i < n; i++) {
            while(!monoStack.empty() && heights[monoStack.top()] < heights[i]) {
                int top = monoStack.top();
                monoStack.pop();
                ans[top]++;
            }
            if(!monoStack.empty()) {
                ans[monoStack.top()]++;
            }
            monoStack.push(i);
        }
        return ans;
    }
};
```

## [2807. 在链表中插入最大公约数](https://leetcode.cn/problems/insert-greatest-common-divisors-in-linked-list/description/?envType=daily-question&envId=2024-01-06)

```c++
class Solution {
public:
    ListNode* insertGreatestCommonDivisors(ListNode* head) {
        ListNode* move = head;
        while(move->next) {
            move->next = new ListNode(gcd(move->val, move->next->val), move->next);
            move = move->next->next;
        }
        return head;
    }
};
```

## [383. 赎金信](https://leetcode.cn/problems/ransom-note/description/?envType=daily-question&envId=2024-01-07)

```c++
class Solution {
public:
    bool canConstruct(string ransomNote, string magazine) {
        int cnt[26] = {0};
        for(char c : magazine) {
            cnt[c - 'a']++;
        }
        for(char c : ransomNote) {
            if(cnt[c - 'a']-- == 0) return false;
        }
        return true;
    }
};
```

## [447. 回旋镖的数量](https://leetcode.cn/problems/number-of-boomerangs/description/?envType=daily-question&envId=2024-01-08)

```c++
class Solution {
public:
    int numberOfBoomerangs(vector<vector<int>>& points) {
        int n = points.size();
        vector<unordered_map<int, int>> data(n);
        for(int i = 0; i < n; i++) {
            for(int j = i + 1; j < n; j++) {
                int distance = 
                    (points[i][0] - points[j][0])*(points[i][0] - points[j][0])
                    + 
                    (points[i][1] - points[j][1]) * (points[i][1] - points[j][1]);
                data[i][distance]++;
                data[j][distance]++;
            }
        }
        int ans = 0;
        for(int i = 0; i < n; i++) {
            for(auto ite = data[i].begin(); ite != data[i].end(); ite++) {
                ans += ite->second * (ite->second - 1);
            }
        }
        return ans;
    }
};
```

## [2707. 字符串中的额外字符](https://leetcode.cn/problems/extra-characters-in-a-string/description/)
- 很常规的dp
```c++
class Solution {
public:
    int minExtraChar(string s, vector<string>& dictionary) {
        int len = s.length();
        unordered_set<string> dict;
        for(auto& d : dictionary) {
            dict.insert(d);
        }
        vector<int> dp(len + 1, INT_MAX);
        dp[0] = 0;
        for(int i = 1; i <= len; i++) {
            for(int j = 0; j < i; j++) {
                dp[i] = min(dp[j] + (dict.count(s.substr(j, i - j)) ? 0 : i-j), dp[i]);
            }
        }
        return dp[len];
    }
};
```

## [2696. 删除子串后的字符串最小长度](https://leetcode.cn/problems/minimum-string-length-after-removing-substrings/description/)

- 括号匹配的思路

```c++
class Solution {
public:
    int minLength(string s) {
        int length = s.length();
        stack<char> stk;
        for(int i = 0; i < length; i++) {
            if(!stk.empty()) {
                char top = stk.top();
                if((top == 'A' && s[i] == 'B') || (top == 'C' && s[i] == 'D')) {
                    stk.pop();
                    continue;
                }
            }
            stk.push(s[i]);
        }
        return stk.size();
    }
};
```

## [2645. 构造有效字符串的最少插入数](https://leetcode.cn/problems/minimum-additions-to-make-valid-string/description/)

```c++
class Solution {
public:
    int addMinimum(string word) {
        int len = word.length();
        int ans = 0;
        for(int i = 0; i < len; i++) {
            switch(word[i]) {
                case 'a' : {
                    if(!(i + 1 < len && word[i+1] == 'b')) {
                        ans++;
                    } else {
                        i++;
                    }
                    if(!(i + 1 < len && word[i+1] == 'c')) {
                        ans++;
                    } else {
                        i++;
                    }
                }
                break;
                case 'b' : {
                    ans++;
                    if(!(i + 1 < len && word[i+1] == 'c')) {
                        ans++;
                    } else {
                        i++;
                    }
                }
                break;
                case 'c' : {
                    ans += 2;
                }
                break;
            }
        }
        return ans;
    }
};
```

## [2085. 统计出现过一次的公共字符串](https://leetcode.cn/problems/count-common-words-with-one-occurrence/description/)

```c++
class Solution {
public:
    int countWords(vector<string>& words1, vector<string>& words2) {
        unordered_map<string, int> cnt1, cnt2;
        int ans = 0;
        for(auto& s : words1) {
            cnt1[s]++;
        }
        for(auto& s : words2) {
            cnt2[s]++;
        }
        for(auto ite = cnt1.begin(); ite != cnt1.end(); ite++) {
            if(ite->second == 1 && cnt2[ite->first] == 1) ans++;
        }
        return ans;
    }
};
```

## [2182. 构造限制重复的字符串](https://leetcode.cn/problems/construct-string-with-repeat-limit/description/?envType=daily-question&envId=2024-01-13)

```c++
class Solution {
public:
    string repeatLimitedString(string s, int repeatLimit) {
        int cnt[26] = {0};
        string ans;
        for(char c : s) {
            cnt[c - 'a']++;
        }
        char cur = 'z' - 'a', next;
        while(cur >= 0) {
            while(cur >= 0 && cnt[cur] == 0) cur--;
            if(cur < 0) break;
            next = cur - 1;
            while(next >= 0 && cnt[next] == 0) next--;
            int cost = min(cnt[cur], repeatLimit);
            cnt[cur] -= cost;
            ans += string(cost, cur + 'a');
            if(cnt[cur] > 0) {
                if(next < 0) break;
                ans += next + 'a';
                cnt[next]--;
            }
        }
        return ans;
    }
};
```

## [83. 删除排序链表中的重复元素](https://leetcode.cn/problems/remove-duplicates-from-sorted-list/description/?envType=daily-question&envId=2024-01-14)

```c++
class Solution {
public:
    ListNode* deleteDuplicates(ListNode* head) {
        if(!head) return nullptr;
        ListNode *move = head;
        while(move->next) {
            if(move->val == move->next->val) {
                move->next = move->next->next;
            } else {
                move = move->next;
            }
        }
        return head;
    }
};
```

## [82. 删除排序链表中的重复元素 II](https://leetcode.cn/problems/remove-duplicates-from-sorted-list-ii/description/?envType=daily-question&envId=2024-01-15)

```c++
class Solution {
public:
    ListNode* deleteDuplicates(ListNode* head) {
        if(!head) return nullptr;
        ListNode dummy(0, head), *move = &dummy;
        while(move->next && move->next->next) {
            if(move->next->val == move->next->next->val) {
                ListNode *cur = move->next;
                while(cur->next && cur->val == cur->next->val) {
                    cur = cur->next;
                }
                cur = cur->next;
                move->next = cur;
            } else {
                move = move->next;
            }
        }
        return dummy.next;
    }
};
```

## [2368. 受限条件下可到达节点的数目](https://leetcode.cn/problems/reachable-nodes-with-restrictions/description/?envType=daily-question&envId=2024-03-02)

### dfs
- 我的评价是，平平无奇

```c++
class Solution {
public:
    int reachableNodes(int n, vector<vector<int>>& edges, vector<int>& restricted) {
        vector<vector<int>> g(n);
        vector<bool> restricted_map(n, false);
        int ans = 0;
        for(int i = 0; i < n-1; i++) {
            g[edges[i][0]].push_back(edges[i][1]);
            g[edges[i][1]].push_back(edges[i][0]);
        }
        for(int rest_node : restricted) {
            restricted_map[rest_node] = true;
        }
        function<void(int,int)> visitTree = [&](int grandpa, int father) {
            ans++;
            for(int child : g[father]) {
                if(restricted_map[child] || child == grandpa) continue;
                visitTree(father, child);
            }
        };
        visitTree(-1, 0);
        return ans;
    }
};
```
### 非递归dfs
```c++
class Solution {
public:
    int reachableNodes(int n, vector<vector<int>>& edges, vector<int>& restricted) {
        vector<vector<int>> g(n);
        vector<bool> restricted_map(n, false);
        int ans = 0;
        for(int i = 0; i < n-1; i++) {
            g[edges[i][0]].push_back(edges[i][1]);
            g[edges[i][1]].push_back(edges[i][0]);
        }
        for(int rest_node : restricted) {
            restricted_map[rest_node] = true;
        }
        queue<pair<int, int>> q;
        q.emplace(-1, 0);
        while(!q.empty()) {
            auto [parent, node] = q.front();
            q.pop();
            ans++;
            for(int child : g[node]) {
                if(restricted_map[child] || child == parent)
                    continue;
                q.emplace(node, child);
            }
        }
        return ans;
    }
};
```

### 并查集

```c++
class Solution {
    class UFDSet {
        vector<int> vec;
    public:
        UFDSet(int n) : vec(n) {
            iota(vec.begin(), vec.end(), 0);
        }
        int find(int x) {
            return vec[x] == x ? x : (vec[x] = find(vec[x]));
        }
        void Union(int x, int y) {
            vec[find(x)] = find(y);
        }

    };
public:
    int reachableNodes(int n, vector<vector<int>>& edges, vector<int>& restricted) {
        int ans = 0;
        UFDSet ufdSet(n);
        vector<bool> isRestricted(n, false);
        for(int restricted_node : restricted) {
            isRestricted[restricted_node] = true;
        }
        for(int i = 0; i < n-1; i++) {
            if(!isRestricted[edges[i][0]] && !isRestricted[edges[i][1]])
                ufdSet.Union(edges[i][0], edges[i][1]);
        }
        for(int i = 0; i < n; i++) {
            if(ufdSet.find(0) == ufdSet.find(i)) {
                ans++;
            }
        }
        return ans;
    }
};
```

## [238. 除自身以外数组的乘积](https://leetcode.cn/problems/product-of-array-except-self/description/)

- 虽然但是，空间`O(1)`不是应该原地修改吗？

```c++
class Solution {
public:
    vector<int> productExceptSelf(vector<int>& nums) {
        int n = nums.size();
        vector<int> res(n, 1);
        for(int i = n-2; i >= 0; i--) {
            res[i] = nums[i+1] * res[i+1];
        }
        int left = 1;
        for(int i = 0; i < n; i++) {
            res[i] *= left;
            left *= nums[i];
        }
        return res;
    }
};
```

## [225. 用队列实现栈](https://leetcode.cn/problems/implement-stack-using-queues/description/?envType=daily-question&envId=2024-03-03)

```c++
class MyStack {
    queue<int> q;
    int len;
public:
    MyStack() : len(0) {

    }
    
    void push(int x) {
        q.push(x);
        for(int i = 0; i < len; i++) {
            q.push(q.front());
            q.pop();
        }
        len++;
    }
    
    int pop() {
        int ret = q.front();
        q.pop();
        len--;
        return ret;
    }
    
    int top() {
        return q.front();
    }
    
    bool empty() {
        return len == 0;
    }
};
```
