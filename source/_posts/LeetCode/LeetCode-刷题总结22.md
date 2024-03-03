---
title: LeetCode-22
date: 2023-2-20 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## [2347. 最好的扑克手牌](https://leetcode.cn/problems/best-poker-hand/)
```c++
class Solution {
public:
    string bestHand(vector<int>& ranks, vector<char>& suits) {
        vector<int> rank_count(13, 0), suits_count(4, 0);
        for(int i = 0; i < 5; i++) {
            rank_count[ranks[i]-1]++;
            suits_count[suits[i] - 'a']++;
        }
        int count = 0;
        for(int i = 0; i < 4; i++) {
            count = max(count, suits_count[i]);
        }
        if(count == 5) return "Flush";
        count = 0;
        for(int i = 0; i < 13; i++) {
            count = max(count, rank_count[i]);
        }
        if(count >= 3) {
            return "Three of a Kind";
        } else if (count == 2) {
            return "Pair";
        }
        return "High Card";
    }
};
```

## [1604. 警告一小时内使用相同员工卡大于等于三次的人](https://leetcode.cn/problems/alert-using-same-key-card-three-or-more-times-in-a-one-hour-period/)

```c++
class Solution {
public:
    vector<string> alertNames(vector<string>& keyName, vector<string>& keyTime) {
        map<string, vector<int>> hour_count;
        int len = keyName.size();
        for(int i = 0; i < len; i++) {
            int h = (keyTime[i][0]-'0')*10 + keyTime[i][1] - '0', m = (keyTime[i][3] - '0') * 10 + keyTime[i][4] - '0';
            hour_count[keyName[i]].push_back(h*60+m);
        }
        vector<string> warning_list;
        for(auto ite = hour_count.begin(); ite != hour_count.end(); ite++) {
            bool warn = false;
            sort(ite->second.begin(), ite->second.end());
            int len = ite->second.size();
            for(int i = 0; i < len-2; i++) {
                if(ite->second[i+2] - ite->second[i] <= 60) {
                    warn = true;
                    break;
                }
            }
            if(warn) {
                warning_list.push_back(ite->first);
            }
        }
        return warning_list;
    }
};
```

```c++
class Solution {
public:
    vector<string> alertNames(vector<string>& keyName, vector<string>& keyTime) {
        map<string, priority_queue<int>> hour_count;
        int len = keyName.size();
        for(int i = 0; i < len; i++) {
            int h = (keyTime[i][0]-'0')*10 + keyTime[i][1] - '0', m = (keyTime[i][3] - '0') * 10 + keyTime[i][4] - '0';
            hour_count[keyName[i]].push(h*60+m);
        }
        vector<string> warning_list;
        for(auto ite = hour_count.begin(); ite != hour_count.end(); ite++) {
            int len = ite->second.size();
            if(len <= 2) continue;
            int a, b, c;
            a = ite->second.top();
            ite->second.pop();
            b = ite->second.top();
            ite->second.pop();
            c = ite->second.top();
            ite->second.pop();
            bool warn = a - c <= 60;
            while(!warn && !ite->second.empty()) {
                a = b;
                b = c;
                c = ite->second.top();
                ite->second.pop();
                warn = a - c <= 60;
            }
            if(warn) {
                warning_list.push_back(ite->first);
            }
        }
        return warning_list;
    }
};
```

## [2331. 计算布尔二叉树的值](https://leetcode.cn/problems/evaluate-boolean-binary-tree/)
```c++
class Solution {
public:
    bool evaluateTree(TreeNode* root) {
        if(root->val <= 1) return root->val == 1 ? true : false;
        bool left = evaluateTree(root->left);
        bool right = evaluateTree(root->right);
        return root->val == 2 ? left||right : left&&right;
    }
};
```

## [1798. 你能构造出连续值的最大数目](https://leetcode.cn/problems/maximum-number-of-consecutive-values-you-can-make/)

```c++
class Solution {
public:
    int getMaximumConsecutive(vector<int>& coins) {
        int res = 1;
        sort(coins.begin(), coins.end());
        for (auto& i : coins) {
            if (i > res) {
                break;
            }
            res += i;
        }
        return res;
    }
};
```

