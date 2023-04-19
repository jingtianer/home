---
title: LeetCode-13
date: 2022-10-22 21:15:36
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## [1640. 能否连接形成数组](https://leetcode.cn/problems/check-array-formation-through-concatenation/)

```c++
class Solution {
public:
    bool canFormArray(vector<int>& arr, vector<vector<int>>& pieces) {
        int arr_map[105] = {0};
        int len_arr = arr.size();
        for(int i = 0; i < len_arr; i++) {
            arr_map[arr[i]] = i+1;
        }
        int pie_len = pieces.size();
        for(int i = 0; i < pie_len; i++) {
            int i_len = pieces[i].size();
            int diff = arr_map[pieces[i][0]];
            if(diff == 0) {
                return false;
            }
            for(int j = 1; j < i_len; j++) {
                if(diff != arr_map[pieces[i][j]] - j) {
                    return false;
                }
            }
        }
        return true;
    }
};
```
> 4ms，和最快的思路刚好相反，用map存储arr的index，最快的思路是反过来，用map存一个piece的第一个index

```c++
class Solution {
public:
    bool canFormArray(vector<int>& arr, vector<vector<int>>& pieces) {
        int arr_map[105] = {0};
        int len_arr = arr.size();
        int pie_len = pieces.size();
        for(int i = 0; i < pie_len; i++) {
            arr_map[pieces[i][0]] = i+1;
        }
        int i = 0;
        while(i < len_arr) {
            int row = arr_map[arr[i]];
            if(row == 0) return false;
            vector<int>& subv = pieces[row-1];
            int i_len = subv.size();
            for(int j = 0; j < i_len; j++, i++) {
                if(arr[i] != subv[j]) {
                    return false;
                }
            }
        }
        return true;
    }
};
```

## [707. 设计链表](https://leetcode.cn/problems/design-linked-list/)

```c++
struct List {
    List *next;
    int val;
    List(int val0, List* next0 = nullptr):val(val0), next(next0) {}
};

class MyLinkedList {
private:
    List *root;
    List *tail;
    int size;
    inline List* getNode(int& index) {
        List *move = root;
        while(index > 0 && move->next != nullptr) {
            move = move->next;
            index--;
        }
        return move;
    }
public:
    MyLinkedList() {
        root = new List(0);
        tail = root;
        size = 0;
    }
    
    int get(int index) {
        List *move = getNode(index);
        return (move->next == nullptr) ? -1 : move->next->val;
    }
    
    void addAtHead(int val) {
        List* node = new List(val, root->next);
        root->next = node;
        if(root == tail) {
            tail = node;
        }
        size++;
    }
    
    void addAtTail(int val) {
        List* node = new List(val, tail->next);
        tail->next = node;
        tail = node;
        size++;
    }
    
    void addAtIndex(int index, int val) {
        List *move = getNode(index);
        if(index > 0) {
            return;
        }
        List* node = new List(val, move->next);
        move->next = node;
        if(move == tail) {
            tail = node;
        }
        size++;
    }
    
    void deleteAtIndex(int index) {
        List *move = getNode(index);
        List *target = move->next;
        if(target != nullptr)  {
            move->next = target->next;
            if(target == tail) {
                tail = move;
            }
            delete target;
            size--;
        }
    }
};
```

> 60ms -> 36ms 之前内部函数getNode有两个参数，第二个参数off用于返回index和找到的节点的距离差距。将这个参数优化掉，维护一个size替代。

## [1652. 拆炸弹](https://leetcode.cn/problems/defuse-the-bomb/)

```c++
class Solution {
public:
    vector<int> decrypt(vector<int>& code, int k) {
        int len = code.size();
        if(k > 0) {
            vector<int> after(len, 0);
            for(int i = 0; i < k; i++) {
                after[0] += code[(i+1)%len];
            }
            for(int i = 1; i < len; i++) {
                if(i + k < len) {
                    after[i] = after[i-1] - code[i] + code[(i+k)];
                } else {
                    after[i] = after[i-1] - code[i] + code[(i+k)- len];
                }
                // cout << (i+k+1)%len << " " << code[(i+k)%len] << endl;
            }
            return after;
        }
        if(k < 0) {
            vector<int> before(len, 0);
            for(int i = 0; i < -k; i++) {
                before[0] += code[(i + k + len)%len];
            }
            for(int i = 1; i < len; i++) {
                if ((i -1 + k) >= 0) {
                    before[i] = before[i-1] - code[(i -1 + k)] + code[i-1];
                } else {
                    before[i] = before[i-1] - code[(i -1 + k + len)] + code[i-1];
                }
                // cout << (i+k+len)%len << endl;
            }
            return before;
        }
        return vector<int>(len, 0);
    }
};
```

