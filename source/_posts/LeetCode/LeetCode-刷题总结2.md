---
title: LeetCode-2
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

## [20. 有效的括号](https://leetcode-cn.com/problems/valid-parentheses/)

### 思路
1. 创建一个栈
2. 遍历字符串
   1. 如果是左半部分，把这个字符压栈
   2. 如果是右半部分，先看一下栈顶元素和它是否配对，如果配对，弹栈，不配对，结束，返回false
3. 字符串遍历结束后，看栈是否已经空了，如果没空，说明左右括号数量不对应false
### AC代码
```c++
static const auto __ = []() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	return nullptr;
}();
class Solution {
public:
    bool isValid(string s) {
        int p[128] = {0};
        p['('] = ')'; p[')'] = 0;
        p['['] = ']'; p[']'] = 0;
        p['{'] = '}'; p['}'] = 0;
        stack<char> sta;
        for (int i = 0; i < s.length(); i++) {
            if (p[s[i]]) {
                sta.push(s[i]);
            } else {
                if (sta.empty() || p[sta.top()] != s[i]) return false;
                sta.pop();
            }
        }
        return sta.empty();
    }
};
```
#### [26. 删除排序数组中的重复项](https://leetcode-cn.com/problems/remove-duplicates-from-sorted-array/)

### 第一次AC代码

```c++
class Solution {
public:
    int removeDuplicates(vector<int>& nums) {
        nums.erase(unique(nums.begin(), nums.end()), nums.end());
        return nums.size();
    }
};
```

我知道这样很不道德，所以

### 思路
- 双指针法
- 一个数用来遍历一遍数组，一个用来记录当前不重复的数的位置
- 每次循环把j指向的数赋值给i
- 当j指向的数与当前数不等的时候，i++，这样下一个不重复的数放到了它的后面

### 第二次AC代码

```c++
class Solution {
public:
    int removeDuplicates(vector<int>& nums) {
        if (!nums.size()) return 0;
        int i = 0;
        for (int j = 1; j < nums.size(); j++) {
            if (nums[i] != nums[j])
                i++;
            nums[i] = nums[j];
        }
        return i + 1;
    }
};
```

## [27. 移除元素](https://leetcode-cn.com/problems/remove-element/)

### 思路1
类似上一题的双指针法
i用于循环变量
当i指向的值不是要删除的元素时，把i的值赋值给当前的j，j再自增
每次循环，i自增

### 思路2
把要删除的值移动到数组的末尾
1. 一个n，记录数组的长度
2. 遍历数组，每找到一个要删除的值，把它和`n-1`指向的元素赋值给它，数组长度n自减，这个时候指针不要移动，因为要判断刚才末尾的那个数是不是也是要删除的

### 思路3
iterator遍历，调用vector的erase直接删

### AC代码（从上到下依次是三个思路）

```c++
class Solution {
public:
    int removeElement(vector<int>& nums, int val) {
        int j = 0;
        for (int i = 0; i < nums.size(); i++) {
            if (nums[i] != val) {
                nums[j] = nums[i];
                j++;
            }
            
        }
        return j;
    }
};
```
```c++
class Solution {
public:
    int removeElement(vector<int>& nums, int val) {
        int n = nums.size();
        int i = 0;
        while (i < n) {
            if (nums[i] == val) {
                nums[i] = nums[n-1];
                n--;
            } else {
                i++;
            }
        }
        return n;
    }
};
```
```c++
class Solution {
public:
    int removeElement(vector<int>& nums, int val) {
        for (vector<int>::iterator i = nums.begin(); i != nums.end(); i++) {
            if (*i == val) {
                nums.erase(i);
                i--;
            }
        }
        return nums.size();
    }
};
```
## [28. 实现strStr()](https://leetcode-cn.com/problems/implement-strstr/)

### AC代码

