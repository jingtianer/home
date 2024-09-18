---
title: LeetCode-38
date: 2024-9-9 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## 2181. 合并零之间的节点

```c++
class Solution {
public:
    ListNode* mergeNodes(ListNode* head) {
        int sum = 0;
        ListNode dummy;
        ListNode *move_dummy = &dummy;
        ListNode *move = head;
        while(move->next) {
            sum = 0;
            while(move->next && move->next->val != 0) {
                sum += move->next->val;
                move = move->next;
            }
            move->val = sum;
            move_dummy->next = move;
            move_dummy = move_dummy->next;
            move = move->next;
            move_dummy->next = nullptr;
        }
        return dummy.next;
    }
};
```

## 977. 有序数组的平方

```c++
class Solution {
public:
    vector<int> sortedSquares(vector<int>& nums) {
        int len = nums.size();
        vector<int> merged_array(len);
        int i = 0, j = len - 1;
        for(int k = len - 1; k >= 0; k--) {
            if(abs(nums[i]) > abs(nums[j])) {
                merged_array[k] = nums[i] * nums[i];
                i++;
            } else {
                merged_array[k] = nums[j] * nums[j];
                j--;
            }
        }
        return merged_array;
    }
};
```

- 按照绝对值归并
- 双指针，从左右两端开始移动，

## 3174. 清除数字

```c++
class Solution {
public:
    string clearDigits(string s) {
        string res;
        for(char c : s) {
            if(!(c >= '0' && c <= '9')) {
                res.push_back(c);
            } else {
                res.pop_back();
            }
        }
        return res;
    }
};
```

- 模拟

## 2860. 让所有学生保持开心的分组方法数

```c++
class Solution {
public:
    int countWays(vector<int>& nums) {
        map<int, int> cnt;
        for(int n : nums) {
            cnt[n]++;
        }
        vector<int> arr;
        int len = 0;
        for(auto [num, total] : cnt) {
            arr.push_back(num);
            len++;
        }
        int i = 0;
        int ans = 0;
        int preSum = 0;
        while(i < len - 1) {
            preSum += cnt[arr[i]];
            if(preSum < arr[i+1] && preSum > arr[i]) {
                ans++;
            }
            i++;
        }
        return ans + 1 + (arr[0] == 0 ? 0 : 1);
    }
};
```

### 思路
- 假设选择了第i个学生，他的开心条件是`cnt > nums[i]`，那么
  - 所有满足`nums[j] <= nums[i]`的学生都必须被选择
  - 如果存在学生`j`，`nums[j] == nums[i] + 1`，`nums[k] == nums[j]`那么满足的学生k都必须被选择
  - 其他情况都不需要考虑，是一定无法满足条件的
- 只要统计每个num对应多少学生，按照num排序，
- 对于第i个num，如果选择他，他之前的学生必须选择
  - 如果num[i+1] == num[i] + 1，那么无法满足，是空集
  - 如果num[i+1] > num[i] + 1，那么只要累计学生足够条件，就能满足，满足的情景+1
- 利用前缀和，记录num以及小于num的学生数，学生数大于num


## 3176. 求出最长好子序列 I

### 二维dp

```c++
class Solution {
public:
    int maximumLength(vector<int>& nums, int k) {
        int len = nums.size();
        vector<vector<int>> dp(len, vector<int>(k + 1));
        int maxLen = 0;
        for(int i = 0; i < len; i++) {
            dp[i][0] = 1;
            for(int j = 0; j < i; j++) {
                if(nums[i] == nums[j]) {
                    dp[i][0] = max(dp[i][0], dp[j][0] + 1);
                }
            }
            maxLen = max(maxLen, dp[i][0]);
        }
        for(int i = 0; i < len; i++) {
            for(int j = 1; j <= k; j++) {
                for(int m = 0; m < i; m++) {
                    if(nums[i] == nums[m]) {
                        dp[i][j] = max(dp[i][j], dp[m][j] + 1);
                    } else {
                        dp[i][j] = max(dp[i][j], dp[m][j - 1] + 1);
                    }
                }
                maxLen = max(maxLen, dp[i][j]);
            }
        }
        return maxLen;
    }
};
```

