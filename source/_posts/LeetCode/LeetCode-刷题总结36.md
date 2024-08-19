---
title: LeetCode-36
date: 2024-8-18 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## [551. 学生出勤记录 I](https://leetcode.cn/problems/student-attendance-record-i/description/?envType=daily-question&envId=2024-08-18)

```c++
class Solution {
public:
    bool checkRecord(string s) {
        int count = 0;
        int max_seq_late = 0;
        int seq_late = 0;
        for(char c : s) {
            if(c == 'A') count++;
            if(c == 'L') {
                seq_late++;
            } else {
                max_seq_late = max(max_seq_late, seq_late);
                seq_late = 0;
            }
        }
        max_seq_late = max(max_seq_late, seq_late);
        return count < 2 && max_seq_late < 3;

    }
};
```

- 连续相同的值的个数
- 统计元素出现的次数

## [3137. K 周期字符串需要的最少操作次数](https://leetcode.cn/problems/minimum-number-of-operations-to-make-word-k-periodic/description/?envType=daily-question&envId=2024-08-17)

```c++
class Solution {
public:
    int minimumOperationsToMakeKPeriodic(string word, int k) {
        unordered_map<string, int> subStrCount;
        int len = word.length();
        for(int i = 0; i < len; i += k) {
            subStrCount[word.substr(i, k)]++;
        }
        int minOpCnt = len / k;
        for(auto& ite : subStrCount) {
            minOpCnt = min(minOpCnt, len / k - ite.second);
        }
        return minOpCnt;
    }
};
```

- 翻译一下规则，就是把长度为`nk`的字符串切割成`n`个长度为`k`的子串，一次操作可以把一个子串替换成另一个字串，求如何替换，将所有字串都相同。
- 翻译好需求，就很清楚了，直接统计每个字串出现的次数，取出现次数最大的，替换次数最少，为`n - cnt[i]`

## [3117. 划分数组得到最小的值之和](https://leetcode.cn/problems/minimum-sum-of-values-by-dividing-array/description/?envType=daily-question&envId=2024-08-16)

### 超时暴搜

```c++
class Solution {
    int n;
    int m;
    unsigned int minSum = -1;
public:
    int minimumValueSum(vector<int>& nums, vector<int>& andValues) {
        n = nums.size();
        m = andValues.size();
        vector<vector<unsigned int>> andMat(n, vector<unsigned int>(n, INT_MAX));
        for(int i = 0; i < n; i++) {
            andMat[i][i] = nums[i];
            for(int j = i + 1; j < n; j++) {
                andMat[i][j] = andMat[i][j-1] & nums[j];
            }
        }
        search(andMat, andValues, 0, 0, 0);
        return minSum;
    }

    void search(const vector<vector<unsigned int>>& andMat, const vector<int>& andValues, int depth, int start, unsigned int sum) {
        if(depth + 1 == m) {
            if(andMat[start][n-1] == andValues[m-1]) {
                minSum = min(minSum, sum + andMat[n-1][n-1]);
            }
            return;
        }
        for(int i = start + 1; i < n - m + depth + 2; i++) {
            if(andMat[start][i-1] == andValues[depth]) {
                search(andMat, andValues, depth + 1, i, sum + andMat[i-1][i-1]);
            }
        }
    }
};
```

## [3148. 矩阵中的最大得分](https://leetcode.cn/problems/maximum-difference-score-in-a-grid/description/?envType=daily-question&envId=2024-08-15)

```c++
class Solution {
public:
    int maxScore(vector<vector<int>>& grid) {
        int m = grid.size(), n = grid[0].size();
        vector<vector<int>> mat(m, vector<int>(n, INT_MIN));
        int maxScore = INT_MIN;
        mat[0][0] = 0;
        for(int i = 0; i < m; i++) {
            for(int j = 0; j < n; j++) {
                if(i > 0) mat[i][j] = max(max(mat[i][j], grid[i][j] - grid[i-1][j]), mat[i-1][j] + grid[i][j] - grid[i-1][j]);
                if(j > 0) mat[i][j] = max(max(mat[i][j], grid[i][j] - grid[i][j-1]), mat[i][j-1] + grid[i][j] - grid[i][j-1]);
                if(i > 0 || j > 0) maxScore = max(maxScore, mat[i][j]);
            }
        }
        return maxScore;
    }
};
```

