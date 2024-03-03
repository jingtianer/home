---
title: LeetCode-21
date: 2023-2-13 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## [1234. 替换子串得到平衡字符串](https://leetcode.cn/problems/replace-the-substring-for-balanced-string/)

```c++
class Solution {
public:
    bool isBalance(int* count, int avg) {
        return count['Q'] <= avg && count['R'] <= avg && count['E'] <= avg && count['W'] <= avg;
    }
    int balancedString(string s) {
        int count[128] = {0};
        for (char c : s) {
            count[c]++;
        }
        int len = s.length();
        int avg = len / 4;

        if (isBalance(count, avg)) {
            return 0;
        }
        int res = len;
        for (int l = 0, r = 0; l < len; l++) {
            while (r < len && !isBalance(count, avg)) {
                count[s[r]]--;
                r++;
            }
            if (!isBalance(count, avg)) {
                break;
            }
            res = min(res, r - l);
            count[s[l]]++;
        }
        return res;
    }
};
```

## [1138. 字母板上的路径](https://leetcode.cn/problems/alphabet-board-path/)

```c++
class Solution {
public:
    string alphabetBoardPath(string target) {
        int x = 0, y = 0;
        string res = "";
        for(char c : target) {
            int next_x = getX(c), next_y = getY(c);
            char step_x = 'L', step_y = 'U';
            int diff_x = x - next_x, diff_y = y - next_y;
            
            if(next_x > x) {
                step_x = 'R';
                diff_x = -diff_x;
            }
            if(next_y > y) {
                step_y = 'D';
                diff_y = - diff_y;
            }
            if(next_y == 5) {
                for(int i = 0; i < diff_x; i++) {
                    res += step_x;
                }
                for(int i = 0; i < diff_y; i++) {
                    res += step_y;
                }

            } else {
                for(int i = 0; i < diff_y; i++) {
                    res += step_y;
                }
                for(int i = 0; i < diff_x; i++) {
                    res += step_x;
                }
            }
            
            res += "!";
            x = next_x;
            y = next_y;
        }
        return res;
    }
    int getX(char c) {
        return (c - 'a') % 5;
    }
    int getY(char c) {
        return (c - 'a') / 5;
    }
};
```

> 如果默认先纵向走，再横向走，那么当从外部到z时，需要先横向走再纵向走
> 如果默认先横向走，再纵向走，那么当从z到外部时，需要先纵向走再横向走
>

## [2335. 装满杯子需要的最短总时长](https://leetcode.cn/problems/minimum-amount-of-time-to-fill-cups/)

```c++
class Solution {
public:
    int fillCups(vector<int>& amount) {
        int res = 0;
        int x,y;
        int minn = 0;
        if(amount[0] == 0 || amount[1] == 0 || amount[2] == 0) {
            if(amount[0] == 0) minn = 0;
            if(amount[1] == 0) minn = 1;
            if(amount[2] == 0) minn = 2;
        } else {
            if(amount[1] < amount[minn]) {
                minn = 1;
            }
            if(amount[2] < amount[minn]) {
                minn = 2;
            }
            int a,b;
            if(amount[(minn+1)%3] > amount[(minn + 3 - 1) % 3]) {
                a = (minn+1)%3;
                b = (minn + 3 - 1) % 3;
            } else {
                b = (minn+1)%3;
                a = (minn + 3 - 1) % 3;
            }
            res += amount[minn];
            int diff = min(amount[a] - amount[b], amount[minn]);
            amount[minn] -=  diff;
            amount[a] -= diff;
            amount[a] -= amount[minn]/2;
            amount[b] -= amount[minn] - amount[minn]/2;
            amount[minn] = 0;
        }
        res += max(amount[(minn + 3 - 1) % 3], amount[(minn+1)%3]);
        return res;
    }
};
```

> 假设初始状态，三杯水的需求量都大于0。选最少的一种，让他和另外两种水一起接，并且尽量让另外两杯水的需求量相近，处理好最少的一种后，最少的一种就变成了0
> 对于剩下的两中温度，操作数就是最大的那个温度
> 如果初始有一个为0，则将minn初始化为对应下标
> 由于只有3个，可以取余减少重复代码

## [1797. 设计一个验证系统](https://leetcode.cn/problems/design-authentication-manager/)

