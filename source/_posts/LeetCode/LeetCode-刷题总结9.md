---
title: LeetCode-9
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

## [92. 反转链表 II](https://leetcode-cn.com/problems/reverse-linked-list-ii/)
### 思路
1. 两个指针a、b，分别找到被反转的第一个结点的前一个结点，被反转的结点的最后一个结点，（在开头设置一个哑结点，防止被反转的第一个结点是头结点）
2. 再来一个指针c，保存被反转的最后一个结点的next，然后把最后一个结点的next设为null
3. 反转链表，然后把新链表的head接回去，把c接回到末尾
4. 返回哑结点的next，不能返回head，因为反转以后，head有可能不是head了

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
    ListNode* reverseBetween(ListNode* head, int m, int n) {
        ListNode* dummy = new ListNode(0), *a, *b, *c;
        dummy->next = head;
        a = b = c = dummy;
        for (int i = 0; i < m - 1; i++) {
            a = a->next;
            b = b->next;
        }
        for (int i = 0; i < n - m + 1; i++) {
            b = b->next;
        }
        c = b->next;
        b->next = NULL;
        a->next = reverseList(a->next);
        while (a->next != NULL) {
            a = a->next;
        }
        a->next = c;
        return dummy->next;
    }
    ListNode* reverseList(ListNode* head) {
        if (head == NULL || head->next == NULL) return head;
        ListNode *temp = reverseList(head->next);
        head->next->next = head;
        head->next = NULL;
        return temp;
    }
};
```

## [15. 三数之和](https://leetcode-cn.com/problems/3sum/)

### 思路
1. 遍历数组，取每个值的相反数作为target，然后转化为两数之和的问题，去重时要注意
   1. 保证target只查找一次
   2. 保证第二个循环j = i + 1开始
   3. 保证查找到的数的下标 c  > j
   4. 保证第二次循环的相同元素对应的值不会被反复查找，即变量find

### AC代码
```c++
class Solution {
public:
    vector<vector<int>> threeSum(vector<int>& nums) {
        sort(nums.begin(), nums.end());
        int len = nums.size();
        vector<vector<int>> ans;
        map<int, int> m;
        for (int i = 0; i < len; i++) {
            m[nums[i]] = i + 1;
        }
        for (int i = 0; i < len; ) {
            int target = -nums[i];
            for (int j = i + 1; j < len;) {
                int find = target - nums[j];
                if (m.count(find)) {
                    int c = m[find] - 1;
                    //cout << nums[i] << nums[j] << nums[c] << endl;
                    if (c > j) {
                        ans.push_back({nums[i], nums[j], nums[c]});
                    }
                }
                while (j < len && nums[j] == target - find) {
                    j++;
                }
            }
            while (i < len && nums[i] == -target) {
                i++;
            }
        }
        return ans;
    }
};
```
### 大佬思路
#### 二分查找
### 大佬代码
```c++
class Solution {
public:
    vector<vector<int>> threeSum(vector<int>& nums) {
        set<vector<int>> ans;
        if(nums.size()<3)return vector<vector<int>>(ans.begin(),ans.end());
        sort(nums.begin(),nums.end());
        int left,right,target;
        for(int i=0;i<nums.size()-2;++i){
            if(nums[i] > 0)
            {
                break;
            }
            if(nums[i] == nums[i - 1] && i > 0)
               continue;
            left=i+1,right=nums.size()-1,target=-nums[i];
            while(left<right){
                if(nums[left]+nums[right]==target){
                    ans.insert({nums[i], nums[left], nums[right]});
                    ++left;
                    --right;
                }else if(nums[left]+nums[right]>target){
                    --right;
                }else {
                    ++left;
                }
            }
        }
        return vector<vector<int>>(ans.begin(),ans.end());
    }
};
```

## [43. 字符串相乘](https://leetcode-cn.com/problems/multiply-strings/)
### 思路
两层for循环相乘，把相乘的结果全都加起来
### AC代码
```c++
class Solution {
public:
    string multiply(string num1, string num2) {
        int len1 = num1.length(), len2 = num2.length();
        int len = len1 > len2 ? len1 : len2;
        string zero(len - len1, '0');
        num1 = zero + num1;
        zero = string(len - len2, '0');
        num2 = zero + num2;
        string ans = "0";
        for (int i = len - 1; i >= 0; i--) {
            string temp = num1;
            int carry = 0;
            zero = string(len - 1 - i, '0');
            for (int j = len - 1; j >= 0; j--) {
                temp[j] = ((num1[j] - '0')*(num2[i] - '0') + carry)%10+ '0';
                carry = ((num1[j] - '0')*(num2[i] - '0') + carry)/10;
            }
            temp = string(1, carry + '0') + temp + zero;
            ans = addStrings(ans, temp);
            
        }
        int i = 0;
        while (ans[i] == '0') i++;
        len = ans.length();
        return i == len ? "0" : ans.substr(i, len - i);
    }
    string addStrings(string& num1, string& num2) {
        int carry = 0;
        int len1 = num1.length();
        int len2 = num2.length();
        int len = len1 > len2 ? len1 : len2;
        string zero = string(len - len1, '0');
        num1 = zero + num1;
        zero = string(len - len2, '0');
        num2 = zero + num2;
        for (int i = len - 1; i >= 0; i--) {
            int n = carry + num1[i] + num2[i] - 2*'0';
            num1[i] = n % 10 + '0';
            carry = n / 10;
        }
        if (carry) num1.insert(0, 1, carry + '0');
        return num1;
    }
};
```
## [73. 矩阵置零](https://leetcode-cn.com/problems/set-matrix-zeroes/)
### 思路
想写出来很简单，目前是空间O(M+N)的算法
### AC代码
```c++
class Solution {
public:
    void setZeroes(vector<vector<int>>& matrix) {
        int r = matrix.size(), c = matrix[0].size();
        unordered_map<int, bool> rows, cols;
        for (int i = 0; i < r; i++) {
            for (int j = 0; j < c; j++) {
                if (matrix[i][j] == 0) {
                    rows[i] = true;
                    cols[j] = true;
                }
            }
        }
        for (auto x : rows) {
            for (int i = 0; i < c; i++) {
                matrix[x.first][i] = 0;
            }
        }
        for (auto x : cols) {
            for (int i = 0; i < r; i++) {
                matrix[i][x.first] = 0;
            }
        }
    }
};
```

## [60. 第k个排列](https://leetcode-cn.com/problems/permutation-sequence/)
### 思路
没研究这个，stl直接调用
### AC代码
```c++
class Solution {
public:
    string getPermutation(int n, int k) {
        string ans;
        for (int i = 1; i <= n; i++) {
            ans += char(i + '0');
        }
        for (int i = 0; i < k - 1; i++) {
            next_permutation(ans.begin(), ans.end());
        }
        return ans;
    }
};
```
### 大佬代码
```c++
static const auto io_sync_off = []()
{
    // turn off sync
    std::ios::sync_with_stdio(false);
    // untie in/out streams
    std::cin.tie(nullptr);
    return nullptr;
}();

