---
title: LeetCode-29
date: 2023-12-1 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## [2661. 找出叠涂元素](https://leetcode.cn/problems/first-completely-painted-row-or-column/description/?envType=daily-question&envId=2023-12-01)
```c++
class Solution {
public:
    int firstCompleteIndex(vector<int>& arr, vector<vector<int>>& mat) {
        int m = mat.size(), n = mat[0].size();
        vector<int> cnt_row(m, 0), cnt_col(n, 0);
        vector<int> index(m*n+1);
        for(int i = 0; i < m; i++) {
            for(int j = 0; j < n; j++) {
                index[mat[i][j]] = i*n+j;
            }
        }
        int len = arr.size();
        for(int i = 0; i < len; i++) {
            int x = index[arr[i]]/n, y = index[arr[i]]%n;
            cnt_row[x]++;
            cnt_col[y]++;
            if(cnt_row[x] == n || cnt_col[y] == m) return i;
        }
        return -1;
    }
};
```

## [1657. 确定两个字符串是否接近](https://leetcode.cn/problems/determine-if-two-strings-are-close/description/?envType=daily-question&envId=2023-11-30)

```c++
class Solution {
public:
    inline bool logicXor(bool a, bool b) {
        return (a && !b) || (b && !a);
    }
    bool closeStrings(string word1, string word2) {
        vector<int> word1_cnt(26, 0), word2_cnt(26, 0);
        for(char c : word1) {
            word1_cnt[c - 'a']++;
        }
        for(char c : word2) {
            word2_cnt[c - 'a']++;
        }
        for(int i = 0; i < 26; i++) {
            if(logicXor(word1_cnt[i] == 0, word2_cnt[i] == 0)) return false;
        }
        sort(word1_cnt.begin(), word1_cnt.end());
        sort(word2_cnt.begin(), word2_cnt.end());
        for(int i = 0; i < 26; i++) {
            if(word1_cnt[i] != word2_cnt[i]) return false;
        }
        return true;
    }
};
```

## [2336. 无限集中的最小数字](https://leetcode.cn/problems/smallest-number-in-infinite-set/description/?envType=daily-question&envId=2023-11-29)

```c++
class SmallestInfiniteSet {
    vector<pair<unsigned, unsigned>> s;
public:
    SmallestInfiniteSet() {
        s.emplace_back(1, -1);
    }
    
    int popSmallest() {
        int smallest = s[0].first++;
        if(s[0].first == s[0].second) {
            s.erase(s.begin());
        }
        return smallest;
    }
    
    void addBack(int num) {
        // cout << "add\n";
        int n = s.size();
        int i = 0;
        while(i < n && s[i].second <= num) i++;
        if(i >= n) {
            s.emplace_back(num, num + 1);
            return;
        }
        if(s[i].first <= num) {
            return;
        } else {
            if(s[i].first-1 == num) {
                s[i].first--;
                // 检查前面的，拼接
                if(i-1 >= 0 && s[i-1].second == s[i].first) {
                    s[i-1].second = s[i].second;
                    s.erase(s.begin() + i);
                }
            } else {
                if(i - 1 >= 0 && s[i-1].second == num) {
                    s[i-1].second++;
                } else {
                    s.insert(s.begin() + i, make_pair(num, num+1));
                }
            }
        }
    }
};

/**
 * Your SmallestInfiniteSet object will be instantiated and called as such:
 * SmallestInfiniteSet* obj = new SmallestInfiniteSet();
 * int param_1 = obj->popSmallest();
 * obj->addBack(num);
 */
```

## [1670. 设计前中后队列](https://leetcode.cn/problems/design-front-middle-back-queue/description/?envType=daily-question&envId=2023-11-28)

