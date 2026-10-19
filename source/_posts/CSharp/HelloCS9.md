---
title: HelloCS-9
date: 2019-9-11 21:15:36
tags:
    - CSharp
    - C#
categories: CSharp
toc: true
language: zh-CN
---

# C#中的数据结构
C#提供了以下几种数据结构：Array、ArraList、List<T>、Queue<T>、Stack<T>、Dictionart<K,T>、LinkLedList<T>

## Array
### 特点
1. 数组中数据存储在连续的内存上。
2. 存储的数据类型相同。
3. 通过下标可直接访问。

声明一个属数组时，将在堆中分配一段连续的内存来储存数量为n的数据。存储的数据为值类型时，在分配的内存中会有n个未装箱的值类型被创建；存储的数据为引用类型时，在分配的内存中会有n个引用类型的索引被创建。

### 优点
数组在内存上是连续的存储，因此它的索引速度很快，访问其中的一个元素的时间是恒定的，与其的元素数量无关，数组中赋值与修改的元素很简单。
### 缺点
1. 数组是连续存储，在其俩个元素中插入一个新的元素变得不方便
2. 在声明数组时，必须制定其长度，就会产生当我们声明的长度过长时浪费内存，当声明的长度过短时，会有溢出的风险。这种随机定义数组长度的不稳定性，严重影响了使用Array的使用频率，针对这种缺点，由此引出ArraList。
## ArrayList
```using System.Collections```
### 优点：
1. 使用中不用申明其长度，ArrayList是根据其存储的元素长度来动态变化的。
2. ArrayList可以存储不同类型的元素，ArrayList中所有存储的元素都会当做Object来处理，所以能存储不同的元素。
### 缺点：
1. 发生装箱和拆箱：由于ArrayList中所有的存储的元素都被当做Object类型来处理，值类型在存储中会转换为引用类型（装箱），读取过程中会再转换为值类型（拆箱），装箱时会生成新的引用类型，有时间消耗，影响效率。
2. ArrayList存储类型是不安全的（原因会在深入了解中解释）。因此在实际操作中考虑到安全和效率ArrayList也是几乎不怎么用，下面综合上面的优点、用的最多的List<T>将会登场。

## List<T>
1. ```using System.Collections.Generic;```
2. 为了解决ArrayList不安全类型和装箱和拆箱的缺点，出现了集合泛型。List<T>内部是通过Array来实现的（会在List<T>内部构造介绍）。
### 优点：
1. 保证了存储元素的类型的安全
2. 取消了装箱和拆箱，同时也融合了Array的快速访问和ArrayList长度的灵活的优点。

## Queue<T>
1. ```using System.Collections.Generic;```
2. 这种数据结构中，最先插入的元素是最先被删除（先进先出FIFO ---firist in first out的线性表）通常使用Enqueue和Dequeue这俩个方法实现存取。

## Stack<T>
1. ```using System.Collections.Generic;```
2. 这种数据结构中，最先插入的元素是最先被删除（先进后出LIFO ---late in first out的线性表）通常使用pop和push这俩个方法实现存取

## Dictionart<K,T>
```using System.Collections.Generic;```

Dictionary<K,T>在操作中能快速实现功能，是因为通过更多内存的开销的来满足。在创建字典时，我们可以传入一个容量值，但实际的容量并非该值，字典中而是使用不小于该值的最小质数作为它的实际容量，最小是3。（哈希冲突再说）当有了实际容量，字典并非实现索引，而是通过创建额外的2个数组的来实现间接索引，即int[] buckets和Entry[] entries两个数组（即buckets中保存的其实是entries数组的下标）。我们新建了一个空的字典，那么伴随而来的是2个长度为3的数组。
> 所以当处理的数据不多时，还是慎重使用字典为好。