class Solution {
public:
    string recursive(int n, int k, int * order, string &str) {
        if (n == 0)
            return "";
        int num = (k - 1) / order[n - 1];
        char c = str[num];
        str.erase(str.begin() + num);
        return c + recursive(n - 1, k - num * order[n - 1], order, str);
    }
    
    string getPermutation(int n, int k) {
        int order[n + 1] = {1};
        string str;
        for (int i = 1; i < n + 1; i++) {
            order[i] = i * order[i - 1];
            str.push_back(48 + i);            
        }
        return recursive(n, k, order, str);
    }
};
```

## [34. 在排序数组中查找元素的第一个和最后一个位置](https://leetcode-cn.com/problems/find-first-and-last-position-of-element-in-sorted-array/)
### 思路
一次二分查找，然后向前向后遍历，找到开始和结束，但是最坏情况下，算法从$O(log_2n)$变成$O(n)$
### AC代码
```c++
class Solution {
public:
    vector<int> searchRange(vector<int>& nums, int target) {
        int len = nums.size();
        if (!len) return {-1, -1};
        int low = 0, high = len - 1;
        bool find = false;
        int pos = 0;
        while (low <= high) {
            int mid = low + (high - low)/2;
            if (nums[mid] == target) {
                find = true;
                pos = mid;
                break;
            } else if (nums[mid] > target) {
                high = mid - 1;
            } else {
                low = mid + 1;
            }
        }
        if (!find) {
            return {-1, -1};
        }
        int beg , end;
        beg = end = pos;
        while (beg >= 0 && nums[pos] == nums[beg]) beg--;
        while (end < len && nums[pos] == nums[end]) end++;
        return {beg + 1, end - 1};
    }
};
```
## [24. 两两交换链表中的节点](https://leetcode-cn.com/problems/swap-nodes-in-pairs/)
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
    ListNode* swapPairs(ListNode* head) {
        ListNode dummy(0), *h;
        dummy.next = head;//哑结点定义为局部变量，防止内存泄漏
        h = &dummy;
        while (h->next != NULL) {
            if (h->next->next != NULL) {
                ListNode *a = h->next, *b = h->next->next;
                a->next = b->next;
                b->next = a;
                h->next = b;
                h = h->next->next;
            } else {
                break;
            }
        }
        return dummy.next;
    }
};
```

