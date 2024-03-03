---
title: LeetCode-dp
date: 2022-11-08 11:14:34
tags:
    - LeetCode 
    - 动态规划
    - LeetCode 101
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

> leetcode 101的动态规划专题

## 基本动态规划：一维
### [70. 爬楼梯](https://leetcode.cn/problems/climbing-stairs/)

```c++
class Solution {
public:
    int climbStairs(int n) {
        int a=1,b=2;
        if(n<2) return 1; 
        for(int i = 2; i <n ; i++) {
            int c = a+b;
            a=b;
            b=c;
        }
        return b;
    }
};
```

> dp数组表示上n层楼有几种可能
> 转移方程是 $ dp[i] = dp[i-1] + dp[i-2] $
> 上到第i层有可能从第i-1层或i-2层上来，则上到i层的可能数目就是 $ dp[i-1] + dp[i-2] $ 
> 由于dp[i]只需要前两个数的数据，所以可以优化掉dp数组，用两个变量代替，节省数组空间


### [198. 打家劫舍](https://leetcode.cn/problems/house-robber/)

#### 状态记录
```c++
class Solution {
public:
    int n;
    vector<int> mem;
    int rob(vector<int>& nums) {
        this->n = nums.size();
        mem = vector<int>(n+2, -1);
        return maxRob(nums, -2);
    }
    int maxRob(const vector<int>& nums, int i) {
        if(i < n && mem[i+2] != -1) return mem[i+2];
        int a = (i+2 < n ? maxRob(nums, i+2) + nums[i+2] : 0);
        int b = (i+3 < n ? maxRob(nums, i+3) + nums[i+3] : 0);
        mem[i+2] = (a > b? a : b);
        return mem[i+2];
    }
};
```

> 这是之前实习时写的代码思路不是dp，而是自上而下的带有状态记录的优先搜索
> 思路相同，就是，若打劫i，则一定不能打劫i+1，考虑是打劫i+2还是i+3
> 状态转移方程 $ dp[i] = nums[i] + max(dp[i+2], dp[i+3]) $

#### dp
```c++
class Solution {
public:
    int rob(vector<int>& nums) {
        int len = nums.size();
        vector<int> dp(len);
        if(len == 1) {
            return nums[len-1];
        } else if(len == 2) {
            return max(nums[len-1], nums[len-2]);
        }
        dp[len-1] = nums[len-1];
        dp[len-2] = max(nums[len-1], nums[len-2]);
        dp[len-3] = max(nums[len-2], nums[len-3] + dp[len-1]);
        for(int i = len-4; i >= 0; i--) {
            dp[i] = nums[i] + max(dp[i+3], dp[i+2]);
        }
        return max(dp[0], dp[1]);
    }
};
```

> 由于第0家可以打劫，也可以跳过，所以最终结果是 $ max(dp[0], dp[1]) $

> 同上，也可以优化存储空间

```c++
class Solution {
public:
    int rob(vector<int>& nums) {
        int len = nums.size();
        if(len == 1) {
            return nums[len-1];
        } else if(len == 2) {
            return max(nums[len-1], nums[len-2]);
        }
        int a = nums[len-1],b = max(nums[len-1], nums[len-2]), c = max(nums[len-2], nums[len-3] + nums[len-1]);
        for(int i = len-4; i >= 0; i--) {
            int d = nums[i] + max(a, b);
            a = b;b = c;c = d;
        }
        return max(b, c);
    }
};
```

### [121. 买卖股票的最佳时机](https://leetcode.cn/problems/best-time-to-buy-and-sell-stock/)

```c++
class Solution {
public:
    int maxProfit(vector<int>& prices) {
        int len = prices.size();
        int minPos = len-1;
        int maxx = prices[len-1];
        int maxx1 = prices[len-1];
        for(int i = len-2; i >= 0; i--) {
            maxx1 = max(prices[i], maxx1);
            if(maxx1 - prices[i] > maxx - prices[minPos]) {
                minPos = i;
                maxx = maxx1;
            }
        }
        return maxx - prices[minPos];
    }
};
```

> 记maxx数组中 $ maxx[i] $ 表示 $ max(prices[j]); j = i,i+1,...,n-1 $
> 假设在第i天买入，则应该在第i天后售价最高的一天卖出，也就是 $ maxx[i] $
> 再把maxx数组优化掉 