- `dp[i][j]`代表到第`i`个数为止，恰好有`j`个不同的数的长度
- 转移方程
  - 如果`nums[i] == nums[m]`，不同的数相同，`j`相同, `dp[i][j] = max(dp[i][j], dp[m]p[j])`
  - 如果`nums[i] != nums[m]`，不同的数相同，`j`不同，相差1, `dp[i][j] = max(dp[i][j], dp[m][j-1])`

## 2552. 统计上升四元组

```c++
class Solution {
public:
    long long countQuadruplets(vector<int>& nums) {
        long long ans = 0;
        int n = nums.size();
        vector<vector<int>> numsCnt(n, vector<int>(n+1, 0));
        for(int i = n - 1; i >= 0; i--) {
            for(int j = n - 1; j > i; j--) {
                numsCnt[i][nums[j]]++;
            }
        }
        for(int i = 0; i < n; i++) {
            for(int j = 1; j <= n; j++) {
                numsCnt[i][j] += numsCnt[i][j-1];
            }
        }
        for(int i = 0; i < n; i++) {
            int smallerThanMe = 0;
            int cntOfBiggerAfterMe = 0;
            for(int j = i - 1; j >= 0; j--) {
                if(nums[j] > nums[i]) {
                    cntOfBiggerAfterMe += (n - i - 1) - numsCnt[i][nums[j]];
                } else if(nums[j] < nums[i]) {
                    ans += cntOfBiggerAfterMe;
                }
            }
        }
        return ans;
    }
};
```

- 想用单调递增栈，这样栈内两个相邻元素之间都是比两个数大的，在找到第三个元素后面有多少比第二个元素大的数，就可以了
- 这样只比栈顶两个元素会导致遗漏，直接找`nums[i]`前比`nums[i]`小的数`nums[j1]`，和他们之间比`nums[i]`大的数`nums[j]`，再找出每个数在i后有多少比`nums[j]`大的数，可以统计到到比`nums[j1]`还小的数的组合情况
- `numsCnt[i][j]`表示在开区间`(i, n)`中，有多少比`nums[j]`大的数

## 2555. 两个线段获得的最多奖品

```c++
class Solution {
public:
    int maximizeWin(vector<int>& prizePositions, int k) {
        int i = 0, j = 0;
        int n = prizePositions.size();
        vector<int> windowSum;
        vector<int> windowStart;
        int prizeCnt = 0;
        while(i < n) {
            int start = prizePositions[i];
            int end = prizePositions[i] + k;
            while(j < n && prizePositions[j] <= end) {
                j++;
                prizeCnt++;
            }
            windowSum.push_back(prizeCnt);
            windowStart.push_back(start);
            while(i < n && prizePositions[i] == start) {
                i++;
                prizeCnt--;
            }
        }
        int windowSize = windowSum.size();
        int curMaxTail = windowSum[windowSize - 1];
        int curMaxStart = windowStart[windowSize - 1];
        vector<int> maxTail(windowSize);
        for(int i = windowSize - 2; i >= 0; i--) {
            maxTail[i] = curMaxTail;
            if(windowSum[i] > curMaxTail) {
                curMaxTail = windowSum[i];
                curMaxStart = windowStart[i];
            }
        }
        int ans = 0;
        j = 0;
        for(int i = 0; i < windowSize; i++) {
            while(j < windowSize && windowStart[i] + k >= windowStart[j]) {
                j++;
            }
            j--;
            if(j < n) ans = max(ans, windowSum[i] + maxTail[j]);
        }
        return ans;
    }
};
```

- 虽然两个线段可以重叠，但是重叠部分的奖品不能重复拿，所以问题就变成了长度最长为k的情况下，不想交的两个线段内礼物总数和最大的情况
- 找出所有长度为k的线段的礼物数（`start`相同的不重复记录），记录在`windowSum`中，用`windowStart`记录区间的起点
- 用`maxTail[i]`记录起始点为`windowStart[i]`的线段后方，礼物多的线段的礼物个数
- 最后对于每一个线段，双指针找到不重叠的下一个线段及其后面的最大礼物数，加起来，求最大值

