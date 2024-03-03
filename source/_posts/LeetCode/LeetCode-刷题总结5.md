---
title: LeetCode-5
date: 2019-02-12 21:15:36
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## [350. 两个数组的交集 II](https://leetcode-cn.com/problems/intersection-of-two-arrays-ii/)

### 思路
1. 两个map分别统计在两个数组中一个元素的出现次数
2. 把其中一个数组排序去重，然后查询两个map
3. 取这个元素在两个数组里出现次数的最小值n，往ans里面push该元素n次
### AC代码
```c++
class Solution {
public:
    vector<int> intersect(vector<int>& nums1, vector<int>& nums2) {
        map<int, int> v,n;
        vector<int> ans;
        for (int x : nums1) {
            v[x]++;
        }
        for (int x : nums2) {
            n[x]++;
        }
        sort(nums1.begin(), nums1.end());
        nums1.erase(unique(nums1.begin(), nums1.end()), nums1.end());
        for (int x : nums1) {
            if (v[x] && n[x]) {
                int l = v[x] > n[x] ? n[x] : v[x];
                for (int i = 0; i < l; i++)
                ans.push_back(x);
            }
        }
        return ans;
    }
};
```
### 大佬思路
#### 双指针法
1. 两个数组排序
2. 两个指针指向第0个元素
3. 循环比较，如果某一个指针的元素小，指针后移，知道值相等时，push一次

### 大佬代码
```c++
class Solution {
public:
    vector<int> intersect(vector<int>& nums1, vector<int>& nums2) {
        sort(nums1.begin(), nums1.end());
        sort(nums2.begin(), nums2.end());
        int n1Size = nums1.size();
        int n2Size = nums2.size();
        int i = 0;
        int j = 0;
        vector<int> intersect;
        while((i < n1Size) && (j < n2Size))
        {
            if (nums1[i] < nums2[j])
                ++i;
            else if (nums1[i] > nums2[j])
                ++j;
            else
            {
                intersect.push_back(nums1[i]);
                ++i;
                ++j;
            }
        }
        return intersect;
    }
};
```
## [367. 有效的完全平方数](https://leetcode-cn.com/problems/valid-perfect-square/)

### 思路
自己没好好研究这题的算法
### AC代码
```c++
class Solution {
public:
    bool isPerfectSquare(int num) {
        return (int)sqrt(num) == sqrt(num);
    }
};
```

### 大佬思路
1. 自己写一个搞笑的mySqrt函数，用类似二分查找法实现，毕竟这道题的输入只有整数
2. 暴力搜索

### 大佬代码
```c++
class Solution {
public:
    bool isPerfectSquare(int num) {
        int sqrt = mySqrt(num);
        return sqrt*sqrt == num;
    }

    int mySqrt(int x) {
        int lo,hi;
    long mid;
    lo = 0;
    hi = x;
    while(lo<=hi){
        mid = lo + (hi-lo)/2;
        if(mid*mid>x){
            hi = mid-1;
        } else if ((mid+1)*(mid+1)>x) {
            return mid;
        } else{
            lo = mid+1;
        }
    }
    return lo;
}
```

## [371. 两整数之和](https://leetcode-cn.com/problems/sum-of-two-integers/)

### 思路
1. 用位运算
2. 不会

