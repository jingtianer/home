---
title: LeetCode-单调栈
date: 2023-12-22 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## [739. 每日温度](https://leetcode.cn/problems/daily-temperatures/description/?utm_source=LCUS&utm_medium=ip_redirect&utm_campaign=transfer2china)

- 简单，通过单调栈，弹出栈中小于当前元素的元素，可以找到弹出元素的第一个大于其的位置

```c++
class Solution {
public:
    vector<int> dailyTemperatures(vector<int>& temperatures) {
        stack<int> monoStk;
        int len = temperatures.size();
        vector<int> res(len);
        for(int i = 0; i < len; i++) {
            while(!monoStk.empty() && temperatures[monoStk.top()] < temperatures[i]) {
                int top = monoStk.top();
                res[top] = i - top;
                monoStk.pop();
            }
            monoStk.push(i);
        }
        return res;
    }
};
```

## [42. 接雨水](https://leetcode.cn/problems/trapping-rain-water/description/)

### AC1

#### 思路

- 构造了一个这样的测试用例
```c++
vector<int> testcase = {3,2,1,0,1,2,1,0,1,3};
// |                 |
// | |       |       |
// | | | _ | | | _ | |
```
- 如果构造一个递增的栈，那么栈顶元素比我大时，就要把他们全弹出，显然不合理
- 构造一个递减的栈，从栈顶弹出小于当前长度的元素，那么被弹出的区间内能装水的最大量就是`min(i, top) - height[j]`
- 这样虽然用了单调栈，但复杂度还是高


#### 代码

```c++
class Solution {
public:
    int trap(vector<int>& height) {
        int len = height.size();
        stack<int> monoStk;
        vector<int> rain(len, 0);
        for(int i = 0; i < len; i++) {
            int top = len;
            while(!monoStk.empty() && height[monoStk.top()] < height[i]) {
                top = monoStk.top();
                monoStk.pop();
            }
            if(!monoStk.empty()) top = monoStk.top();
            for(int j = top; j < i; j++) {
                rain[j] = min(height[top], height[i]);
            }
            monoStk.push(i);
        }
        int rainSum = 0;
        for(int i = 0; i < len; i++) {
            if(rain[i] > height[i]) {
                rainSum += rain[i] - height[i];
            }
        }
        return rainSum;
    }
};

// |                 |
// | |       |       |
// | | | _ | | | _ | |
```

### 优化

- 如何在弹栈过程中计算接水量呢
- i把x弹出后，此时top（若存在）与i就是两个墙壁，取其最小值，减去被弹栈元素的高度，乘以宽度，就是两个墙壁之间的储水量
- 如果有更高的两面墙将其包围，由于单调栈的性质，计算的是墙与被弹元素的差值，不会重复计算底部的雨水

```c++
class Solution {
public:
    int trap(vector<int>& height) {
        int len = height.size();
        int rainSum = 0;
        stack<int> monoStk;
        for(int i = 0; i < len; i++) {
            int top = len;
            while(!monoStk.empty() && height[monoStk.top()] < height[i]) {
                top = monoStk.top();
                monoStk.pop();
                if (monoStk.empty()) {
                    break;
                }
                int left = monoStk.top();
                int currWidth = i - left - 1;
                int currHeight = min(height[left], height[i]) - height[top];
                rainSum += currWidth * currHeight;
            }
            monoStk.push(i);
        }
        return rainSum;
    }
};
```

## [456. 132 模式](https://leetcode.cn/problems/132-pattern/description/)

### 思路

- 已知这道题用单调栈，但是构造递增的栈还是递减栈呢，so hard to tell
- 通过尝试，最后使用递减栈
- 将小于当前元素的所有栈內元素弹出后，如果栈内还存在元素，则满足`nums[k] < nums[j]` (当前元素是`nums[k]`)
- 现在只要保证`nums[j]`左侧存在元素`nums[i] < nums[k]`，开一个数组保存当前最小值即可

### ac代码

```c++
class Solution {
public:
    bool find132pattern(vector<int>& nums) {
        int len = nums.size();
        stack<int> monoStack;
        vector<int> minArr(len + 1, INT_MAX);
        for(int i = 1; i <= len; i++) {
            minArr[i] = min(minArr[i-1], nums[i-1]);
        }
        for(int i = 0; i < len; i++) {
            while(!monoStack.empty() && nums[monoStack.top()] <= nums[i]) {
                monoStack.pop();
            }
            if(!monoStack.empty()) {
                int top = monoStack.top();
                if(nums[i] > minArr[top]) {
                    return true;
                }
            }
            monoStack.push(i);
        }
        return false;
    }
};
```

