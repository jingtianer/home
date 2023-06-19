---
title: cha24.进程的创建
date: 2023-6-19 18:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 1
执行下面代码后会产生多少新进程
```c
fork();
fork();
fork();
```

$ 2^3 -1 =  7 $
```c
fork(); // A，产生B， A+B
fork(); // A产生C，B产生D， A+B+C+D
fork(); // ABCD产生EFGH，A+B+C+D+E+F+G+H
```

## 2

编写一个程序以便验证调用vfork()之后，子进程可以关闭一文件描述符（例如描述符0）而不影响对应父进程中的文件描述符。

无聊不写

## 3

假设可以修改程序源代码，如何在某一特定时刻生成一核心转储（core dump）文件，而同时进程得以继续执行?

`fork()`，然后子进程立刻调用`abort()`

## 4

在其他UNIX实现上实验程序清单24-5 ( fork_whos_on_first.c）中的程序，并判断在执行fork()后这些系统是如何调度父子进程的。

不弄好麻烦

## 5

假定在程序清单24-6的程序中，子进程也需要等待父进程完成某些操作。为确保达成这一目的,应如何修改程序?

fork后子进程sigsuspend，父进程执行完成后kill子进程（向子进程发送信号）



