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

## [3151. 特殊数组 I](https://leetcode.cn/problems/special-array-i/description/?envType=daily-question&envId=2024-08-13)

```c++
class Solution {
public:
    bool isArraySpecial(vector<int>& nums) {
        int len = nums.size();
        int odd = nums[0] & 1;
        for(int i = 1; i < len; i++) {
            if((nums[i] & 1) == odd) {
                return false;
            }
            odd = !odd;
        }
        return true;
    }
};
```

## [676. 实现一个魔法字典](https://leetcode.cn/problems/implement-magic-dictionary/description/?envType=daily-question&envId=2024-08-12)


```c++
class MagicDictionary {
    vector<string> dictionary;
public:
    MagicDictionary() {

    }
    
    void buildDict(vector<string> dictionary) {
        this->dictionary = dictionary;
    }
    
    bool search(string searchWord) {
        for(auto& word : dictionary) {
            if(word.size() != searchWord.size()) {
                continue;
            }
            int diff = 0;
            for(int i = 0; i < word.size(); i++) {
                if(word[i] != searchWord[i]) {
                    diff++;
                }
            }
            if(diff == 1) {
                return true;
            }
        }
        return false;
    }
};
```

## [1035. 不相交的线](https://leetcode.cn/problems/uncrossed-lines/description/?envType=daily-question&envId=2024-08-11)

```c++

```

## 3132. 找出与数组相加的整数 II

```c++
class Solution {
public:
    int minimumAddedInteger(vector<int>& nums1, vector<int>& nums2) {
        sort(nums1.begin(), nums1.end());
        sort(nums2.begin(), nums2.end());
        int len2 = nums2.size();
        int x = INT_MAX;
        for(int start = 0; start < 3; start++) {
            int skip = 2 - start;
            int diff = nums2[0] - nums1[start];
            bool flag = true;
            for(int i = 1, j = 1; i < len2; j++) {
                if(nums2[i] - nums1[start+j] != diff) {
                    if(skip > 0) {
                        skip--;
                    } else {
                        flag = false;
                        break;
                    }
                } else {
                    i++;
                }
            }
            if(flag) {
                x = min(x, diff);
            }
        }
        return x;
    }
};
```

- 先排序，计算差值，看是否所有差值都相同
- 由于数组1的长度比数组2长2，所以比时给数组1一个偏移
- 由于需要删除两个，且删除的位置不同，比较时如果遇到不相等的情况，则根据情况跳过一个

## 3131. 找出与数组相加的整数 I

```c++
class Solution {
public:
    int addedInteger(vector<int>& nums1, vector<int>& nums2) {
        return *max_element(nums2.begin(), nums2.end()) - *max_element(nums1.begin(), nums1.end());
    }
};
```

## 3129. 找出所有稳定的二进制数组 I

```c++
class Solution {
    const long long MOD = 1e9 + 7;
public:
    int numberOfStableArrays(int zero, int one, int limit) {
        // 连续的0和1的个数不超过limit
        vector<vector<vector<int>>> dp0 = vector<vector<vector<int>>>(zero + 1, vector<vector<int>>(one + 1, vector<int>(limit+1, 0)));
        vector<vector<vector<int>>> dp1 = vector<vector<vector<int>>>(zero + 1, vector<vector<int>>(one + 1, vector<int>(limit+1, 0)));
        for(int z = 1; z <= min(zero, limit); z++) {
            dp0[z][0][z] = 1;
        }
        for(int o = 1; o <= min(one, limit); o++) {
            dp1[0][o][o] = 1;
        }
        for(int z = 1; z <= zero; z++) {
            for(int o = 1; o <= one; o++) {
                int dp01 = 0;
                int dp11 = 0;
                for(int l = 1; l <= limit; l++) {
                    dp01 = (dp01 + dp1[z-1][o][l]) % MOD; // 含有z-1个0，o个1，末尾连续1的个数为l，的数后面加一个0，变成z+1个0，o个1，末尾连续0的个数为1的数
                    dp11 = (dp11 + dp0[z][o-1][l]) % MOD; // 含有z个0，o-1个1，末尾连续0的个数为l，的数后面加一个1，变成z个0，o+1个1，末尾连续1的个数为1的数
                    dp0[z][o][l] += dp0[z-1][o][l-1]; // 含有z-1个0，o个1，末尾连续0的个数为l-1，的数后面再加一个0，变成z+1个0，o个1，末尾连续0的个数为l的数
                    dp1[z][o][l] += dp1[z][o-1][l-1]; // 含有z-1个0，o个1，末尾连续0的个数为l-1，的数后面再加一个1，变成z个0，o+1个1，末尾连续1的个数为l的数
                }
                dp0[z][o][1] += dp01;
                dp1[z][o][1] += dp11;
            }
        }
        int ans = 0;
        for(int l = limit; l >= 1; l--) {
            ans = (ans + (dp0[zero][one][l] + dp1[zero][one][l]) % MOD) % MOD;
        }
        return ans;
    }
};
```

