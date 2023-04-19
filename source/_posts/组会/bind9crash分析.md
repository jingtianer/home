---
title: bind9crash分析
date: 2023-4-19 12:15:37
tags: 
    - 组会 
categories: 组会
toc: true
language: zh-CN
---

## bind9源码阅读

### loopmgr
- 上次在gdb是发现，当运行到出错位置时，labels该小于128，设置断点到该位置，第一次运行到此处时，并没有crash。采用最原始的输出调试方法，直接运行，发现是多个线程都调用了该函数，其中某一次调用时，labels的值大于了127。

named在启动时，会通过loopmgr创建包括main线程在内的n个线程，每个线程为一个loop

### isc_loop_t
loop的类型定义，其中包含与libuv交互的触发器，两个job栈，isc_job单向链表的表头
```c
isc_joblist_t setup_jobs;
isc_joblist_t teardown_jobs;
```

### isc_job
具体的任务，其中有一个回调函数，回调函数的参数，以及其他辅助的域

### named_server_create
调用链为`main->setup->named_server_create`，该函数用于创建服务，并对loopmgr进行初始化。

### libuv
libuv最初是为Node.js设计的，是一个事件驱动的异步io模型

[![libuv架构](http://docs.libuv.org/en/v1.x/_images/architecture.png)](http://docs.libuv.org/en/v1.x/design.html)

libuv可以处理网络，文件等io，向其提供事件触发后的回调，libuv就可以在相应事件发生后调用该函数，方便程序对io的处理。

### isc__nm_udp_read_cb
我们崩溃的调用栈中的这个函数就是udp请求事件的回调。在前面的`named_server_create`中，会创建timer，timer每tick一下，就会通过interface_mgr把所有监听的协议都读一遍，其中之一就是`isc__nm_udp_read_cb`



