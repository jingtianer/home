---
title: LeetCode-14
date: 2022-10-22 21:15:36
tags: LeetCode
categories: LeetCode
toc: true
language: zh-CN
---

## [927. 三等分](https://leetcode.cn/problems/three-equal-parts/)
```c++
class Solution {
public:
    vector<int> threeEqualParts(vector<int>& arr) {
        int sum = countOne(arr);
        int len = arr.size();
        if(sum % 3 != 0) {
            return {-1,-1};
        }
        if(sum == 0) {
            return {0, len -1};
        }

        int p1,p2,p3;
        p1 = p2 = p3 = 0;
        int i = 0;
        int cur = 0;
        while(i < len) {
            if(arr[i] == 1) {
                if(cur == 0) {
                    p1 = i;
                } else if(cur == sum/3) {
                    p2 = i;
                } else if(cur == 2*sum/3) {
                    p3 = i;
                }
                cur++;
            }
            i++;
        } //把1平均分成3份，p1 p2 p3分别找到三段的第一个1的位置
        // printf("%d %d %d\n", p1, p2, p3);
        int x = p1,y = p2,z = p3;
        int farclen = len - p3;
        if(p1 + farclen > p2 || p2 + farclen > p3) {
            return {-1, -1};
        }
        while(x < p2 && y < p3 && z < len) {
            if(arr[x] != arr[y] || arr[y] != arr[z]) {
                return {-1, -1};
            }
            x++;y++;z++;
        }
        // printf("%d %d %d\n", x, y, z);
        return {p1+farclen-1, p2+farclen};
    }
    int
     countOne(vector<int>& arr) {
        int count = 0;
        for(int a : arr) {
            count += a;
        }
        return count;
    }
};

```

> 难，看懂解析思路后才写出来的

> 刚开始的思路是找0，把1分成了n段，取n/3 , 2n/3和 n段后面的0，然后向右移动双指针比较

> 后来发现有超级长的输入，超时了

> 解析的思路与我刚好相反，先数1的个数，如果是0或者不能被3整除，说明不能分成三段
>
> 1的个数为n，找到第0 n/3 2n/3个1，记为p1, p2, p3
>
> p3到后末尾的长度就是三个子串的长度，如果p1 或 p2 + 字串长度分别大于p2 p3，说明无解
>
> 然后向后比较，若后面的数完全相同则有解

## [1636. 按照频率将数组升序排序](https://leetcode.cn/problems/sort-array-by-increasing-frequency/)

```c++
class Solution {
public:
    vector<int> frequencySort(vector<int>& nums) {
        int freq[205] = {0};
        for(int v : nums) {
            freq[100+v]++;
        }
        int invfreq[205][205] = {0};
        int count[205] = {0};
        for(int i = 0; i < 205; i++) {
            invfreq[freq[i]][count[freq[i]]++] = i-100;
        }
        int numsc = 0;
        for(int i = 1; i < 205; i++) {
            for(int j = count[i]-1; j >= 0; j--) {
                //printf("%d %d\n", i, invfreq[i][j]);
                for(int k = 0; k < i; k++) {
                    nums[numsc++] = invfreq[i][j];
                }
            }
        }
        return nums;
    }
};
```
> 简单，但是还是错了几次（没认真读题，没发现同频率的要降序排列）
> 
> 先用map计算每个数字的出现次数，hash为100+i
> 
> 再把map做倒排索引，由于hash是100+i，那么倒排后的索引也自然以升序排好序了
> 
> 根据倒排索引进行输出。


## [1624. 两个相同字符之间的最长子字符串](https://leetcode.cn/problems/largest-substring-between-two-equal-characters/)

```c++
class Solution {
public:
    int maxLengthBetweenEqualCharacters(string s) {
        int left[26] = {0};
        int right[26] = {0};
        int len = s.size();
        for(int i = 0; i < len; i++) {
            if(left[s[i]-'a'] == 0) {
                left[s[i]-'a'] = i+1;
            }
        }
        for(int i = len-1; i >= 0; i--) {
            if(right[s[i]-'a'] == 0) {
                right[s[i]-'a'] = i+1;
            }
        }
        int max = 0;
        int flag = false;
        for(int i = 0; i < 26; i++) {
            int x = right[i] - left[i] - 1;
            max = max > x ? max : x;
            if(x+1 > 0) flag = true;
        }
        return flag ? max : -1;
    }
};
```

