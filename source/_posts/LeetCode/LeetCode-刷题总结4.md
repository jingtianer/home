---
title: LeetCode-4
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

## [172. 阶乘后的零](https://leetcode-cn.com/problems/factorial-trailing-zeroes/)

### 思路
把2，5的倍数拆成2，5，数5的个数（2一定比5多），这样5一定和2配对，所以5的个数就是末尾0的个数
### AC代码
```c++
class Solution {
public:
    int trailingZeroes(int n) {
        int ans = 0;
        while (n) {
            n /= 5;
            ans += n;
        }
        return ans;
    }
};
```

```c++
class Solution {
public:
    int trailingZeroes(int n) {
        return n == 0 ? 0 : n/5 + trailingZeroes(n / 5);
    }
};
```

## [189. 旋转数组](https://leetcode-cn.com/problems/rotate-array/)

### 思路（递归）
- `k %= nums.size();`取余数，不要循环好多圈
- 把前k个数和后k个数交换
- 把从下标k到结束的数作为源数据调用本函数

### AC代码
```c++
class Solution {
public:
    void rotate(vector<int>& nums, int k) {
        go(0, k, nums);
        /*
        时间复杂度O(n^2/k)
        空间复杂度O(1)
        */
    }
    void go(int beg, int k, vector<int>& nums) {
        k %= nums.size() - beg;
        if (k == 0) return;
        for (int i = beg; i < beg + k; i++) {
            swap(nums[i], nums[nums.size() - k + i - beg]);
        }
        go(beg + k, k, nums);
    }
    void swap(int& a, int& b) {
        int t = a;
        a = b;
        b = t;
    }
};
```

### 思路
- 把整个数组反转一次
- 前0到k-1反转一次
- 后k到结束反转一次

### AC代码

```c++
class Solution {
public:
    void rotate(vector<int>& nums, int k) {
        int n = nums.size();
        k %= n;
        reverse(nums, 0, n - 1);
        reverse(nums, 0, k - 1);
        reverse(nums, k, n - 1);
        /*
        时间复杂度O(n)
        空间复杂度O(1)
        */
        /*------------------------------*/
    }
    void reverse(vector<int>& nums, int begin, int end) {
        while (begin < end) {
            int n = nums[begin];
            nums[begin++] = nums[end];
            nums[end--] = n;
        }
    }
};
```

## [190. 颠倒二进制位](https://leetcode-cn.com/problems/reverse-bits/)

### 思路
- 循环模2，2进制转2进制
- 注意原来的数的前导0也要添加到后面，所以循环条件是循环次数32次（因为给的是32位无符号数）

### AC代码

```c++
class Solution {
public:
    uint32_t reverseBits(uint32_t n) {
    uint32_t ans = 0;
    int i = 32;
    while (i--)
    {
        ans *= 2;
        ans += n % 2;
        n /= 2;
    }
    return ans;
    }
};
```

## [191. 位1的个数](https://leetcode-cn.com/problems/number-of-1-bits/)

### AC代码

```c++
class Solution {
public:
    int hammingWeight(uint32_t n) {
        int c = 0;
        while (n) {
            if (n % 2 == 1)c++;
            n/=2;
        }
        return c;
    }
};
```

## [202. 快乐数](https://leetcode-cn.com/problems/happy-number/)

### 思路
- 计算，看有没有重复，有重复就说明不是快乐数
- 计算，出现4就不是快乐数（不是快乐数的数称为不快乐数（unhappy number），所有不快乐数的数位平方和计算，最後都会进入 4 → 16 → 37 → 58 → 89 → 145 → 42 → 20 → 4 的循环中。）

### AC代码
```c++
class Solution {
public:
    bool isHappy(int n) {
        map<int, int> m;
        while (n != 1) {
            m[n]++;
            if (m[n] > 1) break;
            n = get(n);
        }
        return n == 1;
    }
    int get(int n) {
        int ans = 0;
        while (n) {
            ans += (n % 10) * (n % 10);
            n /= 10;
        }
        return ans;
    }
};
```