## [581. 最短无序连续子数组](https://leetcode.cn/problems/shortest-unsorted-continuous-subarray/description/)

### 思路
- 创建一个单调递增栈，当有元素被弹出时，说明后面的元素被放到前面了，当前元素下标和栈顶元素下标需要被排序
- 由于题目要求一个最大的连续子数组，所以要求下标的最大范围
- 对于特殊情况，即数组中有连续相等的数字时，需要判断这些元素是否也需要参与排序，即增大子数组的范围
- 需要记录被弹出元素的最大值，如果小于它，则需要参与排序。


### 代码
```c++
class Solution {
public:
    int findUnsortedSubarray(vector<int>& nums) {
        stack<int> monoStk;
        int len = nums.size(), l = len, r = -1;
        int maxPop = INT_MIN;
        for(int i = 0; i < len; i++) {
            while(!monoStk.empty() && nums[monoStk.top()] > nums[i]) {
                l = min(l, monoStk.top());
                r = i;
                maxPop = max(maxPop, nums[monoStk.top()]);
                monoStk.pop();
            }
            monoStk.push(i);
        }
        while(!monoStk.empty()) {
            if(nums[monoStk.top()] < maxPop) r = max(r, monoStk.top());
            monoStk.pop();
        }
        return max(r - l + 1, 0);
    }
};
```

## [654. 最大二叉树](https://leetcode.cn/problems/maximum-binary-tree/description/)

### 笨蛋做法

```c++
class Solution {
public:
    TreeNode* constructMaximumBinaryTree(vector<int> nums) {
        if(nums.size() == 0) return nullptr;
        auto max_ite = max_element(nums.begin(), nums.end());
        TreeNode *node = new TreeNode(*max_ite);
        node->left = constructMaximumBinaryTree({nums.begin(), max_ite});
        node->right = constructMaximumBinaryTree({++max_ite, nums.end()});
        return node;
    }
};
```

### 笨蛋方法2

```c++
class Solution {
public:
    TreeNode* constructMaximumBinaryTree(vector<int> nums) {
        int len = nums.size();
        auto cmp = [&nums](int i, int j) { return nums[i] < nums[j]; };
        priority_queue<int, vector<int>, decltype(cmp)> q(cmp);
        for(int i = 0; i < len; i++) {
            q.push(i);
        }
        map<TreeNode*, int> m;
        TreeNode *root = nullptr;
        if(!q.empty()) {
            int top = q.top();
            root = new TreeNode(nums[top]);
            m[root] = top;
            q.pop();
        }
        while(!q.empty()) {
            int top = q.top();
            q.pop();
            TreeNode *node = root, *p = nullptr;
            while(node) {
                p = node;
                if(m[node] < top) {
                    node = node->right;
                } else {
                    node = node->left;
                }
            }
            if(p) {
                TreeNode *tmp = new TreeNode(nums[top]);
                m[tmp] = top;
                if(m[p] < top) {
                    p->right = tmp;
                } else {
                    p->left = tmp;
                }
            }
        }
        return root;
    }
};
```

### 单调栈

