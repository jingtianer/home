---
title: LeetCode-15
date: 2022-10-22 21:15:36
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## [904. 水果成篮](https://leetcode.cn/problems/fruit-into-baskets/)

```c++
class Solution {
public:
    int totalFruit(vector<int>& fruits) {
        int len = fruits.size();
        vector<int> v(len);
        int i = 0;
        int cur = fruits[i];
        i++;
        int max_diff = 1;
        int typea = fruits[0], typeb = -1, typec = -1;
        vector<int> last(len+1);
        int curr = 0;
        int j = 1;
        while(j < len) {
            while(j < len && fruits[j] == fruits[curr]) {
                j++;
            }
            last[j] = curr;
            curr = j;
            j++;
        }
        while(i < len) {
            int diff = 1;
            typeb = typec = -1;
            while(i < len) {
                if(fruits[i] != typea && fruits[i] != typeb) {
                    if(typeb == -1) {
                        typeb = fruits[i];
                    } else if(typec == -1) {
                        typec = fruits[i];
                    }
                }
                if(typec == -1) {
                    diff++;
                } else {
                    break;
                }
                i++;
            }
            max_diff = diff > max_diff ? diff : max_diff;
            if(i-1 >= 0 && i < len){
                typea = fruits[i-1];
                i = last[i]+1;
            }
        }
        return max_diff;
    }
};
```

> 想法很简单，就是从左往右遍历，数当前遇到了几种水果，当遇到第三种水果后，更新一下装入水果的最大值，三种水果记录为typea, typeb, typec
> 然后回溯，找到前一个节点在左侧最后一个typea后第一次出现的位置（其实也是typea最后出现的位置的后两个位置）

### 优化(空间，放弃last数组)
```c++
class Solution {
public:
    int totalFruit(vector<int>& fruits) {
        int len = fruits.size();
        vector<int> v(len);
        int i = 0;
        int cur = fruits[i];
        i++;
        int max_diff = 1;
        int typea = fruits[0], typeb = -1, typec = -1;
        while(i < len) {
            int diff = 1;
            typeb = typec = -1;
            int lasta = i-1, lastb = 0;
            while(i < len) {
                if(fruits[i] != typea && fruits[i] != typeb) {
                    if(typeb == -1) {
                        typeb = fruits[i];
                    } else if(typec == -1) {
                        typec = fruits[i];
                    }
                }
                if(fruits[i] == typea) {
                    lasta = i;
                } else if(fruits[i] == typeb) {
                    lastb = i;
                }
                if(typec == -1) {
                    diff++;
                } else {
                    break;
                }
                i++;
            }
            max_diff = diff > max_diff ? diff : max_diff;
            if(i-1 >= 0 && i < len){
                if(fruits[i-1] == typea) {
                    i = lastb + 2;
                } else if(fruits[i-1] == typeb) {
                    typea = typeb;
                    i = lasta + 2;
                }
                // printf("%d, %d, %d\n", i, lasta, lastb);
            }
        }
        return max_diff;
    }
};
```

## [1441. 用栈操作构建数组](https://leetcode.cn/problems/build-an-array-with-stack-operations/)

```c++
class Solution {
public:
    vector<string> buildArray(vector<int>& target, int n) {
        int cur = 0;
        int len = target.size();
        vector<string> ret;
        for(int i = 0; i < len; i++) {
            int diff = target[i] - cur;
            cur = target[i];
            if(diff > 1) {
                for(int j = 0; j < diff-1; j++) {
                    ret.push_back("Push");
                    ret.push_back("Pop");
                }
            }
            ret.push_back("Push");
        }
        return ret;
    }
};
```