> 直接抄的答案，贪心，代码的意思就是排序，从小到大加起来
> 没注意到题目条件要求是从0开始的，这一点很重要
> 若最大只能到1，则数组为 [1]
> 若最大只能到2，则数组为 [1 1] (不能是[2]，因为这样没有无法组出1)
> 若最大只能到3，则数组为 [1 1 1], [1 2]
> 若最大只能到4，则数组为 [1 1 1 1], [1 1 2]
> 若最大只能到5，则数组为 [1 1 1 1 1], [1 1 1 2], [1 1 3]
>
> 观察上面列表可知，若最大只能到5，则是最大到4在多额外的1，或者最大到2且额外的一个3，这里就能看到令res初始为1，将数组排序后，相加，直到coins[i] > res为止

## [1145. 二叉树着色游戏](https://leetcode.cn/problems/binary-tree-coloring-game/)

> 这道题的提议是，第一步red先手，blue后手选择二叉树中的一个节点
> 选择后的每一步，两个玩家只能选择当前所选所有节点的未涂色的邻接节点
> “我”作为后手的二号节点，如何选择我的第一个节点，让我能涂色的节点大于先手的red
> 为了利益最大化，只有三种选择，选择`x`的父节点，左孩子或右孩子
> 选择父节点，则x及x所有子节点都会被red涂色，自己只能涂色n-red个
> 选择左孩子，自己只能涂色x的左孩子以及左孩子的所有子代节点
> 选择右孩子，与左孩子同理
> 以上三种情况，分别计算red和blue，只要有一种情况可以使得`red < blue`，则blue一定可以胜利，否则一定不能胜利

```c++
class Solution {
public:
    bool btreeGameWinningMove(TreeNode* root, int root_sum, int x) {
        TreeNode* find = search(root, x);
        int red = sum(find);
        if(red < root_sum - red) return true;
        int blue = sum(find->left);
        if(root_sum - blue < blue) return true;
        blue = sum(find->right);
        if(root_sum - blue < blue) return true;
        return false;
    }
    int sum(TreeNode* node) {
        if(node == nullptr) return 0;
        return 1 + sum(node->left) + sum(node->right);
    }
    TreeNode* search(TreeNode* node, int target) {
        if(node->val == target) {
            return node;
        }
        TreeNode* find = nullptr;
        if(node->left != nullptr)
            find = search(node->left, target);
        if(find != nullptr)
            return find;
        if(node->right != nullptr)
            find = search(node->right, target);
        return find;
    }
};
```

> 认真读题发现n就是总节点数，不用再算一遍了

## [1129. 颜色交替的最短路径](https://leetcode.cn/problems/shortest-path-with-alternating-colors/)

### BFS
```c++
class Solution {
public:
    const bool RED = true;
    const bool BLUE = false;
    vector<vector<pair<bool, int>>> graph;
    vector<int> answer;
    vector<map<pair<bool, int>, bool>> visited;
    vector<int> shortestAlternatingPaths(int n, vector<vector<int>>& redEdges, vector<vector<int>>& blueEdges) {
        visited = vector<map<pair<bool, int>, bool>>(n);
        graph = vector<vector<pair<bool, int>>>(n);
        for(auto& edge: redEdges) {
            visited[edge[0]][make_pair(RED, edge[1])] = false;
            graph[edge[0]].push_back(make_pair(RED, edge[1]));
        }
        for(auto& edge: blueEdges) {
            visited[edge[0]][make_pair(BLUE, edge[1])] = false;
            graph[edge[0]].push_back(make_pair(BLUE, edge[1]));
        }
        answer = vector<int>(n, INT_MAX);
        search();
        for(int i = 1; i < n; i++) {
            if(answer[i] == INT_MAX) answer[i] = -1;
        }
        answer[0] = 0;
        return answer;
    }
    void search() {
        int len = 0;
        queue<pair<bool, int>> q;
        q.push(make_pair(RED, 0));
        q.push(make_pair(BLUE, 0));
        while(!q.empty()) {
            queue<pair<bool, int>> tmp;
            while(!q.empty()) {
                auto [color, node] = q.front();
                q.pop();
                for(auto& edge:graph[node]) {
                    if(edge.first != color && !visited[node][edge]) {
                        answer[edge.second] = min(answer[edge.second], len+1);
                        tmp.push(edge);
                        visited[node][edge] = true;
                    }
                }
            }
            len++;
            q = tmp;
        }
    }
};
```