### AC代码
```c++
class Solution {
public:
    int getSum(int a, int b) {
        int temp = 0;
        while(a & b){
            temp = a;
            a ^= b;
            b = (temp & b) << 1;
        }
        return a|b;
    }
};
```
## [374. 猜数字大小](https://leetcode-cn.com/problems/guess-number-higher-or-lower/)
### 思路
1. 暴力搜索不可取，二分查找保平安
2. 不要`mid = (high + low) / 2`，会溢出
```c++
// Forward declaration of guess API.
// @param num, your guess
// @return -1 if my number is lower, 1 if my number is higher, otherwise return 0
int guess(int num);

class Solution {
public:
    int guessNumber(int n) {
        int left = 1, right = n, mid = (n + 1)/2;
        while (left <= right) {
            mid = (left - right)/2 + right;
            switch (guess(mid)) {
                case -1 :
                    right = mid - 1;
                    break;
                case 1 :
                    left = mid + 1;
                    break;
                case 0 :
                    return mid;
            }
        }
        return -1;
    }
};
```
#### [383. 赎金信](https://leetcode-cn.com/problems/ransom-note/)
### 思路
1. 两个表，分别记录每个字母出现次数
2. 遍历26个字母，magazine中字母出现次数大于等于ransom就可以
### AC代码
```c++
class Solution {
public:
    bool canConstruct(string ransomNote, string magazine) {
        int m[26] = {0}, n[26] = {0};
        for (char x : ransomNote) {
            m[x-'a']++;
        }
        for (char x : magazine) {
            n[x-'a']++;
        }
        for (char x : ransomNote) {
            if (m[x-'a'] > n[x-'a'])
                return false;
        }
        return true;
    }
};
```

#### [387. 字符串中的第一个唯一字符](https://leetcode-cn.com/problems/first-unique-character-in-a-string/)

### 思路
记录每个字母出现次数，`遍历字符串`，看谁第一个出现次数是0

### AC代码
```c++
class Solution {
public:
    int firstUniqChar(string s) {
        int n[26] = {0};
        for (char x : s) {
            n[x - 'a']++;
        }
        int len = s.length();
        for (int i = 0; i < len; i++) {
            if (n[s[i] - 'a'] == 1) return i;
        }
        return -1;
    }
};
```


## [389. 找不同](https://leetcode-cn.com/problems/find-the-difference/)

### 思路
1. 记录次数，遍历一遍t，看谁出现次数多一次
2. 异或运算，抵消相同的
### AC代码
```c++
class Solution {
public:
    char findTheDifference(string s, string t) {
        int m[26] = {0}, n[26] = {0};
        for (char x : s) {
            m[x - 'a']++;
        }
        for (char x : t) {
            n[x - 'a']++;
        }
        for (char x : t) {
            if (m[x - 'a'] < n[x - 'a']) return x;
        }
        return -1;
    }
};
```
### AC代码
```c++
class Solution {
public:
    char findTheDifference(string s, string t) {
        int len = s.length();
        char c = t[0];
        for (int i = 0; i < len; i++) {
            c ^= s[i];
            c ^= t[i + 1];//t只比s多一个
        }
        return c;
    }
};
```
## [400. 第N个数字](https://leetcode-cn.com/problems/nth-digit/)

### 思路
1. 把 $10^1$,$10^2$, $10^3$...之前的数算出来，存到数组里
2. 查询数组，得到这个数对应的数量级之前有多少数，然后算出这个数具体是几

### AC代码
```c++
class Solution {
public:
    int findNthDigit(int n) {
        unsigned long long m[10] = {0, 9, 189, 2889, 38889, 488889, 5888889, 68888889, 788888889, 8888888889};
        //10^i之前的数字个数。10之前有9个数，100之前有189个数
        int index = 0;
        for (; index < 10; index++) {
            if (m[index] >= n) {
                break;
            }
        }//找到n所在的范围，index是它的位数len
        n -= m[index - 1];//从例如189对应的100后的第几个数字
        long long ans = pow(10, index - 1) + (n - 1) / (index);//对应的数
        string t = to_string(ans);
        return t[(n - 1) % (index)] - '0';
    }
};
```

## [405. 数字转换为十六进制数](https://leetcode-cn.com/problems/convert-a-number-to-hexadecimal/)

### 思路
1. 用一个`unsigned char`指针指向`int`，循环4次，每次取值是两个16进制数，然后存起来
2. 注意局部变量存在栈里，倒着输出
3. 忽略前导0
### AC代码