```c++
class AuthenticationManager {
public:
    unordered_map<string, int> live;
    int timeToLive;
    AuthenticationManager(int timeToLive) {
        this->timeToLive = timeToLive;
    }
    
    void generate(string tokenId, int currentTime) {
        live[tokenId] = currentTime + timeToLive;
    }
    
    void renew(string tokenId, int currentTime) {
        if(!live.count(tokenId) || live[tokenId] <= currentTime) return;
        live[tokenId] = currentTime + timeToLive;
    }
    
    int countUnexpiredTokens(int currentTime) {
        int count = 0;
        for(auto ite = live.begin(); ite != live.end(); ite++) {
            if(ite->second > currentTime) count++;
        }
        return count;
    }
};

```

## [1250. 检查「好数组」](https://leetcode.cn/problems/check-if-it-is-a-good-array/)

```c++
class Solution {
public:
    bool isGoodArray(vector<int>& nums) {
        int gcd_ = nums[0];
        int n = nums.size();
        for(int i = 0; i < n; i++) {
            gcd_ = gcd(nums[i], gcd_);
            if(gcd_ == 1) return true;
        }
        return false;
    }

    int gcd(int a, int b) {
        if(a < b) return gcd(b, a);
        if(b == 0) return a;
        return gcd(b, a%b);
    }
};
```

> 根据提示 $ Eq. ax+by=1 has solution x, y if gcd(a,b) = 1. $
> 只要整个数组的最大公约数为1，则可满足题意

## [1233. 删除子文件夹](https://leetcode.cn/problems/remove-sub-folders-from-the-filesystem/)

```c++
struct MTreeNode {
    unordered_map<string, MTreeNode*> childList;
};
class Solution {
public:
    vector<string> res;
    vector<string> removeSubfolders(vector<string>& folder) {
        MTreeNode * root = new MTreeNode();
        for(string& dir : folder) {
            vector<string> dirs = splitPath(dir);
            MTreeNode* move = root;
            int dir_len = dirs.size();
            for(int i = 0; i < dir_len; i++) {
                if(!move->childList.count(dirs[i])) {
                    move->childList[dirs[i]] = new MTreeNode();
                }
                move = move->childList[dirs[i]];
            }
        }

        for(string& dir : folder) {
            vector<string> dirs = splitPath(dir);
            MTreeNode* move = root;
            int dir_len = dirs.size();
            for(int i = 0; i < dir_len; i++) {
                if(!move->childList.count(dirs[i])) {
                    break;
                }
                move = move->childList[dirs[i]];
            }
            move->childList.clear();
        }
        
        dfs(root, "");
        return res;

    }
    void dfs(MTreeNode* root, string path) {
        if(root->childList.size() == 0) {
            res.push_back(path);
            return;
        }
        for(auto ite = root->childList.begin(); ite != root->childList.end(); ite++) {
            dfs(ite->second, path+"/"+ite->first);
        }
    }
    vector<string> splitPath(string s) {
        vector<string> path;
        int i = 0;
        int n = s.size();
        while(i < n) {
            string dir;
            while(i < n && s[i] == '/') i++;
            if(i < n) {
                while(i < n && s[i] != '/') {
                    dir.push_back(s[i]);
                    i++;
                }
                path.push_back(dir);
            }
        }
        return path;
    }
};
```

> 模拟，构造那棵树，删除，然后还原

```
执行用时：620 ms, 在所有 C++ 提交中击败了5.15%的用户
内存消耗：213.6 MB, 在所有 C++ 提交中击败了4.99%的用户
```

> 我不管，这是`O(n)`，就是最快的

```c++
class Solution {
public:
    vector<string> res;
    vector<string> removeSubfolders(vector<string>& folder) {
        sort(folder.begin(), folder.end());
        int cmp = 0;
        int i = 1, n = folder.size(), cmp_len = folder[cmp].length();
        res.push_back(folder[cmp]);
        for(; i < n; i++) {
            int j;
            for(j = 0; j < cmp_len && folder[cmp][j] == folder[i][j]; j++);
            if(j == cmp_len && folder[i][j] == '/') {
            } else {
                cmp = i;
                cmp_len = folder[cmp].length();
                res.push_back(folder[cmp]);
            }
        }
        return res;
    }
};
```

> 排序，比较
>

