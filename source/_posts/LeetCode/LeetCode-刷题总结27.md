---
title: LeetCode-27
date: 2023-10-28 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## <font color="orange">[Medium] </font>[29. 两数相除](https://leetcode.cn/problems/divide-two-integers/description/)

### 分析
- 只能用加减法，最朴素的方法是循环相减/加，直到小于0/大于0，计算加/减的次数
- 这样算法是o(n)，考虑到`i+=i`或者`i<<=1`相当于`i*=2`,`i>>=1`相当于`i/=2`
- 只考虑divisor, divident都大于0的情况，先找到整数p，使得 $divisor*2^p <= divident$，$divident-=divisor*2^p, ratio+=2^p$若divident为0，则商为ratio，否则重复上面的过程，直到divident为0。
- 考虑divisor, divident到可能正，可能负，而负数的范围大于正数，直接将所有整数变成负数，并记录符号
- 注意取相反数的时候要用位运算`~x+1`
- 
### 代码
```c++
class Solution {
public:
    int divide(int dividend, int divisor) {
        if(dividend < divisor && dividend > 0) return 0;
        if(dividend > divisor && dividend < 0) return 0;
        if((dividend == INT_MIN) && (divisor == -1)) return INT_MAX;
        if((dividend == INT_MIN) && (divisor == 1)) return INT_MIN;
        if(dividend == divisor) return 1;
        if(dividend < 0 && divisor > 0 && dividend == ~divisor+1) return -1;
        if(dividend > 0 && divisor < 0 && ~dividend+1 == divisor) return -1;
        bool sign = false;
        if(dividend < 0) {
            sign = !sign;
        } else {
            dividend = ~dividend+1;
        }
        if(divisor < 0) {
            sign = !sign;
        } else {
            divisor = ~divisor+1;
        }
        int res = 0;
        int i = -1;
        while(dividend < divisor && divisor >= (INT_MIN >> 1)) {
            divisor += divisor;
            i+=i;
        }
        while(true) {
            while(dividend > divisor) {
                if(i == -1) {
                    return sign ? (res) : (~res+1);
                }
                divisor >>= 1;
                i>>=1;
            }
            dividend -= divisor;
            res+=i;
        }
    }
};
```
## [275. H 指数 II](https://leetcode.cn/problems/h-index-ii/description/?envType=daily-question&envId=2023-10-30)

### 代码
```c++
class Solution {
public:
    int hIndex(vector<int>& citations) {
        int n = citations.size();
        int l = 0, r = n-1;
        int res = 0;
        while(l < r) {
            int mid = (r - l) / 2 + l;
            if(n - mid <= citations[mid]) {
                res = max(res, n-mid);
                r=mid-1;
            } else {
                res = max(res, citations[mid]);
                l = mid+1;
            }
        }
        return max(res, min(citations[l], n-l));
    }
};
```

### 优化
```c++
class Solution {
public:
    int hIndex(vector<int>& citations) {
        int n = citations.size();
        int l = 0, r = n-1;
        int res = 0;
        while(l <= r) {
            int mid = (r - l) / 2 + l;
            if(n - mid <= citations[mid]) {
                r=mid - 1;
            } else {
                l = mid+1;
            }
        }
        return n-l;
    }
};
```

## [274. H 指数](https://leetcode.cn/problems/h-index/description/?envType=daily-question&envId=2023-10-29)

### 代码

```c++
class Solution {
public:
    int hIndex(vector<int>& citations) {
        int arr[1001] = {0};
        int max_cite = 0;
        int min_cite = INT_MAX;
        for(int n : citations) {
            arr[n]++;
            max_cite = max(max_cite, n);
            min_cite = min(min_cite, n);
        }
        int sum = 0, res = 0;
        for(int i = max_cite; i >= min_cite; i--) {
            sum += arr[i];
            res = max(res, min(sum, i));
        }
        return res;
    }
};
```

## [2558. 从数量最多的堆取走礼物](https://leetcode.cn/problems/take-gifts-from-the-richest-pile/description/?envType=daily-question&envId=2023-10-28)

```c++
class Solution {
public:
    long long pickGifts(vector<int>& gifts, int k) {
        priority_queue<int> gift_heap;
        for(int n : gifts) {
            gift_heap.push(n);
        }
        long long res = 0;
        while(k--) {
            gift_heap.push(sqrt(gift_heap.top()));
            gift_heap.pop();
        }
        while(!gift_heap.empty()) {
            res += gift_heap.top();
            gift_heap.pop();
        }
        return res;
    }
};
```

## [1465. 切割后面积最大的蛋糕](https://leetcode.cn/problems/maximum-area-of-a-piece-of-cake-after-horizontal-and-vertical-cuts/description/?envType=daily-question&envId=2023-10-27)