### [413. 等差数列划分](https://leetcode.cn/problems/arithmetic-slices/)

```c++
class Solution {
public:
    int numberOfArithmeticSlices(vector<int>& nums) {
        int len = nums.size();
        if(len < 3) return 0;
        int i = 2;
        int ans = 0;
        int count = 2;
        while(i < len) {
            while(i < len && nums[i] - nums[i-1] == nums[i-1] - nums[i-2]) {
                i++;
                count++;
            }
            if(count >= 3) {
                ans += (count-2)*(count-1)/2;
            }
            if(i < len-1) {
                i += 1;
                count = 2;
            } else {
                break;
            }
        }
        return ans;
    }
};
```

> 由于求的是连续子数组中为等差数列的个数，可以把nums看作多个公差不同的等差数列拼接在一起
> 只需要找到每段最长的等差数列，计算它有多少个子等差数列
> 也就是 $$ \sum_{i=3}^n(n+1-i) = (n-2) \times (n-1)/2 $$ 其中n是等差数列的长度。
> 应该没有用dp的思想吧？

#### dp版

```c++
int numberOfArithmeticSlices(vector<int>& nums) {
    int n = nums.size();
    if (n < 3) return 0;
    vector<int> dp(n, 0);
    for (int i = 2; i < n; ++i) {
        if (nums[i] - nums[i-1] == nums[i-1] - nums[i-2]) {
            dp[i] = dp[i-1] + 1;
        }
    }
    return accumulate(dp.begin(), dp.end(), 0);
}
```

> 举个例子可以看出
> 若nums = [1,2,3,4,5,7,9,11]
> 则dp   = [0,0,1,2,3,0,1,2]
> 一个等差数列中的 $ \sum(dp[i]) $ 和我上面分析的 $ \sum(n+1-i) $ 一样的

## 基本动态规划：二维
### [64. 最小路径和](https://leetcode.cn/problems/minimum-path-sum/)

```c++
class Solution {
public:
    int minPathSum(vector<vector<int>>& grid) {
        int m = grid.size();
        int n = grid[0].size();
        for(int i = 1; i < m; i++) {
            grid[i][0] += grid[i-1][0];
        }
        for(int i = 1; i < n; i++) {
            grid[0][i] += grid[0][i-1];
        }
        for(int i = 1; i < m; i++) {
            for(int j = 1; j < n; j++) {
                grid[i][j] += min(grid[i-1][j], grid[i][j-1]);
            }
        }
        return grid[m-1][n-1];
    }
};
```

> 比较好想，因为只能向右或向下走，那么
> - 对于 $ grid[i][j] (i > 0 , j > 0) $ ， 到达它的最短路径是 $ grid[i][j] + min(grid[i-1][j], grid[i][j-1]) $
> - 对于 $ grid[i][j] (i = 0 , j > 0) $ ， 到达它的最短路径是 $ grid[i][j] + grid[i][j-1] $
> - 对于 $ grid[i][j] (i > 0 , j = 0) $ ， 到达它的最短路径是 $ grid[i][j] + grid[i-1][j] $


#### dp数组压缩

```c++
class Solution {
public:
    int minPathSum(vector<vector<int>>& grid) {
        int m = grid.size();
        int n = grid[0].size();
        vector<int> dp(n);
        dp[0] = grid[0][0];
        for(int i = 1; i < n; i++) {
            dp[i] = grid[0][i] + dp[i-1];
        }
        for(int i = 1; i < m; i++) {
            dp[0] += grid[i][0];
            for(int j = 1; j < n; j++) {
                dp[j] = grid[i][j] + min(dp[j], dp[j-1]);
            }
        }
        return dp[n-1];
    }
};
```

> 每次只更新同一行也是可以的，因为每次只需要左边的和上一行的，其他的不需要

### [542. 01 矩阵](https://leetcode.cn/problems/01-matrix/)

#### 未ac代码

