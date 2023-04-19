---
title: LeetCode-18
date: 2022-11-07 11:14:34
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## [1668. 最大重复子字符串](https://leetcode.cn/problems/maximum-repeating-substring/)

```c++
class Solution {
public:
    int maxRepeating(string sequence, string word) {
        int len1 = sequence.size();
        int len2 = word.size();
        int maxk = 0, k = 0;
        for(int i = 0; i < len1;) {
            bool flag = true;
            int next = i+1;
            bool flag1 = false;
            for(int j = 0; j < len2; j++) {
                if(sequence[i+j] != word[j]) {
                    flag = false;
                    break;
                }
                if(!flag1 && j != 0 && sequence[i+j] == word[0]) {
                    next = i+j;
                    flag1=true;
                }
            }
            // cout << i << " " << k << " " << maxk << endl;
            if(flag) {
                k++;
                i += len2;
            } else {
                maxk = max(k, maxk);
                if(k == 0) {
                    i+=1;
                } else {
                    i = i-len2+1;
                }
                k = 0;
            }
            // cout << i << endl;
        }
        return max(maxk, k);
    }
};
```

> 笨方法，从右向左找，适当回溯

## [754. 到达终点数字](https://leetcode.cn/problems/reach-a-number/)

### 解法1

```c++
class Solution {
public:
    int reachNumber(int target) {
        target = abs(target);
        int n = (sqrt(8.0*target+1)-1)/2; //8.0,防止int溢出
        int sum = (n+1)*n/2;
        if(sum == target) {
            return n;
        }
        int diff = target-sum;
        if((n % 2 == 1 && diff % 2 == 0) || (n % 2 == 0 && diff % 2 == 1)) {
            n += 1;
        } else if(diff %2 == 1) {
            n += 2;
        } else {
            n += 3;
        }
        return n;
    }
};
```

> 这道题直接暴力搜索是不可行的，算法成为$ O( 2^{ target } ) $ 级别

> 考虑到只求步数，负数target可以转化成正数处理
> 首先计算 $ sum = 1 + 2 + 3 + ... + i + ... + n <= target $, 如果  $  sum==target $，则n就是步数
> 否则对sum进行调整，记 $ diff = target-sum  <= n $ (一定小于n+1)，所以需要先减小sum，再加上几个数，使得新的sum等于target
> 情况一，第i步改为向左，再加上n+1, 也就是 $ sum - 2i + n+1 $，调整前后的差为 $ delta = n + 1 -2i $, $ i = 1,2,3,...,n; delta = n-1, n-3, n-5 ... $。这种情况对于`diff奇数n偶数`，或`diff偶数n奇数`的情况适用，总计步数`n+1`
> 情况二，第i步改为向左，再加上n+1和n+2，也就是 $ sum - 2i + n+1 + n+2 $，调整前后的差为 $ delta = 2(n-i) + 3 $, $ i = 1,2,3,...,n; delta = 3, 5, 7, 9, ... $。这种情况对于`diff奇数且diff >= 3`的情况适用，总计步数`n+2`
> 情况三，减去`n+1`,加上`n+2`，显然使用于`diff=1`的情况，总计步数`n+2`，可以和情况二合并
> 情况四，以上没有覆盖到的情况，举个例子可知，总计步数`n+3`


### 解法2

```c++
class Solution {
public:
    int reachNumber(int target) {
        target = abs(target);
        int sum = 0;
        int n = 0;
        while(sum < target) {
            n++;
            sum += n;
        }
        if((sum-target) % 2 == 0) return n;
        while((sum-target)%2) {
            n++;
            sum += n;
        }
        return n;
    }
};
```

> 计算 $ sum=1+2+3+...+n >= target $
> 情况一：如果 $ diff = sum-target <= n $ 是偶数，则步数就是n。 由于diff <= n,所以可以让第i步变成向左，即 $ sum - 2i, i=0,1,2,3,...,n+1 $，则刚好可以变成target
> 其他情况：如果diff是奇数，则继续在sum的基础上加n,直到diff为偶数

### 方法3

```c++
class Solution {
public:
    int reachNumber(int target) {
        target = abs(target);
        int sum = 0;
        int n = 0;
        while(sum < target) {
            n++;
            sum += n;
        }
        if((sum-target) % 2 == 0) return n;
        return n + n%2 +1;
    }
};
```

