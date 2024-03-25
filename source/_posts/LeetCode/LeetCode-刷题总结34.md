---
title: LeetCode-34
date: 2024-3-14 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## [2789. 合并后数组中的最大元素](https://leetcode.cn/problems/largest-element-in-an-array-after-merge-operations/description/?envType=daily-question&envId=2024-03-14)

```c++
class Solution {
public:
    long long maxArrayValue(vector<int>& nums) {
        int n = nums.size();
        long long ans = nums[n-1];
        long long curSum = nums[n-1];
        for(int i = n - 2; i >= 0; i--) {
            if(nums[i] <= curSum) {
                curSum += nums[i];
            } else {
                curSum = nums[i];
            }
            ans = max(ans, curSum);
        }
        return ans;
    }
};
```

## [2864. 最大二进制奇数](https://leetcode.cn/problems/maximum-odd-binary-number/description/?envType=daily-question&envId=2024-03-13)

- 一次遍历原地算法

```c++
class Solution {
public:
    string maximumOddBinaryNumber(string& s) {
        int len = s.length();
        int index = 0;
        for(int i = 0; i < len; i++) {
            if(s[i] == '1') {
                s[i] = '0';
                s[index++] = '1';
            }
        }
        s[index-1] = '0';
        s[len-1] = '1';
        return s;
    }
};
```

## [1261. 在受污染的二叉树中查找元素](https://leetcode.cn/problems/find-elements-in-a-contaminated-binary-tree/description/?envType=daily-question&envId=2024-03-12)

### 不要额外存储，不用恢复节点值
- 用对应满二叉树的标号标记index
- 判断要查的树在第几层，将标号转为0,1,2,3,...
- 二进制位就是搜索方向，找到null就是不存在，找到节点就是存在

```c++
class FindElements {
    TreeNode* root;
    // set<int> s;
    // void dfs(TreeNode * root) {
        // s.insert(root->val);
        // if(root->left) {
        //     root->left->val = (root->val << 1) + 1;
        //     dfs(root->left);
        // }
        // if(root->right) {
        //     root->right->val = (root->val << 1) + 2;
        //     dfs(root->right);
        // }
    // }
public:
    FindElements(TreeNode* root) : root(root) {
        // if(!root) return;
        // root->val = 0;
        // dfs(root);
    }
    
    bool find(int target) {
        // return s.count(target) != 0;
        int mask = 1, x = target + 1;
        while(x) {
            x >>= 1;
            mask <<= 1;
        }
        mask >>= 1;
        TreeNode *node = root;
        int n = target - mask + 1;
        mask >>= 1;
        while(mask && node) {
            if((mask & n) != 0) {
                node = node->right;
            } else {
                node = node->left;
            }
            mask >>= 1;
        }
        if(node) cout << node->val << endl;
        return node != nullptr;
    }
};
```

## [2129. 将标题首字母大写](https://leetcode.cn/problems/capitalize-the-title/description/?envType=daily-question&envId=2024-03-11)

```c++
class Solution {
    bool isLowercase(char c) {
        return c >= 'a' && c <= 'z';
    }
    bool isUppercase(char c) {
        return c >= 'A' && c <= 'Z';
    }
    char toLowercase(char c) {
        return isUppercase(c) ? c - 'A' + 'a' : c;
    }
    char toUppercase(char c) {
        return isLowercase(c) ? c - 'a' + 'A' : c;
    }
public:
    string capitalizeTitle(string title) {
        int len = title.length();
        int i = 0;
        while(i < len) {
            int start = i;
            while(i < len && title[i] != ' ') {
                title[i] = toLowercase(title[i]);
                i++;
            }
            if(i - start > 2) {
                title[start] = toUppercase(title[start]);
            }
            while(i < len && title[i] == ' ') {
                i++;
            }
        }
        return title;
    }
};
```

## [310. 最小高度树](https://leetcode.cn/problems/minimum-height-trees/description/?envType=daily-question&envId=2024-03-17)

