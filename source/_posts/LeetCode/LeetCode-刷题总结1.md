---
title: LeetCode-1
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

## [1.两数之和](https://leetcode-cn.com/problems/two-sum/)
### AC代码
#### 思路
- 刚开始就是用双层for循环写，然后秉承着谦虚的态度看了题解，发现真的有O(N)的算法`一遍哈希表`。

- 主要就是利用`map`建立从数到数组下标的map，然后每次计算出target-nums[i]的值，然后看map里面有对应的下标，有的话就输出，没有就继续。

- map的值为0时，如何区分stl的map知识有限，如何判断0是数组里面没有这个数还是查询的引索为0呢？只要储存的时候下标+1，用的时候减一就行了，这样map值为0，一定是没有这个数。

```c++
class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
        vector<int> ans;
        map<int, int> m;
        for (int i = 0; i < nums.size(); i++) {
            int pos = target - nums[i];
            if (m[pos] != 0 && m[pos] != i + 1) {
                pos = m[pos] - 1;
                ans.push_back(pos > i ? i : pos);
                ans.push_back(pos < i ? i : pos);
                break;
            }
            m[nums[i]] = i + 1;
        }
        return ans;
    }
};

```

## [2. 两数相加](https://leetcode-cn.com/problems/add-two-numbers/)

没想到第二题就是链表了，`LeetCode`给出的这种带构造函数的结构体挺好的，用起来方便了很多，开始创建一个`head`，后面直接返回`head->next`就好。