### AC代码
```c++
class Solution {
public:
    bool isHappy(int n) {
        while (n != 1) {
            if (n == 4) {
                return false;
            }
            n = get(n);
        }
        return true;
    }
    int get(int n) {
        int ans = 0;
        while (n) {
            ans += (n % 10) * (n % 10);
            n /= 10;
        }
        return ans;
    }
};
```

## [203. 移除链表元素](https://leetcode-cn.com/problems/remove-linked-list-elements/)

### 思路
如果头结点是要删的元素，进行的操作不太一样，要单独考虑，然后进行后面的删除。评论区好多用c++的都不管内存泄漏。不是好习惯，坚决杜绝！
### AC代码

```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    ListNode* removeElements(ListNode* head, int val) {
        ListNode* move = head, *last = head;
        while (head != NULL && head->val == val) {
            head = head->next;
            delete last;
            last = head;
        }
        move = head;
        while (move != NULL) {
            if (move->val == val){
                last->next = move->next;
                delete move;
            } else {
                last = move;
            }
            move = last->next;
        }
        return head;
    }
};
```

#### [204. 计数质数](https://leetcode-cn.com/problems/count-primes/)

### 思路
用筛法两个for循环把不是素数的都筛出来
但是要提升性能:
- 忽略偶数
- 如果当前数已经算过了，就不要算
- 用bool的vector，bool一字节，比int短，也可以加速

### AC代码
```c++

class Solution
{
  public:
    int countPrimes(int n)
    {
        if (n <= 2)
            return 0;
        int count = 1;
        vector<bool> notPrime(n,0);
        for (int i = 3; i < sqrt(n); i += 2)
        {
            if (notPrime[i] == 1)continue;
            for (int j = 3; j * i <= n; j += 2)
            {
                notPrime[i * j] = 1;
            }
        }
        notPrime[0] = 1;
        notPrime[1] = 1;
        notPrime[3] = 0;
        notPrime[4] = 1;
        notPrime[5] = 0;
        notPrime[6] = 1;
        notPrime[7] = 0;
        notPrime[8] = 1;
        notPrime[9] = 1;
        for (int i = 1; i < n; i += 2)
        {
            if (notPrime[i] == 0)
                count++;
        }
        return count;
    }
};
```

### 最快大佬的代码
### 思路
#### 看不懂
```c++
class Solution {
public:
    int countPrimes(int n) {
        if (n < 3)
            return 0;
        size_t len = (n-2) >> 1;
        //cout << len << endl;
        vector<char> v(len, 0);
        int count = 1;
        uint i = 0;
        auto m = min(len, 0x7FFEuL);
        while (i < m) {
            if (!v[i]) {
                ++count;
                uint p = (i << 1) + 3;
                //if (p < 0x10000) {
                uint pp = p * p;
                uint j = (pp - 3) >> 1;
                while(j < len) {
                    v[j] = true;
                    j += p;
                }
            }
            ++i;
        }
        while (i < len) {
            if (!v[i])
                ++count;
            ++i;
        }
        return count;
    }
};
```
## [205. 同构字符串](https://leetcode-cn.com/problems/isomorphic-strings/)

### 思路
不太会，抄的评论区代码，但是要注意，一个字母a如果替换成b，就不能替换为c


### AC代码
```c++
static const int boost = [](){
    ios::sync_with_stdio(false);
    cin.tie(nullptr);
    return 0;
}();

class Solution {
public:
    bool isIsomorphic(string s, string t) {
        int alphabetS[256], alphabetT[256], num = 0;
        memset(alphabetS, 0, sizeof(alphabetS));
        memset(alphabetT, 0, sizeof(alphabetT));
        int len = s.length();
        for (int pos = 0; pos < len; pos++)
        {
            if(alphabetS[s[pos]] != alphabetT[t[pos]])
                return false;
            else if (alphabetS[s[pos]] == 0)
                alphabetS[s[pos]] = alphabetT[t[pos]] = ++num;
        }
        return true;
    }
};
```
## [206. 反转链表](https://leetcode-cn.com/problems/reverse-linked-list/)

