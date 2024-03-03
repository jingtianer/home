---
title: LeetCode-3
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

## [58. 最后一个单词的长度](https://leetcode-cn.com/problems/length-of-last-word/)

### AC代码

```c++
class Solution {
public:
    int lengthOfLastWord(string s) {
        reverse(s.begin(), s.end());
        stringstream ss(s);
        string buf;
        ss >> buf;
        reverse(buf.begin(), buf.end());
        return buf.length();
    }
};
```

```c++
class Solution {
public:
    int lengthOfLastWord(string s) {
        int count = 0;
        for (int i = s.length() -1 ; i >= 0; i--) {
            if (s[i] != ' ')count++;
            else if (count > 0) break;
        }
        return count;
    }
};
```

## [66. 加一](https://leetcode-cn.com/problems/plus-one/)

### 思路

写一个模拟加法的算法就可以。假设加0，第一次carry（进位）为1

### AC代码

```c++
static const auto __ = []() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    return nullptr;
}();
class Solution {
public:
    vector<int> plusOne(vector<int>& digits) {
        int carry = 1;
        int i = digits.size();
        while (i && carry) {
            int t = digits[i-1] + carry;
            digits[i-1] = t%10;
            carry = t/10;
            i--;
        }
        if (carry) digits.insert(digits.begin(), carry);
        return digits;
    }
};
```

## [67. 二进制求和](https://leetcode-cn.com/problems/add-binary/)

### AC代码

```c++
class Solution {
public:
    string addBinary(string a, string b) {
        if (a.length() > b.length()) {
            b.insert(0, a.length() - b.length(), '0');
        } else if (a.length() < b.length()){
            a.insert(0, b.length() - a.length(), '0');
        }
        int carry = 0;
        for (int i = a.length() - 1; i >= 0; i--) {
            int n = a[i] + b[i] + carry - '0'*2;
            a[i] = n % 2 + '0';
            carry = n/2;
        }
        if (carry) a.insert(0, 1, carry + '0');
        return a;
    }
};
```

#### [69. x 的平方根](https://leetcode-cn.com/problems/sqrtx/)

### AC代码

```c++
class Solution {
public:
    int mySqrt(int x) {
        return sqrt(x);
    }
};
```

### 思路

暴力求解

```c++
class Solution {
public:
    int mySqrt(int x) {
        if (x <= 0) return 0;
        long long cmp = 0;
        long long i = 0;
        while (cmp <= x) {
            i++;
            cmp = i*i;
            if (i > INT_MAX) {
                i = INT_MIN;
            }
            if (i < INT_MIN) {
                i = INT_MAX;
            }
        }
        return i - 1;
    }
};
```

### 思路

牛顿迭代法
xn+1 = xn - f(xn) / f'(xn);

### AC代码

```c++
class Solution {
public:
    double fx(double x,double n) {
        return x*x - n;
    }
    double dfxdx(double x) {
        return 2*x;
    }
    int mySqrt(int n) {
        double x = 0.01;
        double exp = 0.01;
        double temp = 1;
        while (fabs(x - temp) > exp) {
            temp = x;
            x = x - fx(x, n)/dfxdx(x);
        }
        return x;
    }
};
```

## [88. 合并两个有序数组](https://leetcode-cn.com/problems/merge-sorted-array/)

### 思路

遍历nums2，对于每一个元素，查找比它大的元素，插入

### AC代码

```c++
class Solution {
public:
    void merge(vector<int>& nums1, int m, vector<int>& nums2, int n) {
        int count = 0;
        for (int i = 0, j = 0; i < nums2.size(); i++) {
            while (j < m && nums2[i] > nums1[j])j++;
            nums1.insert(nums1.begin() + j, nums2[i]);
            count++;
            m++;
        }
        nums1.erase(nums1.end() - count, nums1.end());
    }
};
```

### 思路

三个指针a，b，c，分别指向m+n-1,m-1,n-1

a开始向前遍历，比较另外两个指针的值，把较大的那个赋值给a，然后较大的指针前移

### AC代码

```c++
class Solution {
public:
    void merge(vector<int>& nums1, int m, vector<int>& nums2, int n) {
        if (!m) {
            for (int i = 0; i < n; i++) {
                nums1[i] = nums2[i];
            }
            return;
        }
        if (!n) return;
        int i = n + m - 1, j = m - 1, k = n - 1;

        while (j >= 0 && k >= 0) {
            nums1[i--] = nums1[j] > nums2[k] ? nums1[j--] : nums2[k--];    
        }

        if (j != - 1) {
            while (j >= 0) {
                nums1[i--] = nums1[j--];
            }
        }
        if (k != - 1) {
            while (k >= 0) {
                nums1[i--] = nums2[k--];
            }
        }
    }
};
```

## [100. 相同的树](https://leetcode-cn.com/problems/same-tree/)

真没想到从来没接触过树的我居然一遍过了

### 思路

深度优先遍历，先递归调用，访问所有节点

- 遇到结束时，为null，则比较两个是不是都是null，如果不是，说明树的形状不一样

