---
title: LeetCode-8
date: 2019-02-12 21:15:36
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## [581. 最短无序连续子数组](https://leetcode-cn.com/problems/shortest-unsorted-continuous-subarray/)
### 思路
1. 拷贝把备份排序，然后两个指针，依次从头到尾（i），从尾到头（j）比较排序前后两个数组相同下标的值，把第一次不同的下标值记录，最后返回j - i + 1，如果为负数返回0。

### AC代码
```c++
class Solution {
public:
    int findUnsortedSubarray(vector<int>& nums) {
        vector<int> cpy(nums.begin(), nums.end());
        sort(cpy.begin(), cpy.end());
        int len = nums.size();
        int j = len - 1, i = 0;
        for ( ; j >= 0; j--) {
            if (nums[j] != cpy[j]) {
                break;
            }
        }
        for (; i < len; i++) {
            if (nums[i] != cpy[i]) {
                break;
            }
        }
        int ans = j - i + 1;
        return ans > 0 ? ans : 0;
    }
};
```
### 思路
1. 从前到后遍历，一边找最大值，一边找当前值是不是最大值，如果不是，记录当前下标
2. 从后向前遍历，一边找最小值，一边找当前值是不是最小值，如果不是，记录当前下标
3. 返回下标之间的元素数，注意差值为0返回1
### AC代码
```c++
static int pr = []() { 
    std::ios::sync_with_stdio(false); 
    cin.tie(NULL);  
    return 0; 
}();
class Solution {
public:
    int findUnsortedSubarray(vector<int>& nums) {
        int len = nums.size();
        int j = len - 1, i = 0;
        int max = INT_MIN, min = INT_MAX;
        int pre = 0, back = len - 1;
        for (;i < len;i++, j--) {
            max = max > nums[i] ? max : nums[i];
            if (max != nums[i]) {
                pre = i;
            }
            min = min < nums[j] ? min : nums[j];
            if (min != nums[j]) {
                back = j;
            }
        }
        int ans = pre - back + 1;
        return ans > 1 ? ans : 0;
    }
};
```
### 大佬思路
没看懂,为毛遍历这么多次可以这么快？
### 大佬代码
```c++
static int pr = []() { 
    std::ios::sync_with_stdio(false); 
    cin.tie(NULL);  
    return 0; 
}();

class Solution {
public:
    int findUnsortedSubarray(vector<int>& nums) {
        int n = nums.size();
        int left = 0;
        int right = n - 1;
        while (left < n - 1 && nums[left] <= nums[left + 1])
            left += 1;
        if (left == n - 1)
            return 0;
        while (right > 0 && nums[right] >= nums[right - 1])
            right -= 1;
        int min_value = INT32_MAX;
        int max_value = INT32_MIN;
        for (int i = left; i < right + 1; i++) {
            min_value = min(nums[i], min_value);
            max_value = max(nums[i], max_value);
        }
        while (left > -1 && nums[left] > min_value)
            left -= 1;
        while (right < n && nums[right] < max_value)
            right += 1;
        return right - left - 1;
    }
};
```

## [541. 反转字符串 II](https://leetcode-cn.com/problems/reverse-string-ii/)
### 思路
每次反转k或者小于k个字符，然后指针+=2*k
### AC代码
```c++
class Solution {
public:
    string reverseStr(string s, int k) {
        int i = 0;
        int len = s.length();
        while (i < len) {
            int l = len - i > k ? k : len - i;//每次算长度
            reverse(s.begin() + i, s.begin() + i + l);
            i += 2*k;
        }
        return s;
    }
};
```

## [589. N叉树的前序遍历](https://leetcode-cn.com/problems/n-ary-tree-preorder-traversal/)
### 思路 
1. 递归

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
    vector<int> preorder(Node* root) {
        vector<int> ans;
        go(root, ans);
        return ans;
    }
    void go(Node* root, vector<int>& v) {
        if (root == NULL) return;
        v.push_back(root->val);
        for (auto x : root->children) {
            go(x, v);
        }
    }
};
```

### 大佬思路
### 大佬代码
```c++
class Solution {
public:
    