> 4ms -> 0ms 之前使用取余达到题目所说的“循环数组”的效果，后来看题解上直接把数组copy一份，创建一个2n长的数组避免越界。这里不取余，越界后直接加或减去数组长度。

## [788. 旋转数字](https://leetcode.cn/problems/rotated-digits/)

```c++
class Solution {
public:
    int rotatedDigits(int n) {
        int goodDigits[10] = {0, 1, 5, -1, -1, 2, 9, -1, 8, 6};
        int count = 0;
        for(int i = 1; i <= n; i++) {
            bool flag1 = false;
            bool flag2 = false;
            int cur_i = i;
            while(cur_i != 0) {
                int mod = cur_i % 10;
                if(goodDigits[mod] != mod) {
                    flag1 = true;
                }
                if(goodDigits[mod] == -1) {
                    flag2 = true;
                }
                cur_i /= 10;
            }
            if(flag1 && !flag2) {
                count++;
                // printf("%d, ", i);
            }
        }
        return count;
    }
};
```

> 第一次提交没有注意读题，数字的每一位都要能反转，且至少有一位反转后与原来不同，导致逻辑错误。

## [面试题 17.19. 消失的两个数字](https://leetcode.cn/problems/missing-two-lcci/)

```c++
class Solution {
public:
    vector<int> missingTwo(vector<int>& nums) {
        int len = nums.size();
        int a = -1,b = -1;
        for(int i = 0; i < len; i++) {
            while(nums[i] - 1 != i && nums[i] != -1) {
                if(nums[i]-1 == len) {
                    swap(nums[i], a);
                } else if(nums[i]-1 == len+1) {
                    swap(nums[i], b);
                } else {
                    swap(nums[i], nums[nums[i] - 1]);
                }
            }
        }
        while(a - 1 != len && a != -1) {
            if(a-1 == len) {
                swap(a, a);
            } else if(a-1 == len+1) {
                swap(a, b);
            } else {
                swap(a, nums[a - 1]);
            }
        }
        while(b - 1 != len+1 && b != -1) {
            if(b-1 == len) {
                swap(b, a);
            } else if(b-1 == len+1) {
                swap(b, b);
            } else {
                swap(b, nums[b - 1]);
            }
        }
        vector<int> ret(2);
        int count = 0;
        for(int i = 0; i < len; i++) {
            if(nums[i] - 1 != i) {
                ret[count] = i+1;
                count++;
                if(count >= 2) break;
            }
        }
        if(count < 2 && a-1 != len) {
            ret[count] = len+1;
            count++;
        }
        if(count < 2 && b-1 != len) {
            ret[count] = len+2;
            count++;
        }
        return ret;
    }

    void inline swap(int &a, int &b) {
        int temp = a;
        a = b;
        b = temp;
    }
};

```

> 之前做过类似的题目，数字是1 - N，就把他们一直交换，数字N就放到位置N，直到当前循环计数变量i的位置对应的数字和i相同或为-1

> 注意到参数传入的数组只有N-2的长度，而题目要求使用空间O(1)的原地算法，创建两个变量a, b并赋初值为-1，分别作为原来数组的延长，遇到这两个位置时进行特殊判断。

> 后来看代码的时候发现第48行的判断写错了，应该是`count < 2 && b-1 != len+1`，但是代码依旧通过测试了，看来测试样例还是不够全。

## [面试题 01.02. 判定是否互为字符重排](https://leetcode.cn/problems/check-permutation-lcci/)

```c++
class Solution {
public:
    bool CheckPermutation(string s1, string s2) {
        int len = s1.size();
        if(len != s2.size()) return false;
        int m1[26] = {0}, m2[26] = {0};
        for(int i = 0; i < len; i++) {
            m1[s1[i]-'a']++;
            m2[s2[i]-'a']++;
        }
        for(int i = 0; i < 26; i++) {
            if(m1[i] != m2[i]) {
                return false;
            }
        }
        return true;
    }
};
```