> 根据方法1，调整的步数最多3步，进一步分析，当diff为奇数时，sum加几个数可以变成偶数，根据公式 $$ sum = n(n+1)/2 $$
> 可知：
> n偶数，sum偶数，n+1奇数，`sum=sum+n+1`后sum变奇数
> $$ n = 4i, sum=2i(2i+1) $$
>  n奇数，sum奇数，n+1偶数，n+2奇数，`sum=sum+n+1+n+2`后sum变偶数
> $$ n = 4i+1, sum=(4i+1)(2i+1) $$
> n偶数，sum奇数，n+1奇数，`sum=sum+n+1`后sum变偶数
> $$ n = 4i+2, sum=(2i+1)(4i+3) $$ 
> n奇数，sum偶数，n+1偶数，n+2奇数`sum=sum+n+1+n+2`后sum变奇数
> $$ n = 4i+3, sum=(4i+3)(2i+2) $$ 
> 
> 由于diff为奇数，则sum为奇数时要变成偶数，否则变成奇数
> 整理上面的讨论，可知调整的步数为`n%2+1`，总步数为`n+n%2+1`


## [1106. 解析布尔表达式](https://leetcode.cn/problems/parsing-a-boolean-expression/)

```c++
class Solution {
private:
    const static int NOT = '!';
    const static int AND = '&';
    const static int OR = '|';
public:
    bool parseBoolExpr(string expression) {
        stack<char> ops;
        stack<char> value;
        int len = expression.size();
        for(int i = 0; i < len; i++) {
            if(expression[i] == 't' || expression[i] == 'f') {
                value.push(expression[i]);
            } else if(expression[i] == NOT || expression[i] == AND || expression[i] == OR) {
                ops.push(expression[i]);
            } else if(expression[i] == '(') {
                value.push('(');
            } else if(expression[i] == ')') {
                char op = ops.top();
                ops.pop();
                bool res = value.top() == 't'? true : false;
                value.pop();
                if(op == NOT) {
                    res = !res;
                    if(!value.empty()) {
                        value.pop();
                    }
                } else {
                    while(!value.empty() && value.top() != '(') {
                        bool temp = value.top() == 't'? true : false;
                        if (op == AND) {
                            res &= temp;
                        } else if(op == OR) {
                            res |= temp;
                        }
                        value.pop();
                    }
                    if(!value.empty()) {
                        value.pop();
                    }
                }
                value.push(res ? 't' : 'f');
            }
        }
        return value.top() == 't'? true : false;
    }
};
```

> 就是写一个计算器，难点在于n元运算，需要在数值栈中保存括号，以判断每个操作作用于那些值

## [1678. 设计 Goal 解析器](https://leetcode.cn/problems/goal-parser-interpretation/)

```c++
class Solution {
public:
    string interpret(string command) {
        string s;
        int len = command.size();
        for(int i = 0; i < len; i++) {
            if(command[i] == 'G') {
                s.push_back('G');
            } else if(command[i] == '(') {
                if(command[i+1] == ')') {
                    s.push_back('o');
                } else {
                    s.push_back('a');
                    s.push_back('l');
                }
            }
        }
        return s;
    }
};
```

## [816. 模糊坐标](https://leetcode.cn/problems/ambiguous-coordinates/)

```c++
class Solution {
public:
    int len;
    vector<string> ambiguousCoordinates(string s) {
        len = s.size();
        vector<string> coord;
        for(int i = 2; i < len-1; i++) {
            vector<string> n1;
            vector<string> n2;
            gen(move(s), 1, i, n1);
            int len1 = n1.size();
            if(len1 <=0) continue;
            gen(move(s), i, len-1, n2);
            int len2 = n2.size();
            if(len2 <= 0) continue;
            for(int k1 = 0; k1 < len1; k1++) {
                for(int k2=0; k2< len2; k2++) {
                    coord.push_back("(" + n1[k1] + ", " + n2[k2] + ")");
                }
            }
        }
        return coord;
    }
    void gen(string&& s, int i, int j, vector<string>& ret) {
        if(s[j-1] == '0' && s[i] =='0' && j-i>1) {
            return;
        }
        if(s[j-1] == '0') {
            ret.push_back(s.substr(i, j-i));
            return;
        }
        if(s[i] == '0') {
            ret.push_back("0." + s.substr(i+1, j-i-1));
            return;
        }
        for(int k = i; k < j-1; k++) {
            ret.push_back(s.substr(i, k-i+1) + "." + s.substr(k+1, j-k-1));
        }
        ret.push_back(s.substr(i, j-i));
        return;
    }
};
```