    vector<int> preorder(Node* root) {
        if (!root) {
            return vector<int>();
        }
        
        stack<Node*> s;
        s.push(root);
        
        vector<int> ret;
        while (!s.empty()) {
            Node* p = s.top();
            s.pop();
            ret.push_back(p->val);
            int n = (p->children).size();
            for (int i = n - 1; i >= 0; --i) {
                if (p->children[i]) {
                    s.push((p->children)[i]);    
                }
            }
        }
        return ret;
    }
};

static auto _ = []() 
{
    std::ios::sync_with_stdio(false);
    std::cin.tie(nullptr);
    return 0;
}();
```

## [590. N叉树的后序遍历](https://leetcode-cn.com/problems/n-ary-tree-postorder-traversal/)
### AC代码
```c++
class Solution {
public:
    vector<int> postorder(Node* root) {
        vector<int> ans;
        go(root, ans);
        return ans;
    }
    void go(Node* root, vector<int>& v) {
        if (root == NULL) return;
        for (auto x : root->children) {
            go(x, v);
        }
        v.push_back(root->val);
    }
};
```
## [598. 范围求和 II](https://leetcode-cn.com/problems/range-addition-ii/)
### 思路
每次操作，左上角一定是重叠最大的，直接找最小的x，y就可以了
### AC代码
```c++
class Solution {
public:
    int maxCount(int m, int n, vector<vector<int>>& ops) {
        int minFirst = m, minSecond = n;
        for (auto x : ops) {
           minSecond = minSecond > x[1] ? x[1] : minSecond;
           minFirst = minFirst > x[0] ? x[0] : minFirst;
        }
        return minFirst*minSecond;
    }
};
```
## [599. 两个列表的最小索引总和](https://leetcode-cn.com/problems/minimum-index-sum-of-two-lists/)
### 思路
1. 一个map记录第一个数组的下标+1，然后遍历第二个数组，搞一个map，记录下标和对应的餐厅数组
2. 优化，遍历第二个数组的时候，查询，计算下标和，如果下标和小于当前的最小值，那么就clear当前数组，重新把当前这个餐厅push进去，如果等于，直接push餐厅，大于则不管
### AC代码
```c++
class Solution {
public:
    vector<string> findRestaurant(vector<string>& list1, vector<string>& list2) {
        unordered_map<string, int> m;
        map<int, vector<string>> ans;
        int len1 = list1.size();
        int len2 = list2.size();
        for (int i = 0; i < len1; i++) {
            m[list1[i]] = i + 1;
        }
        for (int i = 0; i < len2 ; i++) {
            int pos = m[list2[i]];
            if (pos) {
                ans[pos - 1 + i].push_back(list2[i]);
            }
        }
        return ans.begin()->second;
    }
};
```

### AC代码（优化）

```c++
class Solution {
public:
    vector<string> findRestaurant(vector<string>& list1, vector<string>& list2) {
        unordered_map<string, int> m;
        vector<string> ans;
        int len1 = list1.size();
        int len2 = list2.size();
        int min = INT_MAX;
        for (int i = 0; i < len1; i++) {
            m[list1[i]] = i + 1;
        }
        for (int i = 0; i < len2 ; i++) {
            int pos = m[list2[i]];
            if (pos) {
                int sum = pos - 1 + i;
                if (sum < min) {
                    ans.clear();
                    min = sum;
                    ans.push_back(list2[i]);
                } else if (sum == min) {
                    ans.push_back(list2[i]);
                }
            }
        }
        return ans;
    }
};
```

#### [605. 种花问题](https://leetcode-cn.com/problems/can-place-flowers/)
### 思路
1. 遍历每一个花盆，看它前后有没有花盆，枚举判断，注意如果n == 0时要退出循环
2. 优化：把第一个和最后一个单独拿出来，简化循环时的判断数目

### AC代码
```c++
class Solution {
public:
    bool canPlaceFlowers(vector<int>& flowerbed, int n) {
        int len = flowerbed.size();
        for (int i = 0; i < len && n > 0; i++) {
            if (flowerbed[i]) {
                
            } else {
                if (i == 0) {
                    if (len == 1 || (i + 1 < len && !flowerbed[i + 1])) {
                        n--;
                        flowerbed[i] = 1;
                    }
                } else if (i == len - 1) {
                    if (i - 1 >= 0 && !flowerbed[i - 1]) {
                        n--;
                        flowerbed[i] = 1;
                    }
                } else {
                    if (!flowerbed[i - 1] && !flowerbed[i + 1]) {
                        n--;
                        flowerbed[i] = 1;
                    }
                }
            }
        }
        return n == 0;
    }
};
```

### AC代码（优化）
```c++
class Solution {
public:
    bool canPlaceFlowers(vector<int>& flowerbed, int n) {
        if (n <= 0) return true;
        int len = flowerbed.size();
        if (len <= 0) return false;
        if (len == 1) return n <= 1 && !flowerbed[0];
        int sum = 0;
        if (!flowerbed[0] && !flowerbed[1]) {
            sum++;
            flowerbed[0] = 1;
        }
        for (int i = 1; i < len - 2; i++) {
            if (!flowerbed[i] && !flowerbed[i - 1] && !flowerbed[i + 1]) {
                flowerbed[i] = 1;
                sum++;
            }
        }
        if (!flowerbed[len - 2] && !flowerbed[len - 1]) {
            sum++;
            flowerbed[len - 1] = 1;
        }
        return n <= sum;
    }
};
```

## [628. 三个数的最大乘积](https://leetcode-cn.com/problems/maximum-product-of-three-numbers/)
### 思路
1. 参考[414. 第三大的数](https://leetcode-cn.com/problems/third-maximum-number/)的思路，用一次遍历，得到第一，第二第三大的数（a、b、c），和第一，第二小的数（m1，m2）
2. 分别计算$a*b*c$和$a*m1*m2$，返回较大的一个

### AC代码
```c++
class Solution {
public:
    int maximumProduct(vector<int>& nums) {
        int first = INT_MIN, second = INT_MIN, third = INT_MIN;
        int min1 = INT_MAX, min2 = INT_MAX;
        for (auto x : nums) {
            if (x >= first) {
                third = second;
                second = first;
                first = x;
            } else if (x < first && x >= second) {
                third = second;
                second = x;
            } else if (x < second && x >= third) {
                third = x;
            }
            if (x < min1) {
                min2 = min1;
                min1 = x;
            } else if (x >= min1 && x < min2) {
                min2 = x;
            }
        }
        int ans1 = first*second*third, ans2 = first*min1*min2;
        return ans1 > ans2 ? ans1 : ans2;
    }
};
```
## [633. 平方数之和](https://leetcode-cn.com/problems/sum-of-square-numbers/)
### 思路
1. 脑袋里想一个只有整数点的坐标系，取第一象限，用$y = x$分成两半，看一半，包括$y = x$和另一个坐标轴，在这个三角区域里选取的的不会重复
2. 选取点，从0~$\sqrt{\frac{c}{2}}$中选整数，如果满足$\sqrt{c - i^2}$为整数，那么就可以
3. 优化，类似二分查找

### AC代码
```c++
class Solution {
public:
    bool judgeSquareSum(int c) {
        double n = sqrt(c/2.0);
        for (int i = 0; i <= n; i++) {
            double x  = sqrt(c - i*i);
            if (int(x) == x) {
                return true;
            }
        }
        return false;
    }
};
```

### AC代码（优化）
```c++
class Solution {
public:
    bool judgeSquareSum(int c) {
        int a = 0, b = sqrt(c);
        while (a <= b) {
            double sum = (double)a*a + b*b;
            if (sum == c) {
                return true;
            } else if (sum > c) {
                b--;
            } else {
                a++;
            }
        }
        return false;
    }
};
```
## [637. 二叉树的层平均值](https://leetcode-cn.com/problems/average-of-levels-in-binary-tree/)
### 思路
改造[二叉树的层次遍历](https://leetcode-cn.com/problems/binary-tree-level-order-traversal/)的代码完事儿
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
    vector<double> averageOfLevels(TreeNode* root) {
        if (!root) return {};
        vector<double> ans;
        TreeNode *root1 = new TreeNode(0), *root2 = new TreeNode(0);
        root2->left = root;
        root1->left = root2;
        TreeNode* temp = root1;
        vector<TreeNode*> m = {root1};
        vector<TreeNode*>& father = m;
        vector<TreeNode*> fatherTemp;
        while (father.size()) {
            fatherTemp.clear();
            double sum = 0, count = 0;
            for (TreeNode* x : father) {
                if (x->left != NULL) {
                    fatherTemp.push_back(x->left);
                    if (x->left->left != NULL) {
                        count++;
                        sum += x->left->left->val;
                    }
                    if (x->left->right != NULL) {
                        sum += x->left->right->val;
                        count++;
                    }
                }
                if (x->right != NULL) {
                    fatherTemp.push_back(x->right);
                    if (x->right->left != NULL) {
                        sum += x->right->left->val;
                         count++;
                    }
                    if (x->right->right != NULL) {
                        sum += x->right->right->val;
                        count++;
                    }
                }
            }
            if (count) ans.push_back(sum/count);
            father = fatherTemp;
        }
        return ans;
    }
};
```
## [643. 子数组最大平均数 I](https://leetcode-cn.com/problems/maximum-average-subarray-i/)
### 思路
先算前k个数的和，然后i从k+1个数开始，把尾巴上的数减掉，上i指向的数，跟当前值比大小，储存最大和。
### AC代码
```c++
class Solution {
public:
    double findMaxAverage(vector<int>& nums, int k) {
        int len = nums.size();
        int sum = 0;
        double maxSum = 0;
        for (int i = 0; i < k; i++) {
            sum += nums[i];
        }
        maxSum = sum;
        for (int i = k; i < len; i++) {
            sum -= nums[i - k];
            sum += nums[i];
            maxSum = maxSum > sum ? maxSum : sum;
        }
        return maxSum*1.0/k;
    }
};
static const int _ = []() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    cout.tie(nullptr);
    return 0;
}();
```

