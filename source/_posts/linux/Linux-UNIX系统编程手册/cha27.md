---
title: cha26.监控子进程
date: 2023-6-20 18:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## exec()

- 带e的可以指定环境变量，否则继承
- 带p的允许只提供文件名，允许提供不带`"/"`的路径，在path中寻找
  - 若无`env PATH`默认为`.:/usr/bin/:/bin`
- 带l的用不定长参数（参数列表），以NULL结尾
  - execle在NULL后面接envp数组

## exec执行脚本

当exec第一个参数文件以`"#!"`开始，则会读取该行进行解析

```sh
#!<interpreter-path> [arg] <script> <script-args...> 
```

如
```sh
#!/bin/bash --debug
```

若
```c
execl("xxx.sh", "argv1", "argv2", ..., NULL);
```

则实际调用为

```c
execl("/bin/bash", "--debug", "xxx.sh", "argv1", "argv2", ..., NULL);
```

```sh
#!/bin/awk -f
```

