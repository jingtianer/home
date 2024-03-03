---
title: LeetCode-6
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

## [3. 无重复字符的最长子串](https://leetcode-cn.com/problems/longest-substring-without-repeating-characters/)
### 思路
#### 双指针
1. 如果字符串长度为1的话，直接返回1
2. 建立哈希表，储存字符所在的位置（从1开始数）
3. i，j两个指针，i用来遍历字符串（位置靠前），j用来记录当前不重复的字符的位置
4. 每次循环，先查询map中s[i]的位置，如果在j的字符之前，说明从i到j没有重复字符
5. 如果位置在j或j之后，说明出现重复字符，那么先不移动j，`i-j`的值就是一个非重复子串的长度
6. 然后让j指向s[i]的下一个位置，这样就又变成了一个不重复的子串
7. 循环结束，但是最后一次的统计没有记录，再记录一次。
### AC代码
```c++
class Solution {
public:
    int lengthOfLongestSubstring(string s) {
        if (s.length() == 1) return 1;
        unordered_map<char, int> m;
        int len = s.length();
        int count = 0;
        int max = 0;
        int i = 0, j = 0;
        for ( ; i < len; i++) {
            if (m[s[i]] < j + 1) {
                m[s[i]] = i + 1;
            } else {
                count = i - j;
                j = m[s[i]];
                max = max > count ? max : count;
                m[s[i]] = i + 1;
            }
        }
        count = i - j;
        max = max > count ? max : count;
        return max;
    }
};
```

## [8. 字符串转换整数 (atoi)](https://leetcode-cn.com/problems/string-to-integer-atoi/)

### AC代码
```c++
class Solution {
public:
    int myAtoi(string str) {
        int len = str.length();
        int i = 0;
        while(i < len && str[i] == ' ')i++;
        int ans = 0;
        int nage = 1;
        if (i < len && str[i] == '-') {
            nage = -1;
            i++;
        } else if (i < len && str[i] == '+') {
            i++;
        }
        while (i < len && isdigit(str[i])) {
            if (ans*10ll > INT_MAX) return nage == 1 ? INT_MAX : INT_MIN;
            ans *= 10;
            if (ans+(long long)(str[i] - '0') > INT_MAX) return nage == 1 ? INT_MAX : INT_MIN;
            ans += str[i] - '0';
            i++;
        }
        ans *= nage;
        return ans;
    }
};
```

## [11. 盛最多水的容器](https://leetcode-cn.com/problems/container-with-most-water/)

### 思路
#### 双指针
1. 两个指针分别指向首尾
2. 比较两个指针的大小，计算面积
3. 把刚才较小的指针移动一格
### AC代码
```c++
class Solution {
public:
    int maxArea(vector<int>& height) {
        int i = 0, j = height.size() - 1;
        int max = 0, a;
        while (i < j) {
            if (height[i] < height[j]) {
                a = height[i]*(j - i);
                i++;
            } else {
                a = height[j]*(j - i);
                j--;
            }
            max = max > a ? max : a;
        }
        return max;
    }
};
```