```c++
class Solution {
public:
    vector<vector<int>> updateMatrix(vector<vector<int>>& mat) {
        int m = mat.size(), n = mat[0].size();
        vector<vector<int>> ans(m, vector<int>(n, 20000));
        for(int i = 0; i < m; i++) {
            for(int j = 0; j < n; j++) {
                if(mat[i][j] == 0) {
                    ans[i][j] = 0;
                }
                
                if(i-1 >= 0) {
                    ans[i][j] = min(ans[i-1][j]+1, ans[i][j]);
                }
                if(j-1 >= 0) {
                    ans[i][j] = min(ans[i][j-1]+1, ans[i][j]);
                }
                if(i+1 < m) {
                    ans[i][j] = min(ans[i+1][j]+1, ans[i][j]);
                }
                if(j+1 < n) {
                    ans[i][j] = min(ans[i][j+1]+1, ans[i][j]);
                }

                if(i-1 >= 0) {
                    ans[i-1][j] = min(ans[i-1][j], 1 + ans[i][j]);
                }
                if(j-1 >= 0) {
                    ans[i][j-1] = min(ans[i][j-1], 1 + ans[i][j]);
                }
                if(i+1 < m) {
                    ans[i+1][j] = min(ans[i+1][j], 1 + ans[i][j]);
                }
                if(j+1 < n) {
                    ans[i][j+1] = min(ans[i][j+1], 1 + ans[i][j]);
                }
            }
        }
        return ans;
    }
};
```

> 这个的想法和答案已经很接近了，但我只从一个方向上进行了更新，应该从四个角开始分别进行更新一次

#### ac代码

```c++
class Solution {
public:
    vector<vector<int>> updateMatrix(vector<vector<int>>& matrix) {
        int m = matrix.size(), n = matrix[0].size();
        vector<vector<int>> dist(m, vector<int>(n, INT_MAX / 2));
        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                if (matrix[i][j] == 0) {
                    dist[i][j] = 0;
                }
            }
        }
        for (int i = 0; i < m; ++i) {
            for (int j = 0; j < n; ++j) {
                if (i - 1 >= 0) {
                    dist[i][j] = min(dist[i][j], dist[i - 1][j] + 1);
                }
                if (j - 1 >= 0) {
                    dist[i][j] = min(dist[i][j], dist[i][j - 1] + 1);
                }
            }
        }
        for (int i = m - 1; i >= 0; --i) {
            for (int j = 0; j < n; ++j) {
                if (i + 1 < m) {
                    dist[i][j] = min(dist[i][j], dist[i + 1][j] + 1);
                }
                if (j - 1 >= 0) {
                    dist[i][j] = min(dist[i][j], dist[i][j - 1] + 1);
                }
            }
        }
        for (int i = 0; i < m; ++i) {
            for (int j = n - 1; j >= 0; --j) {
                if (i - 1 >= 0) {
                    dist[i][j] = min(dist[i][j], dist[i - 1][j] + 1);
                }
                if (j + 1 < n) {
                    dist[i][j] = min(dist[i][j], dist[i][j + 1] + 1);
                }
            }
        }
        for (int i = m - 1; i >= 0; --i) {
            for (int j = n - 1; j >= 0; --j) {
                if (i + 1 < m) {
                    dist[i][j] = min(dist[i][j], dist[i + 1][j] + 1);
                }
                if (j + 1 < n) {
                    dist[i][j] = min(dist[i][j], dist[i][j + 1] + 1);
                }
            }
        }
        return dist;
    }
};
```


#### 101

- 其实从左上和右下两个方向就可以了

```c++
vector<vector<int>> updateMatrix(vector<vector<int>>& matrix) {
    if (matrix.empty()) return {};
    int n = matrix.size(), m = matrix[0].size();
    vector<vector<int>> dp(n, vector<int>(m, INT_MAX - 1));
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < m; ++j) {
            if (matrix[i][j] == 0) {
                dp[i][j] = 0;
            } else {
                if (j > 0) {
                    dp[i][j] = min(dp[i][j], dp[i][j-1] + 1);
                }
                if (i > 0) {
                    dp[i][j] = min(dp[i][j], dp[i-1][j] + 1);
                }
            }
        }
    }
    for (int i = n - 1; i >= 0; --i) {
        for (int j = m - 1; j >= 0; --j) {
            if (matrix[i][j] != 0) {
                if (j < m - 1) {
                    dp[i][j] = min(dp[i][j], dp[i][j+1] + 1);
                }
                if (i < n - 1) {
                    dp[i][j] = min(dp[i][j], dp[i+1][j] + 1);
                }
            }
        }
    }
    return dp;
}
```

