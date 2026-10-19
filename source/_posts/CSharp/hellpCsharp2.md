---
title: HelloCS-2
date: 2019-9-11 21:15:36
tags:
    - CSharp
    - C#
categories: CSharp
toc: true
language: zh-CN
---

```csharp
using System;//导入命名空间
using name = HelloCSharp2;//给命名空间起别名
namespace HelloCSharp2
{
    /*
     * using语句
     *     using(resource-qcquisition) embedded-statement
     */
    class MyResource : IDisposable
    {
        public MyResource()
        {
            Console.WriteLine("new MyResource");
        }
        public void Dispose()
        {
            Console.WriteLine("My Resource Disposed");
        }
    }
    class Program
    {
        static void Main(string[] args)
        {
            using (MyResource res = new MyResource())
            {
                Console.WriteLine("do something in using block");
            }
            Console.WriteLine("out of using block");
            new name.MyResource().Dispose();
        }
    }
}
```