### 优化，使用emplace_back()
push_back()方法要调用构造函数和复制构造函数，这也就代表着要先构造一个临时对象，然后把临时的copy构造函数拷贝或者移动到容器最后面。
而emplace_back()在实现时，则是直接在容器的尾部创建这个元素，省去了拷贝或移动元素的过程。
```c++
class Solution {
public:
    vector<string> buildArray(vector<int>& target, int n) {
        int cur = 0;
        int len = target.size();
        vector<string> ret;
        for(int i = 0; i < len; i++) {
            int diff = target[i] - cur - 1;
            cur = target[i];
            for(int j = 0; j < diff; j++) {
                ret.emplace_back("Push");
                ret.emplace_back("Pop");
            }
            ret.emplace_back("Push");
        }
        return ret;
    }
};
```

## [769. 最多能完成排序的块](https://leetcode.cn/problems/max-chunks-to-make-sorted/)

```c++
class Solution {
public:
    int maxChunksToSorted(vector<int>& arr) {
        int count = 0;
        int len = arr.size();
        int maxx = 0;
        for(int i = 0; i < len; i++) {
            if(arr[i] >= maxx) {
                maxx = arr[i];
            }
            if(maxx == i) {
                count++;
            }
        }
        return count;
    }
};
```

> 如果在找到下一个最大值之前，当前最大值能找到最大位置，则存在一个组

## [940. 不同的子序列 II](https://leetcode.cn/problems/distinct-subsequences-ii/)

comming soon

## [902. 最大为 N 的数字组合](https://leetcode.cn/problems/numbers-at-most-n-given-digit-set/)

```c++
class Solution {
public:
    vector<int> digitscount;
    int len;
    int bit;
    int hasdigit[10] = {0};
    int atMostNGivenDigitSet(vector<string>& digits, int n) {
        digitscount = vector<int>(11);
        string nstr = toString(n);
        bit = nstr.size();
        len = digits.size();
        for(int i = 0; i < len; i++) {
            hasdigit[digits[i][0]-'0']=1;
        }
        digitscount[digits[0][0]-'0'+1]++;
        for(int i = 1; i < len; i++) {
            for(int j = digits[i-1][0]-'0'+1; j <= digits[i][0]-'0'; j++) {
                digitscount[j+1] = digitscount[j];
            }
            digitscount[digits[i][0]-'0'+1]++;
        }
        for(int i =  digits[len-1][0]-'0'+1; i < 10; i++) {
            digitscount[i+1] = digitscount[i];
        }
        int count = 0;
        if(len == 1) {
            count = bit-1;
        } else {
            count = len*(1-pow(len, bit-1))/(1-len);
        }
        return count + cal(bit-1, digits, nstr);
    }
    int cal(int i, vector<string>& digits, string& nstr) {
        if(i < 0) return 1;
        int x = digitscount[nstr[i]-'0'];
        return x*pow(len, i) + hasdigit[nstr[i]-'0']*cal(i-1, digits, nstr);
    }
    long long pow(long long x, long long n) {
        long long res = 1;
        while(n) {
            if(n&1){
                res *= x;
            }
            n /= 2;
            x *= x;
        }
        return res;
    }
    string toString(int n) {
        string ret = "";
        while(n) {
            ret.push_back(n%10 + '0');
            n/=10;
        }
        return ret;
    }
};
```

> 思想很简单，首先有n个数字可以用，每个数字使用次数不限，所以求指数
> 目标数字是n位数，那么任意的1位数到n-1位数的任意组合都是可以使用的
> 对于n位数的情况，逐次考虑每一位，对于第i位，
>   1. 若第i位使用的数字小于目标数字的第i位，后面的数字可以任意组合
>   2. 若第i位使用的数字等于目标数字的第i位（前提是digits数组中有这个数），则 $ 1 \times (第i+1位) $ 的情况
> 
> 两种情况之和就是结果

- 需要注意的是，pow使用long long防止结果溢出


### 优化
- 避免反复使用pow函数
- 当hasdigit已经是0了，无需后续计算

