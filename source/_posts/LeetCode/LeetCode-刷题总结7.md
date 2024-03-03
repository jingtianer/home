---
title: LeetCode-7
date: 2019-02-12 21:15:36
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## [532. 数组中的K-diff数对](https://leetcode-cn.com/problems/k-diff-pairs-in-an-array/)
### 思路
1. map，保存每个数出现的次数
2. 遍历map，如果要找差为0的数对，那么如果出现次数大于1，说明有一对儿
3. 如果差不是0，算出另一个数，在map里面查询，查询到了就是一对儿
### AC代码
```c++
class Solution {
public:
    int findPairs(vector<int>& nums, int k) {
        if (k < 0) return 0;
        map<int, int> m;
        for (int x : nums) {
            m[x]++;
        }
        int ans = 0;
        auto ite = m.begin();
        while (ite != m.end()) {
            if (k) {
                int sum = ite->first + k;
                if (m.count(sum)) ans++;//这里要用count函数查询是否存在元素，直接访问会超时
            } else {
                if (ite->second > 1) ans++;
            }
            ite++;
        }
        return ans;
    }
};
```
## [70. 爬楼梯](https://leetcode-cn.com/problems/climbing-stairs/)
### 思路
1. 在纸上计算，可以发现是斐波那契数列的第n+1项
### AC代码
```c++
class Solution {
public:
    int climbStairs(int n) {
        return fib(n + 1);
    }
    int fib(int N) {
        int a = 0, b = 1;
        for (int i = 0; i < N; i++) {
            int c = a + b;
            b = a;
            a = c;
        }
        return a;
    }
};
```
## [429. N叉树的层序遍历](https://leetcode-cn.com/problems/n-ary-tree-level-order-traversal/)
### 思路
遍历爷爷辈的数组，每次把孙子辈们全都放在一个sub数组里面，如果push完以后非空，就push到ans里面，然后把父亲辈放到fatherTemp数组里面，作为下一次的爷爷辈。为了处理第1第2辈，建立两个哑节点，统一算法
### AC代码
```c++
/*
// Definition for a Node.
class Node {
public:
    int val;
    vector<Node*> children;

    Node() {}

    Node(int _val, vector<Node*> _children) {
        val = _val;
        children = _children;
    }
};
*/
class Solution {
public:
    vector<vector<int>> levelOrder(Node* root) {
        if (!root) return {};
        Node *root1 = new Node();
        Node *root2 = new Node();
        root2->children.push_back(root);
        root1->children.push_back(root2);
        vector<vector<int>> ans;
        vector<int> sub;
        vector<Node*> m = {root1};
        vector<Node*>& father = m;
        while (father.size()) {
            sub.clear();
            vector<Node*> fatherTemp;
            for (Node* x : father) {
                for (Node* y : x->children) {
                    for (Node* z : y->children) {
                        sub.push_back(z->val);
                    }
                    fatherTemp.push_back(y);
                }
            }
            if (sub.size())
                ans.push_back(sub);
            father = fatherTemp;
        }
        return ans;
    }
};
```
### 大佬思路

### 大佬代码
```c++]
static auto x = []() { std::ios::sync_with_stdio(false);std::cin.tie(nullptr);return 0;}();
class Solution {
public:
    vector<vector<int>> levelOrder(Node* root) {
        vector<vector<int>> ans;
        queue<Node*> que;
        if(!root) return ans;
        que.push(root);
        while(!que.empty()){
            int k=que.size();
            ans.resize(ans.size()+1);
            for(int i=0;i<k;i++){
                ans[ans.size()-1].push_back(que.front()->val);
                for(Node* node:que.front()->children) que.push(node);
                que.pop();
            }
        }
        return ans;
    }
};
```