> 不必重复遍历边
> 由于自环，平行边的存在，同一个节点可以重复遍历，这样可以凑出红蓝交替的路径
> 对于边，定义为`pair<bool, int>`，代表`<color, next>`
> bfs时，选取与上一条边颜色相反的边入队

### dfs
```c++
class Solution {
public:
    const bool RED = true;
    const bool BLUE = false;
    vector<vector<pair<bool, int>>> graph;
    vector<map<pair<bool, int>, bool>> visited;
    vector<int> shortestAlternatingPaths(int n, vector<vector<int>>& redEdges, vector<vector<int>>& blueEdges) {
        graph = vector<vector<pair<bool, int>>>(n);
        for(auto& edge: redEdges) {
            graph[edge[0]].push_back(make_pair(RED, edge[1]));
        }
        for(auto& edge: blueEdges) {
            graph[edge[0]].push_back(make_pair(BLUE, edge[1]));
        }
        vector<int> answer(n);
        for(int i = 1; i < n; i++) {
            visited = vector<map<pair<bool, int>, bool>>(n);
            for(auto& edge: redEdges) {
                visited[edge[0]][make_pair(RED, edge[1])] = false;
            }
            for(auto& edge: blueEdges) {
                visited[edge[0]][make_pair(BLUE, edge[1])] = false;
            }
            answer[i] = min(search(0, i, 0, RED), search(0, i, 0, BLUE));
            if(answer[i] == INT_MAX) answer[i] = -1;
        }
        return answer;
    }
    int search(int node, int target, int len, bool last_color) {
        if(node == target) return len;
        int find = INT_MAX;
        for(auto& edge : graph[node]) {
            if(edge.first != last_color && !visited[node][edge]) {
                visited[node][edge] = true;
                find = min(search(edge.second, target, len+1, edge.first), find);
                visited[node][edge] = false;
            }
        }
        return find;
    }
};
```

> 超时，但应该是正确的
> 复杂度 $ O(n^2) $

## [1806. 还原排列的最少操作步数](https://leetcode.cn/problems/minimum-number-of-operations-to-reinitialize-a-permutation/)

### 模拟
```c++
class Solution {
public:
    int n;
    int reinitializePermutation(int n) {
        this->n = n;
        vector<int> arr(n),tmp(n), *x, *y;
        for(int i = 0; i < n; i++) {
            arr[i] = i%2 == 0 ? i/2 : n/2+(i-1)/2;
        }
        int step = 1;
        x = &arr;
        y = &tmp;
        while(!ok(x)) {
            for(int i = 0; i < n; i++) {
                (*y)[i] = i%2 == 0 ? (*x)[i/2] : (*x)[n/2+(i-1)/2];
            }
            swap(x, y);
            step++;
        }
        return step;
    }
    bool ok(vector<int>* arr) {
        for(int i = 0; i < n; i++) {
            if((*arr)[i] != i) return false;
        }
        return true;
    }
};
```

### 模拟2

```c++
class Solution {
public:
    int n;
    int reinitializePermutation(int n) {
        this->n = n;
        vector<int> arr(n);
        for(int i = 0; i < n; i++) {
            arr[i] = i%2 == 0 ? i/2 : n/2+(i-1)/2;
        }
        int step = 1, p = arr[1];
        while(p != 1) {
            p = arr[p];            
            step++;
        }
        return step;
    }
};
```

## [238. 除自身以外数组的乘积](https://leetcode.cn/problems/product-of-array-except-self/)
```c++
class Solution {
public:
    vector<int> productExceptSelf(vector<int>& nums) {
        int len = nums.size();
        vector<int> l(len, 1), r(len,1);
        for(int i = 1; i < len; i++) {
            l[i] = l[i-1] * nums[i-1];
            r[len-i-1] = r[len-i] * nums[len-i];
        }
        for(int i = 0; i < len; i++) {
            nums[i] = l[i]*r[i];
        }
        return nums;
    }
};
```

### 空间O(1)

```c++
class Solution {
public:
    vector<int> productExceptSelf(vector<int>& nums) {
        int len = nums.size();
        vector<int> res(len, 1);
        for(int i = 1; i < len; i++) {
            res[len-i-1] = res[len-i] * nums[len-i];
        }
        int left = 1;
        for(int i = 0; i < len; i++) {
            res[i] = left*res[i];
            left *= nums[i];
        }
        return res;
    }
};
```