```c++
class Solution {
public:
    vector<int> digitscount;
    int len;
    int bit;
    int hasdigit[10] = {0};
    int atMostNGivenDigitSet(vector<string>& digits, int n) {
        digitscount = vector<int>(11);
        string nstr = toString(n);
        bit = nstr.size();
        len = digits.size();
        for(int i = 0; i < len; i++) {
            hasdigit[digits[i][0]-'0']=1;
        }
        digitscount[digits[0][0]-'0'+1]++;
        for(int i = 1; i < len; i++) {
            for(int j = digits[i-1][0]-'0'+1; j <= digits[i][0]-'0'; j++) {
                digitscount[j+1] = digitscount[j];
            }
            digitscount[digits[i][0]-'0'+1]++;
        }
        for(int i =  digits[len-1][0]-'0'+1; i < 10; i++) {
            digitscount[i+1] = digitscount[i];
        }
        int count = 0;
        if(len == 1) {
            count = bit-1;
        } else {
            count = len*(1-pow(len, bit-1))/(1-len);
        }
        return count + cal(bit-1, digits, nstr, pow(len, bit-1));
    }
    int cal(int i, vector<string>& digits, string& nstr, int power) {
        if(i < 0) return 1;
        int x = digitscount[nstr[i]-'0'];
        if(hasdigit[nstr[i]-'0'] == 0) {
            return x*power;
        }
        return x*power + hasdigit[nstr[i]-'0']*cal(i-1, digits, nstr, power/len);
    }
    long long pow(long long x, long long n) {
        long long res = 1;
        while(n) {
            if(n&1){
                res *= x;
            }
            n /= 2;
            x *= x;
        }
        return res;
    }
    string toString(int n) {
        string ret = "";
        while(n) {
            ret.push_back(n%10 + '0');
            n/=10;
        }
        return ret;
    }
};
```
> 快速幂算法：
>   - 从代码反推可知，实际上把n看作二进制数
>   - 假设$ n = 110011001b $ ，则$ x^n = x + x^8 + x^{16} + x^{128} + x^{256} $
>   - 等价于$$ \sum_0^n n_i \times x^{2^i} (i从右到左为0,1,2...) $$


## [817. 链表组件](https://leetcode.cn/problems/linked-list-components/)

```c++
class Solution {
public:
    int numComponents(ListNode* head, vector<int>& nums) {
        bool m[10005] = {false};
        for(int num : nums) {
            m[num] = true;
        }
        int component_count  = 0;
        while(head != nullptr && !m[head->val]) {
            head = head->next;
        }
        while(head) {
            while(head != nullptr && m[head->val]) {
                head = head->next;
            }
            while(head != nullptr && !m[head->val]) {
                head = head->next;
            }
            component_count++;
        }
        return component_count;
    }
};
```
> 适当展开循环，可以减少不必要的判断

## [1790. 仅执行一次字符串交换能否使两个字符串相等](https://leetcode.cn/problems/check-if-one-string-swap-can-make-strings-equal/)

```c++
class Solution {
public:
    bool areAlmostEqual(string s1, string s2) {
        int len = s1.size();
        if(s2.size() != len) return false;
        if(s1 == s2) return true;
        int diff1 = -1;
        for(int i = 0; i < len; i++) {
            if(s1[i] != s2[i]) {
                if(diff1 == -1) {
                    diff1 = i;
                } else {
                    char a = s2[diff1];
                    s2[diff1] = s2[i];
                    s2[i] = a;
                    return s1 == s2;
                }
            }
        }
        return false;
    }
};
```

- 可以轻易地用脚趾头想到，两个字符串只能有两处不同，长度相同
- 当找到第二个字符串后进行交换，如果交换后和s1相等，则ok，否则不ok