> 简单，数一下每个字母第一次出现的位置和最后一次出现的位置，相减-1取最大值，再对不存在的情况进行特殊标记，也就是所有字母第一次出现的位置和最后一次出现的位置全都相同的情况

## [827. 最大人工岛](https://leetcode.cn/problems/making-a-large-island/)
### 优化到最短的代码
```c++
class Solution {    
    int indexMap[505][505] = {0}; //岛屿点，对应一个岛
    int areaMap[505*505] = {0}; //岛屿点，对应一个岛
    int n;
    const vector<int> d = {0, -1, 0, 1, 0};
public:
    int largestIsland(vector<vector<int>>& grid) {
        n = grid.size();
        int islandCount = 0;
        int max2area = 0;
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                if(grid[i][j] == 1) {
                    if(indexMap[i][j] == 0) {
                        indexMap[i][j] == ++islandCount;
                        dfs(grid, i, j, islandCount);
                        max2area = max2area > areaMap[islandCount] ? max2area : areaMap[islandCount];
                    }
                }
            }
        }
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                unordered_set<int> neighbour;
                int areai = 1;
                if(grid[i][j] == 0) {
                    for(int k = 0; k < 4; k++) {
                        if(valid(i, j , k) && grid[i + d[k]][j + d[k+1]] == 1) {
                            if(neighbour.count(indexMap[i + d[k]][j + d[k+1]]) == 0) {
                                areai += areaMap[indexMap[i + d[k]][j + d[k+1]]];
                                neighbour.insert(indexMap[i + d[k]][j + d[k+1]]);
                            }
                        }
                    }
                    max2area = max2area > areai ? max2area : areai;
                }
            }
        }
        return max2area;
    }

    bool valid(int i, int j, int k) {
        int x = i + d[k];
        int y = j + d[k+1];
        return x >= 0 && y >= 0 && x < n && y < n;
    }

    void dfs(vector<vector<int>>& grid, int x, int y, int index) {
        if(indexMap[x][y] != 0) return;
        indexMap[x][y] = index;
        areaMap[index]++;
        for(int k = 0; k < 4; k++) {
            if(valid(x, y, k) && grid[x + d[k]][y + d[k+1]] == 1) {
                dfs(grid, x + d[k], y + d[k+1], index);
            } 
        }
    }
};
```
> 但是这样效率特别低，主要是valid函数太低下了

### 不用valid
```c++
class Solution {
private:
    int indexMap[505][505] = {0}; //岛屿点，对应一个岛
    int areaMap[505*505] = {0}; //岛屿点，对应一个岛
    int n;
public:
    int largestIsland(vector<vector<int>>& grid) {
        n = grid.size();
        int islandCount = 0;
        bool find0 = false;
        bool find1 = false;
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                if(grid[i][j] == 1) {
                    find1 = true;
                    if(indexMap[i][j] == 0) {
                        ++islandCount;
                        indexMap[i][j] == islandCount;
                        dfs(grid, i, j, islandCount);
                    }
                } else {
                    find0 = true;
                }
            }
        }
        int max2area = 0;
        if(!find0 && find1) return n*n;
        if(find0 && !find1) return 1;
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                set<int> neighbour;
                int areai = 1;
                if(grid[i][j] == 0) {
                    if(j-1 >= 0 && grid[i][j-1] == 1) {
                        neighbour.insert(indexMap[i][j-1]);
                    }
                    if(i-1 >= 0 && grid[i-1][j] == 1) {
                        neighbour.insert(indexMap[i-1][j]);
                    }
                    if(j+1 < n && grid[i][j+1] == 1) {
                        neighbour.insert(indexMap[i][j+1]);
                    }
                    if(i+1 < n && grid[i+1][j] == 1) {
                        neighbour.insert(indexMap[i+1][j]);
                    }
                    for(set<int>::iterator ite = neighbour.begin(); ite != neighbour.end(); ite++) {
                        areai += areaMap[*ite];
                    }
                    max2area = max2area > areai ? max2area : areai;
                }
            }
        }
        return max2area;
    }

    void dfs(vector<vector<int>>& grid, int x, int y, int index) {
        if(indexMap[x][y] != 0) return;
        indexMap[x][y] = index;
        areaMap[index]++;
        if(y-1 >= 0 && grid[x][y-1] == 1) {
            dfs(grid, x, y-1, index);
        } 
        if(y+1 < n && grid[x][y+1] == 1) {
            dfs(grid, x, y+1, index);
        }
        if(x+1 < n && grid[x+1][y] == 1) {
            dfs(grid, x+1, y, index);
        }
        if(x-1 >= 0 && grid[x-1][y] == 1) {
            dfs(grid, x-1, y, index);
        }
    }
};
```