## [1210. 穿过迷宫的最少移动次数](https://leetcode.cn/problems/minimum-moves-to-reach-target-with-rotations/)
```c++
class Solution {
public:
    int minimumMoves(vector<vector<int>>& grid) {
        int n;
        n = grid.size();
        queue<pair<pair<int, int>, int>> que;
        if(n <= 0) return 0;
        vector<vector<vector<bool>>> visited(n, vector<vector<bool>>(n, vector<bool>(2, false)));
        que.push(make_pair(make_pair(0,0),0));
        int step = 0;
        while(!que.empty()) {
            queue<pair<pair<int, int>, int>> que_temp;
            while(!que.empty()) {
                auto [pos, ver] = que.front();
                auto [x, y] = pos;
                visited[x][y][ver] = true;
                que.pop();
                if(x == n-1 && y == n-2 && !ver) {return step;}
                if(ver) {
                    if(x+2 < n && !grid[x+2][y]) {
                        if(!visited[x+1][y][1]) {
                            que_temp.push(make_pair(make_pair(x+1,y),1));
                            visited[x+1][y][1] = true;
                        }
                    }
                    if(y+1 < n && x+1 < n && !grid[x][y+1] && !grid[x+1][y+1]) {
                        if(!visited[x][y][0]) {
                            que_temp.push(make_pair(make_pair(x,y),0));
                            visited[x][y][0] = true;
                        }
                        if(!visited[x][y+1][1]) {
                            que_temp.push(make_pair(make_pair(x,y+1),1));
                            visited[x][y+1][1] = true;
                        }
                    }
                } else {
                    if(y+2 < n && !grid[x][y+2]) {
                        if(!visited[x][y+1][0]) {
                            que_temp.push(make_pair(make_pair(x,y+1),0));
                            visited[x][y+1][0] = true;
                        }
                    }
                    if(y+1 < n && x+1 < n && !grid[x+1][y] && !grid[x+1][y+1]) {
                        if(!visited[x][y][1]) {
                            que_temp.push(make_pair(make_pair(x,y),1));
                            visited[x][y][1] = true;
                        }
                        if(!visited[x+1][y][0]) {
                            que_temp.push(make_pair(make_pair(x+1,y),0));
                            visited[x+1][y][0] = true;
                        }
                    }
                }
            }
            step++;
            que = que_temp;
        }
        return -1;
    }
};
```

> 经典的BFS

## [2341. 数组能形成多少数对](https://leetcode.cn/problems/maximum-number-of-pairs-in-array/)

```c++
class Solution {
public:
    vector<int> numberOfPairs(vector<int>& nums) {
        unordered_map<int, bool> m;
        int len = nums.size();
        for(int n:nums) {
            if(m.count(n)) {
                m[n] = !m[n];
            } else {
                m[n] = true;
            }
        }
        int res = 0;
        for(auto ite = m.begin(); ite != m.end(); ite++) {
            if(ite->second) {
                res++;
            }
        }
        return {(len - res) >> 1, res};
    }
};
```

## [1139. 最大的以 1 为边界的正方形](https://leetcode.cn/problems/largest-1-bordered-square/)
```c++
class Solution {
public:
    int largest1BorderedSquare(vector<vector<int>>& grid) {
        int m = grid.size(), n = grid[0].size();
        vector<vector<int>> up(m, vector<int>(n, 0)), down(m, vector<int>(n, 0)), left(m, vector<int>(n, 0)), right(m, vector<int>(n, 0));
        for(int i = 0; i < m; i++) {
            left[i][0] = grid[i][0];
            right[i][n-1] = grid[i][n-1];
            for(int j = 1; j < n; j++) {
                if(grid[i][j]) left[i][j] = left[i][j-1] + 1;
                else left[i][j] = 0;
                if(grid[i][n-1-j]) right[i][n-1-j] = right[i][n-j] + 1;
                else right[i][n-1-j] = 0;
            }
        }
        for(int i = 0; i < n; i++) {
            up[0][i] = grid[0][i];
            down[m-1][i] = grid[m-1][i];
            for(int j = 1; j < m; j++) {
                if(grid[j][i]) up[j][i] = up[j-1][i] + 1;
                else up[j][i] = 0;
                if(grid[m-1-j][i]) down[m-1-j][i] = down[m-j][i] + 1;
                else down[m-1-j][i] = 0;
            }
        }
        int maxx = 0;
        for(int i = 0; i < m; i++) {
            for(int j = 0; j < n; j++) {
                if(grid[i][j]) {
                    int diff = min(down[i][j], right[i][j]);
                    for(int l = 0; l < diff; l++) {
                        if(l-up[i+l][j+l]+1 <= 0 && l-left[i+l][j+l]+1 <= 0) {
                            maxx = max(maxx, l+1);
                        }
                    }
                }
            }
        }
        return maxx*maxx;
    }
};
```

