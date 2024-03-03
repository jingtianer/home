---
title: LeetCode-28
date: 2023-11-12 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## <font color="red">[Hard] </font>[715. Range 模块](https://leetcode.cn/problems/range-module/description/?envType=daily-question&envId=2023-11-12)

### 思路
- 二分查找
- 一开始想的是用`[left, right)`和全部区间进行比较查找，但是这样比较困难，在处理边界合并情况时会变成O(N)
- 用`left`和`right`分别在所有ranges中查找
  - 对于query，如果两个下标相同，则true，否则false
  - 对于add，查找left-1和right的下标，然后其间的所有ranges删除，插入新range
  - 对于remove，查找left和right-1的下标，然后根据下标把之间的删除，插入剩余的区间

### ac代码
```c++
class RangeModule {
    vector<pair<int, int>> ranges;
    int len = 0;
    int ops = 0;
    static constexpr bool debug = false;
    void printRanges() {
        int size = ranges.size();
        cout << "len = " << len << ", size = " << size << "\n";
        for(int i = 0; i < size; i++) {
            cout << "[" << ranges[i].first << ", " << ranges[i].second << "]\n";
        }
    }
    bool inRange(int n, int index) {
        return ranges[index].first <= n && n < ranges[index].second;
    }
    bool bigger(int n, int index) {
        return n >= ranges[index].second;
    }
    bool smaller(int n, int index) {
        return ranges[index].first > n;
    }
    int searchRanges(int n) {
        int l = 0, r = len;
        while(l < r) {
            int mid = (r - l) / 2 + l;
            if(inRange(n, mid)) return mid;
            else if(bigger(n, mid)) {
                l = mid + 1;
            } else {
                r = mid;
            }
        }
        return l;
    }
public:
    RangeModule() {

    }
    
    void addRange(int left, int right) {
        // if(debug) {
        //     ops++;
        //     cout << "[" << ops << "], " << "addRange" << "[" << left << ", " << right << "]" << "\n";
        // }
        _addRange(left, right);
        // if(debug) printRanges();
    }
    void _addRange(int left, int right) {
        int leftIndex = searchRanges(left-1);
        int rightIndex = searchRanges(right); // add时考虑合并相邻的集合，所以把边界放宽
        // if(leftIndex > 0 && ranges[leftIndex - 1].second == left) {
        //     leftIndex--;
        // }
        // if(rightIndex < len - 1 && ranges[rightIndex + 1].first == )
        // if(debug) cout << "leftIndex = " << leftIndex << ",  rightIndex = " << rightIndex << "\n";
        if(leftIndex == rightIndex && leftIndex == len) {
        } else {
            left = min(left, ranges[leftIndex].first);
            if(rightIndex < len) {
                if(inRange(right, rightIndex)) {
                    right = max(right, ranges[rightIndex].second);
                    rightIndex++;
                }
            }
            ranges.erase(ranges.begin() + leftIndex, ranges.begin() + rightIndex);
            len -= rightIndex - leftIndex;
        }
        ranges.insert(ranges.begin() + leftIndex, make_pair(left, right));
        len++;
    }
    
    bool queryRange(int left, int right) {
        // if(debug) {
        //     ops++;
        //     cout << "[" << ops << "], " << "queryRange" << "[" << left << ", " << right << "]" << "\n";
        // }
        bool ret = _queryRange(left, right);
        // if(debug) cout << (ret ? "ok" : "not found") << "\n";
        // if(debug) printRanges();
        return ret;
    }
    bool _queryRange(int left, int right) {
        int leftIndex = searchRanges(left);
        int rightIndex = searchRanges(right-1);
        if(leftIndex >= len || rightIndex >= len) return false;
        return leftIndex == rightIndex && inRange(left, leftIndex) && inRange(right-1, rightIndex);
    }
    void removeRange(int left, int right) {
        // if(debug) {
        //     ops++;
        //     cout << "[" << ops << "], " << "removeRange" << "[" << left << ", " << right << "]" << "\n";
        // }
        _removeRange(left, right);
        // if(debug) printRanges();
    }
    void _removeRange(int left, int right) {
        int leftIndex = searchRanges(left);
        int rightIndex = searchRanges(right-1);
        // if(debug) cout << "leftIndex = " << leftIndex << ",  rightIndex = " << rightIndex << "\n";
        if(leftIndex == rightIndex && leftIndex == len) {
            return;
        } else {
            int leftLeft = left, rightRight = right;
            if(inRange(left, leftIndex)) {
                leftLeft = ranges[leftIndex].first;
            }
            if(rightIndex < len) {
                if(inRange(right-1, rightIndex)) {
                    rightRight = ranges[rightIndex].second;
                    rightIndex++;
                }
            }
            // if(debug) cout << "leftIndex = " << leftIndex << ",  rightIndex = " << rightIndex << "\n";
            // if(debug) cout << "leftLeft = " << leftLeft << ",  rightRight = " << rightRight << "\n";
            ranges.erase(ranges.begin() + leftIndex, ranges.begin() + rightIndex);
            len -= rightIndex - leftIndex;
            // if(debug) cout << "len = " << len << "\n";
            if(rightRight > right) {
                len++;
                ranges.insert(ranges.begin() + leftIndex, make_pair(right, rightRight));
                // if(debug) cout << "add right len = " << len << "\n";
            }
            if(leftLeft < left) {
                len++;
                ranges.insert(ranges.begin() + leftIndex, make_pair(leftLeft, left));
                // if(debug) cout << "add left len = " << len << "\n";
            }
        }
    }
};

/**
 * Your RangeModule object will be instantiated and called as such:
 * RangeModule* obj = new RangeModule();
 * obj->addRange(left,right);
 * bool param_2 = obj->queryRange(left,right);
 * obj->removeRange(left,right);
 */
```