## 2332. 坐上公交的最晚时间

### 二分

```c++
class Solution {
public:
    int latestTimeCatchTheBus(vector<int>& buses, vector<int>& passengers, int capacity) {
        sort(buses.begin(), buses.end());
        sort(passengers.begin(), passengers.end());
        int busNum = buses.size();
        int passengersNum = passengers.size();
        vector<int> insertPoints(passengersNum);
        insertPoints[0] = 0;
        for(int i = 1; i < passengersNum; i++) {
            if(passengers[i] - passengers[i - 1] > 1) {
                insertPoints[i] = i; // 不和前一个连号，更新最晚上车位置
            } else {
                insertPoints[i] = insertPoints[i - 1]; // 上车时间不能和别人重复，如果连号，找到前面第一个不连号的位置
            }
        }
        int lastestTime = 0;
        int j = 0;
        int i = 0;
        for(; i < busNum && j < passengersNum; i++) { // 遍历公交车
            int firstCantGetOn = upper_bound(passengers.begin() + j, passengers.end(), buses[i]) - passengers.begin(); // 二分找到第一个，时间上无法上车的人
            int getOnCnt = min(firstCantGetOn - j, capacity);
            if(getOnCnt == 0 && capacity > 0) { // 如果没有人能上，且车容量大于0
                lastestTime = buses[i]; // 最晚就是公交车到站时间
            } else if(getOnCnt < capacity && buses[i] - passengers[j + getOnCnt - 1] > 0) {
                // 如果上车数量小于容量，最晚可以在发车前到达，且最后一个人不是在发车时到达
                lastestTime = buses[i];
            } else if(insertPoints[j + getOnCnt - 1] >= j) {
                // 如果前一个可插入点在j或其之后，也就是这批人中有插入点
                lastestTime = passengers[insertPoints[j + getOnCnt - 1]] - 1;
            } // else: 没有插入点，无法上车，什么都不做
            j += getOnCnt;
        }
        if(i < busNum) {
            return buses.back();
        }
        return lastestTime;
    }
};
```

## 1184. 公交站间的距离

### dijkstra
```c++
class Solution {
public:
    int distanceBetweenBusStops(vector<int>& distance, int start, int destination) {
        int n = distance.size();
        vector<int> dis(n, INT_MAX / 2);
        dis[start] = 0;

        vector<bool> visited(n, false);
        for(int i = 0; i < n; i++) {
            int firstClosestAndNotVisited = -1;
            for(int j = 0; j < n; j++) {
                if(!visited[j] && (firstClosestAndNotVisited == -1 || dis[j] < dis[firstClosestAndNotVisited])) {
                    firstClosestAndNotVisited = j;
                }
            }
            int next = firstClosestAndNotVisited;
            visited[next] = true;
            dis[(next + 1) % n] = min(dis[(next + 1) % n], distance[next] + dis[next]);
            dis[(next - 1 + n) % n] = min(dis[(next - 1 + n) % n], distance[(next - 1 + n) % n] + dis[next]);
        }
        return dis[destination];
    }
};
```


### 一次遍历

```c++
class Solution {
public:
    int distanceBetweenBusStops(vector<int>& distance, int start, int destination) {
        int n = distance.size();
        int counterClockWiseSum = 0;
        int clockWiseSum = 0;
        if(start > destination) {
            swap(start, destination);
        }
        for(int i = 0; i < start; i++) {
            counterClockWiseSum += distance[i];
        }
        for(int i = start; i < destination; i++) {
            clockWiseSum += distance[i];
        }
        for(int i = destination; i < n; i++) {
            counterClockWiseSum += distance[i];
        }
        return min(clockWiseSum, counterClockWiseSum);
    }
};
```

> 由于只有两个路径到达destination，只要计算顺时针和逆时针的总和，取最小值就好