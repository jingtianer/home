---
title: LeetCode-11
date: 2020-07-12 21:15:36
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## 2020-07-27
### [55\. 跳跃游戏](https://leetcode-cn.com/problems/jump-game/)
#### 思路
1. 对nums数组，令nums[i] += i,这样表示i位置最远可以走到的距离
2. 算法
> 从i = 0开始
> 对于当前i，可以从0走到nums[i]，选取0-nums[i]的最大值，如果最大值大于等于n-1，则可以到达最后，若小于，重复这个步骤，除非i=最大值，则不能到达最后

1. 为了降低时间复杂度，创建一个数组v，v[i] = max(nums[k]), k = 0,1,...,i

#### AC代码
```cpp
class Solution {
public:
    bool canJump(vector<int>& nums) {
        int n = int(nums.size());
        for(int i = 0; i < n; i++) {
            nums[i] += i;
        }
        vector<int> v;
        int max = nums[0];
        for(int i = 0; i < n; i++) {
            if (nums[i] > max) {
                max = nums[i];
            }
            v.push_back(max);
        }
        int i = 0;
        while (i != v[i]) {
            i = v[i];
            if (i >= n-1) {
                return true;
            }
        }
        return false || n == 1;
    }
};
```

####   优化
参考已经提交的代码，可以不创建数组v，也用O(n)的时间完成

#### 优化代码
```cpp
class Solution {
public:
    bool canJump(vector<int>& nums) {
        int n = int(nums.size());
        int i = 0;
        int max = nums[0];
        while (i <= max) {
            if (max < i + nums[i]) {
                max = i + nums[i];
            }
            if (max >= n-1) {
                return true;
            }
            i++;
        }
        return false || n == 1;
    }
};
```
这道题leetcode上的测速不准，没有参考价值，相同参考代码能跑出不同的速度。

### [16\. 最接近的三数之和](https://leetcode-cn.com/problems/3sum-closest/)
#### AC代码
```cpp
class Solution {
public:
    int threeSumClosest(vector<int>& nums, int target) {
        sort(nums.begin(), nums.end());
        int mincut = nums[0] + nums[1] + nums[2];
        for(int i = 0; i < (int)nums.size() - 2; i ++) {
            int j = i + 1, k = nums.size() - 1;
            while(j < k) {
                int threesum = nums[i] + nums[j] + nums[k];
                if(abs(threesum - target) < abs(mincut - target)) mincut = threesum;
                if(threesum == target) return target;
                else if(threesum < target) j ++;
                else k --;
            }
        }
        return mincut;
    }
};
```
#### 优化
跳过一些不用考虑的值，1.和上次枚举的数相同的值，2.已经等于target的情况

```cpp
class Solution {
public:
    int threeSumClosest(vector<int>& nums, int target) {
        sort(nums.begin(), nums.end());
        int n = nums.size();
        int best = 1e7;

        // 根据差值的绝对值来更新答案
        

        // 枚举 a
        for (int i = 0; i < n; ++i) {
            // 保证和上一次枚举的元素不相等
            if (i > 0 && nums[i] == nums[i - 1]) {
                continue;
            }
            // 使用双指针枚举 b 和 c
            int j = i + 1, k = n - 1;
            while (j < k) {
                int sum = nums[i] + nums[j] + nums[k];
                // 如果和为 target 直接返回答案
                if (sum == target) {
                    return target;
                }
                if (abs(sum - target) < abs(best - target)) {
                    best = sum;
                }
        
                if (sum > target) {
                    // 如果和大于 target，移动 c 对应的指针
                    int k0 = k - 1;
                    // 移动到下一个不相等的元素
                    while (j < k0 && nums[k0] == nums[k]) {
                        --k0;
                    }
                    k = k0;
                } else {
                    // 如果和小于 target，移动 b 对应的指针
                    int j0 = j + 1;
                    // 移动到下一个不相等的元素
                    while (j0 < k && nums[j0] == nums[j]) {
                        ++j0;
                    }
                    j = j0;
                }
            }
        }
        return best;
    }
};
```

### [61\. 旋转链表](https://leetcode-cn.com/problems/rotate-list/)

### AC代码
```cpp
class Solution {
public:
    ListNode* rotateRight(ListNode* head, int k) {
        if(head == NULL) {
            return head;
        }
        int n = 0;
        ListNode *p = head;
        while (p->next != NULL) {
            n++;
            p = p->next;
        }
        n++;
        k %= n;
        p->next = head;
        p = head;
        for (int i = 0; i < n - k - 1; i++) {
            p = p->next;
        }
        ListNode* new_head = p->next;
        p->next = NULL;
        return new_head;
    }
};
```
#### 经验
看似简单的题，发现了自己的知识漏洞，图遍历的时候要有visit数组记录它是否访问过，此处用map代替。