### 优化
- 防止重复比较diff1 与 diff2之间的字符
```c++
class Solution {
public:
    bool areAlmostEqual(string s1, string s2) {
        int len = s1.size();
        if(s2.size() != len) return false;
        if(s1 == s2) return true;
        int diff1 = -1;
        for(int i = 0; i < len; i++) {
            if(s1[i] != s2[i]) {
                if(diff1 == -1) {
                    diff1 = i;
                } else {
                    for(int j = i+1; j < len; j++) {
                        if(s1[j] != s2[j]) {
                            return false;
                        }
                    }
                    return s2[diff1] == s1[i] && s2[i] == s1[diff1];
                }
            }
        }
        return false;
    }
};
```

## [856. 括号的分数](https://leetcode.cn/problems/score-of-parentheses/)

```c++
class Solution {
public:
    int scoreOfParentheses(string s) {
        stack<int> score;
        int len = s.size();
        score.push(0);
        for(int i = 0; i < len; i++) {
            if(s[i] == '(') {
                score.push(0);
            } else {
            	int sc1 = score.top();
            	score.pop();
            	int sc2 = score.top();
            	score.pop();
            	if(sc1 == 0) {
                	sc1+=1;
            	} else {
                	sc1*=2;
            	}
            	score.push(sc1+sc2);
            }
        }
        return score.top();
    }
};
```

> 进行栈的模拟，遇到左括号push一个0，表示该左括号内部的平衡括号分数总和
> 当遇到一个右括号，pop一个score，如果是0，说明是`()`，则对该score+1，如果不是0，则该score乘以2
> 从栈中再pop一个score记为score2，score2与score相加后入栈
> 为了防止最外端的括号无法取出两个score，在遍历s前先push一个0
> 最终栈顶元素就是最后结果

## [1700. 无法吃午餐的学生数量](https://leetcode.cn/problems/number-of-students-unable-to-eat-lunch/)
```c++
class Solution {
public:
    int countStudents(vector<int>& students, vector<int>& sandwiches) {
        queue<int> stuqueue;
        int len = students.size();
        for(int i = 0; i < len; i++) {
            stuqueue.push(students[i]);
        }
        for(int i = 0; i < len; i++) {
            int count = 0;
            while(count < len && stuqueue.front() != sandwiches[i]) {
                int front = stuqueue.front();
                stuqueue.pop();
                stuqueue.push(front);
                count++;
            }
            if(count == len) return stuqueue.size();
            stuqueue.pop();
        }
        return stuqueue.size();
    }
};
```

## 优化，直接模拟效率太低了
```c++
class Solution {
public:
    int countStudents(vector<int>& students, vector<int>& sandwiches) {
        int len = students.size();
        int s1 = accumulate(students.begin(), students.end(), 0);
        int s0 = len - s1;
        for(int i = 0; i < len; i++) {
            if(sandwiches[i] == 0 && s0 != 0) {
                s0--;
            } else if(sandwiches[i] == 1 && s1 != 0) {
                s1--;
            } else {
                return s0+s1;
            }
        }
        return s0+s1;
    }
};
```

1. 当学生无法拿栈顶的东西时，一定是因为剩下的所有人都不吃当前栈顶元素。
2. 与队列的先后顺序无关
3. 从栈顶到栈底，遇到某个食物只要在队列里随便找一个学生就好了。如果恰好能吃完，则返回0，如果遇到某个食物没人吃了，就返回剩下的人数。

> 根据题意，我们可以知道栈顶的三明治能否被拿走取决于队列剩余的学生中是否有喜欢它的.

只要当前栈顶的东西学生不喜欢，就会一直向后排队，直到出现喜欢的东西为止，所以可以不考虑当前队列的顺序。


## [779. 第K个语法符号](https://leetcode.cn/problems/k-th-symbol-in-grammar/)

```c++
class Solution {
public:
    int kthGrammar(int n, int k) {
        stack<int> route;
        while(k>1) {
            route.push(k%2);
            k = k%2 + k/2;
        }
        //route.push(1);
        string a = "01",b = "10";
        string cur = a;
        int next = 0;
        while(!route.empty()) {
            if(cur[next] == '0') {
                cur = a;
            } else {
                cur = b;
            }
            next=1-route.top();
            route.pop();
        }
        return cur[next]-'0';
    }
};
```

