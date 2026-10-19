---
title: LeetCode 524「通过删除字母匹配到字典里最长单词」
date: 2022-10-20 16:13:22 +0800
tags: 算法
categories: 算法
toc: true
language: zh-CN
---

## 算法内容

本文件实现 LeetCode 524「通过删除字母匹配到字典里最长单词」的一种预处理做法。目标是在字典中找出可以由字符串 `s` 删除若干字符得到的最长单词；若长度相同，返回字典序最小者。

代码先构建 `f[i][c]`，表示从位置 `i` 开始往后字符 `c` 第一次出现的位置，不存在则为 `m`。匹配某个候选词时，只需按字符不断跳到下一个出现位置，如果任一字符不存在则匹配失败。这样可以把每个单词的匹配成本降为 O(单词长度)，预处理为 O(26m)。文件中带有打印矩阵的调试输出和一个示例调用。

## 算法实现

```python
from typing import List, Tuple, Dict
class Solution:
    def findLongestWord(self, s: str, dictionary: List[str]) -> str:
        m = len(s)
        f = [[0] * 26 for _ in range(m)]
        f.append([m] * 26)
        print([chr(ord('a')+i) for i in range(26)])
        for i in range(m - 1, -1, -1):
            print('[', end='')
            for j in range(26):
                if ord(s[i]) == j + 97:
                    f[i][j] = i
                else:
                    f[i][j] = f[i + 1][j]
                print("'{}', ".format(f[i][j]), end='')
            print()
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

print(Solution().findLongestWord("abpcplea", ["ale","apple","monkey","plea"]))

```