```c++
class FrontMiddleBackQueue {
    deque<int> leftHalf, rightHalf;
    int leftHalfLen = 0, rightHalfLen = 0;
public:
    FrontMiddleBackQueue() {

    }
    
    void pushFront(int val) {
        leftHalf.push_front(val);
        if(leftHalfLen - rightHalfLen > 0) {
            rightHalf.push_front(leftHalf.back());
            leftHalf.pop_back();
            rightHalfLen++;
        } else {
            leftHalfLen++;
        }
    }
    
    void pushMiddle(int val) {
        if(leftHalfLen > rightHalfLen) {
            rightHalf.push_front(leftHalf.back());
            leftHalf.pop_back();
            leftHalf.push_back(val);
            rightHalfLen++;
        } else {
            leftHalf.push_back(val);
            leftHalfLen++;
        }
    }
    
    void pushBack(int val) {
        rightHalf.push_back(val);
        if(rightHalfLen >= leftHalfLen) {
            leftHalf.push_back(rightHalf.front());
            rightHalf.pop_front();
            leftHalfLen++;
        } else {
            rightHalfLen++;
        }
    }
    
    int popFront() {
        int ret = -1;
        if(leftHalfLen <= 0) {
            if(rightHalfLen > 0) {
                ret = rightHalf.front();
                rightHalf.pop_front();
                rightHalfLen--;
            }
        } else {
            ret = leftHalf.front();
            leftHalf.pop_front();
            if(leftHalfLen <= rightHalfLen) {
                leftHalf.push_back(rightHalf.front());
                rightHalf.pop_front();
                rightHalfLen--;
            } else {
                leftHalfLen--;
            }
        }
        return ret;
    }
    
    int popMiddle() {
        int ret = -1;
        if(leftHalfLen >= rightHalfLen) {
            if(leftHalfLen == 0) return -1;
            ret = leftHalf.back();
            leftHalf.pop_back();
            leftHalfLen--;
        } else {
            ret = rightHalf.front();
            rightHalf.pop_front();
            rightHalfLen--;
        }
        return ret;
    }
    
    int popBack() {
        int ret = -1;
        if(rightHalfLen <= 0) {
            if(leftHalfLen > 0) {
                ret = leftHalf.back();
                leftHalf.pop_back();
                leftHalfLen--;
            }
        } else {
            ret = rightHalf.back();
            rightHalf.pop_back();
            if(leftHalfLen > rightHalfLen) {
                rightHalf.push_front(leftHalf.back());
                leftHalf.pop_back();
                leftHalfLen--;
            } else {
                rightHalfLen--;
            }
        }
        return ret;
    }
};

/**
 * Your FrontMiddleBackQueue object will be instantiated and called as such:
 * FrontMiddleBackQueue* obj = new FrontMiddleBackQueue();
 * obj->pushFront(val);
 * obj->pushMiddle(val);
 * obj->pushBack(val);
 * int param_4 = obj->popFront();
 * int param_5 = obj->popMiddle();
 * int param_6 = obj->popBack();
 */
```

## [1094. 拼车](https://leetcode.cn/problems/car-pooling/description/?envType=daily-question&envId=2023-12-02)

```c++
class Solution {
public:
    bool carPooling(vector<vector<int>>& trips, int capacity) {
        vector<int> max_capacity(1002, 0);
        int max_end = 0;
        int min_start = 1002;
        int len = trips.size();
        for(int i = 0; i < len; i++) {
            max_capacity[trips[i][1]] += trips[i][0];
            max_capacity[trips[i][2]] -= trips[i][0];
            max_end = max(trips[i][2], max_end);
            min_start = min(trips[i][1], min_start);
        }
        int cur_capacity = 0;
        for(int i = min_start; i <= max_end; i++) {
            cur_capacity += max_capacity[i];
            if(cur_capacity > capacity) return false;
        }
        return true;
    }
};
```

## 1423. 可获得的最大点数
```c++
class Solution {
public:
    int maxScore(vector<int>& cardPoints, int k) {
        int maxSum = 0;
        int sum = 0;
        int len = cardPoints.size();
        for(int i = 0; i < k; i++) {
            sum += cardPoints[i];
        }
        maxSum = sum;
        for(int i = 0; i < k; i++) {
            sum -= cardPoints[k - 1 - i];
            sum += cardPoints[len - 1 - i];
            maxSum = max(maxSum, sum);
        }
        return maxSum;
    }
};
```

```c++
class Solution {
public:
    int maxScore(vector<int> &cardPoints, int k) {
        int n = cardPoints.size();
        int m = n - k;
        int s = accumulate(cardPoints.begin(), cardPoints.begin() + m, 0);
        int min_s = s;
        for (int i = m; i < n; i++) {
            s += cardPoints[i] - cardPoints[i - m];
            min_s = min(min_s, s);
        }
        return accumulate(cardPoints.begin(), cardPoints.end(), 0) - min_s;
    }
};
```

## [1038. 从二叉搜索树到更大和树](https://leetcode.cn/problems/binary-search-tree-to-greater-sum-tree/description/?envType=daily-question&envId=2023-12-04)