- 答案还可以降维

## 600. 不含连续1的非负整数

```c++
class Solution {
    int cnt = 0;
    void search(int i, int n) {
        if(i > n) {
            return;
        }
        cnt++;
        if(!(i & 1)) {
            search((i << 1) | 1, n);
        }
        search((i << 1) | 0, n);
    }
public:
    int findIntegers(int n) {
        search(1, n);
        return cnt + 1;
    }
};
```

## 572. 另一棵树的子树

```c++
class Solution {
    void findNode(TreeNode* root, int val, vector<TreeNode*>& result) {
        if(root == nullptr) {
            return;
        }
        if(root->val == val) {
            result.push_back(root);
        }
        findNode(root->left, val, result);
        findNode(root->right, val, result);
    }
    bool _isSubTree(TreeNode *root, TreeNode* subRoot) {
        if(root == nullptr || subRoot == nullptr) {
            return root == subRoot;
        }
        if(root->val != subRoot->val) {
            return false;
        }
        return _isSubTree(root->left, subRoot->left) && _isSubTree(root->right, subRoot->right);
    }
public:
    bool isSubtree(TreeNode* root, TreeNode* subRoot) {
        vector<TreeNode*> nodes;
        findNode(root, subRoot->val, nodes);
        for(TreeNode* node : nodes) {
            if(_isSubTree(node, subRoot)) 
                return true;
        }
        return false;
    }
};
```

## 3143. 正方形中的最多点数

```c++
class Solution {
public:
public:
    int maxPointsInsideSquare(vector<vector<int>>& points, string s) {
        auto getLineLen = [](const vector<int>& point) { // 点所在正方形的边长/2，用来代表一个正方形
            return max(abs(point[0]), abs(point[1]));
        };
        int len = points.size();
        vector<int> sortedIndex(len);
        iota(sortedIndex.begin(), sortedIndex.end(), 0);
        sort(sortedIndex.begin(), sortedIndex.end(), [&points, &getLineLen](int a, int b){ return getLineLen(points[a]) < getLineLen(points[b]); });
        // 按照点所在正方形的边长排序
        unordered_set<char> labelSet; // 记录出现过的label，不允许出现相同的label
        int cnt = 0;
        int maxcnt = 0;
        int i = 0;
        bool valid = true;
        while(i < len && valid) {
            int index = sortedIndex[i];
            int lineLen = getLineLen(points[index]);
            while(i < len && lineLen == getLineLen(points[index = sortedIndex[i]])) {
                // 遍历所有相同边长的点
                char label = s[index];
                if(labelSet.count(label)) {
                    valid = false; // 这个正方形的边上遇到了出现过的label，这个正方形失效，更大的正方形也失效
                    break;
                } else {
                    cnt++;
                }
                labelSet.insert(label);
                i++;
            }
            if(valid) { // 对于合法正方形，更新点数
                maxcnt = cnt;
            }
        }
        return maxcnt;
    }
};
```

## 3128. 直角三角形


### 四次前缀和

