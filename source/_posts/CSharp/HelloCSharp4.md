---
title: HelloCS-4
date: 2019-9-11 21:15:36
tags:
    - CSharp
    - C#
categories: CSharp
toc: true
language: zh-CN
---

# 结构
值类型

不可以声明无参数构造函数

不能声明析构函数

不可以进行实例字段的初始化

不能继承，可以实现接口

在结构中，this是一个变量，可以对this赋值，
```csharp
using System;

namespace Struct
{
    public struct stu
    {
        public stu(int age, string sex, int id)
        {
            this.age = age;
            this.sex = sex;
            this.id = id;
            this.uuid = age.ToString() + sex + id.ToString();
        }
        public int age;
        public string sex;
        public int id;
        private string uuid;

        public override string ToString()
        {
            return base.ToString() + "\n" + 
                "{age   = " + age + "}," +
                "{sex   = " + sex + "}," + 
                "{id    = " + id + "}," + 
                "{uuid  = " + uuid + "}";
        }
        public void setValue(stu s)
        {
            this = s;
        }
    }
    class Program
    {
        static void Main(string[] args)
        {
            stu s = new stu(19, "female", 1);
            stu s1 = new stu(20, "male", 2);
            Console.WriteLine("s = " + s.ToString());
            Console.WriteLine("s1 = " + s1.ToString());
            s.setValue(s1);
            Console.WriteLine("s1 = " + s);
        }
    }
}


```