```c++
class Solution {
public:
    vector<int> findMinHeightTrees(int n, vector<vector<int>>& edges) {
        if(n == 1) return {0};
        vector<int> ans, deg(n);
        vector<vector<int>> g(n);
        for(auto & edge : edges) {
            g[edge[0]].push_back(edge[1]);
            g[edge[1]].push_back(edge[0]);
            deg[edge[0]]++;
            deg[edge[1]]++;
        }
        queue<int> q;
        for(int i = 0; i < n; i++) {
            if(deg[i] == 1) q.push(i);
        }
        while(!q.empty()) {
            int q_size = q.size();
            ans.clear();
            while(q_size--) {
                int node = q.front();
                q.pop();
                deg[node]--;
                for(int child : g[node]) {
                    deg[child]--;
                    if(deg[child] == 1) q.push(child);
                }
                ans.push_back(node);
            }
        }
        return ans;
    }
};
```

- 看了答案，拓扑排序，最后一批就是根

## [2684. 矩阵中移动的最大次数](https://leetcode.cn/problems/maximum-number-of-moves-in-a-grid/description/?envType=daily-question&envId=2024-03-16)

- 暴力！暴力！
- 记忆优化搜索

```c++
class Solution {
    int ans = 0;
    int m, n;
    bool checkBounds(int i, int j) {
        return i >= 0 && j >= 0 && i < m && j < n;
    }
    vector<vector<int>> mem;
    int dfs(int i, int j, int len, vector<vector<int>>& grid) {
        if(checkBounds(i-1, j+1) && grid[i][j] < grid[i-1][j+1]) {
            mem[i][j] = max(mem[i][j], 1 + (mem[i-1][j+1] == 0 ? (mem[i-1][j+1] = dfs(i-1, j+1, len+1, grid)) : mem[i-1][j+1]));
        }
        if(checkBounds(i+1, j+1) && grid[i][j] < grid[i+1][j+1]) {
            mem[i][j] = max(mem[i][j], 1 + (mem[i+1][j+1] == 0 ? (mem[i+1][j+1] = dfs(i+1, j+1, len+1, grid)) : mem[i+1][j+1]));
        }
        if(checkBounds(i, j+1) && grid[i][j] < grid[i][j+1]) {
            mem[i][j] = max(mem[i][j], 1 + (mem[i][j+1] == 0 ? (mem[i][j+1] = dfs(i, j+1, len+1, grid)) : mem[i][j+1]));
        }
        return mem[i][j];
    }
public:
    int maxMoves(vector<vector<int>>& grid) {
        m = grid.size(), n = grid[0].size();
        mem = vector<vector<int>>(m, vector<int>(n));
        for(int i = 0; i < m; i++) {
            ans = max(ans, dfs(i, 0, 0, grid));
        }
        return ans;
    }
};
```

## [303. 区域和检索 - 数组不可变](https://leetcode.cn/problems/range-sum-query-immutable/description/?envType=daily-question&envId=2024-03-18)

```c++
class NumArray {
    vector<int> prevSum;
public:
    NumArray(vector<int>& nums) : prevSum(nums) {
        int len = prevSum.size();
        for(int i = 1; i < len; i++) {
            prevSum[i] += prevSum[i-1];
        }
    }
    
    int sumRange(int left, int right) {
        return left == 0 ? prevSum[right] : prevSum[right] - prevSum[left-1];
    }
};
```

> 前前前前前坠河（缀和）

## [2671. 频率跟踪器](https://leetcode.cn/problems/frequency-tracker/description/?envType=daily-question&envId=2024-03-21)

- 两个hash表