```c++
class Solution {
public:
    long long numberOfRightTriangles(vector<vector<int>>& grid) {
        long long number = 0;
        int m = grid.size(), n = grid[0].size();
        vector<int> verticalSum;
        verticalSum = vector<int>(n);
        for(int i = 0; i < m; i++) {
            int horSum = 0;
            for(int j = 0; j < n; j++) {
                if(!grid[i][j]) continue;
                verticalSum[j] += grid[i][j];
                horSum += grid[i][j];
                number += (horSum - 1) * (verticalSum[j] - 1);
            }
        }

        verticalSum = vector<int>(n);
        for(int i = m - 1; i >= 0; i--) {
            int horSum = 0;
            for(int j = 0; j < n; j++) {
                if(!grid[i][j]) continue;
                verticalSum[j] += grid[i][j];
                horSum += grid[i][j];
                number += (horSum - 1) * (verticalSum[j] - 1);
            }
        }

        verticalSum = vector<int>(n);
        for(int i = m - 1; i >= 0; i--) {
            int horSum = 0;
            for(int j = n - 1; j >= 0; j--) {
                if(!grid[i][j]) continue;
                verticalSum[j] += grid[i][j];
                horSum += grid[i][j];
                number += (horSum - 1) * (verticalSum[j] - 1);
            }
        }

        verticalSum = vector<int>(n);
        for(int i = 0; i < m; i++) {
            int horSum = 0;
            for(int j = n - 1; j >= 0; j--) {
                if(!grid[i][j]) continue;
                verticalSum[j] += grid[i][j];
                horSum += grid[i][j];
                number += (horSum - 1) * (verticalSum[j] - 1);
            }
        }
        return number;
    }
};
```

## LCP 40. 心算挑战

### 贪心

```c++
class Solution {
public:
    int maximumScore(vector<int>& cards, int cnt) {
        vector<int> odd, even;
        sort(cards.begin(), cards.end());
        for(int card : cards) {
            ((card & 1) ? odd : even).push_back(card);
            // 三目运算符的这种用法终于被我用上了
        }
        int score = 0;
        int odd_index = odd.size() - 1;
        int even_index = even.size() - 1;
        while(cnt) {
            bool has2_odd = odd_index >= 1;
            bool has2_even = even_index >= 1;
            bool cnt_at_least_2 = cnt >= 2;
            if(has2_odd && has2_even && cnt_at_least_2) {
                if(even[even_index] >= odd[odd_index] + odd[odd_index - 1]) {
                    goto do_even;
                } else if(odd[odd_index] + odd[odd_index - 1] >= even[even_index] + even[even_index - 1]) {
                    goto do_odd;
                } else {
                    goto do2_even;
                }
            } else {
                if((cnt == 1 || odd_index == 0) && even_index >= 0) {
                    // odd或cnt为1，even大于0, 取even
                    goto do_even;
                } else if(odd_index < 0 && even_index >= 0 && cnt > 1) {
                    // odd为0，even不为0，cnt大于1，取even
                    goto do_even;
                } else if(even_index == 0 && odd_index >= 1 && cnt >= 2) {
                    if(cnt == 2) {
                        goto do_odd;
                    } else if(even[even_index] > odd[odd_index] + odd[odd_index - 1]) {
                        goto do_even;
                    } else {
                        goto do_odd;
                    }
                } else if(even_index < 0 && odd_index >= 1 && cnt >= 2) {
                    goto do_odd;
                }
                break;
            }
            do_odd:
            score += odd[odd_index] + odd[odd_index - 1];
            cnt -= 2;
            odd_index -= 2;
            goto next;
            do2_even:
            score += even[even_index] + even[even_index - 1];
            cnt -= 2;
            even_index -= 2;
            goto next;
            do_even:
            score += even[even_index];
            cnt -= 1;
            even_index -= 1;
            next:
        }
        return cnt == 0 ? score : 0;
    }
};
```

- 先排序，然后按照奇偶性分成两个数组
- 贪心，每次从奇数数组中取出两个奇数，或者从偶数数组中取数，直到取完数组，或者奇数数组剩一个，或者取够了cnt个数
- 如何选取：
  - 由于奇数数组每次取两个，占用两个cnt资源，而偶数数组可以取一个也可以取两个，导致前面的取法会影响后续cnt能否刚好取够。
  - 是连续取两个偶数，还是取两个奇数，还是只取一个偶数？
    - `odd=[...,3,7]`, `even=[...,12]`,由于偶数数组中`12`大于奇数数组的`3+7`，所以取`12`,`(一个偶数完胜)`
    - `odd=[...,3,7]`, `even=[...,6,6]`,这次`6`小于`3+7`,可是连续取`两个6`的得分大于`3+7`，所以取`6+6`。`(两个奇数拉低了平均值)`
    - `odd=[...,3,7]`, `even=[...,2,6]`,这次`6`小于`3+7`，连续两次都选择偶数`2+6`也比选择`3+7`两个奇数小，所以选两个奇数
  - 以上选取策略需要`len(odd) >= 2` `and` `len(even) >= 2` `and` `ret >= 2`
  - 下面讨论不满足以上情况，也就是`len(odd)`,`len(even)`,`ret`不会同时大于等于`2`的情况
  - 由于可能的情况太多太复杂，列表讨论