### 优化
一些情况可以利用原有的ranges，而无需删除

```c++
class RangeModule {
    vector<pair<int, int>> ranges;
    int len = 0;
    int ops = 0;
    static constexpr bool debug = false;
    void printRanges() {
        int size = ranges.size();
        cout << "len = " << len << ", size = " << size << "\n";
        for(int i = 0; i < size; i++) {
            cout << "[" << ranges[i].first << ", " << ranges[i].second << "]\n";
        }
    }
    bool inRange(int n, int index) {
        return ranges[index].first <= n && n < ranges[index].second;
    }
    bool bigger(int n, int index) {
        return n >= ranges[index].second;
    }
    bool smaller(int n, int index) {
        return ranges[index].first > n;
    }
    int searchRanges(int n) {
        int l = 0, r = len;
        while(l < r) {
            int mid = (r - l) / 2 + l;
            if(inRange(n, mid)) return mid;
            else if(bigger(n, mid)) {
                l = mid + 1;
            } else {
                r = mid;
            }
        }
        return l;
    }
public:
    RangeModule() {

    }
    
    void addRange(int left, int right) {
        if(debug) {
            ops++;
            cout << "[" << ops << "], " << "addRange" << "[" << left << ", " << right << "]" << "\n";
        }
        _addRange(left, right);
        if(debug) printRanges();
    }
    void _addRange(int left, int right) {
        int leftIndex = searchRanges(left-1);
        int rightIndex = searchRanges(right); // add时考虑合并相邻的集合，所以把边界放宽
        if(debug) cout << "leftIndex = " << leftIndex << ",  rightIndex = " << rightIndex << "\n";
        if(leftIndex == rightIndex && leftIndex == len) {
            ranges.insert(ranges.begin() + leftIndex, make_pair(left, right));
            len++;
        } else {
            left = min(left, ranges[leftIndex].first);
            if(rightIndex < len) {
                if(inRange(right, rightIndex)) {
                    right = max(right, ranges[rightIndex].second);
                    rightIndex++;
                }
            }
            if(leftIndex == rightIndex && !inRange(left-1, leftIndex) && !inRange(right, rightIndex)) {
                ranges.insert(ranges.begin() + leftIndex, make_pair(left, right));
                len++;
            } else {
                ranges[leftIndex].first = left;
                ranges[leftIndex].second = right;
                leftIndex++;
                if(rightIndex > leftIndex) ranges.erase(ranges.begin() + leftIndex, ranges.begin() + rightIndex);
                if(rightIndex > leftIndex) len -= rightIndex - leftIndex;
            }
            
        }
    }
    
    bool queryRange(int left, int right) {
        if(debug) {
            ops++;
            cout << "[" << ops << "], " << "queryRange" << "[" << left << ", " << right << "]" << "\n";
        }
        bool ret = _queryRange(left, right);
        if(debug) cout << (ret ? "ok" : "not found") << "\n";
        if(debug) printRanges();
        return ret;
    }
    bool _queryRange(int left, int right) {
        int leftIndex = searchRanges(left);
        int rightIndex = searchRanges(right-1);
        if(leftIndex >= len || rightIndex >= len) return false;
        return leftIndex == rightIndex && inRange(left, leftIndex) && inRange(right-1, rightIndex);
    }
    void removeRange(int left, int right) {
        if(debug) {
            ops++;
            cout << "[" << ops << "], " << "removeRange" << "[" << left << ", " << right << "]" << "\n";
        }
        _removeRange(left, right);
        if(debug) printRanges();
    }
    void _removeRange(int left, int right) {
        int leftIndex = searchRanges(left);
        int rightIndex = searchRanges(right-1);
        if(debug) cout << "leftIndex = " << leftIndex << ",  rightIndex = " << rightIndex << "\n";
        if(leftIndex == rightIndex && leftIndex == len) {
            return;
        } else {
            int leftLeft = left, rightRight = right;
            if(inRange(left, leftIndex)) {
                leftLeft = ranges[leftIndex].first;
            }
            if(rightIndex < len) {
                if(inRange(right-1, rightIndex)) {
                    rightRight = ranges[rightIndex].second;
                    rightIndex++;
                }
            }
            if(debug) cout << "leftIndex = " << leftIndex << ",  rightIndex = " << rightIndex << "\n";
            if(debug) cout << "leftLeft = " << leftLeft << ",  rightRight = " << rightRight << "\n";
            if(rightRight > right) {
                rightIndex--;
                ranges[rightIndex].first = right;
                ranges[rightIndex].second = rightRight;
                if(debug) cout << "add right len = " << len << "\n";
            }
            if(leftLeft < left) {
                if(leftIndex == rightIndex) {
                    ranges.insert(ranges.begin() + leftIndex, make_pair(leftLeft, left));
                    len++;
                } else {
                    ranges[leftIndex].first = leftLeft;
                    ranges[leftIndex].second = left;
                    leftIndex++;
                }
                if(debug) cout << "add left len = " << len << "\n";
            }
            ranges.erase(ranges.begin() + leftIndex, ranges.begin() + rightIndex);
            len -= rightIndex - leftIndex;
            if(debug) cout << "len = " << len << "\n";
        }
    }
};

/**
 * Your RangeModule object will be instantiated and called as such:
 * RangeModule* obj = new RangeModule();
 * obj->addRange(left,right);
 * bool param_2 = obj->queryRange(left,right);
 * obj->removeRange(left,right);
 */
```

