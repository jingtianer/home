---
title: LeetCode-17
date: 2022-11-01 18:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## [1662. 检查两个字符串数组是否相等](https://leetcode.cn/problems/check-if-two-string-arrays-are-equivalent/)

```c++
class Solution {
public:
    bool arrayStringsAreEqual(vector<string>& word1, vector<string>& word2) {
        return join(move(word1)) == join(move(word2));
    }
    string join(vector<string>&& word) {
        string s;
        int len = word.size();
        if(len <= 0) return s;
        for(int i = 0; i < len-1; i++) {
            s += word[i];
        }
        s+=word[len-1];
        return s;
    }
};
```

> 实现一个join函数就好了

## [481. 神奇字符串](https://leetcode.cn/problems/magical-string/)

```c++
class Solution {
public:
    int magicalString(int n) {
        int bit = 3;
        int count = 1;
        bool q[100005] = {false};
        int queue_front = 0;
        int queue_rear = 0;
        bool cur=1;
        bool gen=0;
        while(bit < n) {
            bit += cur+1;
            q[queue_front++] = gen;
            if(cur) {
                q[queue_front++] = gen;
            }
            gen=1-gen;
            count+=gen?cur+gen:0;
            cur = q[queue_rear++];
        }
        return count -(bit>n && gen);
    }
};
```

> 关键在于想清楚如何生成这个神奇字符串，题目中说，s的前几个字符是12211
> 1生成1,s=1
> 2生成22，因为前一个1生成了1，这个2不能也生成1,s=122
> 2生成11，因为前一个2生成了2，这个2不能也生成2,s=12211
> 1生成2，前一个2生成了1，这个1就只能生成2了,s=122112
> 1生成1,s=1221121
> 2生成22,s=122112122

> 只要有前三个字符122，即可生成全部字符

## [784. 字母大小写全排列](https://leetcode.cn/problems/letter-case-permutation/)

```c++
class Solution {
public:
vector<string> res;
int len;
    vector<string> letterCasePermutation(string s) {
        len = s.size();
        search(s, 0);
        return res;
    }
    void search(string s, int index) {
        if(index>=len) {
            res.emplace_back(s);
            return;
        }
        if(isalpha(s[index])) {
            search(s,index+1);
            if(isupper(s[index])) {
                s[index] = s[index]-'A'+'a';
            } else {
                s[index] = s[index]-'a'+'A';
            }
            search(s, index+1);
        } else {
            search(s, index+1);
        }
    }
};
```

> 搜! 搜就完了

### 优化

- 可以搜索下一个alpha的位置，不必每个字符都递归，节省递归深度

```c++
class Solution {
public:
vector<string> res;
int len;
    vector<string> letterCasePermutation(string s) {
        len = s.size();
        search(s, nextAlpha(s, 0));
        return res;
    }
    void search(string& s, int index) {
        if(index>=len) {
            res.emplace_back(s);
            return;
        }
        int next=nextAlpha(s, index+1);
        search(s,next);
        if(isupper(s[index])) {
            s[index] = s[index]-'A'+'a';
        } else {
            s[index] = s[index]-'a'+'A';
        }
        search(s, next);
    }
    int nextAlpha(string& s, int index){
        while(index<len && !isalpha(s[index])) index++;
        return index;
    }
};
```

## [1773. 统计匹配检索规则的物品数量](https://leetcode.cn/problems/count-items-matching-a-rule/)

```c++
class Solution {
public:
    int countMatches(vector<vector<string>>& items, string ruleKey, string ruleValue) {
        int index=0;
        if(ruleKey[0]=='c') {
            index=1;
        } else if(ruleKey[0]=='n') {
            index=2;
        }
        int count = 0;
        for(auto &&item : items) {
            if(!item[index].compare(ruleValue)) {
                count++;
            }
        }
        return count;
    } 
};
```

> 感觉直接比较第0个字符应该也很快吧？