```c++
class FrequencyTracker {
    unordered_map<int, int> freq2num;
    unordered_map<int, int> num2freq;
public:
    FrequencyTracker() {

    }
    
    void add(int number) {
        int oldFred = num2freq[number];
        num2freq[number]++;
        if(oldFred > 0) {
            freq2num[oldFred]--;
        }
        freq2num[oldFred+1]++;
    }
    
    void deleteOne(int number) {
        int oldFred = num2freq[number];
        if(oldFred > 0) {
            num2freq[number]--;
            freq2num[oldFred]--;
            if(oldFred > 1) 
                freq2num[oldFred-1]++;
        }
    }
    
    bool hasFrequency(int frequency) {
        return freq2num[frequency] != 0;
    }
};
```

## [1969. 数组元素的最小非零乘积](https://leetcode.cn/problems/minimum-non-zero-product-of-the-array-elements/description/?envType=daily-question&envId=2024-03-20)

- 根据小学知识，若`a+b=Constant`，则`abs(a-b)`越大，`a*b`越小
- 对于两个互补的数，如`10101`和`01010`可以变成`00001`和`11110`，这样他们差距最大，乘积最小
- `00000`和`11111`互补但是`00000`不考虑，最后还要成员它
- 只要计算有多少对互补数N，互补数的最小乘积A，答案等于`A^N*(全1)`

```c++
class Solution {
    const long long MOD = 1e9 + 7;
    long long pow(long long base, long long index) {
        long long ans = 1;
        while(index) {
            if(index & 1) ans = (ans * base) % MOD;
            base = (base * base) % MOD;
            index >>= 1;
        }
        return ans;
    }
public:
    int minNonZeroProduct(int p) {
        return (pow(((1LL << p) - 2) % MOD, ((1LL << (p - 1)) - 1)) * (((1LL << p) - 1) % MOD)) % MOD;
    }
};
```

> 取模的时候要注意优先级`*/%`是同级的，要加括号

## [1793. 好子数组的最大分数](https://leetcode.cn/problems/maximum-score-of-a-good-subarray/description/?envType=daily-question&envId=2024-03-19)
- 一眼单调栈
```c++
class Solution {
public:
    int maximumScore(vector<int>& nums, int k) {
        int len = nums.size();
        vector<int> leftPos(len), rightPos(len);
        stack<int> monoStack;
        for(int i = 0; i < len; i++) {
            leftPos[i] = i;
            int top = -1;
            while(!monoStack.empty() && nums[monoStack.top()] >= nums[i]) {
                top = monoStack.top();
                monoStack.pop();
            }
            if(top != -1) leftPos[i] = leftPos[top];
            monoStack.push(i);
        }
        monoStack = stack<int>();
        int ans = 0;
        for(int i = len - 1; i >= 0; i--) {
            int top = -1;
            rightPos[i] = i;
            while(!monoStack.empty() && nums[monoStack.top()] >= nums[i]) {
                top = monoStack.top();
                monoStack.pop();
            }
            if(top != -1) rightPos[i] = rightPos[top];
            if(rightPos[i] >= k && k >= leftPos[i]) ans = max(ans, (rightPos[i] - leftPos[i] + 1) * nums[i]);
            monoStack.push(i);
        }
        return ans;
    }
};
```

## 蚂蚁2024年3月23日测评
### 第二题
- 给一个数组，对其中一个数自增0-1次，数组乘积最最多有几个0
```c++
//
// Created by jingtian on 2024/3/23.
//
#include <bits/stdc++.h>
using namespace std;

int cntOf(int n, int divisor) {
    int cnt = 0;
    while(n % divisor == 0) {
        cnt++;
        n /= divisor;
    }
    return cnt;
}

int main() {
    int n;
    while(cin >> n) {
        vector<int> arr(n);
        int cntOf2 = 0, cntOf5 = 0;
        for(int i = 0; i < n; i++) {
            cin >> arr[i];
            cntOf2 += cntOf(arr[i], 2);
            cntOf5 += cntOf(arr[i], 5);
        }
        int ans = min(cntOf2, cntOf5);
        for(int i = 0; i < n; i++) {
            ans = max(ans, min(cntOf2 - cntOf(arr[i], 2) + cntOf(arr[i]+1, 2),
            cntOf5 - cntOf(arr[i], 5) + cntOf(arr[i]+1, 5)));
        }
        cout << ans << endl;
    }
    return 0;
}
```
### 第三题

