---
title: LeetCode-30
date: 2023-12-19 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## [162. 寻找峰值](https://leetcode.cn/problems/find-peak-element/description/?envType=daily-question&envId=2023-12-18)

```c++
class Solution {
public:
    int findPeakElement(vector<int>& nums) {
        int index = 0;
        int n = nums.size();
        while(index < n-1 && nums[index] < nums[index+1]) index++;
        return index;
    }
};
```

## [1901. 寻找峰值 II](https://leetcode.cn/problems/find-a-peak-element-ii/description/?envType=daily-question&envId=2023-12-19)

```c++
class Solution {
public:
    vector<int> findPeakGrid(vector<vector<int>>& mat) {
        int x = 0, y = 0;
        int m = mat.size(), n = mat[0].size();
        bool findPoint = true;
        while(findPoint) {
            findPoint = false;
            if(x + 1 < m && mat[x+1][y] > mat[x][y]) {
                findPoint = true;
                x++;
            } else if(x - 1 >= 0 && mat[x-1][y] > mat[x][y]) {
                findPoint = true;
                x--;
            } else if(y + 1 < n && mat[x][y+1] > mat[x][y]) {
                findPoint = true;
                y++;
            } else if(y - 1 >= 0 && mat[x][y-1] > mat[x][y]) {
                findPoint = true;
                y--;
            }

        }
        return {x, y};
    }
};
```

贪心，从某一点开始，如果上下左右存在比当前点大的数，移动过去，直到无法移动

## [746. 使用最小花费爬楼梯](https://leetcode.cn/problems/min-cost-climbing-stairs/description/?envType=daily-question&envId=2023-12-17)

```c++
class Solution {
public:
    int minCostClimbingStairs(vector<int>& cost) {
        int n = cost.size();
        vector<int> vecc(n+1, INT_MAX);
        vecc[0] = vecc[1] = 0;
        for(int i = 0; i < n-1; i++) {
            vecc[i+1] = min(vecc[i+1], vecc[i] + cost[i]);
            vecc[i+2] = min(vecc[i+2], vecc[i] + cost[i]);
        }
        vecc[n] = min(vecc[n], vecc[n-1] + cost[n-1]);
        return vecc[n];
    }
};
```

```c++
class Solution {
public:
    int minCostClimbingStairs(vector<int>& cost) {
        int n = cost.size();
        int a = cost[0], b = cost[1];
        for(int i = 2; i < n; i++) {
            int t = cost[i] + min(a, b);
            a = b;
            b = t;
        }
        return min(a, b);
    }
};
```

## [2415. 反转二叉树的奇数层](https://leetcode.cn/problems/reverse-odd-levels-of-binary-tree/description/?envType=daily-question&envId=2023-12-15)

```c++
class Solution {
public:
    TreeNode* reverseOddLevels(TreeNode* root) {
        queue<TreeNode *> q;
        if(root) q.push(root);
        int n = 1;
        bool rev = false;
        while(!q.empty()) {
            int cnt = n;
            vector<TreeNode *> tmp;
            while(n--) {
                TreeNode *node = q.front();
                q.pop();
                if(rev) tmp.push_back(node);
                if(node->left && node->right) {
                    q.push(node->left);
                    q.push(node->right);
                }
            }
            if(rev) {
                for(int i = 0; i < cnt / 2; i++) {
                    swap(tmp[i]->val, tmp[cnt - 1 - i]->val);
                }
            }
            rev = !rev;
            n = cnt << 1;
        }
        return root;
    }
};
```

## [1631. 最小体力消耗路径](https://leetcode.cn/problems/path-with-minimum-effort/description/?envType=daily-question&envId=2023-12-11)

