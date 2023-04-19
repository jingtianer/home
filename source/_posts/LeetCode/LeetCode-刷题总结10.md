---
title: LeetCode-10
date: 2020-07-12 21:15:36
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## 2020-07-25
### [Z 字形变换](https://leetcode-cn.com/problems/zigzag-conversion/)

#### AC代码

```cpp
class Solution {
public:
    string convert(string s, int numRows) {
        if (numRows <= 1) {
            return s;
        }
        int n = s.size();
        string temp[numRows];
        int t_numRows = 0;
        int p = 0;
        while(p < n) {
            while(p < n && t_numRows < numRows) {
                temp[t_numRows] += s[p];
                p++;
                t_numRows++;
            }
            t_numRows = numRows -2;
            while (p < n && t_numRows > 0) {
                temp[t_numRows] += s[p];
                p++;
                t_numRows--;
            }
        }
        string res;
        for(int i = 0 ; i < numRows; i++) {
            res = res + temp[i];
        }
        return res;
    }
};
```

#### 优化思路

1. 两层while循环多次判断p<n,效率底下，实际上只需要当t_numRows==0或t_numRows==numRows-1时改变方向即可

2. 实际上需要的string数组长度是min(n, numRows)
   
   #### 优化代码
   
   ```cpp
   class Solution {
   public:
    string convert(string s, int numRows) {
        if (numRows <= 1) {
            return s;
        }
        int n = int(s.size());
        int len = min(numRows, n);
        vector<string> temp(len);
        int t_numRows = 0;
        bool goingDown = false;
        for(int i = 0; i < n; i++) {
            temp[t_numRows] += s[i];
            if (t_numRows == 0 || t_numRows == numRows-1) {
                goingDown = !goingDown;
            }
            t_numRows += goingDown ? 1 :-1;
        }
        string res;
        for (int i = 0; i < len; i++) res += temp[i];
        return res;
    }
   };
   ```
   
   #### 再次优化
   
   可以直接找新旧数列的数字关系，直接计算
   
   #### 优化代码
   
   ```cpp
   class Solution {
   public:
    string convert(string s, int numRows) {
        if (numRows <= 1) {
            return s;
        }
        int len_s = int(s.size());
        int unit =(2*numRows-2);
        int n = len_s/unit;
        int remain = len_s%unit;
        string res(len_s, 0);
        for (int i = 0; i < len_s; i++) {
            int p = 0;
            if (i%unit == 0) {
                p = i/unit+1;
            } else {
                int r = i%unit + 1,c = i/unit+1;
                if (r > numRows) {
                    r = unit-r+2;
                    p = 1;
                } else if (r == numRows) {
                    p = 1-c;
                }
                p += n + (n*2)*(r-2) + 2*(c-1) + min(r-1, remain)+1;
                if (remain > numRows) {
                    p += max(r-(unit-remain+2),0);
                }
            }
            res[p-1] = s[i];
        }
        return res;
    }
   };
   ```
   
   #### 最终成绩
   
   > 执行用时：8 ms, 在所有 C++ 提交中击败了98.89%的用户
   > 
   > 内存消耗：7.7 MB, 在所有 C++ 提交中击败了100.00%的用户

### ### [75. 颜色分类](https://leetcode-cn.com/problems/sort-colors/)

#### AC代码 计数

```cpp
class Solution {
public:
    void sortColors(vector<int>& nums) {
        int n[3] = {0};
        for(int i : nums) {
            n[i]++;
        }
        int x = 0;
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < n[i]; j++) {
                nums[j+x] = i;
            }
            x += n[i];
        }
    }
};
```

#### 优化 三指针法

```cpp
class Solution {
public:
    void sortColors(vector<int>& nums) {
        int f,t = int(nums.size())-1,m;
        f = m = 0;
        while (m <= t) {
            if (nums[m] == 0) {
                swap(nums[m++], nums[f++]);
            } else if (nums[m] == 2) {
                swap(nums[m], nums[t--]);
            } else {
                m++;
            }
        }
    }
    void xchg(int& a, int& b) {
        a = a+b;
        b = a-b;
        a = a-b;
    }
};
```

### [129. 求根到叶子节点数字之和](https://leetcode-cn.com/problems/sum-root-to-leaf-numbers/)

#### AC代码

```cpp
class Solution {
public:
    int sum = 0;
    void go(TreeNode* root, int num) {
        if (root->left == NULL && root->right == NULL) {
            sum += num*10+root->val;
            return;
        }
        if (root->left != NULL) {
            go(root->left, num*10+root->val);
        }
        if (root->right != NULL) {
            go(root->right, num*10+root->val);
        }
    }
    int sumNumbers(TreeNode* root) {
        if (root == NULL) {
            return 0;
        }
        go(root, 0);
        return sum;
    }
};
```