### 首次通过的代码，比较冗长
```c++
class Solution {
private:
    struct Island {
        int area;
        int index;
        Island(int a, int i):area(a), index(i) {}
    };
    bool edgeMap[505][505]; //边界点，对应的哪个岛
    Island* islandMap[505][505]; //岛屿点，对应一个岛
    // vector<Island*> allIsland; //方便回收内存
    int n;
public:
    int largestIsland(vector<vector<int>>& grid) {
        n = grid.size();
        int island_count = 0;
        bool find0 = false;
        bool find1 = false;
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                if(grid[i][j] == 1) {
                    find1 = true;
                    Island *island = nullptr;
                    if(islandMap[i][j] == nullptr) {
                        island = new Island(0, island_count++);
                        dfs(grid, i, j, island);
                    } else {
                        island = islandMap[i][j];
                    }

                    if(j-1 >= 0 && grid[i][j-1] == 0) {
                        edgeMap[i][j-1] = true;
                    }
                    if(i-1 >= 0 && grid[i-1][j] == 0) {
                        edgeMap[i-1][j] = true;
                    }

                } else {
                    find0 = true;
                    Island *island = nullptr;
                    if(j-1 >= 0 && grid[i][j-1] == 1) {
                        edgeMap[i][j] = true;
                    }
                    if(i-1 >= 0 && grid[i-1][j] == 1) {
                        edgeMap[i][j] = true;
                    }
                }
            }
        }
        // int max_area = 0;
        int max2area = 0;
        if(!find0 && find1) return n*n;
        if(find0 && !find1) return 1;
        for(int i = 0; i < n; i++) {
            for(int j = 0; j < n; j++) {
                set<Island*> neighbour;
                int areai = 1;
                
                if(edgeMap[i][j]) {
                    if(j-1 >= 0 && grid[i][j-1] == 1) {
                        Island *island = islandMap[i][j-1];
                        neighbour.insert(island);
                    }
                    if(i-1 >= 0 && grid[i-1][j] == 1) {
                        Island *island = islandMap[i-1][j];
                        neighbour.insert(island);
                    }
                    if(j+1 < n && grid[i][j+1] == 1) {
                        Island *island = islandMap[i][j+1];
                        neighbour.insert(island);
                    }
                    if(i+1 < n && grid[i+1][j] == 1) {
                        Island *island = islandMap[i+1][j];
                        neighbour.insert(island);
                    }
                    for(set<Island*>::iterator ite = neighbour.begin(); ite != neighbour.end(); ite++) {
                        areai += (*ite)->area;
                    }
                    
                    max2area = max2area > areai ? max2area : areai;
                }

            }
        }
        return max2area;
        // return max_area > max2area ? max_area : max2area;
    }

    void addDot(int x, int y) {
        edgeMap[x][y] = true;
    }

    void dfs(vector<vector<int>>& grid, int x, int y, Island *island) {
        if(islandMap[x][y] != nullptr) return;
        islandMap[x][y] = island;
        island->area++;
        // printf("add %p x=%d y=%d, area=%d\n", island, x, y, island->area);
        if(y-1 >= 0 && grid[x][y-1] == 1) {
            dfs(grid, x, y-1, island);
        } 
        if(y+1 < n && grid[x][y+1] == 1) {
            dfs(grid, x, y+1, island);
        }
        if(x+1 < n && grid[x+1][y] == 1) {
            dfs(grid, x+1, y, island);
        }
        if(x-1 >= 0 && grid[x-1][y] == 1) {
            dfs(grid, x-1, y, island);
        }
    }
};
```
> 写了很久，其实和题解的思路是一模一样的