### 超时
```c++
class Solution {
public:
    int minimumEffortPath(vector<vector<int>>& heights) {
        int row = heights.size(), col = heights[0].size();
        if(row <= 1 && col <= 1) return 0;
        vector<int> len(row*col, INT_MAX / 2);
        vector<bool> visited(row*col, false);
        len[0] = 0;
        for(int i = 0; i < row*col - 1; i++) {
            int min_dis = 0;
            int node = -1;
            for(int j = 0; j < row*col; j++) {
                if(!visited[j] && (node == -1 || len[j] < len[node])) {
                    node = j;
                }
            }
            int x = node / col, y = node % col;
            if(x < row - 1 && !visited[node+col]) len[node+col] = min(len[node+col], max(len[node], abs(heights[x][y] - heights[x+1][y])));
            if(y < col - 1 && !visited[node+1]) len[node+1] = min(len[node+1], max(len[node], abs(heights[x][y] - heights[x][y+1])));
            if(x > 0 && !visited[node-col]) len[node-col] = min(len[node-col], max(len[node], abs(heights[x][y] - heights[x-1][y])));
            if(y > 0 && !visited[node-1]) len[node-1] = min(len[node-1], max(len[node], abs(heights[x][y] - heights[x][y-1])));

            visited[node] = true;
        }
        return len[row*col-1];
    }
};
```

### 优化
dijkstra需要用优先队列优化一下
```c++
class Solution {
    static constexpr int dirs[4][2] = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}};
public:
    int minimumEffortPath(vector<vector<int>>& heights) {
        int row = heights.size(), col = heights[0].size();
        if(row <= 1 && col <= 1) return 0;
        vector<int> len(row*col, INT_MAX / 2);
        vector<bool> visited(row*col, false);
        len[0] = 0;
        int min_dis = 0;
        int node = -1;
        auto tupleCmp = [](const auto& e1, const auto& e2) {
            auto&& [x1, d1] = e1;
            auto&& [x2, d2] = e2;
            return d1 > d2;
        };
        priority_queue<pair<int, int>, vector<pair<int, int>>, decltype(tupleCmp)> q(tupleCmp);
        q.emplace(0, 0);
        while(!q.empty()) {
            auto [node, dis] = q.top();
            q.pop();
            int x = node / col, y = node % col;
            for(int i = 0; i < 4; i++) {
                int nx = x + dirs[i][0];
                int ny = y + dirs[i][1];
                if(nx >= 0 && ny >= 0 && nx < row && ny < col && max(dis, abs(heights[x][y] - heights[nx][ny])) < len[node + col * dirs[i][0] + dirs[i][1]]) {
                    len[node + col * dirs[i][0] + dirs[i][1]] = max(dis, abs(heights[x][y] - heights[nx][ny]));
                    q.emplace(node + col * dirs[i][0] + dirs[i][1], len[node + col * dirs[i][0] + dirs[i][1]]);
                }
            }
            visited[node] = true;
        }
        return len[row*col-1];
    }
};
```

## [LCR 078. 合并 K 个升序链表](https://leetcode.cn/problems/vvXgSW/description/)

- 方法和和并两个升序链表相同，k个链表每次从k个指针中选择出值最小的一个插入到总链表中
- 使用优先队列可以把算法优化到`O(k*log(k))`

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode() : val(0), next(nullptr) {}
 *     ListNode(int x) : val(x), next(nullptr) {}
 *     ListNode(int x, ListNode *next) : val(x), next(next) {}
 * };
 */