> 类似完全二叉树的思想，10的父节点是1，01的父节点是0
> 比如需要第n行的第k个，那么其父节点是第n-1行第$ \lceil n/2 \rceil = n/2 + n\%2 $个数
> 由于只有0和1两种情况，对于k，如果k%2 == 1,则是其父节点的左子节点，否则是右子节点
> 故可以计算 $ (\lceil n/2 \rceil)\%2 $，依次找到根节点，根节点一定是0，stack中最后一个数一定是1
> 则从0生成01，再根据stack中剩下的数，如果是1，则是01的左节点0，又生成01；如果是0，则是01的右节点1，生成10，用这种方法逐渐生成到叶节点
> 以k=14为例，祖先依次是7，4，2，1，stack中依次是，1，0，0，1，0
> 则 0 -> 01 -> 10 -> 01 -> 01 -> 1

<font color="red">0</font>
<font color="yellow">0</font><font color="red">1</font>
01<font color="yellow">1</font><font color="red">0</font>
011010<font color="red">0</font><font color="yellow">1</font>
011010011001<font color="yellow">0</font><font color="red">1</font>10

> 这个算法甚至不需要用n这个参数

### 优化-使用位运算
```c++
class Solution {
public:
    int kthGrammar(int n, int k) {
        stack<int> route;
        while(k>1) {
            route.push(k%2);
            k = k%2 + k/2;
        }
        int cur = 0x01;
        int next = 1;
        while(!route.empty()) {
            cur = (cur >> next)&0x01;
            if(cur == 0) {
                cur = 0x01;
            } else {
                cur = 0x02;
            }
            next=route.top();
            route.pop();
        }
        return (cur>>next)&0x01;
    }
};
```

## [524. 通过删除字母匹配到字典里最长单词](https://leetcode.cn/problems/longest-word-in-dictionary-through-deleting/)

```c++
class Solution {
public:
    string findLongestWord(string s, vector<string>& dictionary) {
        // sort(dictionary.begin(), dictionary.end());
        int lend = dictionary.size();
        int lens = s.size();
        int maxlen = 0;
        string maxstr = "";
        for(int i = 0; i < lend; i++) {
            int j = 0, k = 0;
            int leni = dictionary[i].size();
            for(; k < leni && j < lens; j++) {
                if(s[j] == dictionary[i][k]) k++;
            }
            if(leni >= maxlen && k >= leni) {
                if(maxlen == leni) {
                    maxstr = dictionary[i] > maxstr ? maxstr : dictionary[i];
                } else {
                    maxstr = dictionary[i];
                }
                maxlen = leni;
            }
        }
        return maxstr;
    }
};
```

> 暴力，干就完了

### 优化(抄答案就完事)
```python
class Solution:
    def findLongestWord(self, s: str, dictionary: List[str]) -> str:
        m = len(s)
        f = [[0] * 26 for _ in range(m)]
        f.append([m] * 26)

        for i in range(m - 1, -1, -1):
            for j in range(26):
                if ord(s[i]) == j + 97:
                    f[i][j] = i
                else:
                    f[i][j] = f[i + 1][j]
        print(f)
        res = ""
        for t in dictionary:
            match = True
            j = 0
            for i in range(len(t)):
                if f[j][ord(t[i]) - 97] == m:
                    match = False
                    break
                j = f[j][ord(t[i]) - 97] + 1
            if match:
                if len(t) > len(res) or (len(t) == len(res) and t < res):
                    res = t
        return res
```

> 大概就是生成一个表，如果f[i][j]不是m，就表示第i位或第i位之后可以取到这个字符
> 为了保证按照顺序使用字母表s中的字符，j=f[i][j]，表示下一次要从这个位置开始取字符

## 81. [搜索旋转排序数组 II](https://leetcode.cn/problems/search-in-rotated-sorted-array-ii/)