## [1334. 阈值距离内邻居最少的城市](https://leetcode.cn/problems/find-the-city-with-the-smallest-number-of-neighbors-at-a-threshold-distance/description/?envType=daily-question&envId=2023-11-14)

### Floyd
```c++
class Solution {
public:
    int findTheCity(int n, vector<vector<int>>& edges, int distanceThreshold) {
        vector<vector<int>> g(n, vector<int>(n, INT_MAX));
        vector<int> cnt(n, 0);
        for(vector<int>& edge : edges) {
            g[edge[0]][edge[1]] = edge[2];
            g[edge[1]][edge[0]] = edge[2];
        }
        for(int w = 0; w < n; w++) {
            for(int i = 0; i < n; i++) {
                for(int j = 0; j < n; j++) {
                    if(g[i][w] != INT_MAX && g[w][j] != INT_MAX && g[i][w] + g[w][j] < g[i][j])
                        g[i][j] = g[i][w] + g[w][j];
                }
            }
        }
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                if(i != j && g[i][j] <= distanceThreshold) {
                    cnt[i]++;
                }
            }
        }
        int ret = 0;
        int min_num = INT_MAX;
        for(int i = n-1; i >= 0; i--) {
            if(cnt[i] < min_num) {
                min_num = cnt[i];
                ret = i;
            }
        }
        return ret;
    }
};
```

中间节点`w`要放在最外层循环
#### 优化一下下
```c++
class Solution {
public:
    int findTheCity(int n, vector<vector<int>>& edges, int distanceThreshold) {
        vector<vector<int>> g(n, vector<int>(n, INT_MAX / 2));
        for(vector<int>& edge : edges) {
            g[edge[0]][edge[1]] = edge[2];
            g[edge[1]][edge[0]] = edge[2];
        }
        for(int w = 0; w < n; w++) {
            g[w][w] = 0;
            for(int i = 0; i < n; i++) {
                for(int j = 0; j < n; j++) {
                    if(g[i][w] + g[w][j] < g[i][j])
                        g[i][j] = g[i][w] + g[w][j];
                }
            }
        }
        int ret = 0;
        int min_num = INT_MAX;
        for(int i = n-1; i >= 0; i--) {
            int cnt = 0;
            for(int j = 0; j < n; j++) {
                if(g[i][j] <= distanceThreshold) {
                    cnt++;
                }
            }
            if(cnt < min_num) {
                // cout << "i = " << i << ", cnt[i] = " << cnt[i] << "\n";
                min_num = cnt;
                ret = i;
            }
        }
        return ret;
    }
};
```
### BFS

