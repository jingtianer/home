---
title: LeetCode-23
date: 2023-2-27 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## [1144. 递减元素使数组呈锯齿状](https://leetcode.cn/problems/decrease-elements-to-make-array-zigzag/)

```c++
class Solution {
public:
    int movesToMakeZigzag(vector<int>& nums) {
        int odd2less, even2less;
        odd2less = even2less = 0;
        int n = nums.size();
        if(n <= 1) return 0;
        for(int i = 1; i < n - 1; i++) {
            if(i%2 == 0) {
                if(nums[i] >= min(nums[i-1], nums[i+1])) {
                    even2less += nums[i] - min(nums[i-1], nums[i+1]) + 1;
                }
            } else {
                if(nums[i] >= min(nums[i-1], nums[i+1])) {
                    odd2less += nums[i] - min(nums[i-1], nums[i+1]) + 1;
                }
            }
        }
        if(nums[0] >= nums[1]) {
            even2less += nums[0] - nums[1] + 1;
        }
        if(nums[n-1] >= nums[n-2]) {
            if((n-1)%2 == 0) {
                even2less += nums[n-1] - nums[n-2] + 1;
            } else {
                odd2less += nums[n-1] - nums[n-2] + 1;
            }
        }
        return min(even2less, odd2less);

    }
};
```

> 遍历所有奇数，使其小于两端，记录操作数1
> 遍历所有偶数，使其小于两端，记录操作数2
> 返回最小值

### 优化代码行数
```c++
class Solution {
public:
    int movesToMakeZigzag(vector<int>& nums) {
        int op[2] = {0}, n = nums.size();
        if(n <= 1) return 0;
        for(int i = 1; i < n - 1; i++) {
            if(nums[i] >= min(nums[i-1], nums[i+1]))
                op[i&1] += nums[i] - min(nums[i-1], nums[i+1]) + 1;
        }
        if(nums[0] >= nums[1]) {
            op[0] += nums[0] - nums[1] + 1;
        }
        if(nums[n-1] >= nums[n-2]) {
            op[(n-1)&1] += nums[n-1] - nums[n-2] + 1;
        } 
        return min(op[0], op[1]);
    }
};
```

## [2325. 解密消息](https://leetcode.cn/problems/decode-the-message/submissions/406636854/)

```c++
class Solution {
public:
    string decodeMessage(string key, string message) {
        vector<int> alphabet = vector<int>(26, -1);
        int klen = key.length(), slen = message.length(), index = 0;
        for(int i = 0; i < klen && index < 26; i++) {
            if(isalpha(key[i]) && alphabet[key[i] - 'a'] == -1) {
                alphabet[key[i] - 'a'] = 'a' + index++;
            }
        }
        for(int i = 0; i < slen; i++) {
            if(isalpha(message[i]))
                message[i] = alphabet[message[i] - 'a'];
        }
        return message;
    }
};
```

## [2319. 判断矩阵是否是一个 X 矩阵](https://leetcode.cn/problems/check-if-matrix-is-x-matrix/description/)

```c++
class Solution {
public:
    bool checkXMatrix(vector<vector<int>>& grid) {
        int n = grid.size();
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                if((i - j == 0 || i + j == n - 1)) {
                    if(grid[i][j] == 0) return false;
                } else {
                    if(grid[i][j] != 0) return false;
                }
            }
        }
        return true;
    }
};
```

> 主对角线，副对角线上的元素不能是0，其他必须是0
> 主对角线上的点满足 $ i - j == 0 $， 副对角线上满足 $ i + j == n-1 $

## [1669. 合并两个链表](https://leetcode.cn/problems/merge-in-between-linked-lists/description/)

```c++
class Solution {
public:
    ListNode* mergeInBetween(ListNode* list1, int a, int b, ListNode* list2) {
        int i = 0;
        ListNode *dummy = new ListNode(0, list1), *x, *y, *move;
        for(move = dummy; i <= b; move = move->next, i++) {
            if(i == a) {
                x = move;
            }
            if(i == b) {
                y = move->next;
            }
        }
        x->next = list2;
        move = list2;
        while(move->next != nullptr) move = move->next;
        move->next = y->next;
        return dummy->next;
    }
};
```

### 优化
```c++
class Solution {
public:
    ListNode* mergeInBetween(ListNode* list1, int a, int b, ListNode* list2) {
        int i = 0;
        ListNode *x, *y;
        for(x = list1; i < a-1; x = x->next, i++);
        for(y = x; i < b; y = y->next, i++);
        x->next = list2;
        while(list2->next != nullptr) list2 = list2->next;
        list2->next = y->next;
        return list1;
    }
};
```

> 题目中 a, b的范围是 $ 1 <= a <= b < list1.length - 1 $，第一个节点不需要被删除，所以dummy节点是多余的
> 将寻找a，b的for循环拆成两块，减少if跳转指令的执行次数
> move节点也是多余的