```c++
/*
odd     even    cnt     do
// odd或cnt为1，even大于0,只能取even
2+      2+      1       even
2       2+      1       even
1       2+      2+      even
1       2+      2       even
1       2+      1       even
0       2+      1       even
2+      2       1       even
2       2       1       even
1       2       2+      even
1       2       2       even
1       2       1       even
0       2       1       even
2+      1       1       even
2       1       1       even
1       1       2+      even
1       1       2       even
1       1       1       even
0       1       1       even

// odd为0，even不为0，cnt大于1，取even
0       2+      2+      even
0       2+      2       even
0       2       2+      even
0       2       2       even
0       1       2+      even
0       1       2       even

// even只剩一个, cnt剩两个，不能取even，odd大于等于2个，取odd
2+      1       2       odd
2       1       2       odd

// even只剩一个, cnt大于两个，可以取even，但需要和odd比较
2+      1       2+      even, odd1+odd2比较
2       1       2+      even, odd1+odd2比较

// even用完了, odd还有两个以上, 取odd
2+      0       2+      odd
2+      0       2       odd
2       0       2+      odd
2       0       2       odd


// even,odd都取完了，无法取够cnt，break
0       0       2+      break
0       0       2       break

// cnt或odd为1，没有even可取，无法满足条件，break
2+      0       1       break
2       0       1       break
1       0       2+      break
1       0       2       break
1       0       1       break
0       0       1       break
*/
```

> `2+`代表个数大于`2`

### 排序
```c++
class Solution {
public:
    int maximumScore(vector<int>& cards, int cnt) {
        int odd = -1, even = -1;
        int tmp = 0;
        int n = cards.size();
        sort(cards.begin(), cards.end());
        for(int i = n - 1; i > n - cnt - 1; i--) {
            ((cards[i] & 1) ? odd : even) = cards[i];
            tmp += cards[i];
            cout << cards[i] << endl;
        }
        if(!(tmp & 1)) return tmp;
        bool flag = false;
        int ans = 0;
        for(int i = n - cnt - 1; i >= 0; i--) {
            if(cards[i] & 1) {
                if(even != -1) {
                    flag = true;
                    ans = max(ans, tmp - even + cards[i]);
                    
                }
            } else {
                if(odd != -1) {
                    ans = max(ans, tmp - odd + cards[i]);
                    flag = true;
                }
            }
        }
        return ans;
    }
};
```

- 排序后前cnt个数加起来，如果是偶数，则是所求最大的情况，直接返回
- 否则，前cnt个和加起来是奇数，用后面的数替换前面的数，使和变成偶数
  - 如果后面的数是奇数，则减去最后一个偶数，这样和为偶数
  - 如果后面的数是偶数，则减去最后一个奇数，这样和为奇数

### 哈希

和上一个想法思路一致，`1<=cards[i]<=1000`，可以把他映射到一个长度1000的数组中，记录下标早cards中出现的次数，可以避免排序。

```c++
class Solution {
public:
    int maximumScore(vector<int>& cards, int cnt) {
        int hash[1001] = {0};
        int n = cards.size();
        for(int i = 0; i < n; i++) {
            hash[cards[i]]++;
        }
        int i = 1000;
        int tmp = 0;
        int odd = -1, even = -1;
        for(int j = 0; j < cnt && i > 0; j++) {
            while(i > 0 && hash[i] == 0) i--;
            if(i == 0) break; // will never happen
            tmp += i;
            hash[i]--;
            ((i & 1) ? odd : even) = i;
        }
        if(!(tmp & 1)) return tmp;
        int ans = 0;
        while(i > 0) {
            while(i > 0 && hash[i] == 0) i--;
            if(i == 0) break;
            if((i & 1) == 1 && even != -1) {
                ans = max(ans, tmp - even + i);
            } else if((i & 1) == 0 && odd != -1) {
                ans = max(ans, tmp - odd + i);
            }
            hash[i]--;
        }
        return ans;
    }
};
```

