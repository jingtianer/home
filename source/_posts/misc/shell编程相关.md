---
title: shell编程相关
date: 2023-4-20 11:28:00
tags: 
    - misc
    - shell
categories: misc
toc: true
language: zh-CN
---

## kill僵尸进程

- 强制kill掉其父进程，但是会导致shell也死掉
```sh
ps -ef | grep defunct | awk '{ len=split($0, a, " ");print a[3]; }' | xargs kill -9
```