> 记录上下左右四个方向从位置(i, j)开始连续的1的个数
> 对于一个为1的点，在其下方和右方有连续1的范围内的斜对角上的各点，如果斜对角线上各点的上方和左方能和(i,j)的下方和右方围成正方形，则更新最大值。

## [1663. 具有给定数值的最小字符串](https://leetcode.cn/problems/smallest-string-with-a-given-numeric-value/)

```c++
class Solution {
public:
    string getSmallestString(int n, int k) {
        string res(n, 'a'-1);
        for(int i = n-1; i >= 0; i--) {
            res[i] += min(26, k-i);
            k -= min(26, k-i);
        }
        return res;
    }
};
```

```c++
class Solution {
public:
    string getSmallestString(int n, int k) {
        string res(n, 'a');
        int i = n-1;
        k-=n;
        for( ; k >= 26; i--) {
            res[i] += 25;
            k -= 25;
        }
        res[i] += k;
        return res;
    }
};
```

## 1237. 找出给定方程的正整数解
### 暴力搜索
```c++
class Solution {
public:
    vector<vector<int>> findSolution(CustomFunction& customfunction, int z) {
        vector<vector<int>> res;
        int x, y;
        for(x = 1; x <= 1000; x++) {
            for(y = 1000; y > 1 && customfunction.f(x,y) > z; y--);
            if(customfunction.f(x,y) == z) {
                res.push_back({x, y});
            }
        }
        return res;
    }
};
```
### 二分查找
```c++
class Solution {
public:
    vector<vector<int>> findSolution(CustomFunction& customfunction, int z) {
        vector<vector<int>> res;
        int x, y;
        for(x = 1; x <= 1000; x++) {
            int l = 1, r = 1001;
            while(l <= r) {
                y = (r - l) / 2 + l;
                if(customfunction.f(x, y) == z) break;
                if(customfunction.f(x,y) > z) r = y-1;
                else l = y+1;
            }
            if(customfunction.f(x,y) == z) {
                res.push_back({x, y});
            }
        }
        return res;
    }
};
```
> 由于是增函数，则确定x，y可以二分


### 双指针
```c++
class Solution {
public:
    vector<vector<int>> findSolution(CustomFunction& customfunction, int z) {
        vector<vector<int>> res;
        int x = 1, y = 1000;
        for(x = 1; x <= 1000; x++) {
            int l = 1, r = 1001;
            for(; y > 1 && customfunction.f(x, y) > z; y--);
            if(customfunction.f(x,y) == z) {
                res.push_back({x, y});
            }
        }
        return res;
    }
};
```

> 由于是递增的，x增大y必然要减少

## [1792. 最大平均通过率](https://leetcode.cn/problems/maximum-average-pass-ratio/)

### 超时
```c++
class Solution {
public:
    double maxAverageRatio(vector<vector<int>>& classes, int extraStudents) {
        double res = 0;
        int len = classes.size();
        for(int i = 0; i < extraStudents; i++) {
            double max_res = 0;
            int p = 0;
            for(int j = 0; j < len; j++) {
                double diff = (classes[j][0]+1.0) / (classes[j][1] + 1) - 1.0*classes[j][0]/classes[j][1];
                if(diff > max_res) {
                    max_res = diff;
                    p = j;
                }
            }
            classes[p][0]++;
            classes[p][1]++;
            // cout << p << endl;
        }
        for(int j = 0; j < len; j++) {
            res += 1.0*classes[j][0]/classes[j][1];
        }
        return res / len;
    }
};
```

> 虽然错了，但是这里的思路是正确的
> 根据糖水不等式， $ (a+c)/(b+c) > b / a $
> 目标所有班级的糖水浓度之和的平均值最大，也就是浓度总和最大
> 每份糖应该加在能使得 $ diff = (a+c)/(b+c) - b / a $ 最大化的位置上