## 3111. 覆盖所有点的最少矩形数目

```c++
class Solution {
public:
    int minRectanglesToCoverPoints(vector<vector<int>>& points, int w) {
        sort(points.begin(), points.end(), [](const vector<int>& a, const vector<int>& b){ return a[0] < b[0]; });
        int len = points.size();
        int i = 1;
        int cnt = 1;
        int lastx = points[0][0];
        while(i < len) {
            while(i < len && points[i][0] - lastx <= w) i++;
            if(i >= len) break;
            cnt++;
            lastx = points[i][0];
        }
        return cnt;
    }
};
```

- 啊?这是中等题吗

## 3007. 价值和小于等于 K 的最大数字

### 公式法
```c++
class Solution {
    long long accumulatedValueOf(long long k, int x) {
        long long value = 0;
        for(int mask_off = 63; mask_off >= 1; mask_off--) {
            long long mask = 1l << (mask_off - 1);
            if(!(mask & k)) continue;
            k = k & ~mask;
            if(mask_off % x == 0) {
                value += ((k|mask) - mask + 1);
            }
            value += mask / 2 * ((mask_off - 1) / x);
        }
        return value;
    }
public:
    long long findMaximumNumber(long long k, int x) {
        long long l = 1, r = 1e15;
        while(l < r) {
            long long mid = (r - l + 1) / 2 + l;
            long long accuValue = accumulatedValueOf(mid, x);
            if(accuValue <= k) {
                l = mid;
            } else {
                r = mid - 1;
            }
        }
        return l;
    }
};
```
#### 思路
- 记$ price_n(x) = bit\_count(n, x) $ 
- 记$ accumulated_n(x) = \sum_{i=1}^nprice_i(x) $ 
- `bit_count`, `price`是n的价值，也就是下标被x整除的位数和
- 对于`n>0`, 函数`bit_count`, 是恒大于零的。
- 所以数列$ \{accumulated_n(x)\} $是单调递增的，如果能找到计算$ \{accumulated_n(x)\} $的公式，利用二分查找即可快速找到答案

#### 公式推导

- 以`n = 7`, `x = 1`为例

```
0000
0001
0010
0011
0100
0101
0110
0111
```

可以观察到`0 + 7` = `1 + 6` = `2 + 5` = `3 + 4` = 二进制的`111`
总价值为: `3*4=12`

也就是对于$ n = 0 ... (2^i-1) $时，他们的总价值为$ i * 2^{i-1} $ 

$ a_{2^i}(1) = i * 2^{i-1}$

- 以`n = 10`, `x = 1`为例

```
0000
0001
0010
0011
0100
0101
0110
0111
1000
1001
1010
```
先计算`n = 0...7`的总价值，为`12`
$ a_{2^i-1}(1) = i * 2^{i-1}$, $i = 3$的情况

组成部分为`n = 0...7`和`n = 8...10`

对于`n = 8...10`
先数出最高位的情况，也就是$n - (2^i - 1)$，再去掉最高位，变成以下情况
```
00
01
10
```
也就是`n = 2`, `x = 1`的情况，重复上面的操作
也就是 $ b_n(i) = n\%2^{i+1} - (2^i - 1) $
- 对于更复杂的情况如: `n = 1001101`, `x = 1`
总价值为
$ a_{2^6-1}(1) + b_n(6) + $
$ a_{2^3-1}(1) + b_n(3) + $
$ a_{2^2-1}(1) + b_n(2) + $
$ a_{2^0-1}(1) + b_n{0}$

- 对于`x != 1`的情况，也就是
$ a_{2^i}(x) =  \lfloor\frac{i}{x}\rfloor * 2^{i-1}$
$ b_n(i, x) = n\%2^{i+1} - (2^i - 1) $ $(i \% x = 0)$ 
$ b_n(i, x) = 0 $ $(i \% x \not ={0})$ 


## 2961. 双模幂运算
快速幂秒了！