```c++
class Solution {
public:
    bool search(vector<int>& nums, int target) {
        int len = nums.size();
        int k = 1;
        for(int i = 1; i < len; i++, k++) {
            if(nums[i] < nums[i-1]) {
                break;
            }
        }
        k = len - k;
        // cout << k << endl;
        int l = 0, r = len;
        while(l <= r) {
            int mid = (r - l)/2 + l;
            // cout << nums[(mid - k + len)%len] << endl;
            if(target == nums[(mid - k + len)%len]) {
                return true;
            } else if(target < nums[(mid - k + len)%len]) {
                r = mid-1;
            } else {
                l = mid+1;
            }
        }
        // cout << l << r << endl;
        return target == nums[(r - k + len)%len] || target == nums[(l - k + len)%len];
    }
};
```

> O(n)的算法不太好

## 优化
```c++
class Solution {
public:
    bool search(vector<int> &nums, int target) {
        int n = nums.size();
        if (n == 0) {
            return false;
        }
        if (n == 1) {
            return nums[0] == target;
        }
        int l = 0, r = n - 1;
        while (l <= r) {
            int mid = (l + r) / 2;
            if (nums[mid] == target) {
                return true;
            }
            if (nums[l] == nums[mid] && nums[mid] == nums[r]) {
                ++l;
                --r;
            } else if (nums[l] <= nums[mid]) {
                if (nums[l] <= target && target < nums[mid]) {
                    r = mid - 1;
                } else {
                    l = mid + 1;
                }
            } else {
                if (nums[mid] < target && target <= nums[n - 1]) {
                    l = mid + 1;
                } else {
                    r = mid - 1;
                }
            }
        }
        return false;
    }
};
```

> 分成了两个递增区间，左边较大的和右边较小的
> 如果mid落在左边区间，如果mid大于target 且 target也落在较大的区间，向左移动，否则向右移动
> 如果mid落在右边区间，如果mid小于target 且 target也落在较大的区间，向右移动，否则向左移动
> 如果特殊情况[1,1,0,1,1,1]，则直接缩小区间大小，逐渐逼近

## [540. 有序数组中的单一元素](https://leetcode.cn/problems/single-element-in-a-sorted-array/)

```c++
class Solution {
public:
    int singleNonDuplicate(vector<int>& nums) {
        int len = nums.size();
        int l = 0, r = len;
        while(l <= r) {
            int mid = (r - l)/2 + l;
            if(mid%2 == 0) {
                if(mid > 0 && nums[mid-1] == nums[mid]) {
                    r = mid-1;
                    continue;
                }
                if (mid < len-1 && nums[mid+1] == nums[mid]) {
                    l = mid+1;
                    continue;
                }
                return nums[mid];
            } else {
                if(mid > 0 && nums[mid-1] == nums[mid]) {
                    l = mid+1;
                    continue;
                }
                if (mid < len-1 && nums[mid+1] == nums[mid]) {
                    r = mid-1;
                    continue;
                }
                return nums[mid];
            }
        }
        return nums[l];
    }
};
```

> 如果下标是偶数，如果左边没有单个数字，那么我右边应该和我一样，那么单个数字就在我右边，否则就在我左边
> 如果下标是奇数，如果左边没有单个数字，那么我左边应该和我一样，那么单个数字就在我右边，否则就在我左边

## 优化
如果mid是奇数，处理成偶数
```c++
class Solution {
public:
    int singleNonDuplicate(vector<int>& nums) {
        int len = nums.size();
        int l = 0, r = len-1;
        while(l < r) {
            int mid = (r - l)/2 + l;
            mid -= mid & 1;
            if (nums[mid+1] == nums[mid]) {
                l = mid+2;
            } else {
                r = mid;
            }
        }
        return nums[l];
    }
};
```

## [154. 寻找旋转排序数组中的最小值 II](https://leetcode.cn/problems/find-minimum-in-rotated-sorted-array-ii/)

