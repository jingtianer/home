---
title: 21-RxJava
date: 2024-03-10 21:15:36
tags: Android 高级开发瓶颈突破系列课
categories: Android
toc: true
language: zh-CN
---

## Single

### `static <T> Single.just(T t)`

- 生成一个Single<T>d对象
  - return onAssembly(new SingleJust(t))
  - onAssembly是一个钩子函数，一般情况下不做任何操作，就是调用一个Function<T, R>.apply()

## Observer
- 有后续的`onNext`
- 有周期的Observer.interval()每隔一段时间onNext一次

## Disposable
- 任务丢弃（只会丢弃未开始的，正在进行的任务不会丢弃）


## 线程切换

- subscribOn(schedualer): 通过schedualer创建一个有上游的observable，在上级通过observer返回观察结果时切换线程
- observeOn(schedualer): 通过schedualer创建一个有上游的observable，在subscribe时切换线程，并执行上游的subscribe


### 设计模式

- 观察者模式
  - Rxjava、kotlin的 observer代理
  - LiveData，TextWatcher
  - 各种listener
- 工厂模式 
  - ThreadFactory，OkHttp的RequestFactory
- Builder
  - OkHttp，Retrofit
- 单例模式
  - Handler的mainLooper
  - Application
  - Toast
  - LayoutInflator
  - SharedPrefrence
  - ActivityManager
- 适配器模式
  - 各种Adator： ArrayAdaptor，BaseAdaptor，RecyclerView.Adaptor
  - Okhttp的CallAdapter
- 代理模式
  - Android提供的各种Service
  - 动态代理：Retrofit
  - ContentResolver，ContentProvider