class Solution {
public:
    ListNode* mergeKLists(vector<ListNode*>& lists) {
        auto cmp = [](ListNode *a, ListNode *b) {
            return a->val > b->val;
        };
        priority_queue<ListNode*, vector<ListNode*>, decltype(cmp)> q(cmp);
        ListNode dummyNode;
        ListNode *dummyPtr = &dummyNode;
        int k = lists.size();
        for(int i = 0; i < k; i++) {
            if(lists[i]) q.push(lists[i]);
        }
        while(!q.empty()) {
            ListNode *node = q.top();
            q.pop();
            dummyPtr->next = node;
            dummyPtr = node;
            node = node->next;
            if(node) {
                q.push(node);
            }
        }
        return dummyNode.next;
    }
};
```

## [2866. 美丽塔 II](https://leetcode.cn/problems/beautiful-towers-ii/description/?envType=daily-question&envId=2023-12-21)

### 枚举山峰

```c++
class Solution {
private:
    int len;
    void toHill(const vector<int>& arr, int& index, int endIndex) const {
        while(index + 1 < endIndex && arr[index] <= arr[index+1]) index++;
    }
    void toValley(const vector<int>& arr, int& index, int endIndex) const {
        while(index + 1 < endIndex && arr[index] >= arr[index+1]) index++;
    }
public:
    long long maximumSumOfHeights(vector<int>& maxHeights) {
        len = maxHeights.size();
        int index = 0;
        toHill(maxHeights, index, len);
        long long res = 0;
        while(index < len) {
            int val = maxHeights[index];
            long long sum = 0;
            for(int i = index; i >= 0; i--) {
                val = min(val, maxHeights[i]);
                sum += val;
            }
            val = maxHeights[index];
            for(int i = index + 1; i < len; i++) {
                val = min(val, maxHeights[i]);
                sum += val;
            }
            res = max(sum, res);
            index++;
            toValley(maxHeights, index, len);
            toHill(maxHeights, index, len);
        }
        return res;
    }
}; 
```

### 单调栈

- 还是不会单调栈，明天开学单调栈！


## 2048. 下一个更大的数值平衡数

### 排列组合

- 若平衡数为d位数，将d拆成若干个不相等的数
  - 如：6可以拆成，`6`, `2+4`, `1+5`, `1+2+3`
  - 他们分别对应，`666666`, `224444`, `155555`, `122333`以及他们的排列组合
- 求出所有排列组合，找到大于n的最小排列
- 由于一个数的下一个平衡数的位数可能大于他，需要考虑相邻两位的情况

```c++
class Solution {
    vector<vector<string>> origin = {
        {"1"}, 
        {"22"},
        {"122",     "333"},
        {"1333",    "4444"},
        {"22333",   "14444",    "55555"},
        {"122333",  "155555",   "224444",   "666666"},
        {"1224444"/*, "1666666",  "7777777"*/},
        {"88888888"} // dummy for 1000000
    };
    int n;
    int ret = INT_MAX;
    int len;
public:
    int nextBeautifulNumber(int n) {
        if(n == 0) return 1;
        this->n = n;
        len = digitCnt(n);
        
        for(string s : origin[len-1]) {
            permutaion(s, 0);
        }
        len++;
        for(string s : origin[len-1]) {
            permutaion(s, 0);
        }
        return ret;
    }
    void permutaion(string &arr, int start) {
        if(start == len) {
            int number = 0;
            for(int i = 0; i < len; i++) {
                number *= 10;
                number += arr[i] - '0';
            }
            if(number > n) ret = min(ret, number);
        }
        for(int i = start; i < len; i++) {
            bool flag = false;
            for (int j = start; j < i; j++) {
                if (arr[i] == arr[j]) {
                    flag = true;
                    break;
                }
            }
            if(!flag) {
                swap(arr[i], arr[start]);
                permutaion(arr, start+1);
                swap(arr[i], arr[start]);
            }
        }
    }

    int digitCnt(int n) {
        int digit = 0;
        while(n) {
            n /= 10;
            digit++;
        }
        return digit;
    }
};
```

### 打表

- 生成所有满足条件的数
```c++
#include <stdio.h>
#include <limits.h>
#include <stdbool.h>

bool check(int i) {
    int cnt[10] = {0};
    char digits[128] = {0};
    sprintf(digits, "%d", i);
    char *ptr = digits;
    while(*ptr) {
        cnt[*ptr - '0']++;
        ptr++;
    }
    bool flag = cnt[0] == 0;
    for(int i = 1; i < 10; i++) {
        if(cnt[i] && cnt[i] != i) {
            flag = false;
            break;
        }
    }
    return flag;
}