### [29. 两数相除](https://leetcode-cn.com/problems/divide-two-integers/)

#### AC代码

```cpp
class Solution {
public:
    unsigned int i2ui(int n) {
        return (n<0&&n != -2147483648)?-n:((n == -2147483648) ? 2147483648 : n);
    }
    int divide(int dividend, int divisor) {
        bool neg = (dividend<0)^(divisor<0);
        unsigned int a = i2ui(dividend), b = i2ui(divisor);
        unsigned int res = 0;
        unsigned int tb = b;
        unsigned int add = 1;
        while((tb & 0x80000000)==0) {
            tb <<= 1;
            add <<= 1;
        }
        while (a >= b) {
            if (a >= tb) {
                res += add;
                a -= tb;
            }
            add >>=1;
            tb >>= 1;
        }
        res =  (res > 2147483647 && !neg) ? INT_MAX : res;
        int ires = neg ? ((res>2147483648)?INT_MAX:-res) : res;
        return ires;
    }
};
```

#### 思路

利用最基本的列竖式法，先转成正数，再计算

#### 优化

1. 不满足题目的`假设我们的环境只能存储 32 位有符号整数`的条件

2. 类似上面的算法，把所有数转化为负数，再对divisor=0x80000000时特判

#### 优化代码

```cpp
class Solution {
public:
    int nabs(int n) {
        return (n > 0)? -n : n;
    }
    int divide(int dividend, int divisor) {
        int neg = ((dividend<0)^(divisor<0));
        dividend = nabs(dividend);
        divisor = nabs(divisor);
        int sub = 1;
        if (divisor==INT_MIN) {
            return (dividend == INT_MIN) ? 1 : 0;
        }
        int t_divisor = -divisor;
        while((t_divisor & 0x40000000)==0) {
            t_divisor <<= 1;
            sub <<= 1;
        }
        int res = 0;
//        cout << t_divisor << " " << sub << endl;
        while (dividend <= divisor && sub != 0) {

            if (dividend <= -t_divisor) {
                dividend += t_divisor;
                res -= sub;
            }

            sub >>= 1;
            t_divisor >>= 1;

        }
        if (dividend <= divisor) {
            res = (res == INT_MIN)? res : res-1;
//            cout << res << endl;
        }
        res = !neg ? ((res==-2147483648)?INT_MAX:-res) : res;
        return res;
    }
};
```

#### 最终成绩

> 执行用时：0 ms, 在所有 C++ 提交中击败了100.00%的用户

> 内存消耗：6 MB, 在所有 C++ 提交中击败了100.00%的用户

### [36. 有效的数独](https://leetcode-cn.com/problems/valid-sudoku/)

### AC代码

```cpp
class Solution {
public:
    bool isValidSudoku(vector<vector<char>>& board) {
        for (int i = 0; i < 9; i++) {
            int r[9] = {0};
            int c[9] = {0};
            int s[9] = {0};
            for (int j = 0; j < 9; j++) {
                if (board[i][j] != '.') {
                    r[board[i][j]-'1']++;
                }
                if (board[j][i] != '.') {
                    c[board[j][i]-'1']++;
                }
            }
            int a = i/3;
            int b = i%3;
            for (int ii = 3*a; ii < 3*(a+1); ii++) {
                for (int ij = 3*b; ij < 3*(b+1); ij++) {
                    if (board[ii][ij] != '.') {
                        s[board[ii][ij]-'1']++;
                    }
                }
            }
            for (int j = 0; j < 9; j++) {
                if (r[j] > 1 || c[j] > 1 || s[j] > 1) {
                    return false;
                }
            }

        }
        return true;
    }
};
```

### [5. 最长回文子串](https://leetcode-cn.com/problems/longest-palindromic-substring/)

#### AC代码

```cpp
class Solution {
public:
    map<int ,int, greater<int>> m;
    int rb=0,re=0;
    string longestPalindrome(string s) {
        int n = int(s.size());
        if (n <= 0) {
            return "";
        }

        go(s, 0, n);
        for (int off = 1; off < n; off++) {
            go(s, off, n);
            go(s, 0, n-off);
        }
        while (!m.empty()) {
            int sub = m.begin()->first;
            int sum = m.begin()->second;
            int beg = (sum-sub)/2;
            int end = (sum+sub)/2;
            if(go(s, beg,end) && ((re-rb) > (end-beg))) break;
        }
        return s.substr(rb, re-rb);
    }
    bool go(string& s,int beg, int end) {
        int pos = isPalindrome(s, beg, end);
        if (pos != beg) {
            end -= pos-beg;
            beg = pos;
            m[end-beg]=end+beg;
            return false;
        }else {
            m.erase(end-beg);
            if ((end-beg) > (re-rb)) {
                rb = beg;
                re = end;
            }
            return true;
        }

    }
    int isPalindrome(string& s, int beg, int end) {
        int res = -1;
        for(int i = 0; i < (end-beg)/2; i++) {
            if(s[beg+i] != s[end-1 - i] && i > res) res = i;
        }
        return beg+res+1;
    }
};
```