> 他这里对 $ O(1) $ 的定义是除了输入输出数组外，只用常量级的空间，很容易想到l数组可以优化


## [2357. 使数组中所有元素都等于零](https://leetcode.cn/problems/make-array-zero-by-subtracting-equal-amounts/description/)
```c++
class Solution {
public:
    int minimumOperations(vector<int>& nums) {
        unordered_map<int, int> m;
        for(int n:nums) {
            if(n > 0) {
                m[n]++;
            }
        }
        int count = 0;
        for(auto ite=m.begin(); ite != m.end(); ite++,count++);
        return count;
    }
};
```

## [1238. 循环码排列](https://leetcode.cn/problems/circular-permutation-in-binary-representation/description/)

### 二叉树
```c++
class Solution {
public:
    vector<int> res;
    vector<int> circularPermutation(int n, int start) {
        int len = 1 << n;
        res = vector<int>(len);
        vector<int> rotate(len);
        int split = 2;
        for(int i = 0; i < n; i++) {
            int a = 0;
            for(int j = 0; j < split; j++) {
                cal(len/split*j, len/split*(j+1), a);
                if(j%2==0) a = !a;
            }
            split <<= 1;
        }
        int k = 0;
        while(k < len && res[k] != start) k++;
        for(int i = 0; i < len; i++) {
            rotate[i] = res[(i+k)%len];
        }
        return rotate;
    }
    void cal(int i, int j, int a) {
        for(; i < j; i++) {
            res[i] <<= 1;
            res[i] += a&1;
        }
    }
};
```

> 把他想成一个二叉树，每层按照0110的顺序生成

### 二叉树1

```c++
class Solution {
public:
    vector<int> res;
    vector<int> circularPermutation(int n, int start) {
        int len = 1 << n;
        vector<int> rotate(len);
        
        queue<TreeNode*> q;
        for(int i = 0; i < len; i++) {
            q.push(new TreeNode(i));
        }
        TreeNode* root = nullptr;
        while(!q.empty()) {
            TreeNode *n1 = q.front(), *n2 = nullptr;
            q.pop();
            if(!q.empty()) {
                n2 = q.front();
                q.pop();
                q.push(new TreeNode(n1->val + n2->val, n1, n2));
            } else {
                root = n1;
                break;
            }
        }
        flip(root);
        treavourse(root);
        int k = 0;
        while(k < len && res[k] != start) k++;
        for(int i = 0; i < len; i++) {
            rotate[i] = res[(i+k)%len];
        }
        return rotate;
    }
    void treavourse(TreeNode* root) {
        if(root->left != nullptr && root->right != nullptr) {
            treavourse(root->left);
            treavourse(root->right);
        } else {
            res.push_back(root->val);
        }
    }
    void flip(TreeNode* root) {
        if(root->left == nullptr || root->right == nullptr) return;
        swap(root->right->left, root->right->right);
        flip(root->left);
        flip(root->right);
    }
};
```

> 翻转二叉树，`先序`把右孩子的左右孩子互换
>
>

### 格雷码
```c++
class Solution {
public:
    vector<int> res;
    vector<int> circularPermutation(int n, int start) {
        int len = 1 << n;
        res = vector<int>(len);
        int split = 2;
        for(int i = 0; i < n; i++) {
            int a = 0;
            for(int j = 0; j < split; j++) {
                cal(len/split*j, len/split*(j+1), a);
                if(j%2==0) a = !a;
            }
            split <<= 1;
        }
        for(int i = 0; i < len; i++) {
            res[i] = res[i] ^ start;
        }
        return res;
    }
    void cal(int i, int j, int a) {
        for(; i < j; i++) {
            res[i] <<= 1;
            res[i] += a&1;
        }
    }
};
```

- 格雷码有他的生成公式

```c++
class Solution {
public:
    vector<int> circularPermutation(int n, int start) {
        vector<int> ret(1 << n);
        for (int i = 0; i < ret.size(); i++) {
            ret[i] = (i >> 1) ^ i ^ start;
        }
        return ret;
    }
};
```


