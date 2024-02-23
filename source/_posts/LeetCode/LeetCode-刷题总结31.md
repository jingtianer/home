---
title: LeetCode-31
date: 2023-12-25 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## [1276. 不浪费原料的汉堡制作方案](https://leetcode.cn/problems/number-of-burgers-with-no-waste-of-ingredients/description/?envType=daily-question&envId=2023-12-25)

- 解方程，判断是非负整数解就行
- 用位运算，能快一点

```c++
class Solution {
public:
    vector<int> numOfBurgers(int tomatoSlices, int cheeseSlices) {
        int jumbo = 0, small = 0;
        // jumbo + small == cheeseSlices;
        // 4*jumbo + 2*small == tomatoSlices;
        small = ((cheeseSlices << 2) - tomatoSlices);
        jumbo = (tomatoSlices - (cheeseSlices << 1));
        if(jumbo >= 0 && small >= 0 && (small & 1) == 0 && (jumbo & 1) == 0)
            return {jumbo >> 1, small >> 1};
        return {};
    }
};
```

## 1185. 一周中的第几天

- [梦回大一](https://leetcode.cn/problems/day-of-the-week/?envType=daily-question&envId=2023-12-30)

```c++
class Solution {
public:
    string dayOfTheWeek(int day, int month, int year) {
        int week = 0;
        for(int i = 1971; i < year; i++) {
            week = (week + 31 * 7 + 30 * 4 + 28) % 7;
            if((i % 100 != 0 && i % 4 == 0) || i % 400 == 0) {
                week = (week + 1) % 7;
            }
        }
        for(int i = 1; i < month; i++) {
            if(i == 2) {
                week = (week + 28) % 7;
                if((year % 100 != 0 && year % 4 == 0) || year % 400 == 0) {
                    week = (week + 1) % 7;
                }
            } else if(i == 1 || i == 3 || i == 5 || i == 7 || i == 8 || i == 10 || i == 12) {
                week = (week + 31) % 7;
            } else {
                week = (week + 30) % 7;
            }
        }
        week = (week + day + 4) % 7;
        return vector<string>{"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}[week];
    }
};
```

## [2706. 购买两块巧克力](https://leetcode.cn/problems/buy-two-chocolates/description/?envType=daily-question&envId=2023-12-29)

```c++
class Solution {
public:
    int buyChoco(vector<int>& prices, int money) {
        int minPrice = INT_MAX / 2, secondMinPrice = INT_MAX / 2;
        for(int price : prices) {
            if(price < minPrice) {
                secondMinPrice = minPrice;
                minPrice = price;
            } else if(price < secondMinPrice) {
                secondMinPrice = price;
            }
        }
        return (minPrice + secondMinPrice <= money) ? (money - minPrice - secondMinPrice) : money;
    }
};
```

## [2735. 收集巧克力](https://leetcode.cn/problems/collecting-chocolates/description/?envType=daily-question&envId=2023-12-28)

```c++
class Solution {
public:
    long long minCost(vector<int>& nums, int x) {
        int n = nums.size();
        vector<int> f(nums);
        long long ans = accumulate(f.begin(), f.end(), 0LL);
        for (int k = 1; k < n; ++k) {
            for (int i = 0; i < n; ++i) {
                f[i] = min(f[i], nums[(i + k) % n]);
            }
            ans = min(ans, (long long)(k) * x + accumulate(f.begin(), f.end(), 0LL));
        }
        return ans;
    }
};
```

## [1599. 经营摩天轮的最大利润](https://leetcode.cn/problems/maximum-profit-of-operating-a-centennial-wheel/description/?envType=daily-question&envId=2024-01-01)

### 模拟
- 模拟经营

```c++
class Solution {
public:
    int minOperationsMaxProfit(vector<int>& customers, int boardingCost, int runningCost) {
        int wating = 0;
        int porfit = 0;
        int maxProfit = 0;
        int maxProfitI = -2;
        int len = customers.size();
        int i = 0;
        for(; i < len; i++) {
            if(customers[i] + wating > 4) {
                wating += customers[i] - 4;
                customers[i] = 4;
            } else {
                customers[i] = customers[i] + wating;
                wating = 0;
            }
            porfit += boardingCost * customers[i] - runningCost;
            if(porfit > maxProfit) {
                maxProfit = porfit;
                maxProfitI = i;
            }
        }
        while(wating > 0) {
            int onboard = 0;
            if(wating > 4) {
                onboard = 4;
                wating -= 4;
            } else {
                onboard = wating;
                wating = 0;
            }
            porfit += boardingCost * onboard - runningCost;
            if(porfit > maxProfit) {
                maxProfit = porfit;
                maxProfitI = i;
            }
            i++;
        }
        return maxProfitI+1;
    }
};
```
### 优化

- 数组遍历结束后，剩下的乘客可以不用模拟，直接/4看有几次就好
- 如果`boardingCost` `runningCost`的值恰好无论如何都无法盈利，可以不算后面的

```c++
class Solution {
public:
    int minOperationsMaxProfit(vector<int>& customers, int boardingCost, int runningCost) {
        int wating = 0;
        int porfit = 0;
        int maxProfit = 0;
        int maxProfitI = -1;
        int len = customers.size();
        int i = 1;
        for(; i <= len; i++) {
            wating += customers[i-1];
            int onboard = min(4, wating);
            wating -= onboard;
            porfit += boardingCost * onboard - runningCost;
            if(porfit > maxProfit) {
                maxProfit = porfit;
                maxProfitI = i;
            }
        }
        int fullCost = (boardingCost << 2) - runningCost;
        if(fullCost <= 0) return maxProfitI;
        if(wating > 0) {
            int ramain = wating % 4;
            int roll = wating >> 2;
            wating = ramain;
            porfit += roll * fullCost;
            i += roll;
            if(porfit > maxProfit) {
                maxProfit = porfit;
                maxProfitI = i - 1;
            }
            porfit += boardingCost * wating - runningCost;
            if(porfit > maxProfit) {
                maxProfit = porfit;
                maxProfitI = i;
            }
        }
        return maxProfitI;
    }
};
```

## [889. 根据前序和后序遍历构造二叉树](https://leetcode.cn/problems/construct-binary-tree-from-preorder-and-postorder-traversal/description/?envType=daily-question&envId=2024-02-22)

- 对于根节点，先序序列的右侧是左节点，后序序列的右测是右节点
- 如果两个节点不同，则节点有两个子节点，如果相同，则该节点可能是左节点，也可能是右节点
- 对于其他节点，维护好该节点可在先序序列中可查询子代的范围，如果范围是1，则无子代，否则继续插入子代

### 非递归算法
- 两个数组，分别记录节点在先序、后序序列中的位置
- queue保存当前节点位置，以及在先序序列中后代的范围

```c++
class Solution {
public:
    TreeNode* constructFromPrePost(vector<int>& preorder, vector<int>& postorder) {
        int len = preorder.size();
        TreeNode *root = new TreeNode(preorder[0]);
        queue<tuple<TreeNode*, int, int>> q;
        q.push(make_tuple(root, 0, len));
        vector<int> pre_index(len+1), post_index(len+1);
        for(int i = 0; i < len; i++) {
            pre_index[preorder[i]] = i;
            post_index[postorder[i]] = i;
        }
        while(!q.empty()) {
            auto [node, l, r] = q.front();
            q.pop();
            if(l+1 >= r) continue;
            int left = pre_index[node->val] + 1, right = post_index[node->val] - 1;
            if(left < len && right >= 0) {
                if(preorder[left] != postorder[right]) {
                    node->left = new TreeNode(preorder[left]);
                    node->right = new TreeNode(postorder[right]);
                    q.emplace(node->left, left, pre_index[postorder[right]]);
                    q.emplace(node->right, pre_index[postorder[right]], r);
                } else {
                    node->left = new TreeNode(preorder[left]);
                    q.emplace(node->left, left, r);
                }
            }
        }
        return root;
    }
};
```

### 递归算法

```c++
class Solution {
    int len;
    void insertNode(TreeNode* node, int l, int r, vector<int> &pre_index, vector<int> &post_index, vector<int>& preorder, vector<int>& postorder) {
        if(l+1 >= r) return;
        int left = pre_index[node->val] + 1, right = post_index[node->val] - 1;
        if(left < len && right >= 0) {
            if(preorder[left] != postorder[right]) {
                node->left = new TreeNode(preorder[left]);
                node->right = new TreeNode(postorder[right]);
                insertNode(node->left, left, pre_index[postorder[right]], pre_index, post_index, preorder, postorder);
                insertNode(node->right, pre_index[postorder[right]], r, pre_index, post_index, preorder, postorder);
            } else {
                node->left = new TreeNode(preorder[left]);
                insertNode(node->left, left, r, pre_index, post_index, preorder, postorder);
            }
        }
    }
public:
    TreeNode* constructFromPrePost(vector<int>& preorder, vector<int>& postorder) {
        len = preorder.size();
        TreeNode *root = new TreeNode(preorder[0]);
        vector<int> pre_index(len+1), post_index(len+1);
        for(int i = 0; i < len; i++) {
            pre_index[preorder[i]] = i;
            post_index[postorder[i]] = i;
        }
        insertNode(root, 0, len, pre_index, post_index, preorder, postorder);
        return root;
    }
};
```

- 递归反而更快了
## [106. 从中序与后序遍历序列构造二叉树](https://leetcode.cn/problems/construct-binary-tree-from-inorder-and-postorder-traversal/description/?envType=daily-question&envId=2024-02-21)

```c++
class Solution {
    TreeNode* addNode(int left, int right, vector<int>& inorder, vector<int>& postorder, int &index, unordered_map<int, int>& in_index) {
        if(left >= right || index < 0) return nullptr;
        int val = postorder[index];
        TreeNode *node = new TreeNode(val);
        index--;
        node->right = addNode(in_index[val]+1, right, inorder, postorder, index, in_index);
        node->left = addNode(left, in_index[val], inorder, postorder, index, in_index);
        return node;
    }
public:
    TreeNode* buildTree(vector<int>& inorder, vector<int>& postorder) {
        int len = inorder.size();
        unordered_map<int, int> in_index;
        for(int i = 0; i < len; i++) {
            in_index[inorder[i]] = i;
        }
        int index = len - 1;
        return addNode(0, len, inorder, postorder, index, in_index);
    }
};
```

## [105. 从前序与中序遍历序列构造二叉树](https://leetcode.cn/problems/construct-binary-tree-from-preorder-and-inorder-traversal/description/?envType=daily-question&envId=2024-02-20)

```c++
class Solution {
    int len;
    TreeNode* addNode(int left, int right, vector<int>& preorder, vector<int>& inorder, int &index, unordered_map<int, int>& in_index) {
        if(left >= right || index >= len) return nullptr;
        int val = preorder[index];
        TreeNode *node = new TreeNode(val);
        index++;
        node->left = addNode(left, in_index[val], preorder, inorder, index, in_index);
        node->right = addNode(in_index[val]+1, right, preorder, inorder, index, in_index);
        return node;
    }
public:
    TreeNode* buildTree(vector<int>& preorder, vector<int>& inorder) {
        len = inorder.size();
        unordered_map<int, int> in_index;
        for(int i = 0; i < len; i++) {
            in_index[inorder[i]] = i;
        }
        int index = 0;
        return addNode(0, len, preorder, inorder, index, in_index);
    }
};
```

## [590. N 叉树的后序遍历](https://leetcode.cn/problems/n-ary-tree-postorder-traversal/description/?envType=daily-question&envId=2024-02-19)

```c++
/*
// Definition for a Node.
class Node {
public:
    int val;
    vector<Node*> children;

    Node() {}

    Node(int _val) {
        val = _val;
    }

    Node(int _val, vector<Node*> _children) {
        val = _val;
        children = _children;
    }
};
*/

class Solution {
    vector<int> res;
    void run_postorder(Node *root) {
        for(Node *child : root->children) {
            run_postorder(child);
        }
        res.push_back(root->val);
    }
public:
    vector<int> postorder(Node* root) {
        if(root) run_postorder(root);
        return res;
    }
};
```

## [589. N 叉树的前序遍历](https://leetcode.cn/problems/n-ary-tree-preorder-traversal/description/?envType=daily-question&envId=2024-02-18)
```c++
class Solution {
    vector<int> res;
    void run_preorder(Node *root) {
        res.push_back(root->val);
        for(Node *child : root->children) {
            run_preorder(child);
        }
    }
public:
    vector<int> preorder(Node* root) {
        if(root) run_preorder(root);
        return res;
    }
};
```

## [429. N 叉树的层序遍历](https://leetcode.cn/problems/n-ary-tree-level-order-traversal/description/?envType=daily-question&envId=2024-02-17)

```c++
/*
// Definition for a Node.
class Node {
public:
    int val;
    vector<Node*> children;

    Node() {}

    Node(int _val) {
        val = _val;
    }

    Node(int _val, vector<Node*> _children) {
        val = _val;
        children = _children;
    }
};
*/

class Solution {
public:
    vector<vector<int>> levelOrder(Node* root) {
        vector<vector<int>> res;
        queue<Node*> q;
        if(root) q.push(root);
        while(!q.empty()) {
            vector<int> level;
            int q_size = q.size();
            while(q_size--) {
                Node *node = q.front();
                q.pop();
                level.push_back(node->val);
                for(Node *child : node->children) {
                    q.push(child);
                }
            }
            res.push_back(level);
        }
        return res;
    }
};
```

## [103. 二叉树的锯齿形层序遍历](https://leetcode.cn/problems/binary-tree-zigzag-level-order-traversal/description/?envType=daily-question&envId=2024-02-16)

```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
class Solution {
public:
    vector<vector<int>> zigzagLevelOrder(TreeNode* root) {
        bool rev = false;
        vector<vector<int>> res;
        queue<TreeNode*> q;
        if(root) q.push(root);
        while(!q.empty()) {
            vector<int> level;
            int q_size = q.size();
            while(q_size--) {
                TreeNode *node = q.front();
                q.pop();
                level.push_back(node->val);
                if(node->left) q.push(node->left);
                if(node->right) q.push(node->right);
            }
            if(rev) {
                reverse(level.begin(), level.end());
            }
            res.push_back(level);
            rev = !rev;
        }
        return res;
    }
};
```

```c++
class Solution {
public:
    vector<vector<int>> zigzagLevelOrder(TreeNode* root) {
        bool rev = false;
        vector<vector<int>> res;
        queue<TreeNode*> q;
        if(root) q.push(root);
        while(!q.empty()) {
            int q_size = q.size();
            int index = q_size;
            vector<int> level(q_size);
            while(index--) {
                TreeNode *node = q.front();
                q.pop();
                level[(rev ? index : q_size - index - 1)] = node->val;
                if(node->left) q.push(node->left);
                if(node->right) q.push(node->right);
            }
            res.push_back(level);
            rev = !rev;
        }
        return res;
    }
};
```

## [107. 二叉树的层序遍历 II](https://leetcode.cn/problems/binary-tree-level-order-traversal-ii/description/?envType=daily-question&envId=2024-02-15)

```c++
class Solution {
    int depth(TreeNode *root) {
        return (
            root == nullptr ? 
            0 : 
            1 + max(depth(root->left), depth(root->right)) 
        );
    }
public:
    vector<vector<int>> levelOrderBottom(TreeNode* root) {
        int dep = depth(root);
        vector<vector<int>> res(dep);
        queue<TreeNode*> q;
        if(root) q.push(root);
        while(!q.empty()) {
            int q_size = q.size();
            int index = q_size;
            vector<int> level(q_size);
            while(index--) {
                TreeNode *node = q.front();
                q.pop();
                level[q_size - index - 1] = node->val;
                if(node->left) q.push(node->left);
                if(node->right) q.push(node->right);
            }
            res[--dep] = level;
        }
        return res;
    }
};
```

## [102. 二叉树的层序遍历](https://leetcode.cn/problems/binary-tree-level-order-traversal/description/?envType=daily-question&envId=2024-02-14)

```c++
class Solution {
public:
    vector<vector<int>> levelOrder(TreeNode* root) {
        vector<vector<int>> res;
        queue<TreeNode*> q;
        if(root) q.push(root);
        while(!q.empty()) {
            int q_size = q.size();
            int index = q_size;
            res.push_back(vector<int>(q_size));
            vector<int> &level = res.back();
            while(index--) {
                TreeNode *node = q.front();
                q.pop();
                level[q_size - index - 1] = node->val;
                if(node->left) q.push(node->left);
                if(node->right) q.push(node->right);
            }
        }
        return res;
    }
};
```
## [987. 二叉树的垂序遍历](https://leetcode.cn/problems/vertical-order-traversal-of-a-binary-tree/description/?envType=daily-question&envId=2024-02-13)

- 题目的要求很繁琐，需要输出二维数组，y坐标相同的节点放在同一数组内
- 且需要高层的放在底层的后面，同层的小值位于大值前面

```c++
class Solution {
    int cnt_range(TreeNode *root, int cur, int& left_min, int& right_max) {
        if(!root) return 0;
        int ldep = 0, rdep = 0;
        if(root->left) {
            left_min = min(left_min, cur - 1);
            ldep = cnt_range(root->left, cur-1, left_min, right_max);
        }
        if(root->right) {
            right_max = max(right_max, cur + 1);
            rdep = cnt_range(root->right, cur+1, left_min, right_max);
        }
        return 1 + max(ldep, rdep);
    }
public:
    vector<vector<int>> verticalTraversal(TreeNode* root) {
        int left_min = 0, right_max = 0;
        int depth = cnt_range(root, 0, left_min, right_max);
        vector<vector<int>> ans(right_max - left_min + 1);
        vector<vector<vector<int>>> level_ans(right_max - left_min + 1, vector<vector<int>>(depth));
        queue<pair<TreeNode*, int>> q;
        if(root) q.emplace(root, 0);
        int dep = 0;
        while(!q.empty()) {
            int q_size = q.size();
            while(q_size--) {
                auto [node, y] = q.front();
                q.pop();
                level_ans[y-left_min][dep].push_back(node->val);
                if(node->left) q.emplace(node->left, y-1);
                if(node->right) q.emplace(node->right, y+1);
            }
            dep++;
        }
        for(int i = 0; i < right_max - left_min + 1; i++) {
            for(int j = 0; j < depth; j++) {
                sort(level_ans[i][j].begin(), level_ans[i][j].end());
                for(int node : level_ans[i][j]) {
                    ans[i].push_back(node);
                }
            }
        }
        return ans;
    }
};
```

```c++
class Solution {
    int cnt_range(TreeNode *root, int cur, int& left_min, int& right_max) {
        if(!root) return 0;
        int ldep = 0, rdep = 0;
        if(root->left) {
            left_min = min(left_min, cur - 1);
            ldep = cnt_range(root->left, cur-1, left_min, right_max);
        }
        if(root->right) {
            right_max = max(right_max, cur + 1);
            rdep = cnt_range(root->right, cur+1, left_min, right_max);
        }
        return 1 + max(ldep, rdep);
    }
public:
    vector<vector<int>> verticalTraversal(TreeNode* root) {
        int left_min = 0, right_max = 0;
        int depth = cnt_range(root, 0, left_min, right_max);
        vector<vector<int>> ans(right_max - left_min + 1);
        vector<vector<pair<int, int>>> level_ans(right_max - left_min + 1);
        queue<pair<TreeNode*, int>> q;
        if(root) q.emplace(root, 0);
        int dep = 0;
        while(!q.empty()) {
            int q_size = q.size();
            while(q_size--) {
                auto [node, y] = q.front();
                q.pop();
                level_ans[y-left_min].emplace_back(dep, node->val);
                if(node->left) q.emplace(node->left, y-1);
                if(node->right) q.emplace(node->right, y+1);
            }
            dep++;
        }
        for(int i = 0; i < right_max - left_min + 1; i++) {
            sort(level_ans[i].begin(), level_ans[i].end());
            for(auto [_, node] : level_ans[i]) {
                ans[i].push_back(node);
            }
        }
        return ans;
    }
};
```

## [145. 二叉树的后序遍历](https://leetcode.cn/problems/binary-tree-postorder-traversal/description/?envType=daily-question&envId=2024-02-12)

### 递归

```c++
class Solution {
    void postorder(TreeNode *root, vector<int> &vec) {
        if(!root) return;
        postorder(root->left, vec);
        postorder(root->right, vec);
        vec.push_back(root->val);
    }
public:
    vector<int> postorderTraversal(TreeNode* root) {
        vector<int> res;
        postorder(root, res);
        return res;
    }
};
```

### 非递归

- 在中序遍历的基础上改造
- 对于当前节点，持续向左走压栈，直到无法往左走
- 此时栈顶节点的左子树访问结束，输出栈顶元素
- 若右子树为空，则栈顶元素的右子树访问完成，可以将该元素弹出栈
- 若右子树不为空，考虑该右子树是否是刚才访问过的，通过prev记录上一个输出的节点
  - 若prev于当前元素的right相同，则当前节点已经访问过右子树，输出当前节点
  - 若prev于当前元素的right不同，则当前节点变成右子树
- 此时栈顶元素的左子树节点访问结束，即重复第二步
```c++
class Solution {
public:
    vector<int> postorderTraversal(TreeNode* root) {
        vector<int> res;
        stack<TreeNode *> s;
        TreeNode *cur = root, *prev = nullptr;
        while(!s.empty() || cur) {
            while(cur) {
                s.push(cur);
                cur = cur->left;
            }
            cur = s.top();
            if(cur->right && cur->right != prev) {
                cur = cur->right;
            } else {
                prev = cur;
                s.pop();
                res.push_back(cur->val);
                cur = nullptr;
            }
        }
        return res;
    }
};
```

## [144. 二叉树的前序遍历](https://leetcode.cn/problems/binary-tree-preorder-traversal/description/?envType=daily-question&envId=2024-02-11)

### 递归
```c++
class Solution {
    void preorder(TreeNode *root, vector<int>& ans) {
        if(!root) return;
        ans.push_back(root->val);
        preorder(root->left, ans);
        preorder(root->right, ans);
    }
public:
    vector<int> preorderTraversal(TreeNode* root) {
        vector<int> ans;
        preorder(root, ans);
        return ans;
    }
};
```

### 非递归

```c++
class Solution {
public:
    vector<int> preorderTraversal(TreeNode* root) {
        vector<int> ans;
        stack<TreeNode*> s;
        if(root) s.push(root);
        while(!s.empty()) {
            TreeNode *node = s.top();
            s.pop();
            ans.push_back(node->val);
            if(node->right) s.push(node->right);
            if(node->left) s.push(node->left);
        }
        return ans;
    }
};
```

## [94. 二叉树的中序遍历](https://leetcode.cn/problems/binary-tree-inorder-traversal/description/?envType=daily-question&envId=2024-02-10)

### 递归

```c++
class Solution {
    void inorder(TreeNode *root, vector<int>& ans) {
        if(!root) return;
        inorder(root->left, ans);
        ans.push_back(root->val);
        inorder(root->right, ans);
    }
public:
    vector<int> inorderTraversal(TreeNode* root) {
        vector<int> ans;
        inorder(root, ans);
        return ans;
    }
};
```

### 非递归

- 对于当前节点，持续向左走压栈，直到无法往左走
- 此时栈顶节点的左子树访问结束
- 将右子树变成当前元素，若右子树为空，则栈顶元素的右子树访问完成，可以将该元素弹出栈
- 此时栈顶元素的左子树节点访问结束，即重复第二步

```c++
class Solution {
public:
    vector<int> inorderTraversal(TreeNode* root) {
        vector<int> ans;
        stack<TreeNode *> s;
        TreeNode *cur = root;
        while(!s.empty() || cur) {
            while(cur) {
                s.push(cur);
                cur = cur->left;
            }
            cur = s.top();
            s.pop();
            ans.push_back(cur->val);
            cur = cur->right;
        }
        return ans;
    }
};
```

## [236. 二叉树的最近公共祖先](https://leetcode.cn/problems/lowest-common-ancestor-of-a-binary-tree/description/?envType=daily-question&envId=2024-02-09)
### ac
```c++
class Solution {
    stack<TreeNode*> findTreeNode(TreeNode *root, TreeNode *target) {
        stack<TreeNode *> s;
        TreeNode *cur = root, *prev = nullptr;
        while(!s.empty() || cur) {
            while(cur) {
                s.push(cur);
                cur = cur->left;
            }
            cur = s.top();
            if(cur->right && prev != cur->right) {
                cur = cur->right;
            } else {
                prev = cur;
                if(cur == target) break;
                s.pop();
                cur = nullptr;
            }
        }
        stack<TreeNode *> ans;
        while(!s.empty()) {
            ans.push(s.top());
            s.pop();
        }
        return ans;
    }
public:
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        stack<TreeNode *> pstack = findTreeNode(root, p);
        stack<TreeNode *> qstack = findTreeNode(root, q);
        TreeNode *ans = nullptr;
        while(!pstack.empty() && !qstack.empty()) {
            if(pstack.top() == qstack.top()) {
                ans = pstack.top();
                pstack.pop();
                qstack.pop();
            } else {
                break;
            }
        }
        return ans;
    }
};
```

- 后序遍历时，如果找到目标节点，那么当前栈就是所有祖先
- 对比两个栈，找到最近的祖先

### 优化
- 减少一次遍历
```c++
class Solution {
    stack<TreeNode*> rev(stack<TreeNode*> s) {
        stack<TreeNode*> ans;
        while(!s.empty()) {
            ans.push(s.top());
            s.pop();
        }
        return ans;
    }
    void findTreeNode(TreeNode *root, TreeNode *p, TreeNode *q, stack<TreeNode*>& pstack, stack<TreeNode*>& qstack) {
        stack<TreeNode *> s;
        TreeNode *cur = root, *prev = nullptr;
        bool findp = false, findq = false;
        while(!s.empty() || cur) {
            while(cur) {
                s.push(cur);
                cur = cur->left;
            }
            cur = s.top();
            if(cur->right && prev != cur->right) {
                cur = cur->right;
            } else {
                prev = cur;
                if(cur == p) {
                    pstack = rev(s);
                    findp = true;
                }
                if(cur == q) {
                    qstack = rev(s);
                    findq = true;
                }
                if(findp && findq) break;
                s.pop();
                cur = nullptr;
            }
        }
    }
public:
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        stack<TreeNode *> pstack, qstack;
        findTreeNode(root, p, q, pstack, qstack);
        TreeNode *ans = nullptr;
        while(!pstack.empty() && !qstack.empty()) {
            if(pstack.top() == qstack.top()) {
                ans = pstack.top();
                pstack.pop();
                qstack.pop();
            } else {
                break;
            }
        }
        return ans;
    }
};
```

### 继续优化
#### 非递归
- 参考的代码是递归的，我改成非递归的

```c++
class Solution {
    TreeNode *ans = nullptr;
public:
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        stack<tuple<TreeNode *, bool, bool>> s;
        TreeNode *cur = root, *prev = nullptr;
        while(!s.empty() || cur) {
            while(cur) {
                s.emplace(cur, false, false);
                cur = cur->left;
            }
            auto [node, findp, findq] = s.top();
            cur = node; // 这里多创建一个node
            if(cur->right && prev != cur->right) {
                cur = cur->right;
            } else {
                if(cur == p) {
                    findp = true;
                }
                if(cur == q) {
                    findq = true;
                }
                if(findp && findq && ans == nullptr) {
                    ans = cur;
                    break;
                }
                s.pop();
                if(!s.empty() && (findp || findq)) {
                    auto &[_, last_findp, last_findq] = s.top();
                    last_findp = last_findp || findp;
                    last_findq = last_findq || findq;
                }
                prev = cur;
                cur = nullptr;
            }
        }
        return ans;
    }
};
```

- 不用引用会快一点

```c++
class Solution {
    TreeNode *ans = nullptr;
public:
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        stack<tuple<TreeNode *, bool, bool>> s;
        TreeNode *cur = root, *prev = nullptr;
        while(!s.empty() || cur) {
            while(cur) {
                s.emplace(cur, false, false);
                cur = cur->left;
            }
            auto [node, findp, findq] = s.top();
            cur = node;
            if(cur->right && prev != cur->right) {
                cur = cur->right;
            } else {
                if(cur == p) {
                    findp = true;
                }
                if(cur == q) {
                    findq = true;
                }
                if(findp && findq && ans == nullptr) {
                    ans = cur;
                    break;
                }
                s.pop();
                if(!s.empty() && (findp || findq)) {
                    auto [last, last_findp, last_findq] = s.top();
                    s.pop();
                    last_findp = last_findp || findp;
                    last_findq = last_findq || findq;
                    s.emplace(last, last_findp, last_findq);
                }
                prev = cur;
                cur = nullptr;
            }
        }
        return ans;
    }
};
```


#### 递归

```c++
class Solution {
    TreeNode *ans = nullptr;
    void dfs(TreeNode *cur, TreeNode *p, TreeNode *q, bool& last_findp, bool &last_findq) {
        bool findp = false, findq = false;
        if(cur == p) {
            findp = true;
        }
        if(cur == q) {
            findq = true;
        }
        if(cur->left) {
            dfs(cur->left, p, q, last_findp, last_findq);
            findp = last_findp || findp;
            findq = last_findq || findq;
        }
        if(cur->right) {
            dfs(cur->right, p, q, last_findp, last_findq);
        findp = last_findp || findp;
        findq = last_findq || findq;
        }
        last_findp = findp;
        last_findq = findq;
        if(findp && findq && ans == nullptr) {
            ans = cur;
        }
    }
public:
    TreeNode* lowestCommonAncestor(TreeNode* root, TreeNode* p, TreeNode* q) {
        bool findp = false, findq = false;
        dfs(root, p, q, findp, findq);
        return ans;
    }
};
```

- 避免stl会快

## [993. 二叉树的堂兄弟节点](https://leetcode.cn/problems/cousins-in-binary-tree/description/?envType=daily-question&envId=2024-02-08)

### 非递归

```c++
class Solution {
public:
    bool isCousins(TreeNode* root, int x, int y) {
        TreeNode *xFather = nullptr, *yFather = nullptr;
        int xDepth = 0, yDepth = 0;
        bool findX = false, findY = false;
        TreeNode* s[101] = {nullptr};
        int stack_ptr = 0;
        TreeNode *cur = root, *prev = nullptr;
        while(!(stack_ptr==0) || cur) {
            while(cur) {
                s[stack_ptr++] = cur;
                cur = cur->left;
            }
            cur = s[stack_ptr-1];
            if(cur->right && cur->right != prev) {
                cur = cur->right;
            } else {
                if(cur->val == x) {
                    xFather = stack_ptr-2 >= 0 ? s[stack_ptr-2] : nullptr;;
                    xDepth = stack_ptr;
                    findX = true;
                }
                if(cur->val == y) {
                    yFather = stack_ptr-2 >= 0 ? s[stack_ptr-2] : nullptr;;
                    yDepth = stack_ptr;
                    findY = true;
                }
                if(findX && findY) break;
                stack_ptr--;
                prev = cur;
                cur = nullptr;
            }
        }
        return xFather && yFather && xFather != yFather && xDepth == yDepth;
    }
};
```

### 递归
```c++
class Solution {
    int xDepth = 0, yDepth = 0;
    TreeNode *xFather = nullptr, *yFather = nullptr;
    void postorder(TreeNode *root, TreeNode *parent, int x, int y, int dep) {
        if(!root) return;
        postorder(root->left, root, x, y, dep+1);
        postorder(root->right, root, x, y, dep+1);
        if(root->val == x) {
            xDepth = dep;
            xFather = parent;
        }
        if(root->val == y) {
            yDepth = dep;
            yFather = parent;
        }
    }
public:
    bool isCousins(TreeNode* root, int x, int y) {
        postorder(root, nullptr, x, y, 0);
        return xFather && yFather && xFather != yFather && xDepth == yDepth;
    }
};
```

- leetcode真奇怪，递归算法反而会更快

## [2641. 二叉树的堂兄弟节点 II](https://leetcode.cn/problems/cousins-in-binary-tree-ii/description/?envType=daily-question&envId=2024-02-07)

### ac

```c++
class Solution {
public:
    TreeNode* replaceValueInTree(TreeNode* root) {
        if(!root) return nullptr;
        queue<pair<TreeNode*, TreeNode*>> q;
        q.emplace(root, nullptr);
        while(!q.empty()) {
            vector<pair<TreeNode *, TreeNode *>> level;
            int q_size = q.size(), level_sum = 0;
            int q_size_cnt = q_size;
            while(q_size_cnt--) {
                auto [node, p] = q.front();
                q.pop();
                level_sum += node->val;
                level.emplace_back(node, p);
                if(node->left) q.emplace(node->left, node);
                if(node->right) q.emplace(node->right, node);
            }
            for(int i = 0; i < q_size;) {
                if(i + 1 < q_size && level[i].second == level[i+1].second) {
                    level[i].first->val = level[i+1].first->val = level_sum - level[i].first->val - level[i+1].first->val;
                    i += 2;
                } else {
                    level[i].first->val = level_sum - level[i].first->val;
                    i += 1;
                }
            }
        }
        return root;
    }
};
```

### 优化
- 层次遍历
- 计算子节点（下一层节点）的和
- 父节点对子节点修改，改为两兄弟之和
- 获得当前层的和（`prev_level_sum`），将当前节点值(`node->val`)改为`prev_level_sum` `-` `node->val`

```c++
class Solution {
public:
    TreeNode* replaceValueInTree(TreeNode* root) {
        if(!root) return nullptr;
        queue<TreeNode*> q;
        q.push(root);
        int prev_level_sum = root->val;
        int q_size = 1;
        while(q_size > 0) {
            int level_sum = 0;
            while(q_size--) {
                auto node = q.front();
                q.pop();
                if(node->left) {
                    q.push(node->left);
                    level_sum += node->left->val;
                }
                if(node->right) {
                    q.push(node->right);
                    level_sum += node->right->val;
                }
                if(node->left && node->right) {
                    node->left->val = node->right->val = node->left->val + node->right->val;
                }
                node->val = prev_level_sum - node->val;
            }
            prev_level_sum = level_sum;
            q_size = q.size();
        }
        return root;
    }
};
```