## [1684. 统计一致字符串的数目](https://leetcode.cn/problems/count-the-number-of-consistent-strings/)

```c++
class Solution {
public:
    int countConsistentStrings(string allowed, vector<string>& words) {
        bool all[129] = {false};
        for(char c : allowed) {
            all[c] = true;
        }
        int count = 0;
        for(string &w : words ) {
            bool flag = true;
            for(char c : w) {
                if(!all[c]) {
                    flag = false;
                    break;
                }
            }
            if(flag) {
                count++;
            }
        }
        return count;
    }
};
```

### 位运算
```c++
class Solution {
public:
    int countConsistentStrings(string allowed, vector<string>& words) {
        int all = 0;
        for(char c : allowed) {
            all |= 1 << (c-'a');
        }
        int count = 0;
        for(string &w : words ) {
            bool flag = true;
            for(char c : w) {
                if(!((all >> (c-'a'))&1)) {
                    flag = false;
                    break;
                }
            }
            if(flag) {
                count++;
            }
        }
        return count;
    }
};
```

> 题中说明了 allowed只包含26个字母，所以用一个int就可以表示字符是否存在

## [764. 最大加号标志](https://leetcode.cn/problems/largest-plus-sign/)

### 前缀和
```c++
class Solution {
public:
    int orderOfLargestPlusSign(int n, vector<vector<int>>& mines) {
        vector<vector<int>> mat(n, vector<int>(n, 1)), x(n, vector<int>(n+1, n)),y(n+1, vector<int>(n, n));
        for(auto mine : mines) {
            mat[mine[0]][mine[1]] = 0;
        }
        for(int i = n-1; i >= 0; i--) {
            for(int j = n-1; j >= 0; j--) {
                if(mat[i][j] == 1) {
                    x[i][j] = x[i][j+1];
                } else {
                    x[i][j] = j;
                }
                if(mat[j][i] == 1) {
                    y[j][i] = y[j+1][i];
                } else {
                    y[j][i] = j;
                }
            }
        }
        vector<int> miny(n, -1);
        int maxx = 0;
        for(int i = 0; i < n; i++) {
            int minx = -1;
            for(int j = 0; j < n; j++) {
                if(mat[i][j] == 0) {
                    minx = j;
                    miny[j] = i;
                } else {
                    maxx = max(maxx, min(min(x[i][j] - j , j - minx),  min(y[i][j] - i , i - miny[j])));
                }
            }
        }
        return maxx;
    }
};
```

> 刚开始想用dp，但是想法不对，试了7.8次，最后想到正确的方法
> x, y记录点(i, j) 右测/下方第一个0的坐标，minx记录左方第一个0的坐标，miny记录上方第一个0的位置
> mat用来保存这个矩阵
> 加号的阶数为(i, j)坐标到上下左右四个方向上最近的0的距离的最小值
> 要注意特殊值的处理，右侧/下方没有0，则记其坐标为`n`,上方/左侧没有0记为`-1`

> 一直以为只有把某一侧的数全都加起来才算前缀和
> 只要是把每个位置之前的一维线段或二维矩形预先存储，就叫做前缀和/积分图

### 大佬的解法
```c++
class Solution {
public:
    int orderOfLargestPlusSign(int n, vector<vector<int>>& mines) {
        vector<vector<int>> dp(n, vector<int>(n, n));
        for (auto& e : mines) dp[e[0]][e[1]] = 0;
        for (int i = 0; i < n; ++i) {
            int left = 0, right = 0, up = 0, down = 0;
            for (int j = 0, k = n - 1; j < n; ++j, --k) {
                left = dp[i][j] ? left + 1 : 0;
                right = dp[i][k] ? right + 1 : 0;
                up = dp[j][i] ? up + 1 : 0;
                down = dp[k][i] ? down + 1 : 0;
                dp[i][j] = min(dp[i][j], left);
                dp[i][k] = min(dp[i][k], right);
                dp[j][i] = min(dp[j][i], up);
                dp[k][i] = min(dp[k][i], down);
            }
        }
        int ans = 0;
        for (auto& e : dp) ans = max(ans, *max_element(e.begin(), e.end()));
        return ans;
    }
};
```