## [1326. 灌溉花园的最少水龙头数目](https://leetcode.cn/problems/minimum-number-of-taps-to-open-to-water-a-garden/description/)

### dp
```c++
class Solution {
public:
    int minTaps(int n, vector<int>& ranges) {
        vector<int> dp(n+1, INT_MAX), index(n+1);
        for(int i = 0; i <= n; i++) index[i] = i;
        sort(index.begin(), index.end(), [&ranges](int i, int j)->bool{return i-ranges[i] < j-ranges[j];});
        dp[0] = 0;
        for(int i = 0; i <= n; i++) {
            int start = max(index[i] - ranges[index[i]], 0);
            int end = min(index[i] + ranges[index[i]], n);
            if(dp[start] == INT_MAX) return -1;
            for(int j = start; j <= end; j++) {
                dp[j] = min(dp[start]+1, dp[j]);
            }
        }
        return dp[n];
    }
};
```
> $dp[i]$表示区间$[0, i]$被灌溉所需的最少水龙头数
> 将$ranges[i]$按照$i-ranges[i]$从小到大排序
> 按顺序遍历排序好的ranges，计算其$start,end$
> $start$处已经计算出其所需最小水龙头数了，有两种情况
> - 当前$ [0, x] $已知, $ start <= end <= x $, 则$[start, end]$之间最少水龙头数保持不变
> - 当前$ [0, x] $已知, $ start <= x < end $, 则$[start+1, end]$之间最少水龙头数为$dp[start]+1$
> - 当前$ [0, x] $已知, $ x < start <= end $, 则无解


### 贪心

```c++
class Solution {
public:
    int minTaps(int n, vector<int>& ranges) {
        vector<int> right(n+1);
        for(int i = 0; i <= n; i++) right[max(0, i-ranges[i])] = max(min(i + ranges[i],n), right[max(0, i-ranges[i])]);
        int last = 0;
        int ret = 0;
        int pre = 0;
        for(int i = 0; i < n; i++) {
            last = max(last, right[i]);
            if(i == last) return -1;
            if(i == pre) {
                ret++;
                pre = last;
            }
        }
        return ret;
    }
};
```

> $right[start]$表示从$start$位置，经过某个水龙头的浇灌最远能到达的位置
> $last$表示当前最远到达的位置，$pre$表示上一个使用的水龙头最远的位置
> 从左向右遍历，一边遍历一遍寻找最远能到达的位置，如果$i$到达了最远能到达的位置且不是n，说明无法覆盖。如果i遇到了前一个水龙头的边界，说明接下来该使用下一个水龙头了


## [1247. 交换字符使得字符串相同](https://leetcode.cn/problems/minimum-swaps-to-make-strings-equal/description/)

```c++
class Solution {
public:
    int minimumSwap(string s1, string s2) {
        int count[2][2] = {0};
        int len = s1.length();
        for(int i= 0; i < len; i++) {
            if(s1[i] == 'x' && s2[i] == 'y') {
                count[0][1]++;
            } else if(s1[i] == 'y' && s2[i] == 'x') {
                count[1][0]++;
            }
        }
        int res = count[0][1]/2 + count[1][0]/2;
        if(count[0][1]%2 == 1 && count[1][0]%2 == 1) {
            res+=2;
        } else if(count[0][1]%2 || count[1][0]%2) {
            return -1;
        }
        return res;
    }
};
```

> 根据题目的样例 "xx"+"yy"型("yy"+"xx"型)，只需要一步
> "xy"+"yx"型("yx"+"xy"型)，需要两步
> 交换时可以两个字符串上任意两个位置进行交换。

## [1703. 得到连续 K 个 1 的最少相邻交换次数](https://leetcode.cn/problems/minimum-adjacent-swaps-for-k-consecutive-ones/)