```c++
class Solution {
    int fastPow(int a, int n, int mod) {
        int res = 1;
        while(n) {
            if(n&1) {
                res = (res * a) % mod;
            }
            a = (a * a) % mod;
            n >>= 1;
        }
        return res;
    }
public:
    vector<int> getGoodIndices(vector<vector<int>>& variables, int target) {
        vector<int> goodIndices;
        int len = variables.size();
        for(int i = 0; i < len; i++) {
            int n = fastPow(variables[i][0], variables[i][1], 10);
            n = fastPow(n, variables[i][2], variables[i][3]);
            if(n == target) {
                goodIndices.push_back(i);
            }
        }
        return goodIndices;
    }
};
```

## 682. 棒球比赛

```c++
class Solution {
public:
    int calPoints(vector<string>& operations) {
        int n = operations.size();
        vector<int> scores;
        int scoreCnt = 0;
        for(int i = 0; i < n; i++) {
            int score = 0;
            if (operations[i] == "+") {
                score = scores[scoreCnt - 1] + scores[scoreCnt - 2];
            } else if (operations[i] == "D") {
                score = scores[scoreCnt - 1] * 2;
            } else if (operations[i] == "C") {
                scores.pop_back();
                scoreCnt--;
                continue;
            } else {
                sscanf(operations[i].c_str(), "%d", &score);
            }
            scores.push_back(score);
            scoreCnt++;
        }
        return accumulate(scores.begin(), scores.end(), 0);
    }
};
```

## 3106. 满足距离约束且字典序最小的字符串

```c++
class Solution {
    public:
    int charDistance(char a, char b) {
        int d = abs(a - b);
        return min(d, 26 - d);
    }
public:
    string getSmallestString(string s, int k) {
        int n = s.length();
        for(int i = 0; i < n && k > 0; i++) {
            int target = 'z';
            if(k > 12) {
                target = 'a';
            } else {
                for(int j = 0; j <= k; j++) {
                    target = min(target, (s[i] + j - 'a') % 26 + 'a');
                    target = min(target, (s[i] - j - 'a' + 26) % 26 + 'a');
                }
            }
            k -= charDistance(s[i], target);
            s[i] = target;
        }
        return s;
    }
};
```

- 实际上就是`26`进制数，在有限步骤内，将其转化为同位数下尽量小的数
- 尽量多的将当前最高位变小，高位使用1步的减少量是地位使用一步的26倍
- 简单计算可知，两个字母最大距离为12
  - 当`k > 12`时，一定可以变成`a`
  - 当`k <= 12`时，一定可以变成`a`，寻找k步内能实现的最小字符

## 2740. 找出分区值

```c++
class Solution {
public:
    int findValueOfPartition(vector<int>& nums) {
        sort(nums.begin(), nums.end());
        int len = nums.size();
        int minDiff = INT_MAX;
        for(int i = 1; i < len; i++) {
            minDiff = min(minDiff, abs(nums[i] - nums[i-1]));
        }
        return minDiff;
    }
};
```

## 2844. 生成特殊数字的最少操作

```c++
class Solution {
public:
    int minimumOperations(string num) {
        int len = num.length();
        int first0 = len, first5 = len;
        int i = len - 1;
        int minOp = len;
        while(i >= 0) {
            if(num[i] == '0' && first0 == len) {
                first0 = i;
            } else if(num[i] == '5' && first5 == len) {
                first5 = i;
            }
            if(num[i] == '0' && first0 != len && i < first0) {
                minOp = min(minOp, len - first0 - 1 + first0 - i - 1);
            } else if(num[i] == '2' && first5 != len && i < first5) {
                minOp = min(minOp, len - first5 - 1 + first5 - i - 1);
            } else if(num[i] == '5' && first0 != len && i < first0) {
                minOp = min(minOp, len - first0 - 1 + first0 - i - 1);
            } else if(num[i] == '7' && first5 != len && i < first5) {
                minOp = min(minOp, len - first5 - 1 + first5 - i - 1);
            }
            i--;
        }
        if(first0 != len) minOp = min(minOp, len - 1);
        return minOp;
    }
};
```

- 对于所有25的倍数，举例可知，结尾两位为`00`,`25`,`50`,`75`
- 一个字符串可能有多种方式到达变成25的倍数
  - 如果最后以`00`结尾，先倒着找到第一个`0`，删去后面的所有数，在找第二个`0`，删掉两个`0`中间的数
  - `25`,`50`,`75`同理
  - 返回删除数字最少的情况