> 其实仔细一看，和我是一样的，一个一维for两个二维for，但是很短
> dp存的是到最近的一个0的长度

### 优化空间
```c++
class Solution {
public:
    int orderOfLargestPlusSign(int n, vector<vector<int>>& mines) {
        vector<vector<int>> mat(n, vector<int>(n, n));
        for(auto mine : mines) mat[mine[0]][mine[1]] = 0;
        for(int i = 0; i < n; i++) {
            int l = -1,r = n,u = -1,d = n;
            for(int j = 0, k = n-1; j < n; j++, k--) {
                l = mat[i][j] ? l : j;
                u = mat[j][i] ? u : j;
                r = mat[i][k] ? r : k;
                d = mat[k][i] ? d : k;
                mat[i][j] = min(mat[i][j], j - l);
                mat[j][i] = min(mat[j][i], j - u);
                mat[i][k] = min(mat[i][k], r - k);
                mat[k][i] = min(mat[k][i], d - k);
                
            }
        }
        int maxx = INT_MIN;
        for(vector<int>& vec : mat) maxx = max(maxx, *max_element(vec.begin(), vec.end()));
        return maxx;
    }
};
```

> 参考大佬的方法，把我的思路优化成只用一个二维数组
> 这里要注意mat初始化为n，如果初始化为1的话后面没办法找最小值。

## [462. 最小操作次数使数组元素相等 II](https://leetcode.cn/problems/minimum-moves-to-equal-array-elements-ii/)

### 前缀和

```c++
class Solution {
public:
    int minMoves2(vector<int>& nums) {
        int len = nums.size();
        long long int minn = INT_MAX;
        vector<int> preSum(len, 0);
        preSum[0] = nums[0];
        sort(nums.begin(), nums.end());
        for(int i = 1; i < len; i++) {
            preSum[i] = preSum[i-1] + nums[i];
        }
        for(long long int i = 0; i < len; i++) {
            minn = min(minn, (i+1)*nums[i] - preSum[i] + preSum[len-1] - preSum[i] - (len-i -1)*nums[i]);
        }
        return minn;
    }
};
```

> 先排序，假设第i个数是能使总体调整数最小的数，那么总的调整次数为
> $$ i \times nums_i - \sum_{ j=0 }^{ j=i-1 }(nums_i) + \sum_{ j=i+1 }^{ j=n-1 }(nums_j) - (n - i -1) \times nums_i $$
> $$ i = 0,1,...,n-1 $$
> 并使用前缀和优化
> 找他的最小值即可

### 数学方法

```c++
class Solution {
public:
    int minMoves2(vector<int>& nums) {
        int len = nums.size();
        long long int sum = 0;
        sort(nums.begin(), nums.end());
        for(long long int i = 0; i < len; i++) {
            sum += abs(nums[i] - nums[len/2]);
        }
        return sum;
    }
};
```

> 排序后，中位数之一刚好就是所求元素
> 假设 $ a_i a_j; i+j=len-1 $ 为两个待调整元素
> $ h $ 为最终调整后的数，那么 $$ h = a_j - d_j  = d_i - a_i $$
> 也就是 $$ a_j - a_i = d_j + d_i $$
> 对于关于中心对称的数，不管要调整成他们中间的哪一个数，调整的步数之和总是 $ a_j - a_i $

- 所以根本不需要知道最终调整成哪个数，只要计算对称位置的两个数的差值之和即可

```c++
class Solution {
public:
    int minMoves2(vector<int>& nums) {
        int len = nums.size();
        long long int sum = 0;
        sort(nums.begin(), nums.end());
        for(long long int i = 0; i < len/2; i++) {
            sum += nums[len-1-i] - nums[i];
        }
        return sum;
    }
};
```

### 不排序找到第len/2小的数
```c++
class Solution {
public:
    int minMoves2(vector<int>& nums) {
        int len = nums.size();
        nth_element(nums.begin(), nums.begin() + len/2, nums.end());
        int sum = 0;
        for(int i = 0; i < len; i++) {
            sum += abs(nums[i] - nums[len/2]);
        }
        return sum;
    }
};
```