```c++
class Solution {
    vector<int> arr;
public:
    TreeNode* bstToGst(TreeNode* root) {
        _bstToGst(root);
        int len = arr.size();
        for(int i = len - 2; i >= 0; i--) {
            arr[i] += arr[i+1];
        }
        int index = 0;
        setGst(root, index);
        return root;
    }
    void _bstToGst(TreeNode* root) {
        if(!root) return;
        _bstToGst(root->left);
        arr.push_back(root->val);
        _bstToGst(root->right);
    }
    void setGst(TreeNode* root, int& index) {
        if(!root) return;
        setGst(root->left, index);
        root->val = arr[index++];
        setGst(root->right, index);
    }
};
```

```c++
class Solution {
    int sum = 0;
public:
    TreeNode* bstToGst(TreeNode* root) {
        if(!root) return root;
        bstToGst(root->right);
        sum += root->val;
        root->val = sum;
        bstToGst(root->left);
        return root;
    }
};
```

## [828. 统计子串中的唯一字符](https://leetcode.cn/problems/count-unique-characters-of-all-substrings-of-a-given-string/description/?envType=daily-question&envId=2023-11-26)

```c++
class Solution {
public:
    int uniqueLetterString(string s) {
        vector<vector<int>> vec(26, vector<int>(1, -1));
        int len = s.length(), ret = 0;
        for(int i = 0; i < len; i++) {
            vec[s[i] - 'A'].push_back(i);
        }
        for(int i = 0; i < 26; i++) {
            vector<int> &arr = vec[i];
            arr.push_back(len);
            int arr_len = arr.size();
            for(int j = 1; j < arr_len - 1; j++) {
                ret += (arr[j] - arr[j-1]) * (arr[j + 1] - arr[j]);
            }
        }
        return ret;
    }
};
```

## [1457. 二叉树中的伪回文路径](https://leetcode.cn/problems/pseudo-palindromic-paths-in-a-binary-tree/description/?envType=daily-question&envId=2023-11-25)

```c++
class Solution {
    vector<int> m;
    int odd_cnt = 0;
public:
    Solution():m(10) {}
    int pseudoPalindromicPaths (TreeNode* root) {
        if(!root) {
            return 0;
        }
        int ret = 0;
        m[root->val]++;
        if(m[root->val] % 2 == 1) odd_cnt++;
        else odd_cnt--;
        if(!root->left && !root->right) {
            if(odd_cnt <= 1)ret = 1;
        }
        if(root->left) ret += pseudoPalindromicPaths(root->left);
        if(root->right) ret += pseudoPalindromicPaths(root->right);
        m[root->val]--;
        if(m[root->val] % 2 == 1) odd_cnt++;
        else odd_cnt--;
        return ret;
    }
};
```

## [2824. 统计和小于目标的下标对数目](https://leetcode.cn/problems/count-pairs-whose-sum-is-less-than-target/description/?envType=daily-question&envId=2023-11-24)

```c++
class Solution {
public:
    int countPairs(vector<int>& nums, int target) {
        sort(nums.begin(), nums.end());
        int n = nums.size();
        int ret = 0, pos = n - 1;
        int i = 0;
        while(i < pos) {
            while(pos > i && nums[pos] + nums[i] >= target) pos--;
            ret += pos - i;
            i++;
        }
        return ret;
    }
};
```

```c++
class Solution {
public:
    int countPairs(vector<int>& nums, int target) {
        sort(nums.begin(), nums.end());
        int n = nums.size();
        int ret = 0;
        for(int i = 0; i < n - 1; i++) {
            if(nums[i+1] >= target - nums[i]) break;
            int pos = upper_bound(nums.begin() + i + 1, nums.end(), target - nums[i] - 1) - nums.begin();
            ret += pos - i - 1;
        }
        return ret;
    }
};
```

## [1410. HTML 实体解析器](https://leetcode.cn/problems/html-entity-parser/description/?envType=daily-question&envId=2023-11-23)