### 思路
1. 把结点全都存到数组里
2. 递归，调用自己，再把头结点变成尾巴结点

### AC代码
```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    ListNode* reverseList(ListNode* head) {
        vector<ListNode*> v;
        ListNode *temp = head;
        while (temp != NULL) {
            v.push_back(temp);
            temp = temp->next;
        }
        int len = v.size();
        for (int i = 0; i < len / 2; i++) {
            int swap = v[i]->val;
            v[i]->val = v[len - 1 - i]->val;
            v[len - 1 - i]->val = swap;
        }
        return head;
    }
};
```

```c++
class Solution {
public:
    ListNode* reverseList(ListNode* head) {
        if (head == NULL || head->next == NULL) return head;
        ListNode *temp = reverseList(head->next);
        head->next->next = head;
        head->next = NULL;
        return temp;
    }
};
```

## [217. 存在重复元素](https://leetcode-cn.com/problems/contains-duplicate/)

### 思路
1. 调用api，先sort，再调用unique，判断返回值是不是end()迭代器，是则没有重复


### AC代码

```c++
class Solution {
public:
    bool containsDuplicate(vector<int>& nums) {
        sort(nums.begin(), nums.end());
        return unique(nums.begin(), nums.end()) != nums.end();
        
    }
};
```

```c++
class Solution {
public:
    bool containsDuplicate(vector<int>& nums) {
        sort(nums.begin(), nums.end());
        int len = nums.size();
        for (int i = 1; i < len; i++) {
            if (nums[i - 1] == nums[i]) return true;
        }
        return false;
        
    }
};
```

## [225. 用队列实现栈](https://leetcode-cn.com/problems/implement-stack-using-queues/)

### 思路
queue是先进先出，stack是后进先出。
1. 用deque实现
2. 每次push的元素后，让队列循环pop出来再push回去，使得刚刚push的元素变成第一个

### AC代码
```c++
class MyStack {
public:
    queue<int> data;
    MyStack() {
        
    }
    void push(int x) {
        data.push(x);
        int len = data.size() - 1;
        while (len--) {
            data.push(data.front());
            data.pop();
        }
    }
    int pop() {
        int x = data.front();
        data.pop();
        return x;
    }
    int top() {
        return data.front();
    }
    bool empty() {
        return data.empty();
    }
};
```

```c++
class MyStack {
public:
    deque<int> data;
    MyStack() {
    }
    void push(int x) {
        data.push_front(x);
    }
    int pop() {
        int x = data.front();
        data.pop_front();
        return x;
    }
    int top() {
        return data.front();
    }
    bool empty() {
        return data.empty();
    }
};
```
## [226. 翻转二叉树](https://leetcode-cn.com/problems/invert-binary-tree/)

### 思路
- 递归
  - 深度优先
  - 广度优先


### AC代码

```c++
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode(int x) : val(x), left(NULL), right(NULL) {}
 * };
 */
class Solution {
public:
    TreeNode* invertTree(TreeNode* root) {
        go(root);
        return root;
        
    }
    void go(TreeNode* root) {
        if (root == NULL) return;
        TreeNode* temp = root->left;
        root->left = root->right;
        root->right = temp;//广度优先
        go(root->left);
        go(root->right);
    }
};
```
```c++
class Solution {
public:
    TreeNode* invertTree(TreeNode* root) {
        if (root == NULL) return root;
        TreeNode*left = invertTree(root->right);//深度优先
        TreeNode*right = invertTree(root->left);
        root->right = right;
        root->left = left;
        return root;
        
    }
};
```

## [231. 2的幂](https://leetcode-cn.com/problems/power-of-two/)

### 思路
1. 取2对数看是不是整数
2. 利用二进制位运算
   1. 假设一个无符号数是全1的，那么它是2^k-1
   2. 假设2^k = n，那么只要一个数满足(n)&(n-1) == 0，按位相与

### AC代码

```c++
class Solution {
public:
    bool isPowerOfTwo(int n) {
        return (int)log2(n) == log2(n);
    }
};
```
```c++
class Solution {
public:
    bool isPowerOfTwo(int n) {
        if (n > 0 && ((n)&(n-1)) == 0) return true;
        return false;
    }
};
```