- 自己实现partition

```c++
class Solution {
public:
    int minMoves2(vector<int>& nums) {
        
        int len = nums.size();
        int i = 0, j = len;
        int k = 0;
        for(;;) {
            k = partition(nums, i ,j);
            if(k == len/2) {
                break;
            } else if(k > len/2) {
                j = k;
            } else {
                i = k+1;
            }
        }
        int sum = 0;
        for(int i = 0; i < len; i++) {
            sum += abs(nums[i] - nums[k]);
        }
        return sum;
    }
    int partition(vector<int>& nums, int i, int j) {
        int target = i;
        j--;
        while(i < j) {
            while(j > i && nums[j] >= nums[target]) {
                j--;
            }
            if(nums[j] < nums[target])swap(nums[target], nums[j]);
            target = j;
            while(j > i && nums[i] <= nums[target]) {
                i++;
            }
            if(nums[i] > nums[target])swap(nums[target], nums[i]);
            target = i;
        }
        return i;
    }
};
```

太慢了。。。

- 去掉swap

```c++
class Solution {
public:
    int minMoves2(vector<int>& nums) {
        
        int len = nums.size();
        int i = 0, j = len-1;
        int k = 0;
        for(;;) {
            k = partition(nums, i, j);
            if(k == len/2) {
                break;
            } else if(k > len/2) {
                j = k-1;
            } else {
                i = k+1;
            }
        }
        int sum = 0;
        for(int i = 0; i < len; i++) {
            sum += abs(nums[i] - nums[k]);
        }
        return sum;
    }
    int partition(vector<int>& nums, int i, int j) {
        int pivot = nums[i];
        while(i < j) {
            while(j > i && nums[j] >= pivot) {
                j--;
            }
            nums[i] = nums[j];
            while(j > i && nums[i] <= pivot) {
                i++;
            }
            nums[j] = nums[i];
        }
        nums[i] = pivot;
        return i;
    }
};
```

## [470. 用 Rand7() 实现 Rand10()](https://leetcode.cn/problems/implement-rand10-using-rand7/)

```c++
class Solution {
public:
    int rand10() {
        return rand()%10+1;
    }
};
```

> 满身反骨

## [202. 快乐数](https://leetcode.cn/problems/happy-number/)
```c++
class Solution {
public:
    bool isHappy(int n) {
        while(n != 1) {
            n = next(n);
            if(n == 4) {
                return false;
            }
        }
        return true;
    }
    int next(int n) {
        int sum = 0;
        while(n) {
            sum += (n%10)*(n%10);
            n /= 10;
        }
        return sum;
    }
};
```

> 大家都有相同的循环节

### 快慢指针

```c++
class Solution {
public:
    bool isHappy(int n) {
        int nn = n;
        do {
            n = next(n);
            nn = next(nn);
            if(nn == 1) return true;
            nn = next(nn);
            if(nn == 1) return true;
        } while(n != nn);
        return false;
    }
    int next(int n) {
        int sum = 0;
        while(n) {
            sum += (n%10)*(n%10);
            n /= 10;
        }
        return sum;
    }
};
```

```c++
class Solution {
public:
    bool isHappy(int n) {
        int nn = n;
        do {
            n = next(n);
            if(n == 1) return true;
            nn = next(nn);
            nn = next(nn);
        } while(n != nn);
        return false;
    }
    int next(int n) {
        int sum = 0;
        while(n) {
            sum += (n%10)*(n%10);
            n /= 10;
        }
        return sum;
    }
};
```

## 790. 多米诺和托米诺平铺
```c++
class Solution {
public:
    vector<double> frac;
    int sum = 0;
    int numTilings(int n) {
        frac = vector<double>(n+1, 1);
        for(int i = 2; i <= n; i++) {
            frac[i] = (i * frac[i-1]);
        }
        calcualte(n, n, 0, 1);
        return sum;
    }


    void calcualte(int k, int n, int count, double div) {
        if(k >= 3) {
            for(int i = n/k; i >= 0; i--) {
                double div1 = (div*frac[i]);
                for(int j = (n-i*k)/k; j >= 0; j--) {
                    calcualte(k-1, n - i*k - j*k, count + i + j, (div1*frac[j]) );
                }
            }
        } else if(k == 2) {
            for(int i = n/k; i>=0; i--) {
                calcualte(k-1, n-i*k, count + i, (div*frac[i]));
            }
        } else {
            sum = int(sum + frac[count + n]/div/frac[n])%1000000007;
        }
    }
};
```