### [221. 最大正方形](https://leetcode.cn/problems/maximal-square/)

```c++
class Solution {
public:
    int maximalSquare(vector<vector<char>>& matrix) {
        int m = matrix.size();
        if(m <= 0) return 0;
        int n = matrix[0].size();
        if(n <= 0) return 0;
        int maxx = 0;
        vector<vector<int>> dp(m, vector<int>(n, 0));
        for(int i = m-1; i >= 0; i--) {
            dp[i][n-1] = matrix[i][n-1] - '0';
            maxx = max(maxx, dp[i][n-1]);
        }
        for(int i = n-1; i >= 0; i--) {
            dp[m-1][i] = matrix[m-1][i] - '0';
            maxx = max(maxx, dp[m-1][i]);
        }
        for(int i = m-2; i >= 0; i--) {
            for(int j = n-2; j >= 0; j--) {
                if(matrix[i][j] != '0') {
                    int x = min(dp[i][j+1], min(dp[i+1][j], dp[i+1][j+1]));
                    dp[i][j] = 1 + x + 2*sqrt(x);
                    maxx = max(maxx, dp[i][j]);
                }
            }
        }
        return maxx;
    }
};
```

> 从右下角到左上角，dp表示以(i, j)为左上角顶点的最大正方形大小
> 看点(i+1, j) (i, j+1) (i+1, j+1)三个点的最小值，在最小值的基础上增加一圈
> 也就是边长+1，由于dp[i][j]表示的是面积， $ dp[i][j] = (sqrt(min)+1)^2 = min + 2 \times sqrt(min) + 1 $
> 在计算过程中记录max(dp[i][j])

## 分割类型题
### [279. 完全平方数](https://leetcode.cn/problems/perfect-squares/)

```c++
class Solution {
public:
    int numSquares(int n) {
        vector<int> dp(n+1, 0);
        for(int i = 1; i <= n; i++) {
            int min = INT_MAX-1;
            for(int j = 1; i-j*j >= 0; j++) {
                if(dp[i-j*j] < min) {
                    min = dp[i - j*j];
                }
            }
            dp[i] = min+1;
        }
        return dp[n];
    }
};
```

> dp[i]保存数字i的最少平方数之和，假设 $ i $ 由 $ j \times j $ 和 $ i - j \times j $ 相加而得，那么
> $$ dp[i] = min_{ j=1 }^{ \sqrt i }(dp[i-j \times j]) + 1 $$



### [91. 解码方法](https://leetcode.cn/problems/decode-ways/)

```c++
class Solution {
public:
    int numDecodings(string s) {
        s = "(" + s + ")";
        int n = s.size();
        vector<int> dp(n, 0);
        dp[n-2] = 1;
        for(int i = n-3; i >= 0; i--) {
            int number = s[i+1]*10 + s[i+2] - '0'*11;
            int number1 = s[i+1] - '0';
            dp[i] = ((number >= 10 && number <= 26) ? dp[i+2] : 0) + ((number1 >= 1  && number1 <= 9) ? dp[i+1] : 0);
        }
        return dp[0];
    }
};
```
> 在两个数之间添加隔板，并计算两个隔板之间数字是否合法
> dp[i]表示在数字i后添加一个隔板后，s[i...n-1]共有几种插入隔板的方式
> 如果s[i+1]在1到9之间，则可以在i+1后加入一个隔板
> 如果s[i+1...i+2]在10到26之间，则可以在i+1后不插入隔板而在i+2后加入隔板
> 考虑到隔一个或两个数插入一个隔板，不需要考虑字符串更长的情况
> 则转移方程为 
> $ dp[i] = dp[i+1] + dp[i+2] \quad if \quad 1<=s[i+1]<=9 \quad and \quad 10<=s[i+1...i+2]<=26 $
> $ dp[i] = dp[i+2] \quad if \quad not \quad 1<=s[i+1]<=9 \quad and \quad 10<=s[i+1...i+2]<=26 $
> $ dp[i] = dp[i+1] \quad if \quad 1<=s[i+1]<=9 \quad and \quad not \quad 10<=s[i+1...i+2]<=26 $
> $ dp[i] = 0 \quad if \quad not \quad 1<=s[i+1]<=9 \quad and \quad not \quad 10<=s[i+1...i+2]<=26 $
> 在s前后加入括号是为了避免反复写重复的逻辑，否则代码很冗余

