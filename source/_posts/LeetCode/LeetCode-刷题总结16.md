---
title: LeetCode-16
date: 2022-10-25 18:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## [934. 最短的桥](https://leetcode.cn/problems/shortest-bridge/)

```c++
class Solution {
public:

    int indexMap[105][105] = {0}; //岛屿点，对应一个岛
    int n;
    int edgex[105*105] = {0};
    int edgey[105*105] = {0};
    int edgei[105*105] = {0};
    int edgej[105*105] = {0};
    int edgecount = 0;
    int edgeicount = 0;
    int shortestBridge(vector<vector<int>>& grid) {
        n = grid.size();
        int islandCount = 0;
        int p1x,p1y;
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                if(grid[i][j] == 1 && indexMap[i][j] == 0) {
                    ++islandCount;
                    dfs(grid, i, j, islandCount);
                }
            }
        }
        int min=INT_MAX;
        for(int i = 0; i < edgecount; i++) {
            for(int j = 0; j < edgeicount; j++) {
                int path = abs(edgex[i]-edgei[j]) + abs(edgey[i] - edgej[j]) - 1;
                if(min >= path) {
                    min = path;
                }
            }
        }
        return min;
    }
    void dfs(vector<vector<int>>& grid, int x, int y, int index) {
        if(x < 0 || y < 0 || x >= n || y >= n) return;
        if(indexMap[x][y] != 0 || grid[x][y] != 1) return;
        indexMap[x][y] = index;
        bool flag = (y-1 >= 0 && grid[x][y-1] == 0) || (y+1 < n && grid[x][y+1] == 0) || (x+1 < n && grid[x+1][y] == 0) || (x-1 >= 0 && grid[x-1][y] == 0);
        dfs(grid, x, y-1, index);
        dfs(grid, x, y+1, index);
        dfs(grid, x+1, y, index);
        dfs(grid, x-1, y, index);
        if(flag) {
            if(indexMap[x][y]==1) {
                edgex[edgecount]=x;
                edgey[edgecount]=y;
                edgecount++;
            } else if(indexMap[x][y]==2) {
                edgei[edgeicount]=x;
                edgej[edgeicount]=y;
                edgeicount++;
            }
        }
    }
};
```