## [232. 用栈实现队列](https://leetcode-cn.com/problems/implement-queue-using-stacks/)

### 思路
1. 创建两个栈s、m，每次push存到s里面，然后再逐个弹出s中的元素压到m中（这个过程中s要先拷贝一份）
2. 每次pop的时候，从m中pop，然后再逐个弹出m中的元素压到s中（这个过程中s要先拷贝一份）
3. m用来对顶部元素操作，s来保持队形

### AC代码
```c++
class MyQueue {
public:
    stack<int> s;
    stack<int> m;
    MyQueue() {
    }
    void push(int x) {
        s.push(x);
        update(s,m);
    }
    void update(stack<int> a, stack<int>& b) {
        int len = a.size();
        while (!b.empty()){
            b.pop();
        }
        while (len--) {
            b.push(a.top());
            a.pop();
        }
    }
    int pop() {
        int x = m.top();
        m.pop();
        update(m,s);
        return x;
    }
    int peek() {
        return m.top();
    }
    bool empty() {
        return m.empty();
    }
};
```

## [234. 回文链表](https://leetcode-cn.com/problems/palindrome-linked-list/)

### 思路（暂时没有达到空间O(1)）
#### vector存结点地址
### AC代码
```c++
/**
 * Definition for singly-linked list.
 * struct ListNode {
 *     int val;
 *     ListNode *next;
 *     ListNode(int x) : val(x), next(NULL) {}
 * };
 */
class Solution {
public:
    bool isPalindrome(ListNode* head) {
        /*ListNode* temp = head;
        vector<ListNode*> v;
        while (temp != NULL) {
            v.push_back(temp);
            temp = temp->next;
        }
        int len = v.size();
        for (int i = 0; i < len / 2; i++) {
            if (v[i]->val != v[len - 1 - i]->val) return false;
        }
        return true;*/
    }
};
```
## [292. Nim游戏](https://leetcode-cn.com/problems/nim-game/)

### 思路
巴什博奕，n%(m+1)!=0时，先手总是会赢的
m为每次抽排的最大张数
 
### AC代码
```c++
class Solution {
public:
    bool canWinNim(int n) {
        return n%4 != 0;
    }
};
```

## [242. 有效的字母异位词](https://leetcode-cn.com/problems/valid-anagram/)

### 思路
就是看每个字母的使用次数一不一样
一个数组，记录字母的使用次数，最后次数一样就行。

### AC代码

```c++
class Solution {
public:
    bool isAnagram(string s, string t) {
        int a[26] = {0}, b[26] = {0};
        for (int i = 0; i < s.length(); i++) 
                a[s[i] - 'a']++;
        for (int i = 0; i < t.length(); i++) 
                b[t[i] - 'a']++;
        for (int i = 0; i < 26; i++) {
            if (a[i] != b[i]) return false;
        }
        return true;
    }
};
```

## [258. 各位相加](https://leetcode-cn.com/problems/add-digits/)

###AC代码

```c++
class Solution {
public:
    int addDigits(int num) {
        while (num/10 != 0) {
            int ans = 0;
            while (num) {
                ans += num%10;
                num /= 10;
            } 
            num = ans;
        }
        return num;
        return num == 0 ? 0 : num - 9 * ((num - 1) / 9) ;
    }
};
```

## [263. 丑数](https://leetcode-cn.com/problems/ugly-number/)

### 思路
如果n % m == 0,说明n中至少有一个m的因数，循环n%m == 0时重复n /= m，可以去除所有的m的因数，根据这个思路，如果是丑数，把所有2，3，5的因数去除以后，就是1了

### AC代码
```c++
class Solution {
public:
    bool isUgly(int num) {
        if (num <= 0) return false;
        while (num%2 == 0) num /= 2;
        while (num%3 == 0) num /= 3;
        while (num%5 == 0) num /= 5;
        return num == 1;
    }
};
```

## [268. 缺失数字](https://leetcode-cn.com/problems/missing-number/)