```c++
class Solution {
public:
    int numDecodings(string s) {
        int n = s.size();
        vector<int> dp(n, 0);
        if(n < 1) return n;
        if(n == 1) return s[0] == '0' ? 0 : 1;
        int number = (s[n-2] - '0')*10 + (s[n-1] - '0');
        int number1 = (s[n-1] - '0');
        dp[n-1] = 1;
        dp[n-2] = ((number1 >= 1  && number1 <= 9) ? dp[n-1] : 0);
        for(int i = n-3; i >= 0; i--) {
            number = (s[i+1] - '0')*10 + (s[i+2] - '0');
            number1 = (s[i+1] - '0');
            dp[i] = ((number >= 10 && number <= 26) ? dp[i+2] : 0) + ((number1 >= 1  && number1 <= 9) ? dp[i+1] : 0);
        }
        number = (s[0] - '0')*10 + (s[1] - '0');
        number1 = (s[0] - '0');
        return ((number >= 10 && number <= 26) ? dp[1] : 0) + ((number1 >= 1  && number1 <= 9) ? dp[0] : 0);
    }
};
```

### [139. 单词拆分](https://leetcode.cn/problems/word-break/)

```c++
class Solution {
public:
    bool wordBreak(string s, vector<string>& wordDict) {
        unordered_map<string, bool> dict;
        for(string& s : wordDict) {
            dict[s] = true;
        }
        int len = s.size();
        vector<int> dp(len+1,0);
        dp[0] = 1;
        for(int i = 1; i <= len; i++) {
            int j = i-1;
            bool flag = false;
            while(j >= 0 && !flag) {
                flag = dict[s.substr(dp[j]-1, i - dp[j] + 1)];
                if(flag) break;
                while(j > 0 && dp[j-1] == dp[j]) j--;
                j--;
            }
            if(flag) {
                dp[i] = i+1;
            } else {
                dp[i] = dp[i-1];
            }
        }
        return dp[len] == len+1;
    }
};
```

> 还是分割问题
> 思路是判断在位置i之前插入一个隔板，用dp[i]记录最近一次匹配到字典中的单词的位置
> 如`leetcode`， 对于 `l`,`le`,`lee`, 都没有匹配到，那么dp[i] = 0
> `leet`匹配到了，dp[i] = 4，通过dp[i-1]就可以知道要匹配 0-4的字串
> `leetc`,`leetco`,`leetcod`, 根据 dp[i-1] = 4，发现`c`，`co`，`cd`都不是字典中的串,dp[i] = dp[i-1];
> `leetcode`根据 dp[i-1] = 4，发现`code`是字串，那么dp[i] = i+1;
> 最后检查dp[len]是否等于len + 1

> 上面的思路的一个问题是，对于字典中，子串也在字典内的串，不能只根据dp[i-1]决定子串范围
> 要看dp[0]到dp[i-1]所有子串

#### 101

```c++
class Solution {
public:
    bool wordBreak(string s, vector<string>& wordDict) {
        int len = s.size();
        vector<bool> dp(len, false);
        dp[0] = true;
        for(int i = 0; i <= len; i++) {
            for(string& w : wordDict) {
                int length = w.size();
                if(i >= length && w == s.substr(i-length, length)) {
                    dp[i] = dp[i] || dp[i-length];
                }
            }
        }
        return dp[len];
    }
};
```
## 子序列问题

### [300. 最长递增子序列](https://leetcode.cn/problems/longest-increasing-subsequence/)
```c++
class Solution {
public:
    int lengthOfLIS(vector<int>& nums) {
        int n = nums.size();
        vector<int> dp(n, 1);
        for(int i = 1; i < n; i++) {
            int maxx = 0;
            for(int j = i-1; j >= 0; j--) {
                if(nums[i] > nums[j]) {
                    dp[i] += dp[j];
                    break;
                }
            }
            dp[i] += maxx;
        }
        return *max_element(dp.begin(), dp.end());
    }
};
```
> 这是最简单的方法，还可以用类似单调栈优化