```c++
class Solution {
public:
    int strStr(string haystack, string needle) {
        if (!needle.length()) return 0;
        if (haystack.length() < needle.length()) return -1;
        int n = needle.length();
        for (int i = 0; i < haystack.length() - n + 1; i++) {
            if (haystack.substr(i, n) == needle) {
                return i;
            }
        }
        return -1;
    }
};
```

## [35. 搜索插入位置](https://leetcode-cn.com/problems/search-insert-position/)

### 思路
就是遍历搜索+插入排序，两个算法混合起来就完了

### AC代码

```c++
class Solution {
public:
    int searchInsert(vector<int>& nums, int target) {
        if (target > *(nums.end() - 1)) {
            nums.insert(nums.end(), target);
            return nums.size() - 1;
        }
        for (int i = 0; i < nums.size(); i++) {
            if (nums[i] >= target) {
                if (nums[i] > target) {
                    nums.insert(nums.begin() + i, target);
                }
                return i;
            }
        }
        return nums.size();
    }
};
```

## [38. 报数](https://leetcode-cn.com/problems/count-and-say/)

### 思路
和之前的[1084 外观数列(PAT (Basic Level) Practice)](https://www.jianshu.com/p/50eb9fdf36aa)是一样的，不同点是外观数列是a有x个，这道题是x个a


### AC代码

```c++
static const auto __ = []() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	return nullptr;
}();
class Solution {
public:
    string countAndSay(int n) {
        return ItWasPAT(n);
    }
    
    void add(string& str, char c, int& n) {
        char toNum[1024] = {0};
        sprintf(toNum, "%d", n);
        str.append(toNum);
        str.append(&c, 1);
        n = 0;
    }
    string ItWasPAT (int n) {
        string d = "1";
        string& temp = d;
        for (int i = 0, count = 1; i < n - 1; i++, count = 1) {
            string next = "";
            for (int j = 1; j < temp.length(); j++, count++)
                if (temp[j - 1] != temp[j])
                    add(next, temp[j - 1], count);
            add(next, temp[temp.length() - 1], count);
            temp = next;
        }
        return temp;
    }
};
```

## [53. 最大子序和](https://leetcode-cn.com/problems/maximum-subarray/)

### 思路
这道题不会，直接抄的评论区代码。大一上，还没学动态规划

### AC代码
```c++
class Solution {
public:
    int maxSubArray(vector<int>& nums) {
        if (!nums.size()) return 0;
        int ans = nums[0];
        int sum = nums[0];
        for (int i = 1; i < nums.size(); i++) {
            if (sum > 0) sum += nums[i];
            else sum = nums[i];
            ans = ans < sum ? sum : ans;
        }
        return ans;
    }
};
```
## [83. 删除排序链表中的重复元素](https://leetcode-cn.com/problems/remove-duplicates-from-sorted-list/)

### 思路
1. 链表是有序的
2. 两个指针，一个指针i指向不重复的位置，一个j用来遍历
3. 当j的值和i不一样时，让i的next指向j的next，j再往后移，由于这时候要访问j->next，要判断是否为NULL，如果是的话，说明结束了，让i->next为NULL
4. 这时不要移动i，最后几个元素重复的话，这样会非法访问
5. 这个算法放在java上更好，因为这样做没有delete，内存泄漏可是重罪

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
    ListNode* deleteDuplicates(ListNode* head) {
        if (head == NULL) return NULL;
        ListNode *i = head, *j = head->next;
        int n = 0;
        while (j != NULL) {
            if (i->val == j->val) {
                if (j->next != NULL) {
                    i->next = j->next;
                    j = j->next;
                } else {
                    i->next = NULL;
                    break;
                }
            } else {
                i = j;
                j = j->next;
            }
        }
        return head;
    }
};
```

### AC代码（内存不泄漏版本）

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
    ListNode* deleteDuplicates(ListNode* head) {
        ListNode *i = head, *de;
        if (i == NULL || i->next == NULL) return head;
        while (i->next != NULL) {
            if (i->val == i->next->val) {
                de = i->next;
                i->next = i->next->next;
                delete de;
            } else {
                i = i->next;
            }
        }
        return head;
    }
};
```