### 优先队列
```c++
struct cmp {
    bool operator()(pair<int, int> &a, pair<int, int>& b) {
        double diff_a = (a.first + 1.0) / (a.second + 1.0) - 1.0 * a.first / a.second;
        double diff_b = (b.first + 1.0) / (b.second + 1.0) - 1.0 * b.first / b.second;
        return diff_a < diff_b;
    }
};
class Solution {
public:
    double maxAverageRatio(vector<vector<int>>& classes, int extraStudents) {
        double res = 0;
        int len = classes.size();
        priority_queue<pair<int, int>, vector<pair<int, int>>, cmp> queue;
        for(int j = 0; j < len; j++) {
            queue.push(make_pair(classes[j][0], classes[j][1]));
        }
        for(int i = 0; i < extraStudents; i++) {
            auto [x, y] = queue.top();
            queue.pop();
            queue.push(make_pair(x+1, y+1));
        }
        while(!queue.empty()) {
            auto [x, y] = queue.top();
            queue.pop();
            res += 1.0*x/y;
        }
        return res / len;
    }
};
```
> 使用优先队列进行排序

### 用lambda

```c++
class Solution {
public:
    double maxAverageRatio(vector<vector<int>>& classes, int extraStudents) {
        double res = 0;
        int len = classes.size();
        auto diff = [&](int i) -> double {return (1.0+classes[i][0])/(1+classes[i][1]) - 1.0*classes[i][0]/classes[i][1];};
        auto cmp = [&](int i, int j) -> bool {return diff(i) < diff(j);};
        priority_queue<int, vector<int>, decltype(cmp)> queue(cmp);
        for(int j = 0; j < len; j++) {
            queue.push(j);
        }
        for(int i = 0; i < extraStudents; i++) {
            int j = queue.top();
            queue.pop();
            classes[j][0]++;
            classes[j][1]++;
            queue.push(j);
        }
        while(!queue.empty()) {
            int j = queue.top();
            queue.pop();
            res += 1.0*classes[j][0]/classes[j][1];
        }
        return res / len;
    }
};
```
> 用lambda反而更慢了，不过知道了`decltype`的一个用法

## [1824. 最少侧跳次数](https://leetcode.cn/problems/minimum-sideway-jumps/)
### 贪心
```c++
class Solution {
public:
    int minSideJumps(vector<int>& obstacles) {
        int n = obstacles.size() - 1;
        vector<vector<int>> obstacles_lane(n+1, vector<int>(3, 0));
        for(int i = 0; i < 3; i++) {
            obstacles_lane[n][i] = n+1;
        }
        for(int i = n-1; i >= 0; i--) {
            obstacles_lane[i][0] = obstacles_lane[i+1][0];
            obstacles_lane[i][1] = obstacles_lane[i+1][1];
            obstacles_lane[i][2] = obstacles_lane[i+1][2];
            if(obstacles[i] != 0) {
                obstacles_lane[i][obstacles[i]-1] = i;
            }
        }
        int jump = 0;
        for(int i = obstacles_lane[0][1]-1; i < n; ) {
            int max_lane = 0;
            for(int j = 1; j < 3; j++) {
                if(obstacles_lane[i][j] > obstacles_lane[i][max_lane]) {
                    max_lane = j;
                }
            }
            jump++;
            i = obstacles_lane[i][max_lane]-1;
        }
        return jump;
    }
};
```

> 贪心，先算出右侧最远的一个障碍的位置，直接跳到那一个跑道上，再向前移动
> 在初始的2号跑道上要先向前移动

### dp

```c++
class Solution {
public:
    int minSideJumps(vector<int>& obstacles) {
        int n = obstacles.size() - 1;
        vector<int> dp = {1, 0 ,1};
        for(int i = 1; i <= n; i++) {
            int minCount = INT_MAX;
            //不跳
            for(int j = 0; j < 3; j++) {
                if(j == obstacles[i]-1) {
                    dp[j] = INT_MAX;
                } else {
                    minCount = min(minCount, dp[j]);
                }
            }
            //跳
            for(int j = 0; j < 3; j++) {
                if(j == obstacles[i]-1) {
                    continue;
                } else {
                    dp[j] = min(dp[j], minCount+1);
                }
            }
        }
        return min(dp[0], min(dp[1], dp[2]));
    }
};
```

> 对于当前位置`i`的跑道`j`
> 如果考虑不从`i-1`位置跳，当前到达当前跑到所用跳数不变，如果有障碍则是无穷如果考虑
> 如果跳到当前位置，前提是当前位置没有障碍，则是另外两个跑到跳数+1和自己本身跳数的最小值