```c++
class Solution {
public:
    int lengthOfLIS(vector<int>& nums) {
        int n = nums.size();
        if(n <= 1) return n;
        vector<int> dp(n);
        dp[0] = nums[0];
        int count = 1;
        for(int i = 1; i < n; i++) {
            if(dp[count-1] < nums[i]) {
                dp[count] = nums[i];
                count++;
            } else {
                int pos = -1;
                for(int j = count-1; j >= 0; j--) {
                    if(dp[j] < nums[i]) {
                        pos = j;
                        break;
                    }
                }
                dp[pos+1] = nums[i];
            }
        }
        return count;
    }
};
```

### 1143. 最长公共子序列

```c++
class Solution {
public:
    int longestCommonSubsequence(string text1, string text2) {
        int m = text2.size(), n = text1.size();
        vector<vector<int>> dp(m, vector<int>(n));
        dp[0][0] = text1[0] == text2[0];
        for(int i = 1; i < m; i++) {
            dp[i][0] = max(dp[i-1][0], int(text1[0] == text2[i]) );
        }
        for(int i = 1; i < n; i++) {
            dp[0][i] = max(dp[0][i-1] , int(text1[i] == text2[0]));
        } //初始化
        for(int i = 1; i < m; i++) {
            for(int j = 1; j < n; j++) {
                dp[i][j] = max(dp[i-1][j-1] + (text1[j] == text2[i]), max(dp[i-1][j], dp[i][j-1]));
            }
        }
        return dp[m-1][n-1];
    }
};
```

> 稍微看了一下答案， $ dp[i][j] $ 表示遍历到 $ text1[i] $ , $ text2[j] $ 为止，最长子序列是多少

## 背包问题

### 板子

#### 0-1背包
```c++
int knapsack(vector<int> weights, vector<int> values, int N, int W) {
    vector<vector<int>> dp(N + 1, vector<int>(W + 1, 0));
    for (int i = 1; i <= N; ++i) {
        int w = weights[i - 1], v = values[i - 1];
        for (int j = 1; j <= W; ++j) {
            if (j >= w) {
                dp[i][j] = max(dp[i - 1][j], dp[i - 1][j - w] + v);
            }
            else {
                dp[i][j] = dp[i - 1][j];
            }
        }
    }
    return dp[N][W];
}
```
> 用自己的话说，问题就是有n种物品，每种物品有1个，背包有总容量限制，每种物品有一定价值。怎样装入物品，在容量限制下，尽量让背包价值最大
> $ dp[i][j] $ 表示当遍历到第i个物品时，背包容量为j时（可以不满），背包的最大价值
> 所以状态转移函数是 
> $$ 
> dp[i][j] = max(dp[i - 1][j], dp[i - 1][j - w_{i-1}] + v_{i-1}), \quad j>=w_{i-1} $$
> $$ 
> dp[i][j] = dp[i - 1][j], \quad j < w_{i-1} 
> $$

- 0-1背包的压缩

```c++
int knapsack(vector<int> weights, vector<int> values, int N, int W) {
    vector<int> dp(W + 1, 0);
    for (int i = 1; i <= N; ++i) {
        int w = weights[i - 1], v = values[i - 1];
        for (int j = W; j >= w; --j) {
            dp[j] = max(dp[j], dp[j - w] + v);
        }
    }
    return dp[W];
}
```

#### 完全背包
```c++
int knapsack(vector<int> weights, vector<int> values, int N, int W) {
    vector<vector<int>> dp(N + 1, vector<int>(W + 1, 0));
    for (int i = 1; i <= N; ++i) {
        int w = weights[i - 1], v = values[i - 1];
        for (int j = 1; j <= W; ++j) {
            if (j >= w) {
                dp[i][j] = max(dp[i - 1][j], dp[i][j - w] + v);
            }
            else {
                dp[i][j] = dp[i - 1][j];
            }
        }
    }
    return dp[N][W];
}
```
> 和0-1背包不同的是，每个物品有无限个，因此也需要正向遍历，且状态转移函数中，应该是同列中+物品价值，这样才能向背包中放入多个物品
> 状态转移函数是
> $$ 
> dp[i][j] = max(dp[i - 1][j], dp[i][j - w_{i-1}] + v_{i-1}), \quad j>=w_{i-1} $$
> $$
> dp[i][j] = dp[i - 1][j], \quad j < w_{i-1} 
> $$