```c++
class Solution {
public:
    string toHex(int num) {
        if (!num) return "0";
        char m[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
        unsigned char *c = (unsigned char *)&num;
        unsigned int n[8] = {0};
        for (int i = 0; i < 8; i+=2) {
            n[i] = (*c) % 16;
            n[i + 1] = (*c/16) % 16;
            c++;
        }
        string ans;
        int i = 7;
         while (i >= 0 && n[i] == 0)
             i--;
        for (; i >= 0; i--) {
            ans += m[n[i]];
        }
        return ans;
    }
};
```
## [412. Fizz Buzz](https://leetcode-cn.com/problems/fizz-buzz/)
### 思路
额，，算就是了
### AC代码
```c++
class Solution {
  public:
    vector<string> fizzBuzz(int n) {
        vector<string> v; 
        for (int i = 1; i <= n; i++) {
            if (i % 15 == 0) {
                v.push_back("FizzBuzz");
            }
            else if (i % 3 == 0) {
                v.push_back("Fizz");
            }
            else if (i % 5 == 0) {
                v.push_back("Buzz");
            }
            else {
                v.push_back(to_string(i));
            }
        }
        return v;
    }
};
```
## [414. 第三大的数](https://leetcode-cn.com/problems/third-maximum-number/)
### 思路
1. 搜索三次
2. 第一次最大值
3. 第二次不等于第一次的最大值
4. 第三次不等于前两次的最大值
### AC代码
```c++
class Solution {
public:
    int thirdMax(vector<int>& nums) {
        long i = LONG_MIN, j = LONG_MIN, k = LONG_MIN;
        for (int x : nums) {
            if (x > i) {
                i = x;
            }
        }
        for (int x : nums) {
            if (x > j && x != i) {
                j = x;
            }
        }
        for (int x : nums) {
            if (x > k && x != i && x != j) {
                k = x;
            }
        }
        if (k == LONG_MIN) return i;
        else return k;
    }
};
```
### 大佬思路
1. 搜索一次找最大值
2. 如果有最大值且大于最大的最大值，就把当前值先给了第二大值，第二大值给了第三大值
3. 如果有最大值且小于最大的最大值大于第二大，往后顺延
4. 如果有最大值且小于第二大的最大值大于第三大，往后顺延
### 大佬代码
```c++
class Solution {
public:
    int thirdMax(vector<int>& nums) {
        long first = LONG_MIN, second = LONG_MIN, third = LONG_MIN;
        for (int num : nums) {
            if (num > first) {
                third = second;
                second = first;
                first = num;
            } else if (num > second && num < first) {
                third = second;
                second = num;
            } else if (num > third && num < second) {
                third = num;
            }
        }
        return (third == LONG_MIN || third == second) ? first : third;
    }
};
```
## [415. 字符串相加](https://leetcode-cn.com/problems/add-strings/)
### 思路
1. 找到最长字符串的长度，用这个长度分别给两个字符串添加前导0
2. 倒着遍历字符串，对应相加模拟就行了
3. 别网站最后一位的进位
### AC代码
```c++
class Solution {
public:
    string addStrings(string num1, string num2) {
        int carry = 0;
        int len1 = num1.length();
        int len2 = num2.length();
        int len = len1 > len2 ? len1 : len2;
        string zero;
        for (int i = 0; i < len - len1; i++) {
            zero += '0';
        }
        num1.insert(0, zero);
        zero.clear();
        for (int i = 0; i < len - len2; i++) {
            zero += '0';
        }
        num2.insert(0, zero);
        for (int i = len - 1; i >= 0; i--) {
            int n = carry + num1[i] + num2[i] - 2*'0';
            num1[i] = n % 10 + '0';
            carry = n / 10;
        }
        if (carry) num1.insert(0, 1, carry + '0');
        return num1;
    }
};
```

## [434. 字符串中的单词数](https://leetcode-cn.com/problems/number-of-segments-in-a-string/)

### 思路
stl大法好
### AC代码

```c++
class Solution {
public:
    int countSegments(string s) {
        stringstream ss(s);
        string buf;
        int count = 0;
        while (ss >> buf) {
            count++;
        }
        return count;
    }
};
```