1. next自动赋值为NULL（我觉得可以搞成next默认参数为NULL，自由度更大一点）
2. 必须传递参数，限制使用，更安全
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
    ListNode* addTwoNumbers(ListNode* l1, ListNode* l2) {
        ListNode* temp, *ans;
        int carry = 0, n;
        ans = temp = new ListNode(0);
        while (l1 != NULL || l2 != NULL) {
            //用逻辑或链接，把两个链表都遍历完

            n = (l1 == NULL ? 0 : l1->val) + (l2 == NULL ? 0 : l2->val) + carry;
            //注意某个链表此时可能遍历完的可能

            temp->next = new ListNode(n%10);
            carry = n / 10;
            //计算

            if (l1 != NULL)l1 = l1->next;
            if (l2 != NULL)l2 = l2->next;
            //注意到链表为空或已经遍历完
            temp = temp->next;
            //集体指向next
        }
        if (carry) temp->next = new ListNode(carry);
        //如果还有剩余的进位，再new一个

        return ans->next;
        //返回头结点的next（头结点没意义）
    }
};
```
## [7. 整数反转](https://leetcode-cn.com/problems/reverse-integer/)

### 第一次AC的，28ms

#### 思路
- 先干掉负号，sprintf变字符串，调用std的reverse函数，反转，再变回数字，然后把符号还原
- 由于要考察对溢出的处理，就偷梁换柱用了`long long`，超过`int`范围的就返回0

```c++
class Solution {
public:
    int reverse(int y) {
        long long x = y;
        bool negative = (x < 0);
        if (negative) x *= -1;
        char n[1024];
        sprintf(n, "%lld", x);
        std::reverse(n, n + strlen(n));
        sscanf (n, "%lld", &x);
        if (negative) x *= -1;
        return x >= 2147483647 || x <= -2147483648 ? 0 : x;
    }
};
```

### 看了的高分同学的代码第二次AC的20ms
#### 手动大哭，凭什么一样的算法，人家就是最高分，我就是中位数？？

这位同学代码块的原因主要是解除了与stdio的同步，cin.tie(nullptr)对cin，cout进行加速了，把取消同步的代码删除后，反而比我第一次AC的代码慢了。也不知道是什么原因。

```c++
static int x = [](){ios::sync_with_stdio(false); cin.tie(nullptr); return 0; }();
class Solution {
public:
    int reverse(int y) {
        long long x = y;
        long long ans = 0;
        while (x) {
            ans *= 10;
            ans += x % 10;
            x /= 10;
        }
        return ans >= 2147483647 || ans <= -2147483648 ? 0 : ans;
    }
};
```

## [9. 回文数](https://leetcode-cn.com/problems/palindrome-number/)

### 第一次AC代码

#### 思路
转字符串，直接循环比

```c++
class Solution {
public:
    bool isPalindrome(int x) {
        char n[16] = {0};
        sprintf(n, "%d", x);
        int len = strlen(n);
        for (int i = 0; i < len/2; i++) {
            if (n[i] != n[len - 1 - i]) {
                return false;
            }
        }
        return true;
    }
};
```

### 看了高分同学代码后的第二次AC的代码
#### 思路
把数字当十进制转十进制，算一次的结果刚好和原来的数反转过来，如果大于0，比较两个数是否相等，否则反转一定不合条件，返回false
```c++
class Solution {
public:
    bool isPalindrome(int x) {
        long long y = 0;
        for (int z = x; z; z /= 10) {
            y = y*10 + z % 10;
        }
        return x >= 0 ? y == x : false;
    }
};
```
## [13. 罗马数字转整数](https://leetcode-cn.com/problems/roman-to-integer/)

刚开始毫无思路，后来看了评论里大佬的思路才写出来。

### 第一次AC代码

#### 思路
1. 把几个符号的ASCII值当下标，储存符号的对应的值
2. 遍历字符串，对于每一个字符，如果后一个字符的值大于自身，从总数中减去自己的值，如果后面的值小于等于自身（III，MMII），则在总数中加上自己

```c++
static const auto io_sync_off=[](){
    std::ios::sync_with_stdio(false);
    std::cin.tie(NULL);
    return 0;
}();
class Solution {
public:
    int romanToInt(string s) {
        int m[100] = {0};
        m['M'] = 1000;
        m['D'] = 500;
        m['C'] = 100;
        m['L'] = 50;
        m['X'] = 10;
        m['V'] = 5;
        m['I'] = 1;
        int ans = 0;
        for (int i = 0; i < s.length() - 1; i++) {
            //防止越界，不管最后一个字符，循环结束后单独考虑
            if (m[s[i]] >= m[s[i+1]]) ans += m[s[i]];
            else ans -= m[s[i]];
        }
        ans += m[s[s.length() - 1]];
        //最后一个字符没有后面一个，不论如何，都加上它的值
        return ans;
    }
};
```

## [14. 最长公共前缀](https://leetcode-cn.com/problems/longest-common-prefix/)

### 第一次AC代码
#### 思路

1. 找到最短的字符串
2. 从1开始截取字符串，跟其他字符串的前缀比较，直到出现前缀不同

```c++
static const auto __ = []() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	return nullptr;
}();
class Solution {
public:
    string longestCommonPrefix(vector<string>& strs) {
        string ans;
        for (int i = 0; i < minlen(strs); i++) {
            bool find = false;
            char cmp = strs[0][i];
            for (int j = 0; j < strs.size(); j++) {
                if (cmp != strs[j][i]) {
                    find = true;
                    break;
                }
            }
            if (!find) ans.append(1, cmp);
            else break;
        }
        return ans;
    }
    int minlen(vector<string>& strs) {
        if (strs.size() == 0) return 0;
        int min = strs[0].length();
        for (int i = 1; i < strs.size(); i++) {
            if (strs[i].length() < min) min = strs[i].length();
        }
        return min;
    }
};
```

### 看了题解后利用二分查找法的AC代码（Edition 1）

#### 思路
1. 找到最短的字符串的下标
2. 把最短的字符串一分为二，自己变成前半段，后半段存在另一个string里面
3. 比较一次，如果前缀都相同，把右半边一分为二，拼接到左半半，右半半变成自己的右半半。
4. 一次比较完成后
   1. 如果前缀都相同，且后半半只剩一个字符了，把这个字符拼过去再查一次，有问题就恢复，没问题保留，返回此时的左半半；如果前缀
   2. 如果前缀不同，左半半只剩下一个字符了，在比较一次，看看这个字符是不是公共前缀，是就返回，否则返回空串（没有公共前缀）

```c++
static const auto __ = []() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	return nullptr;
}();
class Solution {
public:
    string longestCommonPrefix(vector<string>& strs) {
        if (strs.size() == 1) return strs[0];
        if (!strs.size()) return "";
        int min = IndexOfMinLen(strs);
        if (!strs[min].length()) return "";
        string sub = strs[min].substr(0, strs[min].length() / 2);
        string right = strs[min].substr(strs[min].length() / 2, strs[min].length() - strs[min].length() / 2);
        while (1){
            bool find = false;
            for (int i = 0; i < strs.size(); i++) {
                if (strs[i].substr(0, sub.length()) != sub) {
                    find = true;
                }
            }
            if (find) {
                if (sub.length() == 1) {
                    for (int i = 0; i < strs.size(); i++) {
                        if (strs[i].substr(0, sub.length()) != sub) {
                            find = true;
                        }
                    }
                    if (find) {
                        sub = "";
                    }
                    break;
                }
                right = sub.substr(sub.length() / 2, sub.length() - sub.length()/2);
                sub = sub.substr(0, sub.length()/2);
                
            } else {
                if (right.length() == 1) {
                    for (int i = 0; i < strs.size(); i++) {
                        if (strs[i].substr(0, sub.length()+1) != sub + right) {
                            find = true;
                        }
                    }
                    if (!find) {
                        sub += right;
                    }
                    break;
                }
                sub.append(right.substr(0, right.length()/2));
                right = right.substr(right.length() / 2, right.length() - right.length()/2);
            }
        }
        return sub;
    }
    int IndexOfMinLen(vector<string>& strs) {
        int min = strs[0].length();
        int pos = 0;
        for (int i = 1; i < strs.size(); i++) {
            if (strs[i].length() < min) {
                min = strs[i].length();
                pos = i;
            }
        }
        return pos;
    }
};
```

### 根据题解写的简化版二分查找（Edition 2）

### 思路
1. 每次截取一半，遍历比较
2. 如果前缀相同，把边界右移一半
3. 如果前缀不同，把边界前移一半

```c++
static const auto __ = []() {
	ios::sync_with_stdio(false);
	cin.tie(nullptr);
	return nullptr;
}();
class Solution {
public:
    string longestCommonPrefix(vector<string>& strs) {
        if (strs.size() == 1) return strs[0];
        if (!strs.size()) return "";
        int min = IndexOfMinLen(strs);
        if (!strs[min].length()) return "";
        int len = strs[min].length();
        int left = 1, right = strs[min].length();
        string sub;
        while (left <= right){
            int mid = (left + right) / 2;
            sub = strs[min].substr(0, mid);
            bool find = false;
            for (int i = 0; i < strs.size(); i++) {
                if (strs[i].substr(0, sub.length()) != sub) {
                    find = true;
                }
            }
            if (find) {
                right = mid - 1;
            } else {
                left = mid + 1;
            }
        }
        sub = strs[min].substr(0, (left + right) / 2);
        return sub;
    }
    int IndexOfMinLen(vector<string>& strs) {
        int min = strs[0].length();
        int pos = 0;
        for (int i = 1; i < strs.size(); i++) {
            if (strs[i].length() < min) {
                min = strs[i].length();
                pos = i;
            }
        }
        return pos;
    }
};
```
