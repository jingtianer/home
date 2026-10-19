---
title: HelloCS-7
date: 2019-9-11 21:15:36
tags:
    - CSharp
    - C#
categories: CSharp
toc: true
language: zh-CN
---

# 分部类型
使用partial修饰符，可以把一个类/结构/接口拆分成不同部分，由不同人实现，最后作为一个整体使用
## 要求、特点
1. 一个分部类的所有部分要在同一个命名空间
2. 一个partial修饰的类和结构可以没有另外的其他部分
3. 如果任何一部分被声明为抽象的，则整个类型都是抽象的
4. 如果任何一部分是密封的，则全都是密封的
5. 如果一个部分声明基类，则该类型都会继承这个基类

# 问题
```cs
using System;
namespace HelloCSharp7
{
    public partial class Part
    {
        int age;
        int name;
        public partial class inner
        {
            int id;
            int sex;
        }
    }
    public partial class Part
    {
        public partial class inner
        {
            int id;
            int sex;
        }
    }
    
}

```
书上说可以这么写，但是vs报错