```c++
class Solution {
public:
    int k;
    int minMoves(vector<int>& nums, int k) {
        int i = 0, j = 0, n = nums.size();
        this->k = k;
        queue<int> index, wait;
        for(int i = 0; i < n; i++) {
            if(nums[i] == 1) {
                index.push(i);
            }
        }
        for(int i = 0; i < k; i++) {
            wait.push(index.front());
            index.pop();
        }
        int minn = cal(wait);
        while(!index.empty()) {
            wait.push(index.front());
            index.pop();
            wait.pop();
            minn = min(cal(wait), minn);
        }
        return minn;
    }
    int cal(queue<int> q) {
        int l = 0, r = 0, count = 1, last = q.front();
        for(int i = 0; i < k/2; i++) {
            q.pop();
            l += count * (q.front() - last - 1);
            count++;
            last  = q.front();
        }
        last = q.front();
        for(int i = k/2; i < k-1; i++) {
            q.pop();
            r += (k - i - 1) * (q.front() - last - 1);
            last  = q.front();
        }
        return l + r;
    }
};
```

> 两个队列 `index` 和 `que`
> index存放值为1的下表
> 从index取k个放入que
> 计算que的长度
> que中pop一个，index也pop一个放入index，再次计算index，直到index为空
> 取每次计算que的最小值
> que计算长度时，从中间一分为二，将两边的1向最中间的1靠拢移动。

### 优化1
```c++
class Solution {
public:
    int k;
    int minMoves(vector<int>& nums, int k) {
        int i = 0, j = 0, count = 0, n = nums.size();
        this->k = k;
        vector<int> index(n);
        int minn = INT_MAX;
        for(int i = 0; i < n; i++) {
            if(nums[i] == 1) {
                index[j] = i;
                j++;
                if(j >= k) {
                    minn = min(cal(move(index), count), minn);
                    count++;
                }
            }
            
        }
        return minn;
    }
    int cal(vector<int>&& v, int start) {
        int l = 0, r = 0;
        int li = 0;
        for(int i = k/2; i > 0; i--) {
            li += (v[i+start] - v[i+start-1] - 1);
            l += li;
        }
        int ri = 0;
        for(int i = k/2; i < k-1; i++) {
            ri += (v[i+start+1] - v[i+start] - 1);
            r += ri;
        }
        return l + r;
    }
};
```

### 题解
```c++
class Solution {
public:
    int minMoves(vector<int>& nums, int k) {
        int n = nums.size();
        int minn = 0, cost = 0;
        vector<int> left{0}, zero;
        int leftSum = 0;
        int i = 0;
        for(; i < n && nums[i] == 0; i++);
        for(; i < n;) {
            i++;
            int count;
            for(count = 0; i < n && nums[i] == 0; i++, count++);
            leftSum += count;
            if(i < n) {
                zero.push_back(count);
                left.push_back(leftSum);
            }
        }
        int l = 0, r = k-2;
        for(int i = l; i <= r; i++) {
            cost += zero[i] * min(1+i, 1+r-i);
        }
        minn=cost;
        int nn = zero.size();
        for(int i = 1, j = k-1; j < nn; i++, j++) {
            int mid = (i+j)/2;
            cost -= left[mid] - left[i-1];
            cost += left[j+1] - left[mid+k%2];
            minn = min(minn, cost);
        }
        return minn;
    }
};
```