## [645. 错误的集合](https://leetcode-cn.com/problems/set-mismatch/)
### 思路
一个vector，初始化为false，一次循环，每出现一个元素，把false变成true，如果已经是true，说明它是重复的元素，同时计算所有元素的和，最后根据等差数列求和公式等一系列计算计算出两个数
### AC代码
```c++
class Solution {
public:
    vector<int> findErrorNums(vector<int>& nums) {
        int n = 0;
        int sum = 0, len = nums.size();
        vector<bool> m(len, false);
        for (auto x : nums) {
            if (!m[x])m[x] = true;
            else n = x;
            sum += x;
        }
        int add = len*(len + 1) / 2 - sum;//相比正常缺少的部分
        return {n, n + add};
    }
};
static const int _ = []() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    cout.tie(nullptr);
    return 0;
}();
```

## [657. 机器人能否返回原点](https://leetcode-cn.com/problems/robot-return-to-origin/)
### AC代码
```c++
class Solution {
public:
    bool judgeCircle(string moves) {
        int u = 0 ,d = 0 ,r = 0 ,l = 0;
        for (auto x : moves) {
            switch(x) {
                case 'U':
                    u++;
                    break;
                case 'D' :
                    d++;
                    break;
                case 'R' :
                    r++;
                    break;
                case 'L' :
                    l++;
                    break;
            }
        }
        return u == d && l == r;
    }
};
static int desyncio = []() { std::ios::sync_with_stdio(false); cin.tie(nullptr); cout.tie(nullptr); return 0; }();
```
### AC代码（优化）
```c++
class Solution {
public:
    bool judgeCircle(string moves) {
        int movex[26] = {0}, movey[26] = {0};
        movey['U' - 'A'] = 1;
        movey['D' - 'A'] = -1;
        movex['L' - 'A'] = -1;
        movex['R' - 'A'] = 1;
        int x = 0, y = 0;
        for (auto c : moves) {
            y += movey[c - 'A'];
            x += movex[c - 'A'];
        }
        return x == 0 && y == 0;
    }
};
static int desyncio = []() { std::ios::sync_with_stdio(false); cin.tie(nullptr); cout.tie(nullptr); return 0; }();
```
## [661. 图片平滑器](https://leetcode-cn.com/problems/image-smoother/)
### 思路
暴力干死这破题
### AC代码
```c++
class Solution {
public:
    vector<vector<int>> imageSmoother(vector<vector<int>>& M) {
        int r = M.size();
        int c = M[0].size();
        if (r <= 1 && c <= 1) return M;
        vector<vector<int>> ans(r, vector<int>(c));
        if (c == 1 || r == 1) {
            if (c == 1) {
                ans[0][0] = (M[0][0] + M[1][0])/2;
                ans[r - 1][0] = (M[r - 1][0] + M[r - 2][0])/2;
                for (int i = 1; i < r - 1; i++) {
                    ans[i][0] = (M[i][0] + M[i - 1][0] + M[i + 1][0])/3;
                }
            } else {
                ans[0][0] = (M[0][0] + M[0][1])/2;
                ans[0][c - 1] = (M[0][c - 1] + M[0][c - 2])/2;
                for (int i = 1; i < c - 1; i++) {
                    ans[0][i] = (M[0][i] + M[0][i - 1] + M[0][i + 1])/3;
                }
            }
            return ans;
        }
        ans[0][0] = (M[0][0] + M[1][1] + M[1][0] + M[0][1])/4;
        ans[0][c - 1] = (M[0][c - 1] + M[0][c - 2] + M[1][c - 1] + M[1][c - 2])/4;
        ans[r - 1][0] = (M[r - 1][0] + M[r-1][1] + M[r - 2][0] + M[r - 2][1])/4;
        ans[r - 1][c - 1] = (M[r - 1][c - 1] + M[r - 1][c - 2] + M[r - 2][c - 1] + M[r - 2][c - 2])/4;
        for (int i = 1; i < r - 1; i++) {
            ans[i][0] = (M[i][0] + M[i - 1][0] + M[i + 1][0] + M[i][1] + M[i - 1][1] + M[i + 1][1])/6;
            ans[i][c - 1] = (M[i][c - 1] + M[i + 1][c - 1] + M[i - 1][c - 1] + M[i][c - 2] + M[i + 1][c - 2] + M[i - 1][c - 2])/6;
        }
        for (int i = 1; i < c - 1; i++) {
            ans[0][i] = (M[0][i] + M[0][i + 1] + M[0][i - 1] + M[1][i] + M[1][i + 1] + M[1][i - 1]) / 6;
            ans[r - 1][i] = (M[r - 1][i] + M[r - 1][i + 1] + M[r - 1][i - 1] + M[r - 2][i] + M[r - 2][i + 1] + M[r - 2][i - 1]) / 6;
        }
        for (int i = 1; i < r - 1; i++) {
            for (int j = 1; j < c - 1; j++) {
                ans[i][j] = (M[i][j] + M[i + 1][j] + M[i - 1][j] + M[i][j + 1] + M[i + 1][j +  1] + M[i - 1][j + 1] + M[i][j - 1] + M[i + 1][j - 1] + M[i - 1][j - 1])/9;
            }
        }
        return ans;
    }
};
static const int _ = []() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    cout.tie(nullptr);
    return 0;
}();
```