- 叶子节点返回后，比较上一节点的值，相同返回true，最后达到函数结尾的一律返回false（值不一样或者形状不一样）

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
    bool isSameTree(TreeNode* p, TreeNode* q) {
        if (p == NULL || q == NULL) return q == p;
        if (isSameTree(p->left, q->left) && isSameTree(p->right, q->right)) {
            if (p->val == q->val) {
                return true;
            }
        }
        return false;
    }
};
```
## [21. 合并两个有序链表](https://leetcode-cn.com/problems/merge-two-sorted-lists/)

### 思路
跟[88. 合并两个有序数组](https://leetcode-cn.com/problems/merge-sorted-array/)的思路是一样样的，不过由于用指针，所以最后处理末尾数据的时候，可以直接把多出来的一截赋值给上一个节点的next

### AC代码
```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
static const auto __ = []() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    return nullptr;
}();
class Solution {
public:
    ListNode* mergeTwoLists(ListNode* l1, ListNode* l2) {
        ListNode *head, *temp, *temp1;
        if (l1 == NULL) return l2;
        if (l2 == NULL) return l1;
        temp = head = new ListNode(0);
        while (l2 != NULL && l1 != NULL) {
            if (l1->val > l2->val) {
                temp->next = l2;
                l2 = l2->next;
            } else {
                temp->next = l1;
                l1 = l1->next;
            }
            temp = temp->next;
        }
        if (l1 != NULL) {
            temp->next = l1;
        }
        if (l2 != NULL) {
            temp->next = l2;
        }
        return head->next;
    }
};
```

## [118. 杨辉三角](https://leetcode-cn.com/problems/pascals-triangle/)
大一必会题，但是题解里说这个也属于动态规划
### AC代码
```c++
class Solution {
public:
    vector<vector<int>> generate(int numRows) {
        vector<vector<int>> ans;
        for (int i = 0; i < numRows; i++) {
            vector<int> line;
            for (int j = 0; j < i + 1; j++) {
                if (j == 0 || j == i) {
                    line.push_back(1);
                } else {
                    line.push_back(ans[i-1][j] + ans[i-1][j-1]);   
                }
            }
            ans.push_back(line);
            line.clear();
        }
        return ans;
    }
};
```

## [119. 杨辉三角 II](https://leetcode-cn.com/problems/pascals-triangle-ii/)

### 思路（空间复杂度为O(K)）的算法
利用组合数的对称性
```c++
class Solution {
public:
    vector<int> getRow(int rowIndex) {
        vector<int> ans(rowIndex + 1);
        for (int i = 0; i < rowIndex+1; i++) {
            for (int j = 0; j < i / 2 + 1; j++) {
                if (j == 0) {
                    ans[j] = 1;
                } else {
                    ans[j] = ans[j] + ans[i - j];   
                }
            }
            for (int j = i / 2 + 1; j < i + 1; j++) {
                ans[i - (j - (i/2+1))] = ans[j - (i/2+1)];
            }
        }
        return ans;
    }
};
```

## [121. 买卖股票的最佳时机](https://leetcode-cn.com/problems/best-time-to-buy-and-sell-stock/)

### 思路
画出售价的`时间 - 价格`图，关注波峰和波谷
如果现在的值小于当前的最小值，则把当前值作为最小值，如果大于最小值，那么计算当前值与最小值的差，如果大于当前利润，则作为最新利润。

### AC代码
```c++
class Solution {
public:
    int maxProfit(vector<int>& prices) {
        int min = INT_MAX;
        int profit = 0;
        for (int i = 0; i < prices.size(); i++) {
            if (prices[i] < min) min = prices[i];
            else 
                if (profit < prices[i] - min)
                    profit = prices[i] - min;
        }
        return profit;
    }
};
```

## [122. 买卖股票的最佳时机 II](https://leetcode-cn.com/problems/best-time-to-buy-and-sell-stock-ii/)

### 思路
找相邻波峰和波谷，波谷买入，波峰售出
大循环遍历数组，内层第一个循环找波谷，下一个循环找波峰
然后波峰波谷相减，加到profit上

```c++
class Solution {
public:
    int maxProfit(vector<int>& prices) {
        if (!prices.size()) return 0;
        int i = 0, peak, valley, profit = 0;
        for (; i <  prices.size() - 1; ) {
            while (i < prices.size() - 1 && prices[i] >= prices[i + 1])
                i++;
            valley = prices[i];
            while (i < prices.size() - 1 && prices[i] <= prices[i + 1])
                i++;
            peak = prices[i];
            profit += peak - valley;
        } 
        return profit;
    }
};
```

## [136. 只出现一次的数字](https://leetcode-cn.com/problems/single-number/)

### 思路

利用异或运算的性质（同为0，不同为1）

### AC代码
```c++
class Solution {
public:
    int singleNumber(vector<int>& nums) {
        int n = 0;
        for (auto num : nums) {
            n ^= num;
        }
        return n;
    }
};
```

## [125. 验证回文串](https://leetcode-cn.com/problems/valid-palindrome/)

### 思路
把是字符的存起来，然后复制反转一份，然后比较

### AC代码

```c++
class Solution {
public:
    bool isPalindrome(string s) {
        string temp, cmp;
        for(int i = 0; i < s.length(); i++) {
            if(isalpha(s[i]) || isdigit(s[i])) {
                temp += tolower(s[i]);
                cmp += tolower(s[i]);
            }
        }
        reverse(cmp.begin(), cmp.end());
        return cmp == temp;
    }
};
```
## [141. 环形链表](https://leetcode-cn.com/problems/linked-list-cycle/)
### 哈希表
```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    bool hasCycle(ListNode *head) {
        map<ListNode*, int> m;
        ListNode* temp = head;
        while (temp != NULL) {
            if (m[temp] >= 2) {
                return true;
            }
            m[temp]++;
            temp = temp->next;
        }
        return false;
};
```
### 思路
#### 双指针
一个指针一次后移一个，一个指针后移两次，如果快的那个先到终点，说明没有环，如果快的追上，慢的，说明一定有环
```c++
class Solution {
public:
    bool hasCycle(ListNode *head) {
        ListNode *slow, *fast;
        slow = fast = head;
        while (slow != NULL) {
            slow = slow->next;
            if (fast != NULL && fast->next != NULL)
            fast = fast->next->next;
            else break;
            if (slow == fast) {
                return true;
            }
        }
        return false;
    }
};
```
## [155. 最小栈](https://leetcode-cn.com/problems/min-stack/)

### AC代码

```c++
class MinStack {
public:
    /** initialize your data structure here. */
    vector<int> data;
    multiset<int> min;
    MinStack() {
    }
    