```c++
class Solution {
public:
    int findMin(vector<int>& nums) {
        int len = nums.size();
        if (len == 1) {
            return nums[0];
        }
        if (len == 2) {
            return min(nums[0], nums[1]);
        }
        int l = 0, r = len-1;
        while (l <= r) {
            int mid = (l + r) / 2;
            if (nums[l] == nums[mid] && nums[mid] == nums[r]) {
                ++l;
                --r;
            } else if (nums[l] <= nums[mid]) {
                if(nums[mid] <= nums[r]) return nums[l];
                if(mid < len-1) {
                    if (nums[mid] <= nums[mid+1]) {
                        l = mid + 1;
                    } else {
                        return nums[mid+1];
                    }
                } else {
                    return nums[mid];
                }
                
            } else {
                if(mid > 0) {
                    if (nums[mid] < nums[mid-1]) {
                        return nums[mid];
                    } else {
                        r = mid -1;
                    }
                } else {
                    return nums[mid];
                }
            }
        }
        return nums[r];
    }
};
```

### 优化，去掉不必要的判断

```c++
class Solution {
public:
    int findMin(vector<int>& nums) {
        int len = nums.size();
        int l = 0, r = len-1;
        while (l < r) {
            int mid = (l + r) / 2;
            if (nums[l] == nums[mid] && nums[mid] == nums[r]) {
                ++l;
                --r;
            } else if (nums[l] <= nums[mid]) {
                if(nums[mid] <= nums[r]) return nums[l];
                if (nums[mid] <= nums[mid+1]) {
                    l = mid + 1;
                } else {
                    return nums[mid+1];
                }
                
            } else {
                if (nums[mid] < nums[mid-1]) {
                    return nums[mid];
                } else {
                    r = mid -1;
                }
            }
        }
        return nums[r];
    }
};
```

### 题解思路

```c++
class Solution {
public:
    int findMin(vector<int>& nums) {
        int len = nums.size();
        int l = 0, r = len-1;
        while (l < r) {
            int mid = (l + r) / 2;
            if (nums[mid] == nums[r]) {
                --r;
            } else if (nums[r] <= nums[mid]) {
                l = mid + 1;
            } else {
                r = mid;
            }
        }
        return nums[r];
    }
};
```
> 不需要关注左边的情况，之前的代码比较对称，可以看出可以简化
> mid比r大，说明落在了左侧较大的区间，右移
> 如果mid比r小，说明落在了右侧的较小区间，左移，但不确定我是不是最小值，故r=mid不减1

## [901. 股票价格跨度](https://leetcode.cn/problems/online-stock-span/)

```c++
class StockSpanner {
public:
    vector<int> stocks;
    int len;
    StockSpanner() {
        len = 0;
    }
    
    int next(int price) {
        stocks.push_back(price);
        len++;
        int m = 0;
        for(int i = len-1; i >= 0; i--) {
            if(stocks[i] <= price) {
                m++;
            } else {
                break;
            }
        }
        return m;
    }
};
```

> 显然太慢了

### 优化
```c++
class StockSpanner {
public:
    vector<int> peak;
    vector<int> stocks;
    int len;
    int peaklen;
    int l1, l2;
    StockSpanner() {
        len = 0;
        peaklen = 0;
    }
    
    int next(int price) {
        len++;
        stocks.push_back(price);
        if(len == 1) {
            return 1;
        }
        if(len == 2) {
            if(stocks[len-2] > price) {
                peaklen++;
                peak.push_back(len-2);
            }
            return 1 + (stocks[len-2] <= price);
        }
        int a = stocks[len-1], b = stocks[len-2], c = stocks[len-3];
        if(b >= a && b > c) {
            peaklen++;
            peak.push_back(len-2);
        }
        int pk = peaklen-1;
        while(pk >= 0 && stocks[peak[pk]] <= price) {
            pk--;
        }
        if(pk < 0) {
            return len;
        }
        int i;
        for(i = peak[pk]; i < len && stocks[i] > price; i++) {
        }
        if(i == len-1) return 1;
        return len - i;
    }
};
```