## [447. 回旋镖的数量](https://leetcode-cn.com/problems/number-of-boomerangs/)
### 思路
1. 把所有点两两配对，计算距离
2. 累加`n(n-1)`排列数$2A_n^2$
### AC代码
```c++
class Solution {
public:
    int numberOfBoomerangs(vector<pair<int, int>>& points) {
        unordered_map<int ,int> m;
        int ans = 0;
        int len = points.size();
        for (int i = 0; i < len; i++) {
            for (int j = 0; j < len; j++) {
                int dx = points[i].first - points[j].first;
                int dy = points[i].second - points[j].second;
                m[dx*dx + dy*dy]++;
            }
            for (auto c : m) {
                ans += c.second*(c.second-1);
            }
            m.clear();
        }
        return ans;
    }
};
```

## [441. 排列硬币](https://leetcode-cn.com/problems/arranging-coins/)
### 思路
1. 直接解方程

### AC代码
```c++
class Solution {
public:
    int arrangeCoins(int n) {
        return (sqrt(1 + 8ll * n) - 1) / 2;
    }
};
```
### 大佬思路
#### 类似二分查找
1. 计算当前mid对应的楼梯数q
2. 如果q<=总数，查找右边
3. 否则查找左边
### 大佬代码
```c++
class Solution {
public:
    int arrangeCoins(int n) {
        if (n <= 0) return 0;
        unsigned long long i = 1, j = n + 1;
        while (j - i>= 1) {
            long long mid = i + (j - i) / 2;
            long long q = mid*(mid + 1) / 2;
            if (q <= n) {
                i = mid + 1;
            } else {
                j = mid;
            }
        }
        return i - 1;
    }
};
```
## [443. 压缩字符串](https://leetcode-cn.com/problems/string-compression/)

### 思路
遍历数次数，然后把次数编程string存起来，最后一个字符一个字符的存到vector数组里，返回
### AC代码
```c++
class Solution {
public:
    vector<char> ans;
    int compress(vector<char>& chars) {
        int len = chars.size();
        vector<string> s;
        int j = 0;
        int count = 0;
        for (int i = 1; i < len; i++) {
            if (chars[j] != chars[i]) {
                j++;
                chars[j] = chars[i];
                s.push_back(to_string(count + 1));
                count = 0;
            } else {
                count++;
            }
        }
        s.push_back(to_string(count + 1));
        for (int i = 0; i < j + 1; i++) {
            ans.push_back(chars[i]);
            if (s[i] == "1") continue;
            int num = s[i].length();
            for (int k = 0; k < num; k++) {
                ans.push_back(s[i][k]);
            }
        }
        chars = ans;
        return chars.size();
    }
};
```

### 大佬思路
遍历一遍，数个数，然后都存到一个string里面（充分利用string重载的`operator+`），最后分解成char数组，返回
### 大佬代码
```c++
class Solution {
 public:
    int compress(vector<char> &chars) {
        int count = 1;
        string str = "";
        for (int i = 1; i < chars.size(); i++) {
            if (chars[i] == chars[i - 1]) {
                count++;
            }
            else {
                if (count != 1) {
                    str += chars[i - 1] + to_string(count);
                }
                else {
                    str += chars[i - 1];
                }
                count = 1;
            }
        }
        if (count != 1) {
            str += chars[chars.size() - 1] + to_string(count);
        }
        else {
            str += chars[chars.size() - 1];
        }
        for (int i = 0; i < str.size(); i++) {
            if (i < chars.size()) {
                chars[i] = str[i];
            }
            else {
                chars.push_back(str[i]);
            }
        }
        return str.size();
    }
};
```
## [448. 找到所有数组中消失的数字](https://leetcode-cn.com/problems/find-all-numbers-disappeared-in-an-array/)