- 完全背包的空间压缩
```c++
int knapsack(vector<int> weights, vector<int> values, int N, int W) {
    vector<int> dp(W + 1, 0);
    for (int i = 1; i <= N; ++i) {
        int w = weights[i - 1], v = values[i - 1];
        for (int j = w; j <= W; ++j) {
            dp[j] = max(dp[j], dp[j - w] + v);
        }
    }
    return dp[W];
}
```
> 101书中说

> “0-1 背包对物品的迭代放在外层，里层的
体积或价值逆向遍历；完全背包对物品的迭代放在里层，外层的体积或价值正向遍历。”

> 但我认为，完全背包正向遍历体积，0-1背包反向遍历体积，内层和外层遍历物品还是容量并没有影响


### [416. 分割等和子集](https://leetcode.cn/problems/partition-equal-subset-sum/)

```c++
class Solution {
public:
    bool canPartition(vector<int>& nums) {
        int sum = accumulate(nums.begin(), nums.end(), 0);
        if(sum & 1) return false;
        int target = sum/2;
        int n = nums.size();
        vector<int> dp(target+1, 0);
        for(int i = 1; i <= n; i++) {
            int w = nums[i-1], v = nums[i-1];
            for(int j = target; j>=w; j--) {
                dp[j] = max(dp[j], dp[j-w] + v);
            }
        }
        return dp[target] == sum-target;
    }
};
```

> 看了一眼答案的思路，知道背包总容量是 $ sum/2 $ 才写出来

#### 101
```c++
class Solution {
public:
    bool canPartition(vector<int>& nums) {
        int sum = accumulate(nums.begin(), nums.end(), 0);
        if(sum & 1) return false;
        int target = sum/2;
        int n = nums.size();
        vector<bool> dp(target+1, false);
        dp[0] = true;
        for(int i = 1; i <= n; i++) {
            int w = nums[i-1];
            for(int j = target; j>=w; j--) {
                dp[j] = dp[j] || dp[j-w];
            }
        }
        return dp[target];
    }
};
```

> 如果放入数nums[i]后，背包容量变成0了，那么说明可以装满背包

### [474. 一和零](https://leetcode.cn/problems/ones-and-zeroes/)

```c++
class Solution {
public:
    int findMaxForm(vector<string>& strs, int m, int n) {
        int strnum = strs.size();
        vector<vector<int>> dp(m+1, vector<int>(n+1, 0));
        for(int i = 1; i <= strnum; i++) {
            int strlen = strs[i-1].size();
            int count0, count1 = accumulate(strs[i-1].begin(), strs[i-1].end(), -strlen*'0');
            count0 = strlen-count1;
            for(int j = m; j >= count0; j--) {
                for(int k = n; k >= count1; k--) {
                    dp[j][k] = max(dp[j][k], dp[j-count0][k-count1]+1);
                }
            }
        }
        return dp[m][n];
    }
};
```
> 喵了一眼答案说要用二维背包，就写了，就过了
> 但是还是晕晕的，感觉只是在套模板

### [322. 零钱兑换](https://leetcode.cn/problems/coin-change/)

```c++
class Solution {
public:
    int coinChange(vector<int>& coins, int amount) {
        int coinTypes = coins.size();
        vector<vector<int>> dp(coinTypes+1, vector<int>(amount+1, 0)), dp1(coinTypes+1, vector<int>(amount+1, 0));
        for(int i = 1; i <= coinTypes; i++) {
            dp[i][0] = amount;
            int w = coins[i-1];
            for(int j = 1; j <= amount; j++) {
                if(j >= w) {
                    dp[i][j] = max(dp[i-1][j], dp[i][j-w]-1);
                    dp1[i][j] = max(dp1[i-1][j], dp1[i][j-w]+w);
                } else {
                    dp[i][j] = dp[i-1][j];
                    dp1[i][j] = dp1[i-1][j];
                }
            }
        }
        return (dp1[coinTypes][amount] == amount) ? amount - dp[coinTypes][amount] : -1;
    }
};
```