## [2315. 统计星号](https://leetcode.cn/problems/count-asterisks/description/)

```c++
class Solution {
public:
    int countAsterisks(string s) {
        int len = s.length();
        int count = 0;
        for(int i = 0; i < len; i++) {
            for(;i < len && s[i] != '|'; i++) {
                if(s[i] == '*') count++;
            }
            for(i++; i < len && s[i] != '|'; i++);
        }
        return count;
    }
};
```


## [1664. 生成平衡数组的方案数](https://leetcode.cn/problems/ways-to-make-a-fair-array/description/)

```c++
class Solution {
public:
    int waysToMakeFair(vector<int>& nums) {
        int n = nums.size(), ret = 0;
        if(n <= 1) return n;
        int len = n;
        if(n % 2 == 1) {
            nums.push_back(0);
            n++;
        }
        vector<int> preSum(n + 2);
        for(int i = 0; i < n; i++) {
            preSum[i+2] = preSum[i] + nums[i];
        }
        for(int i = 0; i < len; i++) {
            int odd = 0, even = 0;
            if(i%2 == 0) {
                even = preSum[n-1 + 2] - preSum[i+2-1] + preSum[i + 2 -2];
                odd = preSum[n-2 + 2] - preSum[i + 2] + preSum[i+2 - 1];
            } else {
                even = preSum[n-1+2] - preSum[i+2] + preSum[i+2 -1];
                odd = preSum[n-2+2] - preSum[i+2+1-2] + preSum[i+2-2];
            }
            if(even == odd) {
                ret++;
            }
        }
        return ret;
    }
};
```

> 分奇数下标和偶数下标计算前缀和
> 当某个值被删除时，其后方奇数下标边偶数下标，偶数下标边奇数下标，前方则不变。
> 假设删除某个数，计算变化后的奇偶下标之和，如果相等，则方案数+1
> 为了方便代码编写，如果n是奇数，则添加一个0保证其为偶数，但注意删除添加的这个数使得平衡并不算有效方案

### 空间优化

```c++
class Solution {
public:
    int waysToMakeFair(vector<int>& nums) {
        int n = nums.size(), ret = 0;
        if(n <= 1) return n;
        int odd1, even1, odd2, even2;
        odd1 = even1 = odd2 = even2 = 0;
        for(int i = 0; i < n; i++) {
            if(i&1) {
                odd2+=nums[i];
            } else {
                even2+=nums[i];
            }
        }
        for(int i = 0; i < n; i++) {
            if(i&1) {
                odd2-=nums[i];
            } else {
                even2-=nums[i];
            }
            if(odd2 + even1 == odd1 + even2) ret++;
            if(i&1) {
                odd1+=nums[i];
            } else {
                even1+=nums[i];
            }
        }
        return ret;
    }
};
```

> odd2,even2表示位置i被删除后，被删除元素后方的奇数下标和和偶数下标和（相对于未改变前的）
> odd1,even1表示位置i被删除后，被删除元素前方的奇数下标和和偶数下标和
> 假设删除i，就从odd2或even2中删除
> 由于变化后奇数下标变偶数，偶数变奇数，则比较 $(odd2 + even1 == odd1 + even2)$是否成立
> 比较后，将i加回odd1或even1

## [2309. 兼具大小写的最好英文字母](https://leetcode.cn/problems/greatest-english-letter-in-upper-and-lower-case/)

```c++
class Solution {
public:
    string greatestLetter(string s) {
        vector<bool> upper(26, false),lower(26, false);
        char maxx = -1;
        for(char c : s) {
            if(c >= 'A' && c <= 'Z') {
                upper[c - 'A'] = true;
                if(lower[c-'A'] && c-'A' > maxx) {
                    maxx = c - 'A';
                }
            }
            if(c >= 'a' && c <= 'z') {
                lower[c - 'a'] = true;
                if(upper[c-'a'] && c-'a' > maxx) {
                    maxx = c-'a';
                }
            }
        }
        return maxx >= 0 ? string(1, maxx + 'A') : "";
    }
};
```