## [907. 子数组的最小值之和](https://leetcode.cn/problems/sum-of-subarray-minimums/)

```c++
class Solution {
public:
    int sumSubarrayMins(vector<int>& arr) {
        int n = arr.size();
        vector<int> monoStack;
        vector<int> left(n), right(n);
        for (int i = 0; i < n; i++) {
            while (!monoStack.empty() && arr[i] <= arr[monoStack.back()]) {
                monoStack.pop_back();
            }
            // 小于栈内元素，则
            left[i] = i - (monoStack.empty() ? -1 : monoStack.back());
            // 若空，则放入下一个序号，否则是与前一个数的距离
            monoStack.emplace_back(i);
        }
        // 得到一个单增的栈
        //只需要找到每个元素 arr[i] 以该元素为最右且最小的子序列的数目 left[i]，以及以该元素为最左且最小的子序列的数目 right[i]，则以 arr[i] 为最小元素的子序列的数目合计为 left[i]×right[i]
        monoStack.clear();
        for (int i = n - 1; i >= 0; i--) {
            while (!monoStack.empty() && arr[i] < arr[monoStack.back()]) {
                monoStack.pop_back();
            }
            right[i] = (monoStack.empty() ? n : monoStack.back()) - i;
            monoStack.emplace_back(i);
        }
        long long ans = 0;
        long long mod = 1e9 + 7;
        for (int i = 0; i < n; i++) {
            ans = (ans + (long long)left[i] * right[i] * arr[i]) % mod; 
        }
        return ans;
    }
};
```

> 看了答案才会，想到是用单调栈，但是没有思路
> $ left \times right $ 的原因是，n个元素的连续子数组的个数为 $ n \times (n-1) $


## [1620. 网络信号最好的坐标](https://leetcode.cn/problems/coordinate-with-maximum-network-quality/)

```c++
class Solution {
public:
    int len;
    int Power(int x, int y, vector<vector<int>>& towers, int radius) {
        int power = 0;
        for(int j = 0; j < len; j++) {
            double d = sqrt((towers[j][0]-x)*(towers[j][0]-x) + (towers[j][1]-y)*(towers[j][1]-y));
            if(d <= radius) {
                power += towers[j][2]/(1+d);
            }
        }
        return power;
    }
    vector<int> bestCoordinate(vector<vector<int>>& towers, int radius) {
        int resx = 0, resy = 0;
        len = towers.size();
        int maxPower = 0;
        for(int x = 0; x <= 100; x++) {
            for(int y = 0; y <= 100; y++) {
                int power = Power(x, y, towers, radius);
                if(power > maxPower) {
                    maxPower = power;
                    resx = x;
                    resy = y;
                } else if(power == maxPower) {
                    bool smaller = (x < resx) || (x == resx && y < resy);
                    if(smaller) {
                        resx = x;
                        resy = y;
                    }
                }
            }
        }
        return {resx, resy};
    }
};
```

> 暴力！！就暴力，看见题干就完了，搜索空间有多大我就搜多大哈哈哈哈或或

### 优化
```c++
class Solution {
public:
    int len;
    int Power(int x, int y, vector<vector<int>>& towers, int radius) {
        int power = 0;
        for(int j = 0; j < len; j++) {
            double d = sqrt((towers[j][0]-x)*(towers[j][0]-x) + (towers[j][1]-y)*(towers[j][1]-y));
            if(d <= radius) {
                power += towers[j][2]/(1+d);
            }
        }
        return power;
    }
    vector<int> bestCoordinate(vector<vector<int>>& towers, int radius) {
        int resx = 0, resy = 0;
        len = towers.size();
        int maxPower = 0;
        for(int x = 0; x <= 50; x++) {
            for(int y = 0; y <= 50; y++) {
                int power = Power(x, y, towers, radius);
                if(power > maxPower) {
                    maxPower = power;
                    resx = x;
                    resy = y;
                }
            }
        }
        return {resx, resy};
    }
};
```

> 大于50的就没必要了，只会衰减