### 思路
记录每个数的出现次数，最后返回出现次数为0的那些数
### AC代码
```c++
class Solution {
public:
    vector<int> findDisappearedNumbers(vector<int>& nums) {
        unordered_map<int, int> m;
        vector<int> ans;
        int len = nums.size();
        for (int x : nums) {
            m[x]++;
        }
        for (int i = 1; i <= len; i++) {
            if (m[i] == 0) {
                ans.push_back(i);
            }
        }
        return ans;
    }
};
```
### 大佬思路
1. i从0开始遍历数组，取nums[i]的绝对值Q（后期正数可能变负数）
2. 把Q-1作为下标，把nums[Q-1]这个数编程负的（自己的绝对值的相反数）
3. 最后正数出现的位置就是`1~n`没出现过的数
### 大佬代码
```c++
class Solution {
public:
    vector<int> findDisappearedNumbers(vector<int>& nums) {
        vector<int> ans;
        int len = nums.size();
        for (int i = 0; i < len; i++) {
            nums[abs(nums[i]) - 1] = -abs(nums[abs(nums[i]) - 1]);
        }
        for (int i = 0; i < len; i++) {
            if (nums[i] > 0) {
                ans.push_back(i + 1);
            }
        }
        return ans;
    }
};
```

## [455. 分发饼干](https://leetcode-cn.com/problems/assign-cookies/)
### 思路
#### 贪心算法 + 双指针法
1. 把所有小孩的胃口的出现次数统计出来，放到哈希表里面
2. 把所有饼干能满足的最大胃口的出现次数统计出来，放到另一个哈希表里面
3. 不用`unordered_map`，要排序的
4. 遍历一遍孩子，如果当前饼干能满足胃口，就尽量多的喂
5. 直到这个孩子的胃口被满足后，i++，不要j++，也许当前饼干还没有用完，而且足够下一个孩子的胃口
6. 如果不能满足胃口，由于map是排序过的，所以也一定不能满足后面的孩子的要求，就j++看下一块饼干的情况
### AC代码
```c++
class Solution {
public:
    int findContentChildren(vector<int>& g, vector<int>& s) {
        map<int, int> bit, chi;
        for (int x : g) {
            chi[x]++;
        }
        for (int x : s) {
            bit[x]++;
        }
        int ans = 0;
        auto i = chi.begin(), j = bit.begin();
        for (; i != chi.end() && j != bit.end(); ) {
            if (i->first <= j->first && j->second > 0) {
                int a = i->second;
                int b = j->second;
                int min = a > b ? b : a;
                i->second -= min;
                j->second -= min;
                ans += min;
                if (i->second == 0)
                i++;
            } else {
                j++;
            }
        }
        return ans;
    }
};
```

### 大佬思路
#### 贪心 + 双指针
1. 排序两个数组
2. 其他思路和我的基本一样，但是人家的代码又简洁效率又高
### 大佬代码
```c++
class Solution {
public:
    int findContentChildren(vector<int>& g, vector<int>& s) {
        sort(g.begin(), g.end());
        sort(s.begin(), s.end());
        int ans = 0;
        int i = 0, j = 0;
        int len1 = g.size(), len2 = s.size();
        for (; i < len1 && j < len2;j++) {
            if (g[i] <= s[j]) {
                i++;
            }
        }
        return i;
    }
};
```
## [461. 汉明距离](https://leetcode-cn.com/problems/hamming-distance/)
### 思路
#### 位运算
1. 异或，相同为1，不同为0
2. 两个数异或，转二进制，把二进制位直接加起来就行