> 简单题，直接统计字母频率就好

## [面试题 17.09. 第 k 个数](https://leetcode.cn/problems/get-kth-magic-number-lcci/)

```c++
class Solution {
public:
    int getKthMagicNumber(int k) {
        vector<int> kth(k);
        int p1,p2,p3;
        p1 = p2 = p3 = 0;
        kth[0] = 1;
        for(int i = 1; i < k; i++) {
            int a, b,c;
            // printf("%d %d %d %d\n", p1, p2, p3, i);
            a = kth[p1] * 3;
            b = kth[p2] * 5;
            c = kth[p3] * 7;
            kth[i] = min(a, min(b,c));
            if(kth[i] == a) {
                p1++;
            }
            if(kth[i] == b) {
                p2++;
            }
            if(kth[i] == c) {
                p3++;
            }
        }
        return kth[k-1];
    }
};
```

> 比较难，尝试了很多次，最后看题解才写出来。

> 刚开始想先用素数筛算出足够的素数，再利用素数数组，从1，3，5，7之后开始，所有的非素数奇数中一个个筛选出不含有除3，5，7外其他素数的数。但是后来发现这样会超时，样例输入`251`时需要350万个素数，光是算素数就已经超时了。

> 最后才用了题解的dp，每次算出一个，如果是乘3就把3的指针向后移，5和7同理，这样就可以逐个由小到大算出第k个数。

## [面试题 01.09. 字符串轮转](https://leetcode.cn/problems/string-rotation-lcci/)

```c++
class Solution {
public:
    bool isFlipedString(string s1, string s2) {
        int len = s1.size();
        int i = 0;
        if(len == 0) return true;
        for(i; i < len; i++) {
            bool flag = true;
            for(int j = 0; j < len; j++) {
                if(s1[(i+j)%len] != s2[j]) {
                    flag = false;
                    break;
                }
            }
            if(flag) {
                return true;
            }
        }
        return false;
    }
};

```

> 最开始暴力直接搜，看了题解后可以构造`string s = s1 + s1`，然后使用kmp搜索s中是否有s2子串

## [面试题 01.08. 零矩阵](https://leetcode.cn/problems/zero-matrix-lcci/)

```c++
class Solution {
public:
    void setZeroes(vector<vector<int>>& matrix) {
        int m = matrix.size();
        if(m <= 0) return;
        int n = matrix[0].size();
        vector<bool> r(m, false), c(n, false);
        // bool r[10000] = {false}, c[10000] = {false};
        for(int i = 0; i < m; i++) {
            for(int j = 0; j < n; j++) {
                if(matrix[i][j] == 0) {
                    r[i] = true;
                    c[j] = true;
                }
            }
        }
        for(int i = 0; i < m; i++) {
            for(int j = 0; j < n; j++) {
                if(r[i]) {
                    matrix[i][j] = 0;
                }
                if(c[j]) {
                    matrix[i][j] = 0;
                }
            }
        }
        
    }
};
```
> 简单题，直接记录某行某列是否有0，然后根据每行每列的flag更新就好了

## [1694. 重新格式化电话号码](https://leetcode.cn/problems/reformat-phone-number/)

```c++
class Solution {
public:
    string reformatNumber(string number) {
        string ret;
        int len = number.size();
        int count_n = 0;
        int count = 0;
        for(int i = 0; i < len; i++) {
            if(number[i] >= '0' && number[i] <= '9') {
                ret.push_back(number[i]);
                count++;
                if(count%3 == 0) {
                    ret.push_back('-');
                }
                count_n = count%3;
            }
        }
        // printf("%d %d\n", count_n, count);
        if(count_n == 0) {
            ret.pop_back();
        } else if(count_n == 1 && count >= 3) {
            int off = count / 3;
            count += off;
            char t = ret[count-2];
            ret[count-2] = ret[count-3];
            ret[count-3] = t;
            
            // printf("%c %c\n", ret[count-2], ret[count-3]);
        }
        return ret;
    }
};
```

> 简单题，第一次提交时忘记之前添加过字符`-`,想通过最后余数对结尾4个的字符的情况进行特殊处理，直接用字符的计数器count忘记加上添加的`-`的个数

## [777. 在LR字符串中交换相邻字符](https://leetcode.cn/problems/swap-adjacent-in-lr-string/)