#### 思路
![testcase](https://assets.leetcode.com/uploads/2020/12/24/tree1.jpg)
> `[3,2,1,6,0,5]`

- 观察这个测试用例生成的二叉树
- 如果构造一个递减的单调栈，在6进入前，从栈顶开始栈內元素依次为
  - `[1,2,3]`
- 6入栈时，会将他们三个弹出，他们三个刚好依次为下一个的右子树
- 6入栈后，被弹出的最后一个元素为6的左子树
- 观察6的右子树，发现也满足这个规律
- 尝试利用这个规律编码，果然对了！！哈哈，开心

#### 代码

```c++
class Solution {
public:
    TreeNode* constructMaximumBinaryTree(vector<int> nums) {
        nums.push_back(INT_MAX);
        int len = nums.size();
        stack<int> monoStack;
        vector<TreeNode *> nodes(len);
        for(int i = 0; i < len; i++) {
            nodes[i] = new TreeNode(nums[i]);
        }
        for(int i = 0; i < len; i++) {
            int top = len;
            while(!monoStack.empty() && nums[monoStack.top()] < nums[i]) {
                top = monoStack.top();
                monoStack.pop();
                if(!monoStack.empty() && nums[monoStack.top()] < nums[i]) {
                    nodes[monoStack.top()]->right = nodes[top]; 
                }
            }
            if(top < len) nodes[i]->left = nodes[top];
            monoStack.push(i);
        }
        TreeNode *root = nodes.back();
        return root->left;
    }
};
```

## [769. 最多能完成排序的块](https://leetcode.cn/problems/max-chunks-to-make-sorted/description/)

- wow amazing！`^v^`
- 

```c++
class Solution {
public:
    int maxChunksToSorted(vector<int>& arr) {
        int len = arr.size(), ret = 0;
        stack<int> monoStack;
        for(int i = 0; i < len; i++) {
            int top = !monoStack.empty() && monoStack.top() > arr[i] ? monoStack.top() : -1;
            while(!monoStack.empty() && monoStack.top() > arr[i]) {
                monoStack.pop();
            }
            if(top != -1) monoStack.push(top);
            else monoStack.push(arr[i]);
        }
        return monoStack.size();
    }
};
```

## [768. 最多能完成排序的块 II](https://leetcode.cn/problems/max-chunks-to-make-sorted-ii/description/)

- yes, yes, yes, you no 看错，和上一题相同的代码
- amazing! wow! `^v^#`


```c++
class Solution {
public:
    int maxChunksToSorted(vector<int>& arr) {
        int len = arr.size(), ret = 0;
        stack<int> monoStack;
        for(int i = 0; i < len; i++) {
            int top = !monoStack.empty() && monoStack.top() > arr[i] ? monoStack.top() : -1;
            while(!monoStack.empty() && monoStack.top() > arr[i]) {
                monoStack.pop();
            }
            if(top != -1) monoStack.push(top);
            else monoStack.push(arr[i]);
        }
        return monoStack.size();
    }
};
```

## [901. 股票价格跨度](https://leetcode.cn/problems/online-stock-span/description/)

- 我太聪明啦，几分钟就写出来啦
- 创建一个递减栈，将小于它的数全都弹出，此时与栈顶的距离就是span

```c++
class StockSpanner {
    stack<pair<int, int>> monoStack;
    int day = 0;
public:
    StockSpanner() {
    }
    
    int next(int price) {
        day++;
        while(!monoStack.empty() && monoStack.top().second <= price) {
            monoStack.pop();
        }
        int span = day;
        if(!monoStack.empty()) {
            span = day - monoStack.top().first;
        }
        monoStack.emplace(day, price);
        return span;
    }
};

/**
 * Your StockSpanner object will be instantiated and called as such:
 * StockSpanner* obj = new StockSpanner();
 * int param_1 = obj->next(price);
 */
```

## [907. 子数组的最小值之和](https://leetcode.cn/problems/sum-of-subarray-minimums/description/)


### 单调栈

- 我真聪明！！！！！
- 用单调栈找到当前元素左右两侧第一个比他小的元素位置，分别记录到`left[i]`, `right[i]`
- 由元素`arr[i]`为最小值的子数组个数为
  - `(right[i] - i + 1l) * (i - left[i] + 1l)`
- 由于构造的是递减栈，为了防止~~世界被破坏~~比被弹出元素更大的元素已经被弹出了，赋值时使用被弹出元素的`left`/`right`


```c++
class Solution {
    static constexpr int MOD = 1000000007;
public:
    int sumSubarrayMins(vector<int>& arr) {
        stack<int> monoStack;
        int len = arr.size();
        int res = 0;
        vector<int> left(len), right(len, len - 1);
        for(int i = 0; i < len; i++) {
            left[i] = right[i] = i;
            while(!monoStack.empty() && arr[monoStack.top()] >= arr[i]) {
                int top = monoStack.top();
                left[i] = left[top];
                monoStack.pop();
            }
            monoStack.push(i);
        }
        monoStack = move(stack<int>());
        for(int i = len - 1; i >= 0; i--) {
            while(!monoStack.empty() && arr[monoStack.top()] > arr[i]) {
                int top = monoStack.top();
                right[i] = right[top];
                monoStack.pop();
            }
            monoStack.push(i);
        }
        for(int i = 0; i < len; i++) {
            res = (res + (right[i] - i + 1l) * (i - left[i] + 1l) * arr[i]) % MOD;
        }
        return res;
    }
};
```