## [1817. 查找用户活跃分钟数](https://leetcode.cn/problems/finding-the-users-active-minutes/)
```c++
class Solution {
public:
    vector<int> findingUsersActiveMinutes(vector<vector<int>>& logs, int k) {
        unordered_map<int, set<int>> UAM;
        vector<int> answer(k, 0);
        for(auto& op:logs) {
            UAM[op[0]].insert(op[1]);
        }
        for(auto ite = UAM.begin(); ite!=UAM.end(); ite++) {
            answer[ite->second.size()-1]++;
        }
        return answer;
    }
};
```

## [1813. 句子相似性 III](https://leetcode.cn/problems/sentence-similarity-iii/)

```c++
class Solution {
public:
    bool areSentencesSimilar(string sentence1, string sentence2) {
        vector<string> splitSentence1 = split(sentence1), splitSentence2 = split(sentence2);
        int wordCount1 = splitSentence1.size(), wordCount2 = splitSentence2.size();
        if(wordCount1 < wordCount2) {
            vector<string> t = splitSentence1;
            splitSentence1 = splitSentence2;
            splitSentence2 = t;
        }
        wordCount1 = splitSentence1.size();wordCount2 = splitSentence2.size();
        int i = 0, j = 0;
        while(i < wordCount1 && splitSentence1[i] != splitSentence2[j]) i++;
        int count = i-j > 0 ? 1 : 0;
        while(i < wordCount1 && j < wordCount2) {
            while(i < wordCount1 && j < wordCount2 && splitSentence1[i] == splitSentence2[j]) {
                i++;j++;
            }
            if(j < wordCount2) {
                while(i < wordCount1 && splitSentence1[i] != splitSentence2[j]) {
                    i++;
                }
                count++;
            } else if(i < wordCount1) {
                count++;
            }
        }
        if(count <= 1 && j == wordCount2) return true;
        i = wordCount1-1;j = wordCount2-1;
        while(i >= wordCount1 && splitSentence1[i] != splitSentence2[j]) i--;
        int count1 = j-i > 0 ? 1 : 0;
        while(i >= 0 && j >= 0) {
            while(i >= 0 && j >= 0 && splitSentence1[i] == splitSentence2[j]) {
                i--;j--;
            }
            if(j >= 0) {
                while(i >= 0 && splitSentence1[i] != splitSentence2[j]) {
                    i--;
                }
                count1++;
            } else if(i >= 0) {
                count1++;
            }
        }
        return (count1 <=1 && j == -1);
    }
    vector<string> split(const string& str) {
        int i = 0, len = str.size();
        vector<string> res;
        while(i < len) {
            string subStr = "";
            while(i < len && str[i] != ' ') {
                subStr += str[i];
                i++;
            }
            res.push_back(subStr);
            while(i < len && str[i] == ' ' ) i++;
        }
        return res;
    }
};
```

> 先split，再双指针
> 数较短的字符串将较长的字符串分成了几份，如果小于2，则ok
> 需要正着反着各尝试一遍

### 题解方法
```c++
class Solution {
public:
    bool areSentencesSimilar(string sentence1, string sentence2) {
        vector<string> splitSentence1 = split(sentence1), splitSentence2 = split(sentence2);
        int wordCount1 = splitSentence1.size(), wordCount2 = splitSentence2.size();
        int i = 0, j = 0;
        while(i < wordCount1 && i < wordCount2 && splitSentence1[i] == splitSentence2[i]) i++;
        while(j < wordCount1-i && j < wordCount2-i && splitSentence1[wordCount1-j-1] == splitSentence2[wordCount2-j-1]) j++;
        return i+j == min(wordCount1, wordCount2);
    }
    vector<string> split(const string& str) {
        int i = 0, len = str.size();
        vector<string> res;
        while(i < len) {
            string subStr = "";
            while(i < len && str[i] != ' ') {
                subStr += str[i];
                i++;
            }
            res.push_back(subStr);
            while(i < len && str[i] == ' ' ) i++;
        }
        return res;
    }
};
```

> 由于只能添加一段，先正向找相同的单词数，再反向找“不与正向重叠的”相同的单词数，如果两者单词数相加刚好等同于较短的字符串的单词数，说明可以通过插入一句话来使两个句子相同