## [2363. 合并相似的物品](https://leetcode.cn/problems/merge-similar-items/description/)
```c++
class Solution {
public:
    vector<vector<int>> mergeSimilarItems(vector<vector<int>>& items1, vector<vector<int>>& items2) {
        map<int, int> m;
        for(auto& v : items1) {
            m[v[0]] += v[1];
        }
        for(auto& v : items2) {
            m[v[0]] += v[1];
        }
        vector<vector<int>> ret;
        for(auto ite = m.begin(); ite != m.end(); ite++) {
            auto& [x, y] = *ite;
            ret.push_back({x, y});
        }
        return ret;
    }
};
```
```c++
class Solution {
public:
    vector<vector<int>> mergeSimilarItems(vector<vector<int>>& items1, vector<vector<int>>& items2) {
        sort(items1.begin(), items1.end(), [](vector<int>& x, vector<int>& y)->bool{return x[0] < y[0];});
        sort(items2.begin(), items2.end(), [](vector<int>& x, vector<int>& y)->bool{return x[0] < y[0];});
        int i = 0, j = 0, value = min(items1[0][0], items2[0][0]);
        int n1 = items1.size(), n2 = items2.size();
        vector<vector<int>> ret{{value, 0}};
        int retSize = 0;
        while(i < n1 && j < n2) {
            while(i < n1 && items1[i][0] == value) {
                ret[retSize][1] += items1[i][1];
                i++;
            }
            while(j < n2 && items2[j][0] == value) {
                ret[retSize][1] += items2[j][1];
                j++;
            }
            if(i < n1 && j < n2) {
                value = min(items1[i][0], items2[j][0]);
                ret.push_back({value, 0});
                retSize++;
            }
        }
        while(i < n1) {
            ret.push_back({items1[i][0], items1[i][1]});
            i++;
        }
        while(j < n2) {
            ret.push_back({items2[j][0], items2[j][1]});
            j++;
        }
        return ret;
    }
};
```

## [2373. 矩阵中的局部最大值](https://leetcode.cn/problems/largest-local-values-in-a-matrix/description/)

```c++
class Solution {
public:
    vector<vector<int>> largestLocal(vector<vector<int>>& grid) {
        int n = grid.size();
        vector<vector<int>> ret = vector<vector<int>>(n-2, vector<int>(n-2, 0));
        for(int i = 1; i < n-1; i++) {
            for(int j = 1; j < n-1; j++) {
                ret[i-1][j-1] = max(grid[i][j], max(max(max(grid[i-1][j], grid[i+1][j]),max(grid[i][j-1], grid[i][j+1])),max(max(grid[i+1][j+1], grid[i-1][j-1]),max(grid[i-1][j+1], grid[i+1][j-1]))));
            }
        }
        return ret;
    }
};
```

## 1828. 统计一个圆中点的数目

### 暴力

```c++
class Solution {
public:
    vector<int> countPoints(vector<vector<int>>& points, vector<vector<int>>& queries) {
        vector<vector<int>> xy = vector<vector<int>>(501, vector<int>(501, 0));
        for(auto& p: points) {
            xy[p[0]][p[1]]++;
        }
        int n = queries.size();
        vector<int> ret(n, 0);
        for(int i = 0; i <= 500; i++) {
            for(int j = 0; j <= 500; j++) {
                if(xy[i][j] > 0) {
                    for(int k = 0; k < n; k++) {
                        int x = queries[k][0], y = queries[k][1], r = queries[k][2];
                        if((i - x)*(i - x) + (j - y)*(j - y) <= r*r) {
                            ret[k] += xy[i][j];
                        }
                    }
                }
            }
        }
        return ret;
    }
};
```

> 注意不同点可能有相同的坐标

### 更暴力
```c++
class Solution {
public:
    vector<int> countPoints(vector<vector<int>>& points, vector<vector<int>>& queries) {
        int m = points.size(), n = queries.size();
        vector<int> ret = vector<int>(n, 0);
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < m; j++) {
                if ((queries[i][0] - points[j][0]) * (queries[i][0] - points[j][0]) + (queries[i][1] - points[j][1]) * (queries[i][1] - points[j][1]) <= queries[i][2] * queries[i][2]) {
                    ret[i]++;
                }
            }
        }
        return ret;
    }
};
```

## 面试题 05.02. 二进制数转字符串

### 乘2法
```c++
class Solution {
public:
    string printBin(double num) {
        int count = 0;
        string res = "0.";
        for(; count < 30 && num > 0; count++) {
            num *= 2;
            int bit = num;
            res.push_back(bit+'0');
            num -= bit;
        }
        return count < 30 ? res : "ERROR";
    }
};
```

### ieee 754
```c++
class Solution {
public:
    string printBin(double num) {
        long long int *bit = (long long int *)&num;
        string res = string(64, '\0');
        int i = 63;
        for(; ((*bit)&1)==0; i--, (*bit) >>= 1);
        int last = i;
        for(; i > 11; i--) {
            res[i - 12] += ((*bit)&1) + '0';
            (*bit) >>= 1;
        }
        int e = ((*bit) & 0x7ff) - 1023;
        string pre = "0.";
        if(e < -1) {
            pre += string(-e-1,'0');
        }
        pre += "1";
        return last-12 < 32-3-(-e-1) ? pre+res : "ERROR";
    }
};
```

> 分别计算浮点数的尾数，阶码，在判断能否用32位保存下来

