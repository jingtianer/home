---
title: LeetCode-位运算
date: 2023-11-5 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## 位运算常见技巧

- 位运算计算

| a   | op  | b    | res        |
| --- | --- | ---- | ---------- |
| x   | xor | 0x00 | x          |
| x   | xor | 0xff | ~x         |
| x   | xor | x    | 0          |
| x   | and | 0x00 | 0          |
| x   | and | 0xff | x          |
| x   | and | x    | x          |
| x   | or  | 0x00 | x          |
| x   | or  | 0xff | 0xff       |
| x   | or  | x    | x          |
| x   | and | x-1  | 去掉最低位 |
| x   | and | -x   | 得到最低位 |

- 状态压缩

用二进制位表示状态

## [268. 丢失的数字](https://leetcode.cn/problems/missing-number/description/)

```c++
class Solution {
public:
    int missingNumber(vector<int>& nums) {
        int n = nums.size();
        int ans = n;
        for(int i = 0; i < n; i++) {
            ans ^= nums[i]^i;
        }
        return ans;
    }
};
```

### 思路

模仿[136. 只出现一次的数字](https://leetcode.cn/problems/single-number/)，将下标和所有数字进行异或。

## [693. 交替位二进制数](https://leetcode.cn/problems/binary-number-with-alternating-bits/description/)

### 神经病做法
- 0x5555555 是最低位为1的01交替
- 0xaaaaaaa 是最低位为0的01交替
- n分别与两个数相与，结果不同时大于0或不同时为0的话，说明没有连续的0
- 对n取反，即可判断有无连续的0
```c++
class Solution {
public:
    bool hasAlternatingBits(int n) {
        if(!(((0x55555555 & n) && !(0xaaaaaaaa & n)) || (!(0x55555555 & n) && (0xaaaaaaaa & n)))) return false;
        if(n == 1) return true;
        // for(int i = 1; i < 32; i++) {
        //     printf(
        //         "if(!(n & 0x%x)) return "
        //         "((0x55555555 & 0x%x & ~n) && !(0xaaaaaaaa & 0x%x & ~n)) || (!(0x55555555 & 0x%x & ~n) && (0xaaaaaaaa & 0x%x & ~n)); else\n", 
        //         (0xffffffffffffffff << i), 
        //         ~(0xffffffffffffffff << i), ~(0xffffffffffffffff << i), ~(0xffffffffffffffff << i), ~(0xffffffffffffffff << i)
        //     );
        // }
        // printf("return false; // unreachable\n");
        if(!(n & 0xfffffffe)) return ((0x55555555 & 0x1 & ~n) && !(0xaaaaaaaa & 0x1 & ~n)) || (!(0x55555555 & 0x1 & ~n) && (0xaaaaaaaa & 0x1 & ~n)); else
        if(!(n & 0xfffffffc)) return ((0x55555555 & 0x3 & ~n) && !(0xaaaaaaaa & 0x3 & ~n)) || (!(0x55555555 & 0x3 & ~n) && (0xaaaaaaaa & 0x3 & ~n)); else
        if(!(n & 0xfffffff8)) return ((0x55555555 & 0x7 & ~n) && !(0xaaaaaaaa & 0x7 & ~n)) || (!(0x55555555 & 0x7 & ~n) && (0xaaaaaaaa & 0x7 & ~n)); else
        if(!(n & 0xfffffff0)) return ((0x55555555 & 0xf & ~n) && !(0xaaaaaaaa & 0xf & ~n)) || (!(0x55555555 & 0xf & ~n) && (0xaaaaaaaa & 0xf & ~n)); else
        if(!(n & 0xffffffe0)) return ((0x55555555 & 0x1f & ~n) && !(0xaaaaaaaa & 0x1f & ~n)) || (!(0x55555555 & 0x1f & ~n) && (0xaaaaaaaa & 0x1f & ~n)); else
        if(!(n & 0xffffffc0)) return ((0x55555555 & 0x3f & ~n) && !(0xaaaaaaaa & 0x3f & ~n)) || (!(0x55555555 & 0x3f & ~n) && (0xaaaaaaaa & 0x3f & ~n)); else
        if(!(n & 0xffffff80)) return ((0x55555555 & 0x7f & ~n) && !(0xaaaaaaaa & 0x7f & ~n)) || (!(0x55555555 & 0x7f & ~n) && (0xaaaaaaaa & 0x7f & ~n)); else
        if(!(n & 0xffffff00)) return ((0x55555555 & 0xff & ~n) && !(0xaaaaaaaa & 0xff & ~n)) || (!(0x55555555 & 0xff & ~n) && (0xaaaaaaaa & 0xff & ~n)); else
        if(!(n & 0xfffffe00)) return ((0x55555555 & 0x1ff & ~n) && !(0xaaaaaaaa & 0x1ff & ~n)) || (!(0x55555555 & 0x1ff & ~n) && (0xaaaaaaaa & 0x1ff & ~n)); else
        if(!(n & 0xfffffc00)) return ((0x55555555 & 0x3ff & ~n) && !(0xaaaaaaaa & 0x3ff & ~n)) || (!(0x55555555 & 0x3ff & ~n) && (0xaaaaaaaa & 0x3ff & ~n)); else
        if(!(n & 0xfffff800)) return ((0x55555555 & 0x7ff & ~n) && !(0xaaaaaaaa & 0x7ff & ~n)) || (!(0x55555555 & 0x7ff & ~n) && (0xaaaaaaaa & 0x7ff & ~n)); else
        if(!(n & 0xfffff000)) return ((0x55555555 & 0xfff & ~n) && !(0xaaaaaaaa & 0xfff & ~n)) || (!(0x55555555 & 0xfff & ~n) && (0xaaaaaaaa & 0xfff & ~n)); else
        if(!(n & 0xffffe000)) return ((0x55555555 & 0x1fff & ~n) && !(0xaaaaaaaa & 0x1fff & ~n)) || (!(0x55555555 & 0x1fff & ~n) && (0xaaaaaaaa & 0x1fff & ~n)); else
        if(!(n & 0xffffc000)) return ((0x55555555 & 0x3fff & ~n) && !(0xaaaaaaaa & 0x3fff & ~n)) || (!(0x55555555 & 0x3fff & ~n) && (0xaaaaaaaa & 0x3fff & ~n)); else
        if(!(n & 0xffff8000)) return ((0x55555555 & 0x7fff & ~n) && !(0xaaaaaaaa & 0x7fff & ~n)) || (!(0x55555555 & 0x7fff & ~n) && (0xaaaaaaaa & 0x7fff & ~n)); else
        if(!(n & 0xffff0000)) return ((0x55555555 & 0xffff & ~n) && !(0xaaaaaaaa & 0xffff & ~n)) || (!(0x55555555 & 0xffff & ~n) && (0xaaaaaaaa & 0xffff & ~n)); else
        if(!(n & 0xfffe0000)) return ((0x55555555 & 0x1ffff & ~n) && !(0xaaaaaaaa & 0x1ffff & ~n)) || (!(0x55555555 & 0x1ffff & ~n) && (0xaaaaaaaa & 0x1ffff & ~n)); else
        if(!(n & 0xfffc0000)) return ((0x55555555 & 0x3ffff & ~n) && !(0xaaaaaaaa & 0x3ffff & ~n)) || (!(0x55555555 & 0x3ffff & ~n) && (0xaaaaaaaa & 0x3ffff & ~n)); else
        if(!(n & 0xfff80000)) return ((0x55555555 & 0x7ffff & ~n) && !(0xaaaaaaaa & 0x7ffff & ~n)) || (!(0x55555555 & 0x7ffff & ~n) && (0xaaaaaaaa & 0x7ffff & ~n)); else
        if(!(n & 0xfff00000)) return ((0x55555555 & 0xfffff & ~n) && !(0xaaaaaaaa & 0xfffff & ~n)) || (!(0x55555555 & 0xfffff & ~n) && (0xaaaaaaaa & 0xfffff & ~n)); else
        if(!(n & 0xffe00000)) return ((0x55555555 & 0x1fffff & ~n) && !(0xaaaaaaaa & 0x1fffff & ~n)) || (!(0x55555555 & 0x1fffff & ~n) && (0xaaaaaaaa & 0x1fffff & ~n)); else
        if(!(n & 0xffc00000)) return ((0x55555555 & 0x3fffff & ~n) && !(0xaaaaaaaa & 0x3fffff & ~n)) || (!(0x55555555 & 0x3fffff & ~n) && (0xaaaaaaaa & 0x3fffff & ~n)); else
        if(!(n & 0xff800000)) return ((0x55555555 & 0x7fffff & ~n) && !(0xaaaaaaaa & 0x7fffff & ~n)) || (!(0x55555555 & 0x7fffff & ~n) && (0xaaaaaaaa & 0x7fffff & ~n)); else
        if(!(n & 0xff000000)) return ((0x55555555 & 0xffffff & ~n) && !(0xaaaaaaaa & 0xffffff & ~n)) || (!(0x55555555 & 0xffffff & ~n) && (0xaaaaaaaa & 0xffffff & ~n)); else
        if(!(n & 0xfe000000)) return ((0x55555555 & 0x1ffffff & ~n) && !(0xaaaaaaaa & 0x1ffffff & ~n)) || (!(0x55555555 & 0x1ffffff & ~n) && (0xaaaaaaaa & 0x1ffffff & ~n)); else
        if(!(n & 0xfc000000)) return ((0x55555555 & 0x3ffffff & ~n) && !(0xaaaaaaaa & 0x3ffffff & ~n)) || (!(0x55555555 & 0x3ffffff & ~n) && (0xaaaaaaaa & 0x3ffffff & ~n)); else
        if(!(n & 0xf8000000)) return ((0x55555555 & 0x7ffffff & ~n) && !(0xaaaaaaaa & 0x7ffffff & ~n)) || (!(0x55555555 & 0x7ffffff & ~n) && (0xaaaaaaaa & 0x7ffffff & ~n)); else
        if(!(n & 0xf0000000)) return ((0x55555555 & 0xfffffff & ~n) && !(0xaaaaaaaa & 0xfffffff & ~n)) || (!(0x55555555 & 0xfffffff & ~n) && (0xaaaaaaaa & 0xfffffff & ~n)); else
        if(!(n & 0xe0000000)) return ((0x55555555 & 0x1fffffff & ~n) && !(0xaaaaaaaa & 0x1fffffff & ~n)) || (!(0x55555555 & 0x1fffffff & ~n) && (0xaaaaaaaa & 0x1fffffff & ~n)); else
        if(!(n & 0xc0000000)) return ((0x55555555 & 0x3fffffff & ~n) && !(0xaaaaaaaa & 0x3fffffff & ~n)) || (!(0x55555555 & 0x3fffffff & ~n) && (0xaaaaaaaa & 0x3fffffff & ~n)); else
        if(!(n & 0x80000000)) return ((0x55555555 & 0x7fffffff & ~n) && !(0xaaaaaaaa & 0x7fffffff & ~n)) || (!(0x55555555 & 0x7fffffff & ~n) && (0xaaaaaaaa & 0x7fffffff & ~n)); else
        return false; // unreachable
    }
};
```

### 正常做法
- n ^ (n>>1) ，某一位为1，相当于这一位和其前一位不一样
- 任何结果形如 `0b000_..._011...111`的，都是正确
- 考虑到 `0b000_..._011...111` + 1 就是 `0b00..00100..00`，
- 只要`(n ^ (n>>1)) + 1`中只有一个1就好了
- (x & (x-1))相当于去掉最低位的1
- 只要`((n ^ (n>>1)) + 1) & ((n ^ (n>>1)))`是0就好了
```c++
class Solution {
public:
    bool hasAlternatingBits(int n) {
        int a = n ^ (n >> 1);
        return a == INT_MAX || (a & (a+1)) == 0;
    }
};
```
### 正常做法2
暴力打表
```c++
class Solution {
public:
    bool hasAlternatingBits(int n) {
        // int x = 0;
        // for(int i = 0; i < 16; i++) {
        //     x <<= 2;
        //     x++;
        //     printf("if(n == 0x%x || n == 0x%x) return true; else\n", x, ~x & ((1 << (i << 1)) - 1));
        // }
        // printf("return false;");
        if(n == 0x1 || n == 0x0) return true; else
        if(n == 0x5 || n == 0x2) return true; else
        if(n == 0x15 || n == 0xa) return true; else
        if(n == 0x55 || n == 0x2a) return true; else
        if(n == 0x155 || n == 0xaa) return true; else
        if(n == 0x555 || n == 0x2aa) return true; else
        if(n == 0x1555 || n == 0xaaa) return true; else
        if(n == 0x5555 || n == 0x2aaa) return true; else
        if(n == 0x15555 || n == 0xaaaa) return true; else
        if(n == 0x55555 || n == 0x2aaaa) return true; else
        if(n == 0x155555 || n == 0xaaaaa) return true; else
        if(n == 0x555555 || n == 0x2aaaaa) return true; else
        if(n == 0x1555555 || n == 0xaaaaaa) return true; else
        if(n == 0x5555555 || n == 0x2aaaaaa) return true; else
        if(n == 0x15555555 || n == 0xaaaaaaa) return true; else
        if(n == 0x55555555 || n == 0x2aaaaaaa) return true; else
        return false;
    }
};
```

## [476. 数字的补数](https://leetcode.cn/problems/number-complement/description/)

```c++
class Solution {
public:
    int findComplement(int num) {
        // for(int i = 1; i < 32; i++) {
        //     printf(
        //         "if(!(num & 0x%x)) return "
        //         "0x%x & ~num; else\n", 
        //         (0xffffffffffffffff << i), 
        //         ~(0xffffffffffffffff << i), ~(0xffffffffffffffff << i), ~(0xffffffffffffffff << i), ~(0xffffffffffffffff << i)
        //     );
        // }
        // printf("return 0;\n");
        if(!(num & 0xfffffffe)) return 0x1 & ~num; else
        if(!(num & 0xfffffffc)) return 0x3 & ~num; else
        if(!(num & 0xfffffff8)) return 0x7 & ~num; else
        if(!(num & 0xfffffff0)) return 0xf & ~num; else
        if(!(num & 0xffffffe0)) return 0x1f & ~num; else
        if(!(num & 0xffffffc0)) return 0x3f & ~num; else
        if(!(num & 0xffffff80)) return 0x7f & ~num; else
        if(!(num & 0xffffff00)) return 0xff & ~num; else
        if(!(num & 0xfffffe00)) return 0x1ff & ~num; else
        if(!(num & 0xfffffc00)) return 0x3ff & ~num; else
        if(!(num & 0xfffff800)) return 0x7ff & ~num; else
        if(!(num & 0xfffff000)) return 0xfff & ~num; else
        if(!(num & 0xffffe000)) return 0x1fff & ~num; else
        if(!(num & 0xffffc000)) return 0x3fff & ~num; else
        if(!(num & 0xffff8000)) return 0x7fff & ~num; else
        if(!(num & 0xffff0000)) return 0xffff & ~num; else
        if(!(num & 0xfffe0000)) return 0x1ffff & ~num; else
        if(!(num & 0xfffc0000)) return 0x3ffff & ~num; else
        if(!(num & 0xfff80000)) return 0x7ffff & ~num; else
        if(!(num & 0xfff00000)) return 0xfffff & ~num; else
        if(!(num & 0xffe00000)) return 0x1fffff & ~num; else
        if(!(num & 0xffc00000)) return 0x3fffff & ~num; else
        if(!(num & 0xff800000)) return 0x7fffff & ~num; else
        if(!(num & 0xff000000)) return 0xffffff & ~num; else
        if(!(num & 0xfe000000)) return 0x1ffffff & ~num; else
        if(!(num & 0xfc000000)) return 0x3ffffff & ~num; else
        if(!(num & 0xf8000000)) return 0x7ffffff & ~num; else
        if(!(num & 0xf0000000)) return 0xfffffff & ~num; else
        if(!(num & 0xe0000000)) return 0x1fffffff & ~num; else
        if(!(num & 0xc0000000)) return 0x3fffffff & ~num; else
        if(!(num & 0x80000000)) return 0x7fffffff & ~num; else
        return 0;
    }
};
```
## [137. 只出现一次的数字 II](https://leetcode.cn/problems/single-number-ii/)

- 没做出来，再接再厉

## [260. 只出现一次的数字 III](https://leetcode.cn/problems/single-number-iii/description/)

没做出来，再接再厉

## [29. 两数相除](https://leetcode.cn/problems/divide-two-integers/description/)

- 在[LeetCode](./LeetCode-刷题总结27.md#medium-29-两数相除)写过，当时没有意识到是位运算
- 大体思路就是类似快速幂

## [67. 二进制求和](https://leetcode.cn/problems/add-binary/)

- 对二进制的理解，和位运算关系不大

## [78. 子集](https://leetcode.cn/problems/subsets/description/)

### 递归法
- 每层递归向指定集合中依次加入一个剩余元素，并再次递归
- 首先加入空集，第一层递归在空集的基础上加入一个元素
- 第二层递归加入第二个元素

```c++
class Solution {
public:
    vector<vector<int>> res;
    int n;
    vector<vector<int>> subsets(vector<int>& nums) {
        n = nums.size();
        res.push_back(move(vector<int>()));
        insert(0, res[0], nums);
        return res;
    }
    void insert(int i, vector<int> v, const vector<int>& nums) {
        for(int j = i; j < n; j++) {
            vector<int> vv = v;
            vv.push_back(nums[j]);
            res.push_back(vv);
            insert(j+1, vv, nums);
        }
    }
};
```

### 二进制状态

- 利用`0`到`1 << N`的所有状态，刚好对应N个元素的所有状态
- 状态第i位表示第i个元素是否在集合中

```c++
class Solution {
public:
    vector<vector<int>> subsets(vector<int>& nums) {
        int state = 0;
        int n = nums.size();
        int len = 1 << n;
        vector<vector<int>> res;
        while(state < len) {
            int s = state, j = 0;
            vector<int> v;
            while(s) {
                if(s & 1) {
                    v.push_back(nums[j]);
                }
                s >>= 1;
                j++;
            }
            res.push_back(v);
            state++;
        }
        return res;
    }
};
```

### 格雷码优化
- 利用格雷码每次只改变一个元素的特性，利用异或找出变化的元素，并判断应该加入元素还是删去元素
- 这样可以优化为非递归算法
```c++
class Solution {
public:
    vector<vector<int>> stateSubsets(vector<int>& nums) {
        int state = 0;
        int n = nums.size();
        int len = 1 << n;
        vector<vector<int>> res;
        while(state < len) {
            int s = state, j = 0;
            vector<int> v;
            while(s) {
                if(s & 1) {
                    v.push_back(nums[j]);
                }
                s >>= 1;
                j++;
            }
            res.push_back(v);
            state++;
        }
        return res;
    }
    
    vector<vector<int>> graySubsets(vector<int>& nums) {
        int state = 0;
        int n = nums.size();
        int len = 1 << n;
        vector<vector<int>> res;
        vector<int> v;
        res.push_back(v);
        int lastGray = 0;
        for(int i = 1; i < len; i++) {
            int gray = i ^ (i >> 1);
            int diff = gray ^ lastGray;
            int l = 0, r = n-1;
            int mid = (r - l)/2 + l;
            while(l <= r) {
                mid = (r - l)/2 + l;
                if((1<<mid) == diff) {
                    break;
                } else if((1<<mid) > diff) {
                    r = mid - 1;
                } else {
                    l = mid + 1;
                }
            }
            if((1 << mid) & gray) {
                v.push_back(nums[mid]);
            } else {
                v.erase(find(v.begin(), v.end(), nums[mid]));
            }
            res.push_back(v);
            lastGray = gray;
        }
        return res;
    }
    vector<vector<int>> subsets(vector<int>& nums) {
        // return stateSubsets(nums);
        return graySubsets(nums);
    }
};
```

## [89. 格雷编码](https://leetcode.cn/problems/gray-code/)

需要生成格雷码，格雷码每相邻两位都不同
`gi = i ^ (i >> 1)`

若i为偶数，i与i+1仅最低位不同，`i>>1`和`(i+1)>>1`相等，`gi^g(i+1) = i^(i+1) = 1`
若i为奇数，i最低位的0是第k位， i^(i+1) = k个1， (i >> 2)^((i+1) >> 2) = k-1个1，gi^g(i+1) = 仅第k位为1

```c++
class Solution {
public:
    vector<int> grayCode(int n) {
        int len = 1 << n;
        vector<int> res(len, 0);
        for(int i = 0; i < len; i++) {
            res[i] = i ^ (i >> 1);
        }
        return res;
    }
};
```

## 90. [子集 II](https://leetcode.cn/problems/subsets-ii/)

- 不具有不重复性，但具有无序性的特殊集合
- 统计每个元素的出现次数，将原数组去重
- 利用状态二进制位表示是否出现某某元素，对于每个元素，要考虑不同的出现次数，这个地方利用递归

```c++
class Solution {
public:
    vector<vector<int>> res;
    void push(vector<int>& nums, int state, int j, vector<int> vv) {
        
        while(state) {
            if(state & 1) {
                for(int i = 0; i < numsCnt[j]; i++) {
                    vv.push_back(nums[j]);
                    if(state >> 1)push(nums, state >> 1, j+1, vv);
                    else res.push_back(vv);
                }
                break;
            }
            state >>= 1;
            j++;
        }
    }
    vector<vector<int>> stateSubsets(vector<int>& nums, int n) {
        int state = 0;
        int len = 1 << n;
        res.push_back({});
        while(state < len) {
            push(nums, state, 0, {});
            state++;
        }
        return res;
    }
    vector<int> numsCnt;
    vector<vector<int>> subsetsWithDup(vector<int>& nums) {
        sort(nums.begin(), nums.end());
        int i = 0, j = 0;
        int n = nums.size();
        while(i < n) {
            nums[j] = nums[i];
            int cnt = i;
            while(i < n && nums[i] == nums[j]) i++;
            cnt = i - cnt;
            numsCnt.push_back(cnt);
            j++;
        }
        return stateSubsets(nums, j);
    }
};
```

## [187. 重复的DNA序列](https://leetcode.cn/problems/repeated-dna-sequences/)

- 将ATGC编码，通过编码之间的比较代替字符串比较
- 由于有四个状态，考虑使用两位来表示

```c++
class Solution {
public:
    vector<string> findRepeatedDnaSequences(string s) {
        auto code = make_pair(0, 0);
        int len = s.length();
        map<pair<int, int>, int> m;
        for(int i = 0; i < 10; i++) {
            code.first <<= 1;
            code.second <<= 1;
            if(s[i] == 'A') {
                code.first  |= 0;
                code.second |= 0;
            } else if(s[i] == 'C') {
                code.first  |= 1;
                code.second |= 0;
            } else if(s[i] == 'G') {
                code.first  |= 0;
                code.second |= 1;
            } else if(s[i] == 'T') {
                code.first  |= 1;
                code.second |= 1;
            } else {
                // unreachable
            }
        }
        m[code]++;
        vector<string> res;
        // cout << code[0].first << ", " << code[0].second << endl;
        for(int i = 10; i < len; i++) {
            int mask = 1024-1;
            code.first <<= 1;
            code.second <<= 1;
            code.first &= mask;
            code.second &= mask;
            if(s[i] == 'A') {
                code.first  |= 0;
                code.second |= 0;
            } else if(s[i] == 'C') {
                code.first  |= 1;
                code.second |= 0;
            } else if(s[i] == 'G') {
                code.first  |= 0;
                code.second |= 1;
            } else if(s[i] == 'T') {
                code.first  |= 1;
                code.second |= 1;
            } else {
                // unreachable
            }
            // cout << codei.first << ", " << codei.second << endl;
            m[code]++;
            if(m[code] == 2) {
                res.push_back(s.substr(i - 9, 10));
            }
        }
        return res;
    }
};
```

- 由于一次只存储长度为10的子串，编码时全都编码到同一个int，避免使用pair

```c++
class Solution {
public:
    unordered_map<char, int> bin = {{'A', 0}, {'C', 1}, {'G', 2}, {'T', 3}};
    vector<string> findRepeatedDnaSequences(string s) {
        auto code = 0;
        int len = s.length();
        unordered_map<int, int> m;
        for(int i = 0; i < 10; i++) {
            code <<= 2;
            code |= bin[s[i]];
        }
        m[code]++;
        // cout << code[0].first << ", " << code[0].second << endl;
        vector<string> res;
        int mask = (1 << 20) - 1;
        for(int i = 10; i < len; i++) {
            code <<= 2;
            code &= mask;
            code |= bin[s[i]];
            // cout << codei.first << ", " << codei.second << endl;
            m[code]++;
            if(m[code] == 2) {
                res.push_back(s.substr(i - 9, 10));
            }
        }
        return res;
    }
};
```

## [190. 颠倒二进制位](https://leetcode.cn/problems/reverse-bits/)

## [191. 位1的个数](https://leetcode.cn/problems/number-of-1-bits/description/)
这两个题没什么好说的，
```c++
class Solution {
    unordered_map<uint32_t, int> cache;
    unordered_map<uint32_t, int> cache_len;
public:
    int hammingWeight(uint32_t n) {
        uint32_t nn = n;
        if (cache[nn]) return cache[nn];
        while (n) {
            if (cache[n]) {
                cache[nn] += cache[n];
                cache_len[nn] += cache_len[n];
                n >>= cache_len[n];
            } else if (n & 1) {
                cache[nn]++;
                cache_len[nn]++;
            }
            n >>= 1;
        }
        return cache[nn];
    }
};
```

## [201. 数字范围按位与](https://leetcode.cn/problems/bitwise-and-of-numbers-range/description/)

将区间内的所有数字相与，得到结果

- 考虑特殊值，即二的幂次
- 如果`[left, right]`区间内出现了一个二的幂次，如`[3, 7]`内只出现了4，那么对于
  - 小于4的数，3=011，与4相与的结果都为0
  - 大于4的数，5=101，6=110，7=111，与4向与只有一个1
  - 之前出现过0，所以结果为0
- 如果区间内出现了大于一个二的幂次，`a, b（a < b`利用上面的结论，也可以得到结果为0
- 如果区间内没有出现2的幂次，也说明`left, right`之间的所有数字最高位都为1，结果至少为1，抛弃最高位，重复以上过程，可以依次找到后续位相与后是否有1

```c++
class Solution {
public:
    inline unsigned highestBit(int n) {
        return 1 << (sizeof(unsigned) * CHAR_BIT - 1 - __builtin_clz(n));
    }
    int rangeBitwiseAnd(int left, int right) {
        int ret = 0;
        // printf("%x, %x\n", left, right);
        while (left) {
            unsigned highest = highestBit(left);
            // cout << highest << endl;
            if ((highest << 1) <= right) return ret;
            ret |= highest;
            left &= ~highest;
            right &= ~highest;
        }

        return ret;
    }
};
```

## [222. 完全二叉树的节点个数](https://leetcode.cn/problems/count-complete-tree-nodes/)

### 一般方法
遍历全部节点计数
```c++
class Solution {
public:
    int countNodes(TreeNode* root) {
        return (root ? (1 + countNodes(root->left) + countNodes(root->right)): 0);
    }
};
```

### 二分
- 完全二叉树的高度很好算，然后就可以算出满二叉树的节点个数
- 对于满二叉树，节点标号的二进制序列就是从root到节点的路径
- 利用二分查找，寻找最右侧存在的节点，利用第二点的性质查找节点，复杂度为`O(log^2(N))`

```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
class Solution {
public:
    int getMaxDepth(TreeNode *root) {
        int maxDepth = 0;
        while(root) {
            root = root->left;
            maxDepth++;
        }
        return maxDepth;
    }
    bool contains(TreeNode *root, int n, int maxDepth) {
        int mask = 1 << (maxDepth - 1);
        while(root) {
            mask >>= 1;
            if(mask & n) {
                root = root->right;
            } else {
                root = root->left;
            }
        }
        return mask == 0;
    }
    int countNodes(TreeNode* root) {
        int maxDepth = getMaxDepth(root);
        if(maxDepth <= 0) return 0;
        int l = ((1 << (maxDepth-1))), r = ((1 << (maxDepth)) - 1);
        while(l < r) {
            int mid = (r - l + 1) / 2 + l;
            if(contains(root, mid, maxDepth)) {
                l = mid;
            } else {
                r = mid - 1;
            }
        }
        return l;
    }
};
```

## [231. 2 的幂](https://leetcode.cn/problems/power-of-two/)

- 判断一个数是否数2的幂，也就是只有一个二进制位，且为正数

```c++
class Solution {
public:
    bool isPowerOfTwo(int n) {
        return n > 0 && (n &(n-1)) == 0;
    }
};
```

## [342. 4的幂](https://leetcode.cn/problems/power-of-four/)

- 也就是只有一个二进制位，且是偶数次幂的位，且不是第0位，而且是正数

```c++
class Solution {
public:
    bool isPowerOfFour(int n) {
        return (!(n&0xaaaaaaaa) && n > 0 && !(n&(n-1)));
    }
};
```

## [287. 寻找重复数](https://leetcode.cn/problems/find-the-duplicate-number/description/)

- 没做出来，再接再厉

## [318. 最大单词长度乘积](https://leetcode.cn/problems/maximum-product-of-word-lengths/)

- 要求不包含相同字母
- 可以将字符串含有的字符编码成二进制，利用与运算的结果判断是否有相同字符

```c++
class Solution {
public:
    int maxProduct(vector<string>& words) {
        int n = words.size();
        map<int, int> bitMap;
        for(int i = 0; i < n; i++) {
            int mask = 0;
            for(auto ite = words[i].rbegin(); ite != words[i].rend(); ite++) {
                mask |= 1 << (*ite - 'a');
            }
            bitMap[mask] = max(bitMap[mask], (int)words[i].length());
        }
        int maxRes = 0;
        for(auto ite = bitMap.begin(); ite != bitMap.end(); ite++) {
            map<int, int>::iterator jte = ite;
            jte++;
            for(; jte != bitMap.end(); jte++) {
                if((ite->first & jte->first) == 0) maxRes = max(maxRes, ite->second * jte->second);
            }
        }
        return maxRes;
    }
};
```

## 338. 比特位计数

- 要求寻找`[0,n]`中所有数的比特位数
- 没做出来，再接再厉
- dp，对于偶数，二进制数等于(i >> 2),对于奇数，等于(i >> 2) + 1

```c++
class Solution {
public:
    vector<int> countBits(int num) {
        vector<int> ans(num+1, 0);
        for(int i = 1; i <= num; i++) {
            ans[i] = ans[i >> 1] + (i & 1);
        }
        return ans;
    }
};
```

## [371. 两整数之和](https://leetcode.cn/problems/sum-of-two-integers/description/)
- 复习一下数电的知识就好啦

```c++
// 0 0 0 0 0
// 0 0 1 1 0
// 0 1 0 1 0
// 0 1 1 0 1 ~abc
// 1 0 0 1 0
// 1 0 1 0 1 a~bc
// 1 1 0 0 1 ab~c
// 1 1 1 1 1 abc
// ~abc + a~bc + ab~c + abc
// bc + a(~bc+b~c)
// bc + a(b^c)
```

```c++
class Solution {
public:
    int getSum(int a, int b) {
        int carry = 0;
        int sum = 0;
        int mask = 1;
        for(int i = 0; i < 32; i++) {
            sum |= (a ^ b ^ carry) & mask;
            carry = (b&carry) | (a & (b ^ carry));
            carry <<= 1;
            mask <<= 1;
        }
        return sum;
    }
};
```

## [389. 找不同](https://leetcode.cn/problems/find-the-difference/description/)
居然没想到，长大后再试试吧

## [393. UTF-8 编码验证](https://leetcode.cn/problems/utf-8-validation/description/)
主要是应用位运算，还是关系不大

```c++
class Solution {
public:
    bool validUtf8(vector<int>& data) {
        int n = data.size();
        for(int i = 0; i < n; i++) {
            int cnt = (0xf8 & data[i]) >> 3;
            // printf("%x, %x\n", cnt, data[i]);
            if(cnt < 0x10) {
                cnt = 0;
            } else if(cnt >= 0x18 && cnt < 0x1c) {
                cnt = 1;
            } else if(cnt >= 0x1c && cnt < 0x1e) {
                cnt = 2;
            } else if(cnt == 0x1e) {
                cnt = 3;
            } else {
                return false;
            }
            while(cnt--) {
                i++;
                if(i >= n) return false;
                if((data[i] & 0xc0) != 0x80) return false;
            }
        }
        return true;
    }
};
```

## [397. 整数替换](https://leetcode.cn/problems/integer-replacement/description/)

### 暴力+记忆优化

```c++
class Solution {
    unordered_map<int, int> cnt;
public:
    int integerReplacement(int n) {
        if(cnt.count(n)) return cnt[n];
        if(n == 1) cnt[n] = 0;
        else if(n&1) cnt[n] =  2 + min(integerReplacement(n>>1), integerReplacement((n>>1) + 1));
        else cnt[n] =  1 + integerReplacement(n >> 1);
        return cnt[n];
    }
};
```

### 贪心

- 偶数，直接除以2
- 奇数，除以4余数为1，-1，相当于尽量避免奇数的出现，延迟奇数的出现，因为奇数操作数是2，偶数是1
- 奇数，除以4余数为3，+1，相当于尽量避免奇数的出现，延迟奇数的出现，因为奇数操作数是2，偶数是1
```c++
class Solution {
    unordered_map<int, int> cnt;
public:
    int integerReplacement(int n) {
        cnt[3] = 2;
        if(cnt.count(n)) return cnt[n];
        int nn = n;
        while(n > 1) {
            int add = 0;
            if(!(n&1)) {
                add = 1;
                n >>= 1;
            } else {
                add = 2;
                if((n >> 1) & 1) {
                    n >>= 1;
                    n++;
                } else {
                    n >>= 1;
                }
            }
            if(cnt.count(n)) {
                cnt[nn] += add + cnt[n];
                break;
            }
            cnt[nn] += add;
        }
        return cnt[nn];
    }
};
```

## [401. 二进制手表](https://leetcode.cn/problems/binary-watch/)
利用二进制做状态

### 状态+检查bitCount
```c++
class Solution {
public:
    int bitCount(int n) {
        int cnt = 0;
        while(n) {
            if(n & 1) cnt++;
            n >>= 1;
        }
        return cnt;
    }
    vector<string> readBinaryWatch(int turnedOn) {
        vector<string> res;
        for(int h = 0; h < 16; h++) {
            for(int m = 0; m < 64; m++) {
                if(bitCount(h) + bitCount(m) != turnedOn) continue;
                char time[6];
                if(h >= 0 && h < 12 && m >= 0 && m < 60) {
                    sprintf(time, "%d:%02d", h, m);
                    res.push_back(time);
                }
            }
        }
        return res;
    }
};
```

### 格雷码

用格雷码的特性，bitcount每次只会加1或减一，省去bitcounts的计算

```c++
class Solution {
public:
    vector<string> readBinaryWatch(int turnedOn) {
        vector<string> res;
        int hBitCount = 0;
        int H = 0;
        int lastH = 0, lastM = 0;
        for(int h = 0; h < 16; h++) {
            int M = 0;
            int mBitCount = 0;
            lastH = H;
            H =  h^(h >> 1);
            if(H & (lastH ^ H)) hBitCount++;
            else if(h) hBitCount--;
            // printf("H=%x, hBitCount=%d\n", H, hBitCount);
            for(int m = 0; m < 64; m++) {
                lastM = M;
                M = m^(m >> 1);
                if(M & (lastM ^ M)) mBitCount++;
                else if(m) mBitCount--;
                // printf("M=%x, mBitCount=%d\n", M, mBitCount);
                if(hBitCount + mBitCount != turnedOn) continue;
                char time[6];
                if(H >= 0 && H < 12 && M >= 0 && M < 60) {
                    sprintf(time, "%d:%02d", H, M);
                    res.push_back(time);
                }
            }
        }
        return res;
    }
};
```

## [405. 数字转换为十六进制数](https://leetcode.cn/problems/convert-a-number-to-hexadecimal/description/)

```c++
class Solution {
    static constexpr int m[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
public:
    string toHex(int num) {
        int cnt = 8;
        string res;
        while(cnt-- && !(0xf & (num >> (cnt * 4))));
        if(cnt >= 0) do {
            res.push_back(m[0xf & (num >> (cnt * 4))]);
        } while(cnt--);
        else return "0";
        return res;
    }
};
```

## [421. 数组中两个数的最大异或值](https://leetcode.cn/problems/maximum-xor-of-two-numbers-in-an-array/)

没写出来，题解也是一位一位的算

## 总结
- 技巧一：利用二进制做状态码
- 技巧二：计科基础，加法器、数电
- 技巧三：利用二进制减少计算量，对状态少的数据进行编码，用位运算一次计算多个数据
- 技巧四：考察[常用技巧](#位运算常见技巧)
- 技巧五：利用格雷码优化
- 技巧六：逐位计算结果