### [133\. 克隆图](https://leetcode-cn.com/problems/clone-graph/)
### AC代码
```cpp
class Solution {
public:
    Node* cloneGraph(Node* node) {
        if(node == NULL) return NULL;
        unordered_map<Node*, Node*> m;
        queue<Node*> q;
        q.push(node);
        Node* head = new Node(node->val, vector<Node*>{});
        m[node]=head;
        while (!q.empty()) {
            Node* temp = q.front();
            q.pop();
            for (Node* child: temp->neighbors) {
                if(!m.count(child)) {
                    m[child] = new Node(child->val, vector<Node*>{});
                    q.push(child);
                }
                m[temp]->neighbors.push_back(m[child]);
                
            }
        }
        return head;
    }
};
```
### [120\. 三角形最小路径和](https://leetcode-cn.com/problems/triangle/)

#### 超时算法 普通的搜索
```cpp
class Solution {
public:
    int minimumTotal(vector<vector<int>>& triangle) {
        int ni = int(triangle.size());
        vector<int> v(ni, 0);
        vector<int> index(ni, 0);
        int sum = INT_MAX;
        while(v[0] == 0) {
            int t_sum = 0;
            for (int j = 0; j < ni; j++) {
                t_sum += triangle[j][index[j]];
            }
            if (t_sum < sum) {
                sum = t_sum;
            }
            int i = ni-1;
            while (i > 0 && v[i] == 1) {
                v[i] = 0;
                i--;
            }
            index[i]++;
            for (int j = i+1; j < ni  ; j++) {
                index[j] = index[j-1];
            }
            v[i] = 1;
            
        }
        return sum;
    }
};
``` 
#### 优化思路
一个个枚举会超时，要用动态规划
#### AC代码
```cpp
class Solution {
public:
    int minimumTotal(vector<vector<int>>& triangle) {
        int ni = int(triangle.size());
        vector<int> v(ni, 0);
        v[0] = triangle[0][0];
        for (int i = 1; i < ni; i++) {
            v[i] = v[i-1] + triangle[i][i];
            for (int j = i - 1; j > 0; j--) {
                v[j] = min(v[j-1],v[j]) + triangle[i][j];
            }
            v[0] += triangle[i][0];
        }
        return *min_element(v.begin(), v.end());
    }
};
```
## 2020-07-28
### [33\. 搜索旋转排序数组](https://leetcode-cn.com/problems/search-in-rotated-sorted-array/)

#### AC代码
```cpp
class Solution {
public:
    int search(vector<int>& nums, int target) {
        int l = 0, h = int(nums.size())-1;
        while (l <= h) {
            int mid = (h-l)/2+l;
            if (nums[mid] == target) {
                return mid;
            }
            if (nums[mid] > nums[l]) {
                if (target >= nums[l] && target < nums[mid]) {
                    h = mid - 1;
                } else {
                    l = mid + 1;
                }
            } else if (nums[mid] == nums[l]) {
                if (h == l) {
                    return -1;
                }
                l++;
            } else {
                if (target <= nums[h] && target > nums[mid]) {
                    l = mid + 1;
                } else {
                    h = mid - 1;
                }
            }
        }
        return -1;
    }
};
```
#### 思路
1. 二分查找法，由于是两段有序，分别有几种情况，且没有相等元素
    1. nums[mid] > nums[l]，说明l-mid为严格的升序，如果target在nums[l]-nums[mid]之间，h=mid-1，否则l=mid+1。切换到l-h之间搜索
    2. nums[mid] == nums[l]，说明 (l+h)/2 = l, h=l-1 或 h=l
        1. h=l-1，令l=h
        2. h=l，mid=h=l，说明无解，return -1
    3. nums[mid] < nums[h]，说明mid-h为严格升序，如果target在nums[mid]-nums[h]之间，l=mid+1，否则h=mid-1。切换到l-h之间搜索


### [74\. 搜索二维矩阵](https://leetcode-cn.com/problems/search-a-2d-matrix/)

#### AC代码
```cpp
class Solution {
public:
    bool searchMatrix(vector<vector<int>>& matrix, int target) {
        int m = int(matrix.size());
        if (m <= 0) {
            return false;
        }
        int n = int(matrix[0].size());
        int num = m*n;
        int l = 0,h = num-1;
        while (l <= h) {// 二分查找法
            int mid = (h-l)/2+l;
            if (matrix[(mid)/n][(mid)%n] == target) {//算出mid对应的下标就行
                return true;
            } else if (matrix[(mid)/n][(mid)%n] > target) {
                h = mid-1;
            } else {
                l = mid+1;
            }
        }
        return false;
        
    }
};
```