```c++
class Solution {
public:
    int maxArea(int h, int w, vector<int>& horizontalCuts, vector<int>& verticalCuts) {
        int h_len = horizontalCuts.size();
        int v_len = verticalCuts.size();
        sort(verticalCuts.begin(), verticalCuts.end());
        sort(horizontalCuts.begin(), horizontalCuts.end());
        int max_h = max(h - horizontalCuts.back(), horizontalCuts.front());
        int max_v = max(w - verticalCuts.back(), verticalCuts.front());
        for(int i = 1; i < h_len; i++) {
            max_h = max(max_h, horizontalCuts[i] - horizontalCuts[i-1]);
        }
        for(int i = 1; i < v_len; i++) {
            max_v = max(max_v, verticalCuts[i] - verticalCuts[i-1]);
        }
        return ((long long)(max_h)%1000000007 * (max_v)%1000000007) % 1000000007;
    }
};
```

## [2520. 统计能整除数字的位数](https://leetcode.cn/problems/count-the-digits-that-divide-a-number/description/?envType=daily-question&envId=2023-10-26)

```c++
class Solution {
public:
    int countDigits(int num) {
        int n = num;
        int ret = 0;
        while(n) {
            if(num % (n % 10) == 0) {
                ret++;
            }
            n /= 10;
        }
        return ret;
    }
};
```

## [2698. 求一个整数的惩罚数](https://leetcode.cn/problems/find-the-punishment-number-of-an-integer/description/?envType=daily-question&envId=2023-10-25)

### 思路
- 首先要计算出所有满足sum(split(i*i)) == i的元素
- 发现很少，直接放到数组里去查表
- 对于一个数i，希望它拆分后和等于target
  - 先分成a，b两份，判断是否等于，等于return true，不等于就把a分开（递归）

### 代码
```c++
class Solution {
public:
    int punishmentNumber(int n) {
        int res = 0;
        // for(int i = 1; i <= 1000; i++) {
        //     int n = i*i;
        //     if(search(i*i, i)) {
        //         cout << i << ", ";
        //     }
        // }
        int punish_arr[] = {1, 9, 10, 36, 45, 55, 82, 91, 99, 100, 235, 297, 369, 370, 379, 414, 657, 675, 703, 756, 792, 909, 918, 945, 964, 990, 991, 999, 1000};
        int len = sizeof(punish_arr)/sizeof(int);
        for(int i = 0; i < len; i++) {
            if(n >= punish_arr[i]) res += punish_arr[i]*punish_arr[i];
        }
        return res;
    }
    bool search(int i, int target) {
        int n = i;
        int base = 1;
        int r = 0;
        while(n) {
            r += base*(n%10);
            if(r+n/10 == target) {
                return true;
            } else {
                if(search(n/10, target - r)){
                    return true;
                }
            }
            n /= 10;
            base *= 10;
        }
        return false;
    }
};
```

## [1155. 掷骰子等于目标和的方法数](https://leetcode.cn/problems/number-of-dice-rolls-with-target-sum/description/?envType=daily-question&envId=2023-10-24)
### 思路
- 先暴力递归，然后发现可以总结出dp公式，然后把递归改成dp尝试，成功了
### 代码
```c++
class Solution {
public:
    vector<vector<int>> dp;
    int numRollsToTarget(int n, int k, int target) {
        dp = vector<vector<int>>(30+1, vector<int>(1000+1, 0));
        dp[0][0] = 1;
        for(int i = 1; i <= n; i++) {
            for(int t = 1; t <= target; t++)
                for(int K = 1;K <= k; K++)
                    if(t >= K)
                        dp[i][t] = (dp[i][t] + dp[i-1][t-K]) % 1000000007;
        }
        return dp[n][target];
    }
    int search(int n, int k, int target) {
        if(target == 0 && n == 0) {
            return 1;
        } else if(n == 0) return 0;
        int res = 0;
        for(int i = 1; i <= k; i++) {
            if(target >= i) {
                res += numRollsToTarget(n-1, k, target-i);
            }
        }
        return res;
    }
};
```

### 优化

观察代码可知，dp[i][t]就是dp[i-1][t-1]+...dp[i-1][t-k]，可以用前缀和优化
```c++
class Solution {
public:
    vector<vector<int>> dp;
    int numRollsToTarget(int n, int k, int target) {
        dp = vector<vector<int>>(30+1, vector<int>(1000+1,0));
        dp[0][0] = 1;
        for(int i = 1; i <= n; i++) {
            for(int t = 1; t <= target; t++) {
                dp[i][t] = (dp[i][t-1] + dp[i-1][t-1]) % 1000000007;
            }
            for(int t = target; t >= k; t--) {
                dp[i][t] = (dp[i][t] - dp[i][t-k] + 1000000007) % 1000000007;
            }
        }
        return dp[n][target];
    }
};
```