### AC代码
```c++
class Solution {
public:
    int hammingDistance(int x, int y) {
        int ans = x ^ y;
        int num = 0;
        while (ans) {
            num += ans % 2;
            ans /= 2;
        }
        return num;
    }
};
```
#### [463. 岛屿的周长](https://leetcode-cn.com/problems/island-perimeter/)
### 思路
1. 只能暴搜了，如果一个格子上有颜色，总边数+=4
2. 如果下方有格子，总边数-=2（不管上面，防止两条边重复计数）
3. 如果右边有格子，总边数-=2（同理，不管左边）
### AC代码
```c++
class Solution {
public:
    int islandPerimeter(vector<vector<int>>& grid) {
        int ans = 0;
        int len = grid.size();
        int wide = grid[0].size();
        for(int i = 0; i < len; i++) {
            for (int j = 0; j < wide; j++) {
                if (grid[i][j]) {
                    ans += 4;
                    if (i + 1 < len && grid[i + 1][j]) {
                        ans -= 2;
                    }
                    if (j + 1 < wide && grid[i][j + 1]) {
                        ans -= 2;
                    }
                }
            }
        }
        return ans;
    }
};
```
## [476. 数字的补数](https://leetcode-cn.com/problems/number-complement/)
### 思路
1. 转二进制数
2. (num%2+1)%2能让1变0，0变1
### AC代码
```c++
class Solution {
public:
    int findComplement(int num) {
        int n = 0;
        long long i = 1;
        while (num) {
            n += i * ((num % 2 + 1) % 2);
            i *= 2;
            num /= 2;
        }
        return n;
    }
};
```
### 大佬思路
位运算，不懂
### 大佬代码
```c++
class Solution {
public:
    int findComplement(int num) {
        int temp = num;
        int c = 0;
        while ( temp > 0 ) {
            temp >>= 1;
            c = ( c << 1 ) + 1;
        }
        return num ^ c;
    }
};
```
## [482. 密钥格式化](https://leetcode-cn.com/problems/license-key-formatting/)
### 思路
1. 把`'-'`全都变成`' '`
2. stringstream把字符串拼起来
3. 倒着遍历每K个加一个`'-'`，并且注意前面是不是头
### AC代码
```c++
class Solution {
public:
    string licenseKeyFormatting(string S, int K) {
        string ans, buf;
        for (int i = 0; i < S.length(); i++) {
            if (S[i] == '-') {
                S[i] = ' ';
            } else {
                S[i] = toupper(S[i]);
            }
        }
        stringstream ss(S);
        while (ss >> buf) {
            ans += buf;
        }
        for (int i = ans.length() - 1, count = 1; i > 0; i--, count++) {
            if (count % K == 0 && i != 0) {
                ans.insert(i, 1, '-');
            }
        }
        return ans;
    }
};
```

### 思路
1. 遍历，判断是不是字母，是字母，变大写，然后push到新的string里面
2. 同时记录字符数，每K个加一个负号
3. 清除前后的负号
4. 反转
### AC代码
```c++
class Solution {
public:
    string licenseKeyFormatting(string S, int K) {
        string ans;
        int count = 0;
        int len = S.length();
        for (int i = len; i >= 0; i--) {
            char t = S[i];
            t = toupper(t);
            if (t != '-') {
                ans.push_back(t);
                if (count == K /*&& i != 0 && i != len*/) {
                    ans.push_back('-');
                    count = 0;
                }
                count++;
            }
        }
        if (ans.back() == '-') ans.pop_back();
        reverse(ans.begin(), ans.end());
        if (ans.back() == '-') ans.pop_back();
		return ans;
    }
};
```
## [485. 最大连续1的个数](https://leetcode-cn.com/problems/max-consecutive-ones/)
### AC代码
```c++
class Solution {
public:
    int findMaxConsecutiveOnes(vector<int>& nums) {
        int len = nums.size();
        int count = 0, max = 0;
        for (int x : nums) {
            if (x) {
                count++;
            } else {
                //max = max > count ? max : count;
                if (max < count) max = count;
                count = 0;
            }
        }
        if (max < count) max = count;
        return max;
    }
};
```

