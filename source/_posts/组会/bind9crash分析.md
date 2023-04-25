---
title: bind9crash分析
date: 2023-4-19 12:15:37
tags: 
    - 组会 
categories: 组会
toc: true
language: zh-CN
---

## bind9 resolver模式
- [参考](https://www.cnblogs.com/doherasyang/p/14464999.html)

DNS resolver大概是指dns服务将dns请求转发给一个带有dns解析功能的路由器，路由器完成剩余部分工作然后将处理结果返回给dns服务器

- 上周在尝试跑通fuzz.c中使用resolver模式的afl钩子，目前还没有跑通，存在两个问题
  - afl变异出的测试用例必须是对域名aaaaaaa.example的一个查询，只有这样named才会将该去查询`master`dns服务器（这里需要参考`bind9主从配置`，将named的`aaaaaa.example`zone配置为从服务器）。对于afl输入的测试用例必须将其变换成一个对于aaaaaaa.example的请求
  - afl钩子会作为一个dns解析器将该请求进行处理，但是处理结果返回给`slave`dns服务器时，`slave`会显示无法找到soa记录，并且以`0`退出程序

> 想跑通这个模式的话，需要找到一个方法，将每次afl测试用例转变成对aaaaaa.example的一个查询。


## asan
上次开会提到查看asan的输出来确认crash

```sh
==26512==AddressSanitizer: failed to intercept '__isoc99_printf'
'==26512==AddressSanitizer: failed to intercept '__isoc99_sprintf'
'==26512==AddressSanitizer: failed to intercept '__isoc99_snprintf'
'==26512==AddressSanitizer: failed to intercept '__isoc99_fprintf'
'==26512==AddressSanitizer: failed to intercept '__isoc99_vprintf'
'==26512==AddressSanitizer: failed to intercept '__isoc99_vsprintf'
'==26512==AddressSanitizer: failed to intercept '__isoc99_vsnprintf'
'==26512==AddressSanitizer: failed to intercept '__isoc99_vfprintf'
'==26512==AddressSanitizer: failed to intercept 'crypt'
'==26512==AddressSanitizer: failed to intercept 'crypt_r'
'==26512==AddressSanitizer: failed to intercept '__cxa_throw'
'==26512==AddressSanitizer: failed to intercept '__cxa_rethrow_primary_exception'
'==26512==AddressSanitizer: libc interceptors initialized
|| `[0x10007fff8000, 0x7fffffffffff]` || HighMem    ||
|| `[0x02008fff7000, 0x10007fff7fff]` || HighShadow ||
|| `[0x00008fff7000, 0x02008fff6fff]` || ShadowGap  ||
|| `[0x00007fff8000, 0x00008fff6fff]` || LowShadow  ||
|| `[0x000000000000, 0x00007fff7fff]` || LowMem     ||
MemToShadow(shadow): 0x00008fff7000 0x000091ff6dff 0x004091ff6e00 0x02008fff6fff
redzone=16
max_redzone=2048
quarantine_size_mb=256M
thread_local_quarantine_size_kb=1024K
malloc_context_size=30
SHADOW_SCALE: 3
SHADOW_GRANULARITY: 8
SHADOW_OFFSET: 0x7fff8000
==26512==Installed the sigaction for signal 11
==26512==Installed the sigaction for signal 7
==26512==Installed the sigaction for signal 8
==26512==T0: stack [0x7fff3cc60000,0x7fff3d460000) size 0x800000; local=0x7fff3d45cd78
==26512==AddressSanitizer Init done
==26512==T1: stack [0x7f85c54ff000,0x7f85c5cfed80) size 0x7ffd80; local=0x7f85c5cfec88
==26512==T2: stack [0x7f85c42ee000,0x7f85c4aedd80) size 0x7ffd80; local=0x7f85c4aedc88
==26512==T3: stack [0x7f85c3aed000,0x7f85c42ecd80) size 0x7ffd80; local=0x7f85c42ecc88
==26512==T4: stack [0x7f85c32ec000,0x7f85c3aebd80) size 0x7ffd80; local=0x7f85c3aebc88
==26512==T5: stack [0x7f85c2aeb000,0x7f85c32ead80) size 0x7ffd80; local=0x7f85c32eac88
==26512==T6: stack [0x7f85c22ea000,0x7f85c2ae9d80) size 0x7ffd80; local=0x7f85c2ae9c88
==26512==T7: stack [0x7f85c1ae9000,0x7f85c22e8d80) size 0x7ffd80; local=0x7f85c22e8c88
==26512==T8: stack [0x7f85c12e8000,0x7f85c1ae7d80) size 0x7ffd80; local=0x7f85c1ae7c88
```

> bind9挖出的crash没有什么有效信息

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

> 目前猜测是多个线程同时读同一个消息，运行较快的线程把资源释放了，运行较慢的线程就读到了错误的数据。但是具体作用机理还是没弄清楚。