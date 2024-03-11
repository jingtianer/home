---
title: 18-Java多线程
date: 2024-03-11 11:15:36
tags: Android 高级开发瓶颈突破系列课
categories: Android
toc: true
language: zh-CN
---

## Thread, Runnable, callable

- 基础

## ThreadFactory

```java
public interface ThreadFactory {
    Thread newThread(Runnable r);
}
```

- 实现一个工厂，生成thread，方便对同类thread进行统一的初始化操作

## Executor

- 见思维导图，《Java核心基础12卷》的笔记

## synchronized

- 固有锁和条件

- 作用
  - 控制进程之间互斥访问
  - 保证监控中的数据被写回内存
  - 非公平锁：先抢锁再排队

### 与ReentrantLock的区别

两者的不同点：
1. ReentrantLock 显示的获得、释放锁，synchronized 隐式获得释放锁
2. ReentrantLock 可**响应中断、可轮回**，synchronized 是不可以响应中断的，为处理锁的不可用性提供了更高的灵活性
3. ReentrantLock 是API 级别的，synchronized 是 JVM 级别的
4. ReentrantLock 可以实现**公平锁**
5. ReentrantLock 通过 Condition 可以绑定多个条件
6. 底层实现不一样， synchronized 是同步阻塞，使用的是**悲观并发策略**，**lock 是同步非阻塞**，采用的是**乐观并发策略**
7. Lock 是一个接口，而 synchronized 是 Java 中的关键字，synchronized 是内置的语言实现。
8. synchronized 在发生异常时，**会自动释放线程占有的锁**，因此不会导致死锁现象发生； 而 Lock 在发生异常时，如果没有主动通过 unLock()去释放锁，则很可能造成死锁现象， 因此使用 Lock 时需要在finally 块中释放锁。
9. Lock 可以让等待锁的**线程响应中断**，而 synchronized 却不行，使用synchronized 时， 等待的线程会一直等待下去，不能够响应中断。
10. 通过 Lock **可以知道有没有成功获取锁**，而 synchronized 却无法办到。
11. Lock 可以提高多个线程进行读操作的效率，既就是**实现读写锁**等。

- 乐观锁和悲观锁（数据库）
  - 乐观锁：认为很少会发生冲突，在操作时不加锁，在写入时观察数据与之前读取时是否相同，相同则直接写回，不相同则重新操作一次
  - 悲观锁：以每次在拿数据的时候都会上锁
- 公平锁非公平锁
  - 公平锁：按规则排队等锁，倾向于调度等待时间最长的线程
  - 非公平锁：先竞争锁，再排队

## ReetrentLock

- 获取条件
- 获取读写锁