```c++
class Solution {
public:
    bool strneq(const string& str, int index, int strlen, const char *cmp, int len) {
        if(strlen - index < len) return false;
        for(int i = 0; i < len; i++) {
            if(str[index + i] != cmp[i]) return false;
        }
        return true;
    }
    string entityParser(string text) {
        string res;
        int len = text.length(), i = 0;
        while(i < len) {
            if(text[i] != '&') res.push_back(text[i]);
            else {
                if(strneq(text, i, len, "&quot;", 6)) {
                    i += 6;
                    res.push_back('"');
                    continue;
                } else if(strneq(text, i, len, "&apos;", 6)) {
                    i += 6;
                    res.push_back('\'');
                    continue;
                } else if(strneq(text, i, len, "&amp;", 5)) {
                    i += 5;
                    res.push_back('&');
                    continue;
                } else if(strneq(text, i, len, "&gt;", 4)) {
                    i += 4;
                    res.push_back('>');
                    continue;
                } else if(strneq(text, i, len, "&lt;", 4)) {
                    i += 4;
                    res.push_back('<');
                    continue;
                } else if(strneq(text, i, len, "&frasl;", 7)) {
                    i += 7;
                    res.push_back('/');
                    continue;
                } else {
                    res.push_back(text[i]);
                }
            }
            i++;
        }
        return res;
    }
};
```

## [2304. 网格中的最小路径代价](https://leetcode.cn/problems/minimum-path-cost-in-a-grid/description/?envType=daily-question&envId=2023-11-22)
```c++
class Solution {
public:
    int minPathCost(vector<vector<int>>& grid, vector<vector<int>>& moveCost) {
        int m = grid.size(), n = grid[0].size();
        vector<vector<int>> g(m, vector<int>(n, INT_MAX / 2));
        for(int j = 0; j < n; j++) {
            g[0][j] = 0;
        }
        for(int i = 0; i < m - 1; i++) {
            for(int j = 0; j < n; j++) {
                for(int k = 0; k < n; k++) {
                    g[i+1][k] = min(g[i+1][k], g[i][j] + grid[i][j] + moveCost[grid[i][j]][k]);
                }
            }
        }
        int minCost = INT_MAX;
        for(int k = 0; k < n; k++) {
            minCost = min(minCost, g[m-1][k] + grid[m-1][k]);
        }
        return minCost;
    }
};
```

## [2216. 美化数组的最少删除数](https://leetcode.cn/problems/minimum-deletions-to-make-array-beautiful/description/?envType=daily-question&envId=2023-11-21)

```c++
class Solution {
public:
    int minDeletion(vector<int>& nums) {
        int len = nums.size();
        int i = 0;
        bool odd = false;
        int deleteCnt = 0;
        while(i < len) {
            int j = i + 1;
            while(!odd && j < len && nums[j] == nums[i]) j++;
            deleteCnt += j - i - 1;
            i = j;
            odd = !odd;
        }
        if((len - deleteCnt) % 2 == 1) {
            deleteCnt++;
        }
        return deleteCnt;
    }
};
```

## [53. 最大子数组和](https://leetcode.cn/problems/maximum-subarray/description/?envType=daily-question&envId=2023-11-20)

写过，记住答案了，还是不太懂

```c++
class Solution {
public:
    int maxSubArray(vector<int>& nums) {
        int subSum = 0, maxSubSum = INT_MIN;
        for(int n : nums) {
            if(subSum <= 0) subSum = n;
            else subSum += n;
            maxSubSum = max(maxSubSum, subSum);
        }
        return maxSubSum;
    }
};
```

### 思考
可以把前缀和的折线图画出来，发现，如果遇到负数，曲线会从最高值降低，
如果在变成0之前遇到正数，则此时在原来的基础上加上该正数，就可以得到目前为止，局部的最大值
如果在变成0之后遇到正数，则此时不在原来的基础上加上该正数，这样正数就不会被前面的负数和儿抵消，从而获得当前的局部最大值

## [2477. 到达首都的最少油耗](https://leetcode.cn/problems/minimum-fuel-cost-to-report-to-the-capital/description/?envType=daily-question&envId=2023-12-05)
- 只要总路程最小就好了，需要对车辆座位的最大化利用
- 如果一条线路的长度不足以坐满一辆车，可以把多个线路的乘客先聚集在最近的公共祖先上，然后统一发车

```c++
class Solution {
public:
    long long minimumFuelCost(vector<vector<int>>& roads, int seats) {
        int n = roads.size() + 1;
        vector<vector<int>> g(n);
        vector<int> parent(n, 0);
        vector<int> len(n, 0);
        vector<int> deg(n, 0);
        vector<bool> visited(n, false);
        for(vector<int> & vec : roads) {
            g[vec[1]].push_back(vec[0]);
            g[vec[0]].push_back(vec[1]);
        }
        queue<int> q;
        q.push(0);
        int depth = 0;
        while(!q.empty()) {
            int node = q.front();
            q.pop();
            depth++;
            visited[node] = true;
            for(int child : g[node]) {
                if(visited[child]) continue;
                parent[child] = node;
                deg[node]++;
                q.push(child);
            }
        }
        visited = vector<bool>(n, false);
        for(int i = 1; i < n; i++) {
            if(deg[i] == 0) {
                q.push(i);
            }
        }
        long long ret = 0;
        while(!q.empty()) {
            int city = q.front();
            q.pop();
            len[parent[city]] += len[city] + 1;
            ret += (len[city] + 1) / seats + ((len[city] + 1)%seats ? 1 : 0);
            deg[parent[city]]--;
            city = parent[city];
            if(deg[city] == 0 && city != 0) {
                q.push(city);
            }
        }
        return ret;
    }
};
```