#### 优化

参考优秀的题解，大致思想是把每个字符作为中心，向左右展开

```cpp
class Solution {
public:
    int l=0,h=0;
    string longestPalindrome(string s) {
        int n = int(s.size());
        if (n <= 1) {
            return s;
        }
        for (int i = 0; i < n; i++) {
            i = findLongest(s, i, n);
        }
        return s.substr(l, h-l+1);
    }
    int findLongest(const string& s,int i, int n) {
        int high = i;
        while (high < n-1 && s[high+1] == s[i]) {
            high++;
        }// 中部字符全部相同
        int ans = high;
        while (i > 0 && high < n-1 && s[i-1]==s[high+1]) {
            i--;
            high++;//向两边展开
        }
        if ((high - i) > h-l) {
            h = high;
            l = i;    //更新最长串的位置
        }
        return ans;
    }
};
```

### [62. 不同路径](https://leetcode-cn.com/problems/unique-paths/)

#### 思路

大佬们都是用dp，而我是推公式，就是这么简单

#### AC代码

```cpp
class Solution {
public:
    int uniquePaths(int m, int n) {
        if (m > n) {
            m = m+n;
            n = m-n;
            m = m-n;
        }
        int res = n;
        if (m < 2) {
            return 1;
        }
        if (m == 2) {
            return n;
        }
        vector<int> v(m-2, 0);
        for (int i = 1; i <= n-1; i++) {
            v[0] += i;
            for (int j = 1; j < m - 2; j++) {
                v[j] += v[j-1];
            }
        }
        for (int i = 0; i < m -2; i++) {
            res += v[i];
        }
        return res;
    }
};
```

#### 最终成绩

> 执行用时：0 ms, 在所有 C++ 提交中击败了100.00%的用户

> 内存消耗：5.9MB, 在所有 C++ 提交中击败了100.00%的用户
### [63\. 不同路径 II](https://leetcode-cn.com/problems/unique-paths-ii/)
#### AC代码
```cpp
class Solution {
public:
    int uniquePathsWithObstacles(vector<vector<int>>& obstacleGrid) {
        int n = int(obstacleGrid.size());
        int m = int(obstacleGrid[0].size());
        bool swap = false;
        if (m > n) {
            m = m+n;
            n = m-n;
            m = m-n;
            swap = true;
        }
        
        vector<long long> v(m+1, 0);
        long long t_v0 = 1;
        for (int i = 0; i < n; i++) {
            if ((!swap && obstacleGrid[n-i-1][m-1]) || (swap && obstacleGrid[m-1][n-1-i])) {
                v[0] = 0;
            } else {
                v[0] = t_v0;
            }
            t_v0 = v[0];
            for(int j  = 1; j < m; j++) {
                if ((!swap && obstacleGrid[n-i-1][m-1-j]) || (swap && obstacleGrid[m-1-j][n-1-i])) {
                    v[j] = 0;
                } else {
                    v[j] += v[j-1];
                }
            }
        }
        return (int)v[m-1];
    }
};
```
#### 优化1
不需要转置，这个问题来自于试错过程中的错误判断
看了题解以后发现自己的代码和它惊人的相似，原来我无师自通学会动规了？？哈哈哈哈
#### 优化1代码
```cpp
class Solution {
public:
    int uniquePathsWithObstacles(vector<vector<int>>& obstacleGrid) {
        int n = int(obstacleGrid.size());
        int m = int(obstacleGrid[0].size());
        vector<long long> v(m+1, 0);
        long long t_v0 = 1;
        for (int i = 0; i < n; i++) {
            if (obstacleGrid[n-i-1][m-1]) {
                v[0] = 0;
            } else {
                v[0] = t_v0;
            }
            t_v0 = v[0];
            for(int j  = 1; j < m; j++) {
                if (obstacleGrid[n-i-1][m-1-j]) {
                    v[j] = 0;
                } else {
                    v[j] += v[j-1];
                }
            }
        }
        return (int)v[m-1];
    }
};
```