- 不知道AC没
- 给一颗数，每次将有公共点的两条边涂色，最多能涂色多少次，输出每次涂色的三个节点
- 贪心，对于倒数第二层的节点，两种情况
  - 偶数个子节点
    - 两两配对涂色
  - 奇数个子节点
    - 剩下一个和父节点涂色
  - 其他层类似

```java
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.util.*;


public class Main {
    private final ByteArrayOutputStream bos = new ByteArrayOutputStream();
    private final PrintStream output = new PrintStream(bos);
    private static class TreeNode {
        public List<TreeNode> child;
        private int tag;
        private final int val;
        public TreeNode(int val) {
            child = new ArrayList<>();
            tag = 0;
            this.val = val;
        }
        public void addChild(TreeNode node) {
            child.add(node);
        }
    }
    private int ans = 0;
    private void postOrder(TreeNode node) {
        for(int i = 0; i < node.child.size(); i++) {
            postOrder(node.child.get(i));
        }
        int cntOK = 0;
        int last = -1;
        for(int i = 0; i < node.child.size(); i++) {
            if(node.child.get(i).tag == 1) {
                cntOK++;
                output.printf("%d %d %d\n", node.val+1, node.child.get(i).val+1, node.child.get(i).child.get(node.child.get(i).child.size()-1).val+1);
                ans++;
            } else {
                if(last == -1) {
                    last = i;
                } else {
                    output.printf("%d %d %d\n", node.child.get(last).val + 1, node.val+1, node.child.get(i).val+1);
                    last = -1;
                    ans++;
                }
            }
        }
        int remain = node.child.size() - cntOK;
        node.tag = remain & 1;
    }
    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        while(scanner.hasNext()) {
            Main main = new Main();
            int n = scanner.nextInt();
            TreeNode[] treeNodes = new TreeNode[n];
            boolean[] visited = new boolean[n];
            Arrays.fill(visited, false);
            Map<Integer, List<Integer>> graph = new HashMap<>();
            for (int i = 0; i < n; i++) {
                treeNodes[i] = new TreeNode(i);
            }
            for(int i = 0; i < n - 1; i++) {
                int x, y;
                x = scanner.nextInt() - 1;
                y = scanner.nextInt() - 1;
                if(!graph.containsKey(x)) {
                    graph.put(x, new ArrayList<>());
                }
                if(!graph.containsKey(y)) {
                    graph.put(y, new ArrayList<>());
                }
                graph.get(x).add(y);
                graph.get(y).add(x);
            }
            Deque<Integer> queue = new ArrayDeque<>();
            queue.add(0);
            while (!queue.isEmpty()) {
                int node = queue.getFirst();
                visited[node] = true;
                queue.removeFirst();
                for(int child : graph.get(node)) {
                    if(visited[child]) continue;
                    treeNodes[node].addChild(treeNodes[child]);
                    queue.addLast(child);
                }
            }
            main.postOrder(treeNodes[0]);
            System.out.println(main.ans);
            System.out.print(main.bos);
        }
    }
}
```

## [2549. 统计桌面上的不同数字](https://leetcode.cn/problems/count-distinct-numbers-on-board/description/?envType=daily-question&envId=2024-03-23)

- 记忆优化搜索

```c++
class Solution {
    vector<bool> visited = vector<bool>(100+1);
    int ans = 1;
public:
    int distinctIntegers(int n) {
        if(visited[n]) {
            return ans;
        }
        visited[n] = true;
        for(int i = n - 1; i > 1; i--) {
            if(!visited[i] && n % i == 1) {
                distinctIntegers(i);
                ans++;
            }
        }
        return ans;
    }
};
```
