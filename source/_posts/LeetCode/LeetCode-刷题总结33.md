---
title: LeetCode-32
date: 2024-3-4 11:14:34
tags: 
    - LeetCode
    - 算法
categories: 
    - LeetCode
    - 算法
toc: true
language: zh-CN
---

## [232. 用栈实现队列](https://leetcode.cn/problems/implement-queue-using-stacks/description/)
- 两个栈倒腾一下可以得到队列
- 一个栈用来入队
- 一个栈用来出队，如果出队栈空，将另一个栈全倒腾过来，如果不空，就出栈一个元素

```c++
class MyQueue {
    stack<int> inStk, outStk;
public:
    MyQueue() {

    }
    
    void push(int x) {
        inStk.push(x);
    }
    
    int pop() {
        if(outStk.empty()) {
            while(!inStk.empty()) {
                outStk.push(inStk.top());
                inStk.pop();
            }
        }
        int top = outStk.top();
        outStk.pop();
        return top;
    }
    
    int peek() {
        if(outStk.empty()) {
            while(!inStk.empty()) {
                outStk.push(inStk.top());
                inStk.pop();
            }
        }
        int top = outStk.top();
        return top;
    }
    
    bool empty() {
        return inStk.empty() && outStk.empty();
    }
};
```