## 2342. 数位和相等数对的最大和

```c++
class Solution {
public:
    int maximumSum(vector<int>& nums) {
        int n = nums.size();
        unordered_map<int, int> bitSumMapMax;
        unordered_map<int, int> bitSumMapSecondMax;
        int maxSum = -1;
        for(int i = 0; i < n; i++) {
            int num = nums[i];
            int sum = 0;
            while(num) {
                sum += num % 10;
                num /= 10;
            }
            if(!bitSumMapMax.count(sum)) {
                bitSumMapMax[sum] = nums[i];
            } else {
                if(nums[i] >= bitSumMapMax[sum]) {
                    bitSumMapSecondMax[sum] = bitSumMapMax[sum];
                    bitSumMapMax[sum] = nums[i];
                    maxSum = max(maxSum, bitSumMapSecondMax[sum] + bitSumMapMax[sum]);
                } else if(!bitSumMapSecondMax.count(nums[i])) {
                    bitSumMapSecondMax[sum] = nums[i];
                    maxSum = max(maxSum, bitSumMapSecondMax[sum] + bitSumMapMax[sum]);
                } else if(nums[i] > bitSumMapSecondMax[sum]) {
                    bitSumMapMax[sum] = nums[i];
                    maxSum = max(maxSum, bitSumMapSecondMax[sum] + bitSumMapMax[sum]);
                }
            }
        }
        return maxSum;
    }
};
```

```c++
class Solution {
public:
    int maximumSum(vector<int>& nums) {
        int n = nums.size();
        unordered_map<int, int> bitSumMapMax;
        int maxSum = -1;
        for(int i = 0; i < n; i++) {
            int num = nums[i];
            int sum = 0;
            while(num) {
                sum += num % 10;
                num /= 10;
            }
            if(!bitSumMapMax.count(sum)) {
                bitSumMapMax[sum] = nums[i];
            } else {
                maxSum = max(maxSum, nums[i] + bitSumMapMax[sum]);
                if(nums[i] >= bitSumMapMax[sum]) {
                    bitSumMapMax[sum] = nums[i];
                }
            }
        }
        return maxSum;
    }
};
```

## [1466. 重新规划路线](https://leetcode.cn/problems/reorder-routes-to-make-all-paths-lead-to-the-city-zero/description/?envType=daily-question&envId=2023-12-07)

```c++
class Solution {
public:
    int minReorder(int n, vector<vector<int>>& connections) {
        vector<vector<int>> g(n), parent(n);
        vector<bool> visited(n, false);
        int ret = 0;
        for(int i = 0; i < n - 1; i++) {
            g[connections[i][0]].push_back(connections[i][1]);
            g[connections[i][1]].push_back(connections[i][0]);
            parent[connections[i][0]].push_back(connections[i][1]);
        }
        stack<int> q;
        q.push(0);
        while(!q.empty()) {
            int node = q.top();
            q.pop();
            visited[node] = true;
            for(int child : g[node]) {
                if(visited[child]) continue;
                if(find(parent[node].begin(), parent[node].end(), child) != parent[node].end()) {
                    ret++;
                }
                q.push(child);
            }
        }
        return ret;
    }
};
```

```c++
class Solution {
public:
    int minReorder(int n, vector<vector<int>>& connections) {
        vector<vector<pair<int, int>>> g(n);
        int ret = 0;
        for(int i = 0; i < n - 1; i++) {
            g[connections[i][0]].push_back(make_pair(connections[i][1], 1));
            g[connections[i][1]].push_back(make_pair(connections[i][0], 0));
        }
        stack<int> q;
        q.push(0);
        while(!q.empty()) {
            int node = q.top();
            q.pop();
            visited[node] = true;
            for(auto& child : g[node]) {
                if(visited[child.first]) continue;
                ret += child.second;
                q.push(child.first);
            }
        }
        return ret;
    }
};
```