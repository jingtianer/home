---
title: 20-Android多线程
date: 2024-03-11 21:15:36
tags: Android 高级开发瓶颈突破系列课
categories: Android
toc: true
language: zh-CN
---

## Thread.yield()

- 暂时把时间片让出去，变成可运行状态(ready)

## handler

### Looper
- ThreadLocal的
- 相当于一个线程里的大循环
- 在大循环里循环从messageQueue中拿消息
- 拿到消息后执行消息

### Handler
- 持有messageQueue，通过post将Runnable变成Message，根据when加入到messageQueue中

### messageQueue

- 一个队列，用链表维护的
- 每个消息包含runnable和对应的handler