    void push(int x) {
        data.push_back(x);
        min.insert(x);
    }
    
    void pop() {
        min.erase(find(min.begin(), min.end(), *(data.end() - 1)));
        data.erase(data.end() - 1);
    }
    
    int top() {
        return *(data.end() - 1);
        return 0;
    }
    
    int getMin() {
        return *(min.begin());
        return 0;
    }
};

/**
 * Your MinStack object will be instantiated and called as such:
 * MinStack obj = new MinStack();
 * obj.push(x);
 * obj.pop();
 * int param_3 = obj.top();
 * int param_4 = obj.getMin();
 */
```

### AC代码

```c++
class MinStack {
public:
    stack<int> data;
    stack<int> min;
    MinStack() {
        
    }
    
    void push(int x) {
        data.push(x);
        if (min.empty() || x <= min.top()) {//要等号
            min.push(x);
        } 
    }
    
    void pop() {
        int p = data.top();
        data.pop();
        if (p == min.top()) {
            min.pop();
        }
    }
    
    int top() {
        return data.top();
    }
    
    int getMin() {
        return min.top();
    }
};
```

### [160. 相交链表](https://leetcode-cn.com/problems/intersection-of-two-linked-lists/)

### 思路
#### 双指针
1. 两个指针，初始化分别指向链表A、B
2. 如果两个指针不相等，一直循环以下动作
   1. AB指针各自向后移动一格
   2. 当某一个指针到大末尾时，指向对方链表的头
3. 最后循环退出，如果结果是NULL表示没有相交

### AC代码
```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    ListNode *getIntersectionNode(ListNode *headA, ListNode *headB) {
        ListNode *l1 = headA, *l2 = headB;
        while (l1 != l2) {
            if (l1 != NULL) {
                l1 = l1->next;
            } else {
                l1 = headB;
            }
            if (l2 != NULL) {
                l2 = l2->next;
            } else {
                l2 = headA;
            }
        }
        return l1;
    }
};
```

## [167. 两数之和 II - 输入有序数组](https://leetcode-cn.com/problems/two-sum-ii-input-array-is-sorted/)

### 思路
#### 双指针
一个指向开头，一个指向结束
相加大于target，后面的前移
相加小于target，前面的后移
等于，返回下标

### AC代码
```c++
class Solution {
public:
    vector<int> twoSum(vector<int>& numbers, int target) {
        int i = 0, j = numbers.size() - 1;
        vector<int> &v = numbers;
        while (i < j) {
            if (v[i] + v[j] > target) j--;
            else if (v[i] + v[j] < target) i++;
            else return {i + 1, j + 1};
        }
        return {};
    }
};
```

## [168. Excel表列名称](https://leetcode-cn.com/problems/excel-sheet-column-title/)

### 思路
#### 递归
- 首先`n--`
- 如果`n`在`0 - 25`，返回对应字母
- 否则先返回`n%26`的对应的字母，再返回`n/26+1`对应的字母
- ps：写完看了评论才反应过来，是转换26进制的问题，手动笑哭

### AC代码
```c++
class Solution {
public:
    string convertToTitle(int n) {
        string ans;
        n--;
        if (n / 26 > 0) {
            ans += convertToTitle(n/26);
            ans += convertToTitle(n%26 + 1);
        } else {
            return string(1 ,(char)('A' + n));
        }
        return ans;
    }
};
```