> 太慢了，非常简单的想法，一个记录用了多少硬币，一个记录当前背包内总价值

#### 空间压缩

```c++
class Solution {
public:
    int coinChange(vector<int>& coins, int amount) {
        int coinTypes = coins.size();
        vector<int> dp(amount+1, 0), dp1(amount+1, 0);
        dp[0] = amount;
        for(int i = 1; i <= coinTypes; i++) {
            int w = coins[i-1];
            for(int j = w; j <= amount; j++) {
                dp[j] = max(dp[j], dp[j-w]-1);
                dp1[j] = max(dp1[j], dp1[j-w]+w);
            }
        }
        return (dp1[amount] == amount) ? amount - dp[amount] : -1;
    }
};
```

#### 101
```c++
class Solution {
public:
    int coinChange(vector<int>& coins, int amount) {
        int coinTypes = coins.size();
        vector<int> dp(amount+1, amount+1);
        dp[0] = 0;
        for(int i = 1; i <= amount; i++) {
            for(int j = 1; j <= coinTypes; j++) {
                int w = coins[j-1];
                if(i >= w) dp[i] = min(dp[i], dp[i-w]+1);
            }
        }
        return (dp[amount] == amount+1) ? -1 : dp[amount];
    }
};
```
> 硬币的价值不用-1而用1，dp表示硬币数，找min，那么dp初值就不能是0
> 无限背包，外层容量，内层物品, 这里没有理解
> 如果`dp[amount]`是`amount+1`，说明没有填满，如果填满了，硬币数量一定小于`amount+1`

```c++
class Solution {
public:
    int coinChange(vector<int>& coins, int amount) {
        int coinTypes = coins.size();
        vector<int> dp(amount+1, amount+1);
        dp[0] = 0;
        for(int i = 1; i <= coinTypes; i++) {
            int w = coins[i-1];
            for(int j = w; j <= amount; j++) {
                dp[j] = min(dp[j], dp[j-w]+1);
            }
        }
        return (dp[amount] == amount+1) ? -1 : dp[amount];
    }
};
```
> 内层容量，外层物品也能过，还可以快一点

## 字符串编辑


### [72. 编辑距离](https://leetcode.cn/problems/edit-distance/)
```c++
class Solution {
public:
    int minDistance(string word1, string word2) {
        int len1 = word1.size(), len2 = word2.size();
        vector<vector<int>> dp(len1+1, vector<int>(len2+1, 0));
        for(int i = 0; i <= len1; i++) {
            dp[i][0] = i;
        }
        for(int i = 0; i <= len2; i++) {
            dp[0][i] = i;
        }
        for(int i = 1; i <= len1; i++) {
            for(int j = 1; j <= len2; j++) {
                int x = int(word1[i-1] != word2[j-1]);
                dp[i][j] = min(x + dp[i-1][j-1], min(dp[i-1][j]+1, dp[i][j-1]+1));
            }
        }
        return dp[len1][len2];
    }
};
```

### [650. 只有两个键的键盘](https://leetcode.cn/problems/2-keys-keyboard/)

```c++
class Solution {
public:
    int minSteps(int n) {
        vector<int> dp(n+1, 0);
        for(int i = 2; i <= n; i++) {
            dp[i] = i;
            for(int j = 2; j <= i; j++) {
                if(i%j == 0) { 
                    dp[i] = min(dp[i], dp[j]+i/j);
                }
            }
        }
        return dp[n];
    }
};
```

> 复杂度为 $ n^2 $

```c++
class Solution {
public:
    int minSteps(int n) {
        vector<int> dp(n+1, 0);
        for(int i = 2; i <= n; i++) {
            dp[i] = i;
            for(int j = 2; j*j <= i; j++) {
                if(i%j == 0) { 
                    dp[i] = dp[j] + dp[i/j];
                }
            }
        }
        return dp[n];
    }
};
```

> 如果j 可以被i 整除，那么长度i 就可以由长度j 操作得到，其操作次数等价于把一个长度为1的A 延展到长度为i/j