> 股价的变化是波动的，会出现波峰和波谷，找到前一个比我大的波峰，向后查找，就可以找到对应的位置

### 再优化
找到波峰，还可以记录波谷，这样波峰波谷之间可以二分查找
```c++
class StockSpanner {
public:
    vector<pair<int, int>> peak;
    vector<int> stocks;
    int len;
    int peaklen;
    int valleylen;
    int l1, l2;
    StockSpanner() {
        len = 0;
        peaklen = 0;
        valleylen = 0;
    }
    
    int next(int price) {
        len++;
        stocks.push_back(price);
        if(len == 1) {
            return 1;
        }
        if(len == 2) {
            if(stocks[len-2] > price) {
                peaklen++;
                peak.push_back(pair<int,int>(len-2, INT_MAX));
            }
            return 1 + (stocks[len-2] <= price);
        }
        int a = stocks[len-1], b = stocks[len-2], c = stocks[len-3];
        if(b >= a && b > c) {
            peaklen++;
            peak.push_back(pair<int, int>(len-2, INT_MAX));
        } else if(b <= a && b < c) {
            peak[peaklen-1].second = len-2;
        }
        int pk = peaklen-1;
        while(pk >= 0 && stocks[peak[pk].first] <= price) {
            pk--;
        }
        if(pk < 0) {
            return len;
        }
        if(peak[pk].second == INT_MAX) return 1;
        auto ite = lower_bound(stocks.begin()+peak[pk].first,stocks.begin()+peak[pk].second+1,price, greater<int>());
        if(ite == stocks.end()) return 1;
        return stocks.end() - ite;
    }
};
```
> debug没de出来
### 看答案
```c++
class StockSpanner {
public:
    StockSpanner() {
        this->stk.emplace(-1, INT_MAX);
        this->idx = -1;
    }
    
    int next(int price) {
        idx++;
        while (price >= stk.top().second) {
            stk.pop();
        }
        int ret = idx - stk.top().first;
        stk.emplace(idx, price);
        return ret;
    }

private:
    stack<pair<int, int>> stk; 
    int idx;
};
```

> 好像是一样的思路，但是我像个傻子

## [347. 前 K 个高频元素](https://leetcode.cn/problems/top-k-frequent-elements/)

```c++
class Solution {
public:
    vector<int> topKFrequent(vector<int>& nums, int k) {
        unordered_map<int, int> frequent;
        int len = nums.size();
        for(int i = 0; i < len; i++) {
            frequent[nums[i]]++;
        }
        sort(nums.begin(), nums.end(), [&](int a, int b) -> bool {
            if(frequent[a] != frequent[b]) {
                return frequent[a] > frequent[b];
            }
            return a < b;
        });
        vector<int> res;
        res.push_back(nums[0]);
        int count = 1;
        for(int i = 1; count < k; i++) {
            if(nums[i] != nums[i-1]) {
                res.push_back(nums[i]);
                count++;
            }
        }
        return res;
    }
};
```

### 优化
三次遍历
```c++
class Solution {
public:
    vector<int> topKFrequent(vector<int>& nums, int k) {
        unordered_map<int, int> frequent;
        map<int, set<int>> inv;
        int len = nums.size();
        for(int i = 0; i < len; i++) {
            frequent[nums[i]]++;
        }
        for(int i = 0; i < len; i++) {
            inv[frequent[nums[i]]].insert(nums[i]);
        }
        vector<int> res;
        int count = 0;
        for(auto ite = inv.rbegin(); ite != inv.rend() && count < k; ite++) {
            for(auto jte = ite->second.begin(); jte != ite->second.end(); jte++) {
                res.push_back(*jte);
                count++;
            }
        }
        return res;
    }
};
```