- 只能向下或向右走，所以右下方的格子不会影响左上方格子的最终结果，直接拿上方格子和左方格子的值计算，并存储到达每个格子的最小值就好。

## [3152. 特殊数组 II](https://leetcode.cn/problems/special-array-ii/description/?envType=daily-question&envId=2024-08-14)

### 二分

```c++
class Solution {
public:
    vector<bool> isArraySpecial(vector<int>& nums, vector<vector<int>>& queries) {
        int n = nums.size();
        vector<int> startIndex, endIndex;
        vector<bool> ans;
        int s = 0;
        for(int i = 1; i < n; i++) {
            if(((nums[i] & 1) ^ (nums[i-1] & 1)) == 0) {
                startIndex.push_back(s);
                endIndex.push_back(i - 1);
                s = i;
            }
        }
        startIndex.push_back(s);
        endIndex.push_back(n - 1);
        for(auto &query : queries) {
            int start = query[0], end = query[1];
            int findIndex = upper_bound(startIndex.begin(), startIndex.end(), start) - startIndex.begin() - 1;
            ans.push_back(endIndex[findIndex] >= end);
        }
        return ans;
    }
};
```

- `lower_bound`: 直译是下界，实际上是上确界，也就是可以等于被查找的元素
- `upper_bound`: 直译是上界，也就是不可以等于被查找的元素

### 模仿线段树
```c++
class Solution {
    class SegTree {
        vector<int>& nums;
        vector<bool> segTree;
        int n;
        int alignedSize;
        unsigned int alignment(unsigned int n) {
            unsigned int mask = 0x80000000;
            while(mask && !(mask & n)) mask >>= 1;
            return (n & (n-1)) != 0 ? (mask << 1) : mask; // 得到大于等于n的2的幂
        }
        void initSegTreeLeaf() {
            if(n <= 1) return;
            for(int i = 0; i < n - (n & 1); i+=2) {
                int leftIndex = alignedSize + i - 1;
                int rightIndex = alignedSize + i;
                leftIndex = (leftIndex - 1) >> 1;
                segTree[leftIndex] = ((nums[i] & 1) ^ (nums[i+1] & 1));
            }
        }
        bool initSegTree(int start, int end, int index) {
            int mid = (end - start) / 2 + start;
            if(start >= end) return true;
            if(index >= alignedSize / 2) return segTree[index];
            if(mid >= 0 && mid + 1 < n) {
                segTree[index] = (nums[mid] & 1) ^ (nums[mid+1] & 1);
            }
            segTree[index] = segTree[index] & initSegTree(start, mid, 2 * index + 1) & initSegTree(mid+1, end, 2 * index + 2);
            return segTree[index];
        }
        bool query(int i , int j, int start, int end, int index) {
            int mid = (end - start) / 2 + start;
            if(start == end) return true;
            if(i <= start && end <= j) {
                return segTree[index];
            }
            if(mid >= i && mid + 1 <= j && !((nums[mid] & 1) ^ (nums[mid+1] & 1))) return false;
            if(mid >= i && !query(i, j, start, mid, 2 * index + 1)) {
                return false;
            }
            if(mid + 1 <= j && !query(i, j, mid+1, end, 2 * index + 2)) {
                return false;
            }
            return true;
        }
        public:
        SegTree(vector<int>& nums): \
            nums(nums), n(nums.size()), \
            alignedSize(alignment(n)) {
            segTree = vector<bool>(alignedSize, true); // 不用乘2，因为叶子节点全是true
            initSegTreeLeaf();
            initSegTree(0, alignedSize - 1, 0);
        }
        bool query(int i , int j) {
            return query(i, j, 0, alignedSize - 1, 0);
        }
    };
public:
    vector<bool> isArraySpecial(vector<int>& nums, vector<vector<int>>& queries) {
        vector<bool> ans;
        SegTree segTree(nums);
        for(auto& q : queries) {
            bool result = segTree.query(q[0], q[1]);
            ans.push_back(result);
        }
        return ans;
    }
};
```

哎，速度不是很快`279ms 击败13.48%`

### dp