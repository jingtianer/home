---
title: aflgo原理&挖掘情况
date: 2023-5-29 12:15:37
tags:
    - 组会
    - aflgo
categories: 组会
toc: true
language: zh-CN
---

## aflgo原理

### aflgo作用

参考：[AFLGO：定向灰盒模糊测试](https://www.codenong.com/cs106349864/)

aflgo在AFL的基础上优化了种子选取。把给定的源码位置设置为Targets，然后AFLGO能在AFL的基础上把离距离Target更近的种子给予更多的能量，使AFLGO能够更快的覆盖Target并测试我们感兴趣的地方。他在以下场景非常适用。

- 补丁测试
在程序出现漏洞后通常会打补丁，在补丁后的版本可以针对补丁部分重点测试，查看新版本是否有新的漏洞。

- 漏洞重现
在有些上报的漏洞中处于隐私问题不会提供出发的输入，仅仅会报告漏洞出现在代码的哪些位置，那么AFLGO就可以针对漏洞出现的位置重点测试，重现能触发漏洞的输入。

- 静态分析的验证
在静态分析得到可能出现问题的漏洞代码后，可以使用AFLGO进行问题代码位置的动态测试。

### aflgo距离计算

#### 编译期间静态计算
- 函数级的距离，LLVM可以在CG中算出两个函数中最短（边数量最少）的距离
![fuction  level](/home/images/aflgo/aflgo-formular1.webp)
- 基本块级距离，计算出函数级距离后，根据如下公式，计算基本块级距离
![bb  level](/home/images/aflgo/aflgo-formular2.webp)

#### 种子距离的动态计算

在fuzz过程中，根据已经访问过的BB，动态计算种子的距离
![seed distance](/home/images/aflgo/aflgo-formular3.webp)
并对该距离进行归一化
![seed distance uniformization](/home/images/aflgo/aflgo-formular4.webp)

### aflgo种子调度：基于模拟退火的调度算法

模拟退火算法用于在一个很大的、通常是离散的搜索空间中，在一个可接受的时间预算内逼近全局最优。
该算法在最开始，处于exploration（探索）阶段，会一致对待所有的种子，给予最大的随机可能性。当大于时间阈值后，进入exploitation（利用）时期，对favor（偏好）的种子更多的变异能量。

![](/home/images/aflgo/aflgo-formular5.webp)

这个图说明了随着时间的增加，距离越大的种子被赋予的能量也更大

> 右侧这个图表达了相反的意思，可能是画错了吗？

### aflgo调度算法的实现

AFL本身的调度算法基于种子的运行时间、种子的大小、种子的发现时间、种子的生成代数。

aflgo的调度算法如下
![](/home/images/aflgo/aflgo-formular6.png)
也就是在AFL的基础上乘了一个系数，不会过度弱化种子其他维度的重要性也可以强化目标位置的导向型。

在exploitation（利用）时期，当时间足够长时，可以得到
对于距离较远的种子，其能量值趋近于afl能量的1/32
![](/home/images/aflgo/aflgo-formular7.png)
对于距离较近的种子，其能量值趋近于afl能量的32倍
![](/home/images/aflgo/aflgo-formular8.png)

## 漏洞挖掘情况

### knot 
挖到2个crash，未分析

### named
依旧没结果，除了上次那个能让named崩溃的crash。

> crash方面想挖久一点，多出点crash后再分析