## [12. 整数转罗马数字](https://leetcode-cn.com/problems/integer-to-roman/)
### 思路
把所有的符号和对应的数字存起来，然后转化
### AC代码
```c++
class Solution {
public:
    string intToRoman(int num) {
        vector<int> vals = {1000,900,500,400,100,90,50,40,10,9,5,4,1};
		vector<string> romans = {"M", "CM","D","CD","C","XC","L","XL","X","IX","V","IV","I"};
        string ans;
        for (int i = 0; i < 13;i++) {
            while (num >= vals[i]) {
                ans += romans[i];
                num -= vals[i];
            }
        }
        return ans;
    }
};
```
## [19. 删除链表的倒数第N个节点](https://leetcode-cn.com/problems/remove-nth-node-from-end-of-list/)
### 思路
1. vector保存结点地址，然后用数组访问下标愉快的操作
2. 两次遍历，第一次计算链表长度，这样就可以计算出指针移动多少次可以到达要删除的位置，这样就可以删除了
3. 一次遍历，两个指针（a， b）。创建一个哑结点指向头结点，a指向哑结点，b先向后移动n次，然后a，b一起移动，直到b移动到结尾。这样a就移动到了要删除的结点的前面。然后删除。然后返回哑结点的next。

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
    ListNode* removeNthFromEnd(ListNode* head, int n) {
        vector<ListNode*> v;
        ListNode* temp = head;
        while (temp != NULL) {
            v.push_back(temp);
            temp = temp->next;
        }
        int len = v.size();
        if (len == n) {
            temp = head;
            head = head->next;
            delete temp;
            return head;
        }
        temp = v[len - n];
        ListNode* x = v[len - n - 1];
        x->next = temp->next;
        delete temp;
        return head;
    }
};
```
### AC代码
```c++
class Solution {
public:
    ListNode* removeNthFromEnd(ListNode* head, int n) {
        ListNode* temp = head;
        int len = 0;
        while (temp != NULL) {
            temp = temp->next;
            len++;
        }
        int pos = len - n;
        temp = head;
        if (pos) {
            for (int i = 0; i < pos - 1; i++) {
                temp = temp->next;
            }
            ListNode* del = temp->next;
            temp->next = temp->next->next;
            delete del;
        } else {
            head = head->next;
            delete temp;
        }
        return head;
    }
};
```
### AC代码
```c++
class Solution {
public:
    ListNode* removeNthFromEnd(ListNode* head, int n) {
        ListNode *a,  *b = head;
        a = new ListNode(0);//哑结点
        a->next = head;
        head = a;//让head指向哑结点，最后return的接口统一
        for (int i = 0; i < n; i++) {
            b = b->next;//b指针先走
        }
        while (b != NULL) {
            a = a->next;
            b = b->next;
        }
        ListNode* del = a->next;
        a->next = a->next->next;
        delete del;
        return head->next;
    }
};
```

## [31. 下一个排列](https://leetcode-cn.com/problems/next-permutation/)
### 思路
1. 没思路，不过以前用过的代码找出来了
2. 不知道为啥自己写的reverse函数效率比stl的reverse慢
### AC代码
```c++
class Solution {
public:
    void nextPermutation(vector<int>& nums) {
        int len = nums.size();
        int i = len - 1;
        int j = i - 1;
        while (j >= 0 && nums[j] >= nums[j+1]) {
            j--;
        }
        if (j < 0) {
            std::reverse(nums.begin(), nums.end());
            return;
        }
        i = len - 1;
        while (i >= 0 && nums[i] <= nums[j]) {
            i--;
        }
        swap(nums[i], nums[j]);
        std::reverse(nums.begin()+j+1, nums.end());
    }
    void swap(int& a, int& b) {
        int t = a;
        a = b;
        b = t;
    }
    void reverse(vector<int>& nums, int beg, int end) {
        for (int i = beg, j = end - 1; i < j; i++, j--) {
            swap(nums[i], nums[j]);
        }
    }
};
```

```c++
class Solution {
public:
    void nextPermutation(vector<int>& nums) {
        next_permutation(nums.begin(), nums.end());
    }
};
```

## [50. Pow(x, n)](https://leetcode-cn.com/problems/powx-n/)
### 思路
1. 直接算肯定不行的
2. 如果算$x^4$，可以看做是$(x^2)^2$
3. 同样的$x^y = (x^2)^\frac{y}{2}$，以此类推$x^y = (x^{2m})^{\frac{y}{2m}}$
### AC代码
```c++
class Solution {
public:
    double myPow(double x, int n) {
        double ans = 1;
        for (int i = n; i != 0; i /= 2) {
            if (i % 2 != 0) {
                ans *= x;
            }
            x *= x;
        }
        return n < 0 ? 1/ans : ans;
    }
};
```

## [46. 全排列](https://leetcode-cn.com/problems/permutations/)
### 思路
把上次[31. 下一个排列](https://leetcode-cn.com/problems/next-permutation/)的代码复制过来，改一改或者直接调用next_permutation
### AC代码
```c++
class Solution {
public:
    vector<vector<int>> permute(vector<int>& nums) {
        sort(nums.begin(), nums.end());
        vector<vector<int>> ans;
        do {
            ans.push_back(nums);
        } while (nextPermutation(nums));
        return ans;
    }
    bool nextPermutation(vector<int>& nums) {
        int len = nums.size();
        int i = len - 1;
        int j = i - 1;
        while (j >= 0 && nums[j] >= nums[j+1]) {
            j--;
        }
        if (j < 0) {
            std::reverse(nums.begin(), nums.end());
            return false;
        }
        i = len - 1;
        while (i >= 0 && nums[i] <= nums[j]) {
            i--;
        }
        swap(nums[i], nums[j]);
        std::reverse(nums.begin()+j+1, nums.end());
        return true;
    }
};
```