## [500. 键盘行](https://leetcode-cn.com/problems/keyboard-row/)
### 思路
1. 建立哈希表，把每个字母对应的键盘行数标号
2. 遍历所有字符串，看是不是同一行，统计，记录
3. 按照要求输出
### AC代码
```c++
class Solution {
public:
    vector<string> findWords(vector<string>& words) {
        string keyBoard[3] = {"QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM"};
        unordered_map<char, char> m;
        for (int i = 0; i < 3; i++) {
            int len = keyBoard[i].length();
            for (int j = 0; j < len; j++) {
                m[keyBoard[i][j]] = i;
                m[keyBoard[i][j] - 'A' + 'a'] = i;
            }
        }
        int n = words.size();
        vector<string> ans;
        for (int i = 0; i < n; i++) {
            int len = words[i].length();
            int cmp = m[words[i][0]];
            bool find = true;
            for (int j = 0; j < len; j++) {
                if (cmp != m[words[i][j]]) {
                    find = false;
                    break;
                }
            }
            if (find) {
                ans.push_back(words[i]);
            }
        }
        return ans;
    }
};
```
## [504. 七进制数](https://leetcode-cn.com/problems/base-7/)
### 思路
就是普通进制转换问题
### AC代码
```c++
class Solution {
public:
    string convertToBase7(int num) {
        string ans;
        bool nagetive = num < 0;
        if (nagetive) {
            num *= -1;
        }
        do {
            ans = (char)(num % 7 + '0') + ans;
            num /= 7;
        } while (num);
        if (nagetive){
            ans = "-" + ans;
        }
        return ans;
    }
};
```
## [506. 相对名次](https://leetcode-cn.com/problems/relative-ranks/)
### 思路
1. 拷贝一份，排序，map记录排名
2. 遍历原来的数组，输出
### AC代码
```c++
class Solution {
public:
    vector<string> findRelativeRanks(vector<int>& nums) {
        vector<int> copy = nums;
        string rank[3] = {"Gold Medal", "Silver Medal", "Bronze Medal"};
        map<int, int> m;
        sort(copy.begin(), copy.end(), greater<int>());
        int len = nums.size();
        for (int i = 0; i < len; i++) {
            m[copy[i]] = i;
        }
        vector<string> ans;
        for (auto x : nums) {
            if (m[x] >= 0 && m[x] < 3) {
                ans.push_back(rank[m[x]]);
            } else {
                ans.push_back(to_string(m[x] + 1));
            }
        }
        return ans;
    }
};
```
## [507. 完美数](https://leetcode-cn.com/problems/perfect-number/)
### 思路

### AC代码
```c++
class Solution {
public:
    bool checkPerfectNumber(int num) {
        if (num <= 1) return false;
        int ans = 1;
        for (int i = 2; i < sqrt(num); i++) {
            if (num % i == 0) {
                ans += i + num/i;
            }
        }
        return ans == num;
    }
};
```

### 思路
$1*10^8$的完美数只有6,28,496,8128,33550336
### AC代码
```java
class Solution {
    public boolean checkPerfectNumber(int num) {
        switch(num) {
            case 6:
            case 28:
            case 496:
            case 8128:
            case 33550336:
                return true;
        }
        return false;
    }
}
```

## [509. 斐波那契数](https://leetcode-cn.com/problems/fibonacci-number/)
### 思路
居然真的只是求斐波那契数列，还只要前30位
### AC代码
```c++
class Solution {
public:
    int fib(int N) {
        int a = 0, b = 1;
        for (int i = 0; i < N; i++) {
            int c = a + b;
            b = a;
            a = c;
        }
        return a;
    }
};
```
## [520. 检测大写字母](https://leetcode-cn.com/problems/detect-capital/)
### 思路
1. 先把前导的大写字母跳过
2. 如果当前指针正好指在0或1，那么只要后面有大写字母，就算错（除非长度只有1）
3. 如果指在1后面，那么后面有小写字母就算错
### AC代码
```c++
class Solution {
public:
    bool detectCapitalUse(string word) {
        int len = word.length();
        int i = 0;
        while (i < len && word[i] >= 'A' && word[i] <= 'Z') i++;
        if (i > 1) {
            for ( ; i < len; i++) {
                if (word[i] >= 'a' && word[i] <= 'z') {
                    return false;
                }
            }
        } else {
            if (len <= 1) {
                return true;
            } else {
                for ( ; i < len; i++) {
                    if (word[i] >= 'A' && word[i] <= 'Z') {
                        return false;
                    }
                }
            }
        }
        return true;
    }
};