> 没通过，思路不对，算阶乘溢出，找出所有组合的代价也太大

> 在这个地方我犯了一个错误，就是认为 $ \frac{a}{b} \quad mod\quad c = \frac{a\quad mod\quad c}{b\quad mod\quad c} $
> 正确的关系是， $ \frac{a}{b}\quad mod\quad c = \frac{a\quad mod\quad (b \cdot c)}{b} $ ，证明：
> $ \frac{a}{b}\quad mod\quad c = k $
> $ \frac{a}{b} = x \cdot c + k $
> $ a  = b \cdot x \cdot c + b \cdot k $
> $ a\quad mod\quad (b \cdot c) = b \cdot k $
> $ a\quad mod\quad (b \cdot c) / b = k $
> $ \frac{a}{b}\quad mod\quad c = \frac{a\quad mod\quad (b \cdot c)}{b} $

> $ a^n \quad mod \quad c = (a \cdot a^{n-1}) \quad mod \quad c = ((a \quad mod \quad c) \cdot (a^{n-1} \quad mod \quad c)) \quad mod \quad c$


### dp
```c++
#define MOD 1000000007
class Solution {
public:
    int numTilings(int n) {
        vector<vector<long long>> dp(n+1, vector<long long>(4, 0));
        dp[0][3] = 1;
        for(int i = 1; i <= n; i++) {
            dp[i][0] = dp[i-1][3];
            dp[i][1] = (dp[i-1][0] + dp[i-1][2])%MOD;
            dp[i][2] = (dp[i-1][0] + dp[i-1][1])%MOD;
            dp[i][3] = (dp[i-1][0] + dp[i-1][1] + dp[i-1][2] + dp[i-1][3])%MOD;
        }
        return dp[n][3];
    }
};
```
> ![](https://assets.leetcode-cn.com/solution-static/790/1.png)

### 快速幂
```c++
#define MOD 1000000007
class Solution {
public:
    int numTilings(int n) {
        vector<vector<long long>> pow = {
            {0,0,0,1},
            {1,0,1,0},
            {1,1,0,0},
            {1,1,1,1}
        }, base = {
            {0,0,0,0},
            {0,0,0,0},
            {0,0,0,0},
            {1,0,0,0}
        };
        pow = matPow(pow, n, 4);
        base = matMul(pow, base, 4, 4, 4);
        return base[3][0];
    }
    vector<vector<long long>> matPow(vector<vector<long long>>& a, int pow, int m) {
        vector<vector<long long>> res(m, vector<long long>(m));
        for(int i = 0; i < m; i++) {
            res[i][i] = 1;
        }
        while(pow) {
            if(pow&1) {
                res = matMul(a, res,m,m,m);
            }
            a = matMul(a, a,m,m,m);
            pow = pow >> 1;
        }
        return res;
    }

    vector<vector<long long>> matMul(vector<vector<long long>>& a, vector<vector<long long>>& b, int m, int n, int k) {
        vector<vector<long long>> c(m, vector<long long>(k));
        for(int i = 0; i < m; i++) {
            for(int j = 0; j < k; j++) {
                int sum = 0;
                for(int l = 0; l < n; l++) {
                    sum = (sum + (a[i][l]*b[l][j])%MOD)%MOD;
                }
                c[i][j] = sum;
            }
        }
        return c;
    }
};
```

## [791. 自定义字符串排序](https://leetcode.cn/problems/custom-sort-string/)
```c++
class Solution {
public:
    string customSortString(string order, string s) {
        int lenO = order.size();
        int argOrder[26] = {0};
        for(int i = 0; i < lenO; i++) {
            argOrder[order[i]-'a'] = i+1;
        }
        sort(s.begin(), s.end(), [&](char x, char y) -> bool{
            return argOrder[x-'a'] < argOrder[y-'a'];
        });
        return s;
    }
};
```