写了半天，发现带权图不能bfs求最短路径

### dijkstra

```c++
class Solution {
    int min_index(int len, const  vector<int>& v, const vector<bool>& visited) {
        pair<int, int> ret(INT_MAX, -1);
        for(int i = 0; i < len; i++) {
            if(!visited[i] && v[i] < ret.first) {
                ret = {v[i], i};
            }
        }
        return ret.second;
    }
public:
    int findTheCity(int n, vector<vector<int>> &edges, int distanceThreshold) {
        vector<vector<pair<int, int>>> g(n);
        for(auto& edge : edges) {
            g[edge[0]].push_back(make_pair(edge[1], edge[2]));
            g[edge[1]].push_back(make_pair(edge[0], edge[2]));
        }
        int ret = -1;
        int min_cnt = INT_MAX;
        for(int node = 0; node < n; node++) {
            int cnt = 0;
            vector<int> min_dis(n, INT_MAX >> 2);
            vector<bool> visited(n, false);
            min_dis[node] = 0;
            int next = node;
            do {
                visited[next] = true;
                for(auto& [child, weight] : g[next]) {
                    min_dis[child] = min(min_dis[child], min_dis[next] + weight);
                }
            } while((next = min_index(n, min_dis, visited)) != -1);
            for(int i = 0; i < n; i++) {
                if(min_dis[i] <= distanceThreshold) {
                    cnt++;
                }
            }
            if(cnt <= min_cnt) {
                min_cnt = cnt;
                ret = node;
            }
        }
        return ret;
    }
};
```

## [307. 区域和检索 - 数组可修改](https://leetcode.cn/problems/range-sum-query-mutable/description/?envType=daily-question&envId=2023-11-13)
### 分块
#### 思路
把数组分成`sqrt(n)`份，存储每份的和
更新时，找到对应区间把值更新，`O(1)`
求值时，把left到right对应区间的和加起来，加上right右边的不足一个区间的，减去左侧超过一个区间的，三个运算都在`sqrt(n)`内完成, `O(sqrt(n))`

#### 代码
```c++
class NumArray {
    vector<int> data;
    vector<int> preSum;
    int size;
    int len;
public:
    NumArray(vector<int>& nums) {
        data = nums;
        len = nums.size();
        if(len == 0) return;
        size = sqrt(len);
        preSum = vector<int>(size + 20, 0);
        for(int i = 0; i < len; i++) {
            preSum[i / size] += nums[i];
        }
    }
    
    void update(int index, int val) {
        int prev = data[index];
        data[index] = val;
        preSum[index / size] += val - prev;
    }
    
    int sumRange(int left, int right) {
        int sum = 0;
        for(int i = left/size; i < right/size; i++) {
            sum += preSum[i];
        }
        for(int i = right / size * size; i <= right; i++) {
            sum += data[i];
        }
        for(int i = left / size * size; i < left; i++) {
            sum -= data[i];
        }
        return sum;
    }
};

/**
 * Your NumArray object will be instantiated and called as such:
 * NumArray* obj = new NumArray(nums);
 * obj->update(index,val);
 * int param_2 = obj->sumRange(left,right);
 */
```

### 线段树
- 构造一棵树
  - 根节点代表`[0, n-1]`的和
  - 两个子节点分别代表`[0,(n-1)/2]`和`[(n-1)/2+1, n-1]`的和
  - 如果区间为0，则不继续细分
- 更新
  - 根据index在树中查找，同时更新所有父节点的值
- 查询
  - 对于一个查询，
    - 如果查询范围刚好等于节点代表的范围，则返回该节点的值
    - 如果不同，则将查询一分为两个子查询，分别交给子节点处理，直到遇到子查询与子节点代表的范围相同，将所有子查询相加