### 思路
1. 0-n 11 个数中缺了一个，可以先算出等差数列的sum(0,n)，然后变量数组减去所有元素，最后的差就是缺少的元素
2. 看不懂的位运算，异或抵消
### AC代码

```c++
class Solution {
public:
    int missingNumber(vector<int>& nums) {
        int ans = nums.size();
        ans = ans*(ans+1)/2;
        for (int x : nums) {
            ans -= x;
        }
        return ans;
    }
};
```
```c++
class Solution {
public:
    int missingNumber(vector<int>& nums) {
        int sum = nums.size();
        int len = sum;
        for (int i = 0; i < len; i++) {
            sum ^= nums[i];
            sum ^= i;
        }
        return sum;
    }
};
```

## [278. 第一个错误的版本](https://leetcode-cn.com/problems/first-bad-version/)

### 思路
暴力搜索不可取，二分查找保平安

### AC代码
```c++
// Forward declaration of isBadVersion API.
bool isBadVersion(int version);

class Solution {
public:
    int firstBadVersion(int n) {
        long long mid , a = 1, b = n;
        if (isBadVersion(1)) return 1;
        while (a <= b) {
            mid=a+(b-a)/2;
            bool bad, left, right;
            bad = isBadVersion(mid);
            left = isBadVersion(mid - 1);
            right = isBadVersion (mid + 1);
            if (bad && !left) return mid;
            else if (bad && right) b = mid - 1;
            else a = mid + 1;
        }
        if (isBadVersion(n)) return n;
        return -1;
    }
};
```

## [283. 移动零](https://leetcode-cn.com/problems/move-zeroes/)

### 思路
1. 冒泡排序的思想，不过条件换成左边的数是0，则交换一次
2. 双指针，从左往右遍历

### AC代码

```c++
class Solution {
public:
    void moveZeroes(vector<int>& nums) {
        int len = nums.size();
        for (int i = len - 1; i >= 0; i--) {
            for (int j = len - 2; j >= 0; j--) {
                if (nums[j] == 0) {
                    int temp = nums[j];
                    nums[j] = nums[j + 1];
                    nums[j + 1] = temp;
                }
            }
        }
    }
};
```

```c++
class Solution {
public:
    void moveZeroes(vector<int>& nums) {
        int len = nums.size();
        int pos = 0;
        for (int i = 0; i < len; i++) {
            if (nums[i] != 0) {
                nums[pos++] = nums[i];
            }
        }
        for (int i = pos; i < len; i++) {
            nums[i] = 0;
        }
    }
};
```

## [290. 单词模式](https://leetcode-cn.com/problems/word-pattern/)

### 思路
1. 建立两个map，验证映射是一一映射
2. 如果当前值在a->b且b->a的映射都是空，那么添加这两个映射
3. 如果有一个是存在的，看两个映射的结果与当前值是否相等，不相等返回false
4. 循环安全结束，返回true
### AC代码
```c++
class Solution {
public:
    bool wordPattern(string pattern, string str) {
        unordered_map<char, string> m;
        unordered_map<string, char> n;
        vector<string> strs;
        stringstream ss(str);
        string buf;
        while (ss >> buf) {
            strs.push_back(buf);
        }
        if (strs.size() != pattern.length()) return false;
        int len = pattern.length();
        for (int i = 0; i < len; i++) {
            if (m[pattern[i]] == "" && n[strs[i]] == 0) {
                m[pattern[i]] = strs[i];
                n[strs[i]] = pattern[i];
            } else {
                if (m[pattern[i]] != strs[i] || n[strs[i]] != pattern[i]) {
                    return false;
                }
            }
        }
        return true;
    }
};
```
## [303. 区域和检索 - 数组不可变](https://leetcode-cn.com/problems/range-sum-query-immutable/)