- 特殊情况
  - 没有找到`00`,`25`,`50`,`75`，可以把整个字符串删掉
  - 没有找到`00`,`25`,`50`,`75`，只找到了一个`0`，可以把`0`以外的数全删掉

## 2766. 重新放置石块

```c++
class Solution {
public:
    vector<int> relocateMarbles(vector<int>& nums, vector<int>& moveFrom, vector<int>& moveTo) {
        unordered_map<int, bool> pos2rock;
        for(int rockPos : nums) {
            pos2rock[rockPos] = true;
        }
        int opNum = moveFrom.size();
        for(int i = 0; i < opNum; i++) {
            if(moveTo[i] == moveFrom[i]) continue;
            pos2rock[moveTo[i]] = true;
            // pos2rock[moveFrom[i]] = 0;
            pos2rock.erase(moveFrom[i]);
        }
        vector<int> res;
        for(const auto& [pos, num] : pos2rock) {
            // if(num) { // 不需要判断，都是true
                res.push_back(pos);
            // }
        }
        sort(res.begin(), res.end());
        return res;
    }
};
```


## 2101. 引爆最多的炸弹

```c++
class Solution {
    class Solve {
        unordered_map<int, vector<int>> graph;
        vector<vector<int>>& bombs;
        int bombsNum;
        int isICanBoomJ(int i, int j) {
            return ((long long)bombs[i][0] - bombs[j][0]) * (bombs[i][0] - bombs[j][0]) + ((long long)bombs[i][1] - bombs[j][1]) * (bombs[i][1] - bombs[j][1]) <= (long long)bombs[i][2] * bombs[i][2];
        }
        int cntNodes(int start) {
            vector<bool> visited = vector<bool>(bombsNum, false);
            return cntNodes(start, visited);
        }
        int cntNodes(int start, vector<bool>& visited) {
            visited[start] = true;
            int child = 0;
            for(int subNode : graph[start]) {
                if(!visited[subNode]) {
                    visited[subNode] = true;
                    child += cntNodes(subNode, visited);
                }
            }
            return 1+child;
        }
        public:
        Solve(vector<vector<int>>& bombs) 
            : bombs(bombs), bombsNum(bombs.size()) {}
        int solve() {
            for(int i = 0; i < bombsNum; i++) {
                for(int j = 0; j < bombsNum; j++) {
                    if(i == j) continue;
                    if(isICanBoomJ(i, j)) {
                        graph[i].push_back(j);
                    }
                }
            }
            int maxBoom = INT_MIN;
            for(int i = 0; i < bombsNum; i++) {
                maxBoom = max(maxBoom, cntNodes(i));
            }
            return maxBoom;
        }
    };
public:
    int maximumDetonation(vector<vector<int>>& bombs) {
        return Solve(bombs).solve();
    }
};
```

```c++
class Solution {
public:
    int maximumDetonation(vector<vector<int>>& bombs) {
        int bombsNum = bombs.size();
        auto isICanBoomJ = [&](int i, int j) {
            return ((long long)bombs[i][0] - bombs[j][0]) * (bombs[i][0] - bombs[j][0]) + ((long long)bombs[i][1] - bombs[j][1]) * (bombs[i][1] - bombs[j][1]) <= (long long)bombs[i][2] * bombs[i][2];
        };
        unordered_map<int, vector<int>> graph;
        function<int(int, vector<bool>&)> _cntNodes = [&](int start, vector<bool>& visited) {
            visited[start] = true;
            int child = 0;
            for(int subNode : graph[start]) {
                if(!visited[subNode]) {
                    visited[subNode] = true;
                    child += _cntNodes(subNode, visited);
                }
            }
            return 1+child;
        };
        auto cntNodes = [&](int start) {
            vector<bool> visited = vector<bool>(bombsNum, false);
            return _cntNodes(start, visited);
        };
        for(int i = 0; i < bombsNum; i++) {
            for(int j = 0; j < bombsNum; j++) {
                if(i == j) continue;
                if(isICanBoomJ(i, j)) {
                    graph[i].push_back(j);
                }
            }
        }
        int maxBoom = INT_MIN;
        for(int i = 0; i < bombsNum; i++) {
            maxBoom = max(maxBoom, cntNodes(i));
        }
        return maxBoom;
    }
};
```

- 注意计算距离时int可能会溢出

## 1186. 删除一次得到子数组最大和