## [1402. 做菜顺序](https://leetcode.cn/problems/reducing-dishes/description/?envType=daily-question&envId=2023-10-22)
- 一眼dp，鉴定为，纯纯的简单题
- 一遍就做对啦哈哈哈
```c++
class Solution {
public:
    int maxSatisfaction(vector<int>& satisfaction) {
        int n = satisfaction.size();
        vector<int> dp(n+1, 0);
        vector<int> sums(n+1, 0);
        sums[0] = accumulate(satisfaction.begin(), satisfaction.end(), 0);
        sort(satisfaction.begin(), satisfaction.end(), less<int>());
        for(int i = 0; i < n; i++) {
            dp[0] += (i+1) * satisfaction[i];
        }
        for(int i = 1; i <= n; i++) {
            if(dp[i-1] < dp[i-1] - sums[i-1]) {
                dp[i] = dp[i-1] - sums[i-1];
                sums[i] = sums[i-1] - satisfaction[i-1];
            } else {
                dp[i] = dp[i-1];
                sums[i] = sums[i-1];
            }
        }
        return dp[n];
    }
};
```

## 优化

dp数组和sum数组可以优化掉

```c++
class Solution {
public:
    int maxSatisfaction(vector<int>& satisfaction) {
        int n = satisfaction.size();
        int dp = 0;
        int sums = 0;
        sort(satisfaction.begin(), satisfaction.end());
        for(int i = 0; i < n; i++) {
            dp += (i+1) * satisfaction[i];
            sums += satisfaction[i];
        }
        for(int i = 1; i <= n; i++) {
            if(dp < dp - sums) {
                dp = dp - sums;
                sums = sums - satisfaction[i-1];
            }
        }
        return dp;
    }
};
```

## [2678. 老人的数目](https://leetcode.cn/problems/number-of-senior-citizens/description/?envType=daily-question&envId=2023-10-23)
```c++
class Solution {
public:
    int countSeniors(vector<string>& details) {
        int res = 0;
        for(const string &laodeng : details) {
            if((laodeng[11] == '6' && laodeng[12] > '0') || (laodeng[11] > '6' && laodeng[12] >= '0')) res++;
        }
        return res;
    }
};
```

## [2316. 统计无向图中无法互相到达点对数](https://leetcode.cn/problems/count-unreachable-pairs-of-nodes-in-an-undirected-graph/description/?envType=daily-question&envId=2023-10-21)
```c++
class Solution {
public:
    vector<vector<int>> g;
    vector<bool> visited;
    long long countPairs(int n, vector<vector<int>>& edges) {
        g = move(vector<vector<int>>(n, vector<int>()));
        visited = move(vector<bool>(n, false));
        for(const vector<int>& edge : edges) {
            g[edge[0]].push_back(edge[1]);
            g[edge[1]].push_back(edge[0]);
        }
        long long res = 0;
        for(int i = 0; i < n; i++) {
            if(!visited[i]) {
                long long node_num = count_nodes(i);
                res += (n - node_num) * node_num;
            }
        }
        return res >>  1;
    }
    int count_nodes(int root) {
        visited[root] = true;
        int res = 1;
        for(int child : g[root]) {
            if(!visited[child])
                res += count_nodes(child);
        }
        return res;
    }
};
```

### 并查集
- 这里一直写不出来，发现并查集无法把所有相连的点归到一个集合中，因为在遍历的时候没有用union操作
```c++
class Solution {
public:
    vector<int> s;
    int find(int x) {
        return x == s[x] ? x : (s[x] = find(s[x]));
    }
    long long countPairs(int n, vector<vector<int>>& edges) {
        s = move(vector<int>(n, 0));
        vector<int> cnt = move(vector<int>(n, 0));
        iota(s.begin(), s.end(), 0);
        size_t elen = edges.size();
        for(int j = 0; j < elen; j++) {
            s[find(edges[j][1])] =  find(edges[j][0]);
        }
        for(int i = 0; i < n; i++) {
            cnt[find(i)]++;
        }
        long long res = 0;
        for(int i = 0; i < n; i++) {
            res += (n - (long long)cnt[i])*cnt[i];
        }
        return res >> 1;
    }
};
```

### 继续优化
- 换个公式减少一次循环
```c++
class Solution {
public:
    vector<int> s;
    int find(int x) {
        return x == s[x] ? x : (s[x] = find(s[x]));
    }
    long long countPairs(int n, vector<vector<int>>& edges) {
        s = move(vector<int>(n, 0));
        vector<int> cnt = move(vector<int>(n, 0));
        iota(s.begin(), s.end(), 0);
        size_t elen = edges.size();
        for(int j = 0; j < elen; j++) {
            s[find(edges[j][1])] =  find(edges[j][0]);
        }
        long long res = 0;
        for(int i = 0; i < n; i++) {
            res += cnt[find(i)]++;
        }
        return (long long)n*(n-1)/2 - res;
    }
};
```

## [2525. 根据规则将箱子分类](https://leetcode.cn/problems/categorize-box-according-to-criteria/description/?envType=daily-question&envId=2023-10-20)

```c++
class Solution {
public:
    string categorizeBox(int length, int width, int height, int mass) {
        bool bulky = length >= 10000 || height >= 10000 || width >= 10000 || (long long)length*width*height >= 1000000000;
        bool heavy = mass >= 100;
        if(bulky &&  heavy) return "Both";
        else if(!bulky && !heavy) return "Neither";
        else if(bulky && !heavy) return "Bulky";
        else return "Heavy";
    }
};
```