int main() {
    printf("{");
    for(int i = 0; i < 1000000; i++) {
        if(check(i)) printf("%d,", i);
    }
    for(int i = 1000000 + 1; i < INT_MAX; i++) {
        if(check(i)) {
            printf("%d}\n", i);
            break;
        }
    }
    return 0;
}
```

```c++
class Solution {
    vector<int> origin = {
        1,22,122,212,221,333,1333,3133,3313,3331,4444,14444,22333,23233,23323,23332,32233,32323,32332,33223,33232,33322,41444,44144,44414,44441,55555,122333,123233,123323,123332,132233,132323,132332,133223,133232,133322,155555,212333,213233,213323,213332,221333,223133,223313,223331,224444,231233,231323,231332,232133,232313,232331,233123,233132,233213,233231,233312,233321,242444,244244,244424,244442,312233,312323,312332,313223,313232,313322,321233,321323,321332,322133,322313,322331,323123,323132,323213,323231,323312,323321,331223,331232,331322,332123,332132,332213,332231,332312,332321,333122,333212,333221,422444,424244,424424,424442,442244,442424,442442,444224,444242,444422,515555,551555,555155,555515,555551,666666,1224444
    };
public:
    int nextBeautifulNumber(int n) {
        return *upper_bound(origin.begin(), origin.end(), n);
    }
};
```

## [1671. 得到山形数组的最少删除次数](https://leetcode.cn/problems/minimum-number-of-removals-to-make-mountain-array/description/?envType=daily-question&envId=2023-12-22)

### dp
- 不会，抄答案
- `arr1[i]`表示`0..(i-1)`中小于`nums[i]`的元素个数
- `arr2[i]`表示`(i+1)..(len)`中小于`nums[i]`的元素个数
- `arr1[i] + arr2[i] + 1`表示以`i`为山峰的山状数组长度

```c++
class Solution {
    int n = 0;
    vector<int> getLISArray(const vector<int>& nums) {
        vector<int> dp(n, 1);
        for (int i = 0; i < n; ++i) {
            for (int j = 0; j < i; ++j) {
                if (nums[j] < nums[i]) {
                    dp[i] = max(dp[i], dp[j] + 1);
                }
            }
        }
        return dp;
    }
public:
    int minimumMountainRemovals(vector<int>& nums) {
        n = nums.size();
        vector<int> pre = getLISArray(nums);
        vector<int> suf = getLISArray({nums.rbegin(), nums.rend()});
        reverse(suf.begin(), suf.end());
        int ans = 0;
        for (int i = 0; i < n; ++i) {
            if (pre[i] > 1 && suf[i] > 1) {
                ans = max(ans, pre[i] + suf[i] - 1);
            }
        }

        return n - ans;
    }
};
```

## [1962. 移除石子使总数最小](https://leetcode.cn/problems/remove-stones-to-minimize-the-total/description/?envType=daily-question&envId=2023-12-23)

### 模拟

#### ac代码
```c++
class Solution {
public:
    int minStoneSum(vector<int>& piles, int k) {
        priority_queue<int> q;
        int ret = 0;
        for(int rock : piles) {
            if(rock) q.push(rock);
        }
        while(!q.empty() && k--) {
            int rock = q.top();
            q.pop();
            if(rock - rock / 2) q.push(rock - rock / 2);
        }
        while(!q.empty()) {
            int rock = q.top();
            q.pop();
            ret += rock;
        }
        return ret;
    }
};
```

#### 优化模拟

- 一边减少一边算最终结果

```c++
class Solution {
public:
    int minStoneSum(vector<int>& piles, int k) {
        priority_queue<int> q(piles.begin(), piles.end());
        int ret = accumulate(piles.begin(), piles.end(), 0);
        while(k--) {
            int rock = q.top();
            q.pop();
            if(rock - rock / 2) q.push(rock - rock / 2);
            ret -= rock / 2;
        }
        return ret;
    }
};
```

### 时间100%

- 看了时间100%的方法，由于数字最大是10000，可以创建一个长度为10000+1的bool数组
- 从下标最大到最小，选择存在于原数组的下标（bool数组置为true），除二，并把剩余部分设置为true
- 这样就可以起到和优先队列一样的效率

#### 代码


```c++
class Solution {
public:
    int minStoneSum(vector<int>& piles, int k) {
        bool buck[10000] = {false};
        int ret = 0, max_rock = INT_MIN;
        for(int rock : piles) {
            max_rock = max(max_rock, rock);
            buck[rock-1] = true;
            ret += rock;
        }
        while(max_rock--) {
            if(!buck[max_rock]) continue;
            if(k--) {
                int diff = (max_rock + 1) / 2;
                buck[max_rock - diff] = true;
                ret -= diff;
            } else {
                break;
            }
        }
        return ret;
    }
};
```

这个代码跑是错的，因为没有考虑同一个数出现多次的情况，所以不能使用bool数组

```c++
class Solution {
public:
    int minStoneSum(vector<int>& piles, int k) {
        int buck[10000+1] = {false};
        int ret = 0, max_rock = INT_MIN;
        for(int rock : piles) {
            max_rock = max(max_rock, rock);
            buck[rock]++;
            ret += rock;
        }
        for(;max_rock && k; max_rock--) {
            int width = min(buck[max_rock], k);
            int diff = (max_rock) / 2;
            ret -= diff * width;
            buck[max_rock - diff] += width;
            k -= width;
        }
        return ret;
    }
};
```

## [1954. 收集足够苹果的最小花园周长](https://leetcode.cn/problems/minimum-garden-perimeter-to-collect-enough-apples/description/?envType=daily-question&envId=2023-12-24)

### 枚举
- 刚开始看错题了，认为只计算正方形的边上的苹果数
- 推导出当边长为`2*radius`时，边上的苹果数目为
  - `4*radius + 8*radius + 4*3*radius*(radius-1)`
- 枚举边长并将边上的苹果加起来，直到超过需要的苹果即可
#### 公式推导

- bfs的思想
- 边长为0的所有点`(0,0)` 的子节点，分为两类是 
  - `|x| + |y| = 1` (1, 0), (0, 1), (-1, 0), (0, -1)
  - `|x| + |y| = 2` (1, 1), (1, -1), (-1, 1), (-1, -1)
- 点可能存在两种子节点，一种节点会让`|x| + |y|`增大1，另一种会增大2
  - 四个角上的子节点会增大二，四个角上的子节点有增大2和增大1的
  - 非四个角上的子节点只会增大1
- 四个角上的节点的`|x| + |y| = 2*radius`孵化子代
  - 产生4个增大2的，也就是公差为2的，也就是`4*2*radius`
  - 产生8个增大1的
- 剩余节点孵化子代
  - 只会产生一个公差为1的
- 再统计边长为1的所有点的子节点，可以发现，当半径为`radius`时：
  - `|x| + |y| = radius` 的有 4 个
  - `|x| + |y| = radius + i`, `i = 1, 2, ..., radius-1`的各有8个
  - `|x| + |y| = 2*radius`的有4个
- 总和为：
  - `4*radius`
  - $ 8 \times \sum_{i=radius+1}^{2*radius-1}{i} = \frac{(3 \times radius)\times(radius-1)}{2} \times 8$ 
  - `4*2*radius`
  - 将以上三部分求和，得到 $ 4*radius + 8*radius +  12*radius*(radius - 1)$

#### 代码

```c++
class Solution {
public:
    long long minimumPerimeter(long long neededApples) {
        long long radius = 0, apple = 0;
        while(apple < neededApples) {
            radius++;
            apple += 4*radius + 8*radius + 4*3*radius*(radius-1);
        }
        return 8 * radius;
    }
};
```

### 二分

- 将上面的公式再次推导，即可得到对于半径为radius的正方形上以及其内部，共有苹果
  - $ 2*radius*(radius+1)*(2*radius+1) $
- 然后就能愉快的二分啦

```c++
class Solution {
public:
    long long minimumPerimeter(long long neededApples) {
        long long mid = 0, apple = 0;
        int l = 0, r = 500000;
        while(l < r) {
            // [l, r]
            // f(l) < target
            // f(r) >= target
            mid = (r - l) / 2 + l;
            apple = 2*mid*(mid+1)*(2*mid+1);
            if(apple < neededApples) {
                l = mid + 1;
            } else {
                r = mid;
            }
        }
        // [r, l)
        return 8 * l;
    }
};

// l = mid + 1, r = mid - 1, 闭区间
// r = mid, l = mid, 开区间
// l <= r // 双闭区间(对应区间没有数)
```