## [102. 二叉树的层次遍历](https://leetcode-cn.com/problems/binary-tree-level-order-traversal/)
### 思路
和上一题[429. N叉树的层序遍历](https://leetcode-cn.com/problems/n-ary-tree-level-order-traversal/)一个想法
### AC代码
```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */
class Solution {
public:
    vector<vector<int>> levelOrder(TreeNode* root) {
        if (!root) return {};
        vector<vector<int>> ans;
        vector<int> sub;
        TreeNode *root1 = new TreeNode(0), *root2 = new TreeNode(0);
        root2->left = root;
        root1->left = root2;
        TreeNode* temp = root1;
        vector<TreeNode*> m = {root1};
        vector<TreeNode*>& father = m;
        vector<TreeNode*> fatherTemp;
        while (father.size()) {
            fatherTemp.clear();
            sub.clear();
            for (TreeNode* x : father) {
                if (x->left != NULL) {
                    fatherTemp.push_back(x->left);
                    if (x->left->left != NULL)
                        sub.push_back(x->left->left->val);
                    if (x->left->right != NULL)
                        sub.push_back(x->left->right->val);
                }
                if (x->right != NULL) {
                    fatherTemp.push_back(x->right);
                    if (x->right->left != NULL)
                        sub.push_back(x->right->left->val);
                    if (x->right->right != NULL)
                        sub.push_back(x->right->right->val);
                }
            }
            if (sub.size()) ans.push_back(sub);
            father = fatherTemp;
        }
        return ans;
    }
};
```

## [404. 左叶子之和](https://leetcode-cn.com/problems/sum-of-left-leaves/)
### 思路
1. 递归
2. 如果左边的左边和左边的右边都是空，那么我的左边就是个叶子
3. 改进，不用vector存结点的指针，直接加起来

### AC代码
```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */
class Solution {
public:
    int sumOfLeftLeaves(TreeNode* root) {
        vector<TreeNode*> leaves;
        int ans = 0;
        getLeaves(root, leaves);
        for (auto x : leaves) {
            ans += x->val;
        }
        return ans;
    }
    void getLeaves(TreeNode* root, vector<TreeNode*>& leaves) {
        if (root == NULL) return;
        if (root->left == NULL && root->right == NULL) return;
        if (root->left != NULL) {
            if (root->left->left == NULL && root->left->right == NULL) {
                leaves.push_back(root->left);
            }
        }
        getLeaves(root->left, leaves);
        getLeaves(root->right, leaves);
    }
};
```

### AC代码（改进）
```c++
class Solution {
public:
    int sumOfLeftLeaves(TreeNode* root) {
        vector<TreeNode*> leaves;
        int ans = 0;
        getLeaves(root, ans);
        return ans;
    }
    void getLeaves(TreeNode* root, int& sum) {//传入引用
        if (root == NULL) return;
        if (root->left == NULL && root->right == NULL) return;
        if (root->left != NULL) {
            if (root->left->left == NULL && root->left->right == NULL) {
                sum += root->left->val;
            }
        }
        getLeaves(root->left, sum);
        getLeaves(root->right, sum);
    }
};
```

## [492. 构造矩形](https://leetcode-cn.com/problems/construct-the-rectangle/)

### 思路
1. 两个变量a，b,a = sqrt(area)，a++不断搜索，直到第一个为整数，然后a = sqrt(area)开始不断a--搜索，得到两组可能的答案，比较谁的差距小，然后输出
2. 优化，只搜索一半就行
### AC代码
```c++
class Solution {
public:
    vector<int> constructRectangle(int area) {
        int a1 = sqrt(area);
        int b1 = 0;
        int a2 = a1;
        int b2 = 0;
        while (area % a1) {
            a1--;
        }
        b1 = area / a1;
        while (area % a2) {
            a2++;
        }
        b2 = area / a2;
        int ansa, ansb;
        if (abs(a1 - b1) > abs(a2 - b2)) {
            ansa = a2;
            ansb = b2;
        } else {
            ansa = a1;
            ansb = b1;
        }
        if (ansa > ansb) {
            int t = ansa;
            ansa = ansb;
            ansb = t;
        }
        return {ansb, ansa};
    }
};
```
### AC代码（优化）
```c++
class Solution {
public:
    vector<int> constructRectangle(int area) {
        int a1 = sqrt(area);
        int b1 = 0;
        int a2 = a1;
        int b2 = 0;
        while (area % a1) {
            a1--;
        }
        b1 = area / a1;
        return {b1, a1};
    }
};
```

## [453. 最小移动次数使数组元素相等](https://leetcode-cn.com/problems/minimum-moves-to-equal-array-elements/)
### 思路
1. 没思路，评论说可以推导公式，就推出来了
2. $ans = \Sigma_{i=0}^{nums.size() - 1}[nums[i] - min(nums)]$
3. 公式推导思路（以下字母ASCII越大，代表的值就越大）
     1. {a}——0
     2. {b, a}——b - a
     3. {c, b, a}——b - a + c - a
4. 从a开始，先让a等于b，然后让两个b等于第三小的数，让三个第三小的数等于第四小的数...

### AC代码
```c++
class Solution {
public:
    int minMoves(vector<int>& nums) {
        int min = INT_MAX;
        for (int x : nums) {
            if (x < min) {
                min = x;
            }
        }
        int ans = 0;
        for (int x : nums) {
            ans += x - min;
        }
        return ans;
    }
};
```
### AC代码（优化）
```c++
class Solution {
public:
    int minMoves(vector<int>& nums) {
        long long min = INT_MAX, ans = 0, len = nums.size(), sum = 0;
        for (int x : nums) {
            if (x <= min) {
                min = x;
            }
            sum += x;
            
        }
        return sum - min*len;
    }
};
```
## [551. 学生出勤记录 I](https://leetcode-cn.com/problems/student-attendance-record-i/)
### 思路
把统计连续相同字符个数和统计某一个字符出现次数的算法结合在一起就行
### AC代码
```c++
class Solution {
public:
    bool checkRecord(string s) {
        int maxL = 0, numA = 0;
        int len = s.length();
        for (int i = 0; i < len;) {
            int count = 0;
            if (s[i] == 'A') {
                numA++;
                i++;//统计'A'的个数
            } else if (s[i] == 'L') {
                while (s[i] == 'L') {
                    i++;
                    count++;//统计连续的'L'的个数
                }
                maxL = maxL > count ? maxL : count;
            } else {
                i++;
            }
        }
        return numA <= 1 && maxL <= 2;
    }
};
```
## [557. 反转字符串中的单词 III](https://leetcode-cn.com/problems/reverse-words-in-a-string-iii/)
### 思路
一个指针，进去以后保存一次指针位置，然后指针后移，移动到空格或者结束为止，保存一次指针的位置，reverse两个指针
### AC代码
```c++
class Solution {
public:
    string reverseWords(string s) {
        int i = 0;
        int len = s.length();
        while (i < len) {
            int beg = i;
            while (i < len && s[i] != ' ') i++;
            int end = i;
            reverse(s.begin() + beg, s.begin() + end);
            i++;
        }
        return s;
    }
};
```

## [559. N叉树的最大深度](https://leetcode-cn.com/problems/maximum-depth-of-n-ary-tree/)
### 思路
1. 把之前[429. N叉树的层序遍历](https://leetcode-cn.com/problems/n-ary-tree-level-order-traversal/)的代码直接拿来用
2. 简化代码
### AC代码
```c++
/*
// Definition for a Node.
class Node {
public:
    int val;
    vector<Node*> children;

    Node() {}

    Node(int _val, vector<Node*> _children) {
        val = _val;
        children = _children;
    }
};
*/
class Solution {
public:
    int maxDepth(Node* root) {
        return levelOrder(root).size();
    }
    vector<vector<int>> levelOrder(Node* root) {
        if (!root) return {};
        Node *root1 = new Node();
        Node *root2 = new Node();
        root2->children.push_back(root);
        root1->children.push_back(root2);
        vector<vector<int>> ans;
        vector<int> sub;
        vector<Node*> m = {root1};
        vector<Node*>& father = m;
        while (father.size()) {
            sub.clear();
            vector<Node*> fatherTemp;
            for (Node* x : father) {
                for (Node* y : x->children) {
                    for (Node* z : y->children) {
                        sub.push_back(z->val);
                    }
                    fatherTemp.push_back(y);
                }
            }
            if (sub.size())
                ans.push_back(sub);
            father = fatherTemp;
        }
        return ans;
    }
};
```

### AC代码（简化）
```c++
class Solution {
public:
    int maxDepth(Node* root) {
        if (!root) return {};
        Node *root1 = new Node();
        Node *root2 = new Node();
        root2->children.push_back(root);
        root1->children.push_back(root2);
        vector<Node*> m = {root1};
        vector<Node*>& father = m;
        int count = 0;
        while (father.size()) {
            vector<Node*> fatherTemp;
            bool empty = true;
            for (Node* x : father) {
                for (Node* y : x->children) {
                    if (y->children.size()) empty = false;
                    fatherTemp.push_back(y);
                }
            }
            father = fatherTemp;
            if (!empty)
            count++;
        }
        return count;
    }
};
```

## [561. 数组拆分 I](https://leetcode-cn.com/problems/array-partition-i/)
### 思路
1. 排个序，把下标为偶数的项全都加起来

### AC代码
```c++
class Solution {
public:
    int arrayPairSum(vector<int>& nums) {
        sort(nums.begin(), nums.end());
        int len = nums.size(), ans = 0;
        for (int i = 0; i < len; i+=2) {
            ans += nums[i];
        }
        return ans;
    }
};
```

## [566. 重塑矩阵](https://leetcode-cn.com/problems/reshape-the-matrix/)
### 思路
1. 先把不能转换的排除
2. 两个下标m，n，指向原来数组的行和列，当n为原来数组的c时，m++，n = 0

### AC代码
```c++
class Solution {
public:
    vector<vector<int>> matrixReshape(vector<vector<int>>& nums, int r, int c) {
        int hight = nums.size(), width = nums[0].size();
        if (r*c != hight*width) {
            return nums;
        }
        vector<vector<int>> ans;
        int m = 0,n = 0;
        for (int i = 0; i < r; i++) {
            vector<int> temp;
            for (int j = 0; j < c; j++) {
                if (n == width) {
                    m++;
                    n = 0;
                }
                temp.push_back(nums[m][n++]);
            }
            ans.push_back(temp);
        }
        return ans;
    }
};
```

## [575. 分糖果](https://leetcode-cn.com/problems/distribute-candies/)

### 思路
1. map或者数组（已知数据范围）记录是否出现，一边遍历一边数

### AC代码
```c++
class Solution {
public:
    int distributeCandies(vector<int>& candies) {
        int m[200001] = {0};
        int len = candies.size();
        int count = 0;
        for (auto x : candies) {
            if (m[x + 100000] == 0) {
                m[x + 100000] = 1;
                count++;
            }
        }
        return min(count, len / 2);
    }
};
```