> 和之前写的一道题有点像，[827. 最大人工岛](https://leetcode.cn/problems/making-a-large-island/)
> `827. 最大人工岛`我先dfs找到所有连通子图和包围岛的0点，然后找这些点中有无同时包围多个岛的，把他们的面积加起来取最大值

> 这道题也可以使用相同的方法，找到每个岛屿的边界点，然后计算边界点的距离(只有两个岛，两个岛之间肯定是可以连通的，且不管使用那条途径，最短距离一定是 $ abs(x_1 - x_2) + abs(y_1-y_2)-1 $)

### 看答案

```c++
class Solution {
public:
    void dfs(int x, int y, vector<vector<int>>& grid, queue<pair<int, int>> &qu) {
        if (x < 0 || y < 0 || x >= grid.size() || y >= grid[0].size() || grid[x][y] != 1) {
            return;
        }
        qu.emplace(x, y);
        grid[x][y] = -1;
        dfs(x - 1, y, grid, qu);
        dfs(x + 1, y, grid, qu);
        dfs(x, y - 1, grid, qu);
        dfs(x, y + 1, grid, qu);
    }

    int shortestBridge(vector<vector<int>>& grid) {
        int n = grid.size();
        vector<vector<int>> dirs = {{-1, 0}, {1, 0}, {0, 1}, {0, -1}};

        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                if (grid[i][j] == 1) {
                    queue<pair<int, int>> qu;
                    dfs(i, j, grid, qu);
                    int step = 0;
                    while (!qu.empty()) {
                        int sz = qu.size();
                        for (int i = 0; i < sz; i++) {
                            auto [x, y] = qu.front();
                            qu.pop();
                            for (int k = 0; k < 4; k++) {
                                int nx = x + dirs[k][0];
                                int ny = y + dirs[k][1];
                                if (nx >= 0 && ny >= 0 && nx < n && ny < n) {
                                    if (grid[nx][ny] == 0) {
                                        qu.emplace(nx, ny);
                                        grid[nx][ny] = -1;
                                    } else if (grid[nx][ny] == 1) {
                                        return step;
                                    }
                                }
                            }
                        }
                        step++;
                    }
                }
            }
        }
        return 0;
    }
};
```

> 对于一个为1的点，先dfs吧所有在同一个岛屿内的1放入队列q中
> 对于队列中的每个节点，把包围他们的0入队，反复操作，直到遇到1
> 也就是在岛屿附近画圈，遇到1对应的圈数就是结果。

## [915. 分割数组](https://leetcode.cn/problems/partition-array-into-disjoint-intervals/)

```c++
class Solution {
public:
    int partitionDisjoint(vector<int>& nums) {
        int n = nums.size();
        vector<int> max(n+1);
        max[0] = INT_MIN;
        vector<int> min(n);
        min[n-1] = nums[n-1];
        for(int i = 0; i < n; i++) {
            if(nums[i] > max[i]) {
                max[i+1] = nums[i];
            } else {
                max[i+1] = max[i];
            }
        }
        for(int i = n-2; i >= 0; i--) {
            if(nums[i] < min[i+1]) {
                min[i] = nums[i];
            } else {
                min[i] = min[i+1];
            }
        }
        for(int i = 1; i < n; i++) {
            if(max[i] <= min[i]) {
                return i;
            }
        }
        return -1;
    }
};
```
> 没想到会这么慢

### 优化1

- max数组没必要
- 不用vector

```c++
class Solution {
public:
    int partitionDisjoint(vector<int>& nums) {
        int n = nums.size();
        int min[100005] = {0};
        min[n-1] = nums[n-1];
        for(int i = n-2; i >= 0; i--) {
            if(nums[i] < min[i+1]) {
                min[i] = nums[i];
            } else {
                min[i] = min[i+1];
            }
        }
        int max = nums[0];
        for(int i = 1; i < n; i++) {
            if(max <= min[i]) {
                return i;
            }
            if(max < nums[i]) {
                max = nums[i];
            }
        }
        return -1;
    }
};
```

## [1768. 交替合并字符串](https://leetcode.cn/problems/merge-strings-alternately/)

```c++
class Solution {
public:
    string mergeAlternately(string word1, string word2) {
        string ret;
        int len1 = word1.size(), len2 = word2.size();
        int i = 0;
        for(; i < len1 && i < len2; i++) {
            ret.push_back(word1[i]);
            ret.push_back(word2[i]);
        }
        if(len1 < len2) {
            for(; i < len2; i++) {
                ret.push_back(word2[i]);
            }
        } else {
            for(; i < len1; i++) {
                ret.push_back(word1[i]);
            }
        }
        return ret;
    }
};
```


## [1235. 规划兼职工作](https://leetcode.cn/problems/maximum-profit-in-job-scheduling/)

```c++
class Solution {
public:
    int jobScheduling(vector<int>& startTime, vector<int>& endTime, vector<int>& profit) {
        int n = startTime.size();
        vector<int> index(n);
        for(int i = 0; i < n; i++) {
            index[i] = i;
        }
        sort(index.begin(), index.end(), [&](int a, int b)->bool {return endTime[a] < endTime[b];});
        vector<int> dp(n+1);
        for(int i = 1; i <= n; i++) {
            int j = index[i-1];
            int k = i-2;
            for(; k >= 0; k--) {
                if(endTime[index[k]] <= startTime[j]) break;
            }
            dp[i] = max(dp[i-1], dp[k+1] + profit[j]);
        }
        return dp[n];
    }
};
```

> 开始想用贪心，给时薪排序，一次选择，但是发现这样得到的不是profit最大，而是工作时间更短的情况下的收益最大
> 看了答案后自己写的，发现是一个非常典型的dp问题

### 官方题解

```c++
class Solution {
public:
    int jobScheduling(vector<int> &startTime, vector<int> &endTime, vector<int> &profit) {
        int n = startTime.size();
        vector<vector<int>> jobs(n);
        for (int i = 0; i < n; i++) {
            jobs[i] = {startTime[i], endTime[i], profit[i]};
        }
        sort(jobs.begin(), jobs.end(), [](const vector<int> &job1, const vector<int> &job2) -> bool {
            return job1[1] < job2[1];
        });
        vector<int> dp(n + 1);
        for (int i = 1; i <= n; i++) {
            int k = upper_bound(jobs.begin(), jobs.begin() + i - 1, jobs[i - 1][0], [&](int st, const vector<int> &job) -> bool {
                return st < job[1];
            }) - jobs.begin();
            dp[i] = max(dp[i - 1], dp[k] + jobs[i - 1][2]);
        }
        return dp[n];
    }
};
```


## 复习 [769. 最多能完成排序的块](https://leetcode.cn/problems/max-chunks-to-make-sorted/)

这个题之前没有看太懂，现在再看一次

### 题解1
```java
class Solution {
    public int maxChunksToSorted(int[] arr) {
        int n = arr.length, ans = 0;
        for (int i = 0, j = 0, min = n, max = -1; i < n; i++) {
            min = Math.min(min, arr[i]);
            max = Math.max(max, arr[i]);
            if (j == min && i == max) {
                ans++; j = i + 1; min = n; max = -1;
            }
        }
        return ans;
    }
}

作者：AC_OIer
链接：https://leetcode.cn/problems/max-chunks-to-make-sorted/solution/by-ac_oier-4uny/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

> 这个题解比官方的好理解一点，j比i落后一点
> 当i，j区间内拥有i，j两个数时，且i是最大值，j的最小值，这时对这个区间排序，可以让max = i到i的位置，min = j到j的位置
> 也就是说i，j区间内所有数字都找到了自己的位置。这就找到了一个划分，重复这样做，就可以找到所有区间


### 题解2

```c++
class Solution {
public:
    int maxChunksToSorted(vector<int>& arr) {
        stack<int> stk;
        for (int v : arr) {
            if (stk.empty() || v >= stk.top()) {
                stk.push(v);
            } else {
                int mx = stk.top();
                stk.pop();
                while (!stk.empty() && stk.top() > v) {
                    stk.pop();
                }
                stk.push(mx);
            }
        }
        return stk.size();
    }
};

作者：lcbin
链接：https://leetcode.cn/problems/max-chunks-to-make-sorted/solution/by-lcbin-jgrv/
来源：力扣（LeetCode）
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```

> 以数据

#### 单调栈
单调栈：分为单调递增和单调递减栈(栈内元素成递增或者递减性)

- 单调栈的作用
  - 把序列中每个元素放到单调栈中进行维护就可以在 O(n) 的时间复杂度内求出区间每个元素为最大值/最小值时

- 单调栈的性质如下：
  - 元素加入栈前会把栈顶破坏单调性的元素删除
  - 一般使用单调栈的题目具有以下的两点
    - 离自己最近（栈的后进先出的性质）
    - 比自己大（小）、高(低)

板子：
```c++
stack<int> stk;
for (遍历这个数组){
   if (栈空 || 栈顶元素大于等于当前比较元素){
       入栈;
   }
   else{
       while (栈不为空 && 栈顶元素小于当前元素){
            栈顶元素出栈;
            更新结果;
        }
        当前数据入栈;
   }
}
```

## [1822. 数组元素积的符号](https://leetcode.cn/problems/sign-of-the-product-of-an-array/)

```c++
class Solution {
public:
    int arraySign(vector<int>& nums) {
        bool ret = false;
        for(int n : nums) {
            if(n==0){
                return 0;
            } else if (n<0) {
                ret=!ret;
            }
        }
        return ret?-1:1;
    }
};
```

> 比较简单，就是数数的问题