### 思路
题目保证数组不会改变，且要多次调用sumRange()，采用以下方法提高效率
1. 类比数列的知识，创建一个vector，存放前i项和
2. 在构造对象时，变量一遍数组O(N)，得到所有的前n项和
3. 每次调用函数时，直接返回两个`sj`和`si-1`的差即可
4. 为了减少if-else的执行，数据的第一个地方存一个0，这样返回`sj+1` - `si`即可
### AC代码
```c++
class NumArray {
public:
    vector<int> s;
    NumArray(vector<int> nums) {
        int sum = 0;
        int len = nums.size();
        s.push_back(0);
        for (int i = 0; i < nums.size(); i++) {
            sum += nums[i];
            s.push_back(sum);
        }
    }
    
    int sumRange(int i, int j) {
        return s[j + 1] - s[i];
    }
};
```
## [326. 3的幂](https://leetcode-cn.com/problems/power-of-three/)

### 思路
1. 看3^log3(n)取整 是否等于n本身
2. 用到了数论的知识，3的幂次的质因子只有3，而所给出的n如果也是3的幂次，故而题目中所给整数范围内最大的3的幂次的因子只能是3的幂次，1162261467是3的19次幂，是整数范围内最大的3的幂次

### AC代码
```c++
class Solution {
public:
    bool isPowerOfThree(int n) {
        if (n <= 0) return false;
        return (int)pow(3, round((log(n) / log(3)))) == n;
    }
};
```
```c++
class Solution {
public:
    bool isPowerOfThree(int n) {
        return n > 0 && 1162261467%n == 0;
    }
};
```
## [342. 4的幂](https://leetcode-cn.com/problems/power-of-four/)

### 思路
1. 看以log2(num)是否为偶数
2. 查看二进制的所有奇数位，全是0即可（参见二进制转10进制公式，奇数为上的2的指数都是奇数）
### AC代码

```c++
class Solution {
  public:
    bool isPowerOfFour(long long num) {
        double n = log2(num);
        return (int)n == n ? (int)n % 2 == 0 : false;
    }
};
```
```c++
class Solution {
  public:
    bool isPowerOfFour(long long num) {
        if (num < 0 || num & (num-1)){//check(is or not) a power of 2.
            return false;
        }
        return num & 0x55555555;//check 1 on odd bits
    }
};
```
## [344. 反转字符串](https://leetcode-cn.com/problems/reverse-string/)

### AC代码
```c++
class Solution {
public:
    void reverseString(vector<char>& s) {
        reverse(s.begin(), s.end());
    }
};
```

## [345. 反转字符串中的元音字母](https://leetcode-cn.com/problems/reverse-vowels-of-a-string/)

### AC代码
```c++
class Solution {
public://双指针法
    string reverseVowels(string s) {
        int left = 0;
        int right = s.length() - 1;
        char m[128] = {0};
        m['a'] = 1;
        m['e'] = 1;
        m['i'] = 1;
        m['o'] = 1;
        m['u'] = 1;
        m['A'] = 1;
        m['E'] = 1;
        m['O'] = 1;
        m['I'] = 1;
        m['U'] = 1;
        while (left < right) {
            while (left < right && !m[s[left]]) left++;
            while (left < right && !m[s[right]]) right--;
            //加上left<right的判断 条件，防止把换过来的字母换回去
            char m = s[left];
            s[left] = s[right];
            s[right] = m;
            left++;
            right--;
        }
        return s;
    }
};
```

## [349. 两个数组的交集](https://leetcode-cn.com/problems/intersection-of-two-arrays/)

### 思路
1. 先把两个数组排序去重，然后map记录出现次数，然后把出现次数大于1的挑出来作为返回值返回
### AC代码

```c++
class Solution {
public:
    vector<int> intersection(vector<int>& nums1, vector<int>& nums2) {
        unordered_map<int, int> m;
        vector<int> v;
        sort(nums1.begin(), nums1.end());
        nums1.erase(unique(nums1.begin(), nums1.end()), nums1.end());
        sort(nums2.begin(), nums2.end());
        nums2.erase(unique(nums2.begin(), nums2.end()), nums2.end());
        for (int x : nums1) {
            m[x]++;
        }
        for (int x : nums2) {
            m[x]++;
        }
        for (auto x : m) {
            if (x.second > 1) 
                v.push_back(x.first);
        }
        return v;
    }
};
```