```c++
class NumArray {
private:
    vector<int> tree;
    int n;
    int build(int node, int l, int r, const vector<int>& nums) {
        if(l == r) tree[node] = nums[l];
        else {
            int mid = (r - l) / 2 + l;
            tree[node] = build(2*node+1, l, mid, nums) + build(2*node+2, mid+1, r, nums);
        }
        return tree[node];
    }
    void updateTree(int node, int index, int l, int r, int val) {
        if(l == r) tree[node] = val;
        else {
            int mid = (r - l) / 2 + l;
            if(index <= mid) {
                updateTree(node*2+1, index, l, mid, val);
            } else {
                updateTree(node*2+2, index, mid+1, r, val);
            }
            tree[node] = tree[2*node+1] + tree[2*node+2];
        }
    }
    int sumTree(int node, int left, int right, int l, int r) {
        if(left == l && right == r) {
            return tree[node];
        }
        int mid = (r - l) / 2 + l;
        if(left > mid) {
            return sumTree(node*2+2, left, right, mid+1, r);
        } else if(right <= mid) {
            return sumTree(node*2+1, left, right, l, mid);
        } else {
            return sumTree(node*2+1, left, mid, l, mid) + sumTree(2*node+2, mid+1, right, mid+1, r);
        }
    }
public:
    NumArray(vector<int>& nums) {
        n = nums.size();
        tree = vector<int>(n * 4);
        build(0, 0, n-1, nums);
    }
    
    void update(int index, int val) {
        updateTree(0, index, 0, n-1, val);
    }
    
    int sumRange(int left, int right) {
        return sumTree(0, left, right, 0, n-1);
    }
};

/**
 * Your NumArray object will be instantiated and called as such:
 * NumArray* obj = new NumArray(nums);
 * obj->update(index,val);
 * int param_2 = obj->sumRange(left,right);
 */
```

## [765. 情侣牵手](https://leetcode.cn/problems/couples-holding-hands/description/?envType=daily-question&envId=2023-11-11)

### 思路
看了下面的提示：
> Say there are N two-seat couches. For each couple, draw an edge from the couch of one partner to the couch of the other partner.

让我画出座位上的人到其伴侣的箭头
- 如果箭头在同一个沙发上，就无需交换
- 如果不在同一个沙发上，就让另一个人与其交换
- 对每个沙发执行相同的任务
### 代码
```c++
class Solution {
    int n;
    int min_swap_cnt = INT_MAX;
    unordered_map<int, int> pos;
public:
    int minSwapsCouples(vector<int>& row) {
        n = row.size();
        for(int i = 0; i < n; i++) {
            pos[row[i]] = i;
        }
        search(0, 0, row);
        return min_swap_cnt;
    }
    void print(const vector<int>& nums) {
        cout << nums[0];
        for(int i = 1; i < n; i++) cout  << ", " << nums[i];
        cout << "\n";
    }
    bool check(const vector<int>& nums) {
        for(int i = 0; i < n; i+=2) {
            if(abs(nums[i] - nums[i+1]) != 1) return false;
        }
        return true;
    }
    void search(int s, int cnt, vector<int> &nums) {
        // print(nums);
        if(check(nums)) {
            min_swap_cnt = min(min_swap_cnt, cnt);
            return;
        }
        if(s >= n) return;
        int i = s;
        for(int i = s; i < n; i++) {
            int target = nums[i] + ((nums[i] & 1) ? -1 : 1);
            int j = pos[target];
            if(i/2 != j/2) {
                int x = (i&1) ? -1 : 1;
                pos[target] = i + x;
                pos[nums[i + x]] = j;
                swap(nums[i + x], nums[j]);
                search(i + 2, cnt+1, nums);
                // swap(nums[i + x], nums[j]);
                // pos[target] = j;
                // pos[nums[i + x]] = i + x;
                // search(i + 2, cnt, nums);
                break;
            }
        }
    }
};
```

> emm,一点点蒙对的，居然对了

### 简化代码

```c++
class Solution {
public:
    int minSwapsCouples(vector<int>& row) {
        int swap_cnt = 0;
        int n = row.size();
        vector<int> pos(n);
        for(int i = 0; i < n; i++) {
            pos[row[i]] = i;
        }
        for(int i = 0; i < n; i+=2) {
            int target = row[i] + ((row[i] & 1) ? -1 : 1);
            int j = pos[target];
            if(i/2 != j/2) {
                swap(pos[target], pos[row[i + 1]]);
                swap(row[i + 1], row[j]);
                swap_cnt++;
            }
        }
        return swap_cnt;
    }
};
```