## [47. 全排列 II](https://leetcode-cn.com/problems/permutations-ii/)
### AC代码
```c++
class Solution {
public:
    vector<vector<int>> permuteUnique(vector<int>& nums) {
        sort(nums.begin(), nums.end());
        vector<vector<int>> ans;
        do {
            ans.push_back(nums);
        }while (next_permutation(nums.begin(), nums.end()));
        ans.erase(unique(ans.begin(), ans.end()),ans.end());
        return ans;
    }
};
```

### 大佬代码
```c++
class Solution {
public:
    vector<vector<int>> ans;
    vector<bool> b;
    vector<int> v;
    void dfs(int i, const vector<int>& nums)
    {
        if(i == nums.size()){
            ans.push_back(v);
            return;
        }
        for(int j = 0; j < nums.size(); ++j){
            if(j > 0 && nums[j - 1] == nums[j] && !b[j - 1])continue;
            if(!b[j]){
                b[j] = 1;
                v[i] = nums[j];
                dfs(i + 1, nums);
                b[j] = 0;
            }
        }
        return;
    }
    
    vector<vector<int>> permuteUnique(vector<int>& nums) {
        sort(nums.begin(), nums.end());
        v.resize(nums.size());
        b.resize(nums.size());
        dfs(0, nums);
        return ans;
    }
};
```

## [49. 字母异位词分组](https://leetcode-cn.com/problems/group-anagrams/)

### 思路
1. stl使劲套，要用multiset，两个单词字符集相同但是字符个数不同
2. 优化，不用set，map变成string，字符集的字符串排序后对应唯一的“特征字符串”
### AC代码
```c++
class Solution {
public:
    vector<vector<string>> groupAnagrams(vector<string>& strs) {
        map<multiset<char>, vector<string>> m;
        int num = strs.size();
        for (auto &x : strs) {
            multiset<char> s(x.begin(), x.end());
            m[s].push_back(x);
        }
        vector<vector<string>> ans;
        for (auto &x : m) {
            ans.push_back(x.second);
        }
        return ans;
    }
};
static const auto io_sync_off = []() {
    // turn off sync
    std::ios::sync_with_stdio(false);
    // untie in/out streams
    std::cin.tie(nullptr);
    return nullptr;
}();
```
### AC代码（优化）
```c++
class Solution {
public:
    vector<vector<string>> groupAnagrams(vector<string>& strs) {
        unordered_map<string, vector<string>> m;
        for (auto &x : strs) {
            string temp = x;
            sort(x.begin(), x.end());
            m[x].push_back(temp);
        }
        vector<vector<string>> ans;
        for (auto &x : m) {
            ans.push_back(x.second);
        }
        return ans;
    }
};
```

## [80. 删除排序数组中的重复项 II](https://leetcode-cn.com/problems/remove-duplicates-from-sorted-array-ii/)
### 思路
#### 双指针
遍历一遍数组，
### AC代码
```c++
class Solution {
  public:
    int removeDuplicates(vector<int> &nums) {
        int i = 0, j = 0;
        int len = nums.size();
        while (i < len) {
            if (j < 2 || nums[i] > nums[j - 2]) {
                int n = nums[i];
                nums[j++] = n;
            }
            i++;
        }
        return j;
    }
};
```
