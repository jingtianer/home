---
title: HelloCS-8
date: 2019-9-11 21:15:36
tags:
    - CSharp
    - C#
categories: CSharp
toc: true
language: zh-CN
---

# 可空类型
## 可空类型的声明
```csharp
System.Nullable<T> variable;
T? variable;
```
### 注意
1. 可空类型的基础类型不能是可空类型或引用类型
2. 可空类型的基类型可以是（非可空）值类型，有struct约束的类型参数

## 可空bool?类型
可空bool?类型可取的值有true，false，null，其运算符有&、|，逻辑与和逻辑或
### true、false和null的运算关系
|x|y|x & y|x \| y|
|-|-|-|-|
|**true**|**null**|null|true|
|**false**|**null**|false|null|
|**null**|**true**|null|true|
|**null**|**false**|false|null|
|**null**|**null**|null|null|
- #### 以上的运算关系与SQL中的算法一致

# 赋值
## 隐形局部变量
用var作变量类型，实际类型在其初始化表达式推到出来
```cs
var i = 10;//i的类型为int
val s = "这是一个字符串"//string
```
### 注意
```cs
var v1;//隐形局部变量必须赋初值
var v2 = v2 - 1;//隐形局部变量不能包括其本身
var v3 = {1,2,3,4,5};//不能用数组作为初始化表达式的值
//正确写法
var arr = new []{1,2,3,4,5};
var v4 = null;//不能用null（无法推导出的类型）作为初始化的值
```

## 对象初始化器
对对象进行初始化
```cs
using System;
namespace HelloCS8
{
    public class Stu
    {
        public int age;//想在构造器中初始化，必须public
                        //（如果被其他类调用）（等价于直接访问）
        public string name;
    }
    class Program
    {
        private int age;
        protected string name;
        static void Main(string[] args)
        {
            Stu s = new Stu
            {
                age = 10,//注意这里用,
                name = "啊哈哈"//这里不用分好

            };//这里要加分号
            /*
             * 等价于以下写法
             * Stu s = new Stu();
             * s.age = 10;
             * s.name = "啊哈哈";
             */
            Program pro = new Program
            {
                age = 11,//同一个类中,可在构造器中对非public赋值
                name = "哇咔咔"
            };
        }
    }
}
```

## 集合初始化器
```cs
using System;
using System.Collections.Generic;
namespace collection
{
    class Program
    {
        public static void Main(string[] args)
        {
            List<int> arr = new List<int> { 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 };
            foreach(var item in arr)
            {
                Console.WriteLine(item);
            }
        }
    }
}
```

## 匿名类型
无需显示的定义一个类型，类似于java中的匿名类

匿名类是直接从object继承的无名类(nameless class)类型

匿名类是由一系列的读写属性构成
### 例子
```cs
using System;
using System.Collections.Generic;
namespace AnonymousClass
{
    class Program
    {
        class item
        {
            public int ItemID;
            public string ItemName;
            public override string ToString()
            {
                return base.ToString() + "\n{ ItemID = " + ItemID + ", ItemName" + ItemID + "}";
            }
        }
        static void Main(string[] args)
        {
            var Ac = new
            {
                ID = 1,
                Name = "哇耶耶",
                Sex = "Female",
                arr = new List<item>
                {
                    new item
                    {
                        ItemID = 0,
                        ItemName = "小猫"
                    },
                    new item
                    {
                        ItemID = 1,
                        ItemName = "大猫"
                    },
                    new item
                    {
                        ItemID = 2,
                        ItemName = "男朋友"
                    }
                }
            };
            Console.WriteLine("GetType : " + Ac.GetType());
            Console.WriteLine("ID      = " + Ac.ID);
            Console.WriteLine("Name    = " + Ac.Name);
            Console.WriteLine("Sex     = " + Ac.Sex);
            var arr = Ac.arr;
            foreach(var item in arr)
                Console.WriteLine(item);
        }
    }
}
```
运行结果
```
GetType : <>f__AnonymousType0`4[System.Int32,System.String,System.String,System.Collections.Generic.List`1[AnonymousClass.Program+item]]
ID      = 1
Name    = 哇耶耶
Sex     = Female
AnonymousClass.Program+item
{ ItemID = 0, ItemName0}
AnonymousClass.Program+item
{ ItemID = 1, ItemName1}
AnonymousClass.Program+item
{ ItemID = 2, ItemName2}
```
### 等价写法
```cs

using System;
namespace equal
{
    class Program
    {
        static void Main(string[] args)
        {
            var AC = new { ID = 0, Name = "哈哈哈" };
        }
    }
}
```
等价于：
```cs
using System;
namespace equal
{
    class EQUAL
    {
        private int f1;
        private string f2;
        public EQUAL(int a1, string a2)
        {
            f1 = a1;
            f2 = a2;
        }
        public int ID { get { return f1; } set { f1 = value; } }
        public string Name { get { return f2; } set { f2 = value; } }
    }
    class Program
    {
        static void Main(string[] args)
        {
            var AC = new EQUAL(0, "哈哈哈");
        }
    }
}
```

# 匿名数组
不指定数组元素类型，通过初始化参数来推断数组类型
```cs
namespace ACArr
{
    class Program
    {
        static void Main(string[] args)
        {
            var arr = new[] { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
            foreach(var item in arr)
            {
                Console.WriteLine(item);
            }
        }
    }
}
```

# 扩展方法
只能声明在static class
```cs
using System;

namespace HelloCSharp {
    static class ExtensionMethod
    {
        public static int ToInt32(this string str)//只能声明在static class
        {
            return Int32.Parse(str);
        }
    }

    class Program
    {
        static void Main(string[] args)
        {
            string Sval = "255";
            int Ival = Sval.ToInt32();
            Console.WriteLine(Ival);
            Console.Read();
        }
    }
}
```