```c++
class Solution {
public:
    int len;
    bool canTransform(string start, string end) {
        int i,j = 0;
        int len = start.size();
        if(end.size() != len) {
            return false;
        }

        char t[10005] = {0};
        int t_i = 0;
        for(char c: start) {
            if(c != 'X') {
                t[t_i] = c;
                t_i++;
            }
        }
        int t_len = t_i;
        t_i = 0;
        for(char c : end) {
            if(c == 'X') {
                continue;
            }
            if(t_i < t_len && c == t[t_i]) {
                t_i++;
            } else {
                return false;
            }
        }
        if(t_i != t_len) return false;
        while(j < len) {
            if(end[j] == 'L') {
                int it = j;
                while(it < len && start[it] == 'X') {
                    it++;
                }
                if(it < len && start[it] == 'L') {
                    char temp_c = start[it];
                    start[it] = start[j];
                    start[j] = temp_c;
                } else {
                    return false;
                }
            } else if(end[j] == 'R') {
                int it = j;
                while(it >= 0 && start[it] == 'X') {
                    it--;
                }
                if(it >= 0 && start[it] == 'R') {
                    char temp_c = start[it];
                    start[it] = start[j];
                    start[j] = temp_c;
                } else {
                    return false;
                }
            } else {
                
            }
            j++;
        }
        return j == len && start[j-1] == end[len-1];
    }
};
```

> 比较难

> 第一次的思路是直接忽略X，比较L和R的序列是否相同，这个显然是没有完全考虑完全

> 第二次打算进行搜索，生成所有左移右移后的情况，和end进行对比，但是没有考虑到L，R可以多次移动，L多次移动的话就要进行多次的回溯，非常麻烦

> 第三次真正理解题意，根据end对start进行移动，在结合第一次的思路比较一下忽略X的LR序列是否完全相同。

## [1784. 检查二进制字符串字段](https://leetcode.cn/problems/check-if-binary-string-has-at-most-one-segment-of-ones/)

```c++
class Solution {
public:
    bool checkOnesSegment(string s) {
        int count = 0;
        int i = 0;
        int length = s.size();
        while(i < length) {
            while(i < length && s[i] == '1') i++;
            count++;
            while(i < length && s[i] == '0') i++;
        }
        return count <= 1;
    }
};
```

> 简单，有手就行，就是统计有几群连续的1

## [921. 使括号有效的最少添加](https://leetcode.cn/problems/minimum-add-to-make-parentheses-valid/)

```c++
class Solution {
public:
    int minAddToMakeValid(string s) {
        stack<char> sta;
        int count = 0;
        for(char c : s) {
            if(c == '(') {
                sta.push(c);
            } else {
                if(sta.empty()) {
                    count++;
                } else {
                    sta.pop();
                }
            }
        }
        return count + sta.size();
    }
};
```

> 题目的样例好像有错误还是我没看懂，总之是括号匹配，问有几个不匹配的

> 每次出现右括号且没有左括号匹配时，计数器++，字符串变量结束后，在加上栈中剩余的没匹配的左括号的个数就好了。

## [811. 子域名访问计数](https://leetcode.cn/problems/subdomain-visit-count/)

```c++
class Solution {
public:
    vector<string> subdomainVisits(vector<string>& cpdomains) {
        unordered_map<string, int> m;
        for(string& s : cpdomains) {
            char domain[105] = {0};
            int num;
            sscanf(s.c_str(), "%d %s", &num, domain);
            int length = strlen(domain);
            int i = 0;
            m[domain] +=num;
            while(i < length) {
                while(i < length && domain[i] != '.') i++;
                if(i >= length) break;
                char subdomain[105] = {0};
                for(int j = 0; j < length - i - 1; j++) {
                    subdomain[j] = domain[i+1+j];
                }
                m[subdomain] += num;
                i++;
            }
        }
        vector<string> v;
        for(unordered_map<string, int>::iterator i = m.begin(); i != m.end(); i++) {
            char str[105] = {0};
            sprintf(str, "%d %s", i->second, i->first.c_str());
            v.push_back(str);
        }
        return v;
    }
};
```

> 比较简单，找个map统计每个域名的出现个数就行，然后从左往右找`.`，找到后拿到子串，map中统计所有子串的出现个数。