> [参考题解](https://leetcode.cn/problems/minimum-adjacent-swaps-for-k-consecutive-ones/solutions/627364/duo-tu-xin-shou-jiao-cheng-yi-bu-bu-dai-6bps4/)， 就是找到窗口滑动时，cost的O(1)的更新方法

## [1255. 得分最高的单词集合](https://leetcode.cn/problems/maximum-score-words-formed-by-letters/description/)

```c++
class Solution {
public:
    int wn;
    int maxScoreWords(vector<string>& words, vector<char>& letters, vector<int>& score) {
        wn = words.size();
        int ln = letters.size();
        vector<int> letterCount = vector<int>(26);
        for(int i = 0; i < ln; i++) {
            letterCount[letters[i] - 'a']++;
        }
        return dfs(0, words, score, letterCount);
    }
    int dfs(int index, vector<string>& words, vector<int>& score, vector<int> state) {
        if(index >= wn) return 0;
        int scoreNext = dfs(index+1, words, score, state);
        int wlen = words[index].length();
        int scorei = 0;
        for(int i = 0; i < wlen; i++) {
            if(state[words[index][i] - 'a'] > 0) {
                state[words[index][i] - 'a']--;
                scorei += score[words[index][i] - 'a'];
            } else {
                return scoreNext;
            }
        }
        return max(scoreNext, scorei + dfs(index+1, words, score, state));
    }
};
```

> 艺术，就是暴搜！！！
> 然后再记录一下当前状态下，26个字母当前剩余个数

### 状态压缩，但是负优化
```c++
class Solution {
public:
    int maxScoreWords(vector<string>& words, vector<char>& letters, vector<int>& score) {
        int wn = words.size();
        int ln = letters.size();
        vector<int> letterCount = vector<int>(26);
        for(int i = 0; i < ln; i++) {
            letterCount[letters[i] - 'a']++;
        }
        int res = 0;
        for(int s = 1; s < (1 << wn); s++) {
            vector<int> wordCount = letterCount;
            int scoreState = 0;
            for(int i = 0; i < wn; i++) {
                if(s & (1 << i)) {
                    int wlen = words[i].length();
                    for(int j = 0; j < wlen; j++) {
                        if(wordCount[words[i][j] - 'a'] > 0) {
                            wordCount[words[i][j] - 'a']--;
                            scoreState += score[words[i][j] - 'a'];
                        } else {
                            s = ((s >> (wn -i)) + 1) << (wn - i);
                            goto NextState;
                        }
                    }
                }
            }
            res = max(res, scoreState);
            NextState:;
        }
        return res;
    }
};
```

> s的每一位表示对应wordi是否选择，复制最初的状态，统计分数，如果遇到不可以的，直接到下一个状态

### 剪枝

```c++
class Solution {
public:
    int maxScoreWords(vector<string>& words, vector<char>& letters, vector<int>& score) {
        int wn = words.size();
        int ln = letters.size();
        vector<int> letterCount = vector<int>(26);
        for(int i = 0; i < ln; i++) {
            letterCount[letters[i] - 'a']++;
        }
        int res = 0;
        for(int s = 1; s < (1 << wn);) {
            vector<int> wordCount = letterCount;
            int scoreState = 0;
            for(int i = 0; i < wn; i++) {
                if(s & (1 << (wn - i - 1))) {
                    int wlen = words[i].length();
                    for(int j = 0; j < wlen; j++) {
                        if(wordCount[words[i][j] - 'a'] > 0) {
                            wordCount[words[i][j] - 'a']--;
                            scoreState += score[words[i][j] - 'a'];
                        } else {
                            s = ((s >> (wn - i - 1)) + 1) << (wn - i - 1);
                            // s += 1 << (wn - i - 1);
                            goto NextState;
                        }
                    }
                }
            }
            res = max(res, scoreState);
            s++;
            NextState:;
        }
        return res;
    }
};
```

> 题解中的状态 $ s $的第 $ i $ 位(从 $ 0 $ 开始，从左往右)对应的是 $ words $ 数组中第 $ n-1-i $ 个字符串，我这里改成对应第 $ i $ 个字符串


> 对于状态 $ s $，当发现第 $ k $ 位的字符个数条件满足不了以后，第 $ k+1 $ 位至第 $ n-1 $ 位的情况都不需要考虑了，则状态直接跳转到 $ ((s >> (n - k - 1))  + 1) << (n - k - 1) $ ,由于当前状态第 $ k $ 位后全为 $ 0 $ ，也就是当前状态s再加上 $ 1 << (n - k - 1) $


> 或者状态 $ s $ 从 $ -1 $ 到 $ -(1 << wn) $ 

```c++
class Solution {
public:
    int maxScoreWords(vector<string>& words, vector<char>& letters, vector<int>& score) {
        int wn = words.size();
        int ln = letters.size();
        vector<int> letterCount = vector<int>(26);
        for(int i = 0; i < ln; i++) {
            letterCount[letters[i] - 'a']++;
        }
        int res = 0;
        for(int s = -1; s > -(1 << wn);) {
            vector<int> wordCount = letterCount;
            int scoreState = 0;
            for(int i = 0; i < wn; i++) {
                if(s & (1 << (wn - i - 1))) {
                    int wlen = words[i].length();
                    for(int j = 0; j < wlen; j++) {
                        if(wordCount[words[i][j] - 'a'] > 0) {
                            wordCount[words[i][j] - 'a']--;
                            scoreState += score[words[i][j] - 'a'];
                        } else {
                            s -= (1 << (wn - i - 1));
                            goto NextState;
                        }
                    }
                }
            }
            res = max(res, scoreState);
            s--;
            NextState:;
        }
        return res;
    }
};
```