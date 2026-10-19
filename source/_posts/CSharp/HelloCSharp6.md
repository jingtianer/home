---
title: HelloCS-6
date: 2019-9-11 21:15:36
tags:
    - CSharp
    - C#
categories: CSharp
toc: true
language: zh-CN
---

# 接口
## 接口在类继承时的隐藏
```cs
using System;
namespace demo
{
    public class Class1
    {
        public interface I
        {
            void hahahaha();
        }
    }
    public class Class2 : Class1
    {
        new public interface I
            //使用关键字new告诉编译器此处是可以要隐藏父类接口I的
        {
            void wuwuwuwu();
        }
    }
}
```

# 委托
## 类似于函数指针
## 声明形式
```cs
public         delegate int      myDelegate   (int i, int k);
//访问修饰符    delegate 返回类型  委托名        参数列表
```
## 委托类型的实例化
### 要求
    1. 返回类型于声明相同
    2. 参数列表相同（参数名可以不同）
    3. 实例方法可以是静态方法、实例方法或另一个委托实例
### 实例化步骤
    1. 创建委托声明
    2. 编写对应符合要求的方法
    3. 通过new创建委托实例，并作为参数注册对应的方法
### 实例化举例
```cs
using System;
namespace demo2
{
    delegate int MyDelegate(int i);
    class Program
    {
        public int square(int n)
        {
            return n * n;
        }
        public static int cubic(int n)
        {
            return n * n * n;
        }
        public static void Main(string[] args)
        {
            MyDelegate Dlgt = new MyDelegate(new Program().square);
            Console.WriteLine(Dlgt(5));
            Dlgt = new MyDelegate(Program.cubic);
            Console.WriteLine(Dlgt(5));
        }
    }
}
```
### 委托的方法列表
```cs
using System;
namespace demo3
{
    public delegate double math(double x);
    class Program
    {
        public static double square(double x)
        {
            Console.WriteLine("calling method \"square\"");
            return x * x;
        }
        public static double cubic(double x)
        {
            Console.WriteLine("calling method \"cubic\"");
            return x * x * x;
        }
        public static void Main(string[] args)
        {
            math d1 = new math(square);
            math d2 = new math(cubic);
            math d3 = d1 + d2;
            math d4 = d3 + d2 + d1;
            math d5 = d4 - d1;
            math d6 = d3 + d3 + d4 - d2;
            Console.WriteLine(d1(5));
            Console.WriteLine(d2(5));
            Console.WriteLine(d3(5));
            Console.WriteLine(d4(5));
            Console.WriteLine(d5(5));
            Console.WriteLine(d6(5));
            //调用顺序，最终参数列表从左往右依次调用，返回值为最后一个调用的函数的返回值
        }
    }
}
```
#### 运行结果
```
calling method "square"
25
calling method "cubic"
125
calling method "square"
calling method "cubic"
125
calling method "square"
calling method "cubic"
calling method "cubic"
calling method "square"
25
calling method "square"
calling method "cubic"
calling method "cubic"
125
calling method "square"
calling method "cubic"
calling method "square"
calling method "cubic"
calling method "square"
calling method "cubic"
calling method "square"
25
```
# 事件
## 概念
事件是一种特殊类型的委托，它包含两个参数，指定事件源的对象源和封装封装事件的其他任何相关信息的e参数,其中e必须继承System.EventArgs
## 声明事件的委托
```cs
public delegate void EventHandler(object sender, EventArgs e);
```
## 声明事件本身
```cs
public event EventHandler Print;
```
## 注册、移除事件
和委托一样，要给事件注册、移除，用+-运算符就好了

# 异常
```cs
using System
namespace exceptionDemo
{
    public class MyException : Exception
    {
        private string msg;

        public string message
        {
            get
            {
                return msg;
            }
            set
            {
                msg = value;
            }
        }

        public MyException(string message)
        {
            this.message = message;
        }
        
    }
    class Program
    {
        public static int Func(int n)
        {
            if(n == 0)
            {
                throw new MyException("whattttttt?");
            }
            return n;
        }
        public static void Main(string[] args)
        {
            int a = 1000;
            int n = 20;
            for (; n >= 0; n--)
            {
                try
                {
                    Console.WriteLine(a / n);
                    Console.WriteLine(Func(20 - n));
                }
                catch (MyException me)
                {
                    Console.WriteLine(me.message);
                }
                catch (Exception e)
                {
                    Console.WriteLine(e.Message);
                    Console.WriteLine(e.ToString());
                }
                
                
            }
            
        }
    }
}

```

# 泛型
## 设置泛型的约束
```cs
where T : struct        //类型参数必须是指类型，但不能是Nullable类型
where T : class          //类型参数必须是引用类型
where T : new()       //类型擦参数必须具有无参数的公共构造函数
where T : <基类名>    //类型参数必须是指定基类或其派生类
where T : <接口名称>  //类型参数必须是指定的接口或实现指定的接口
where T : U           //类型参数必须是U提供的参数或派生自为U提供的参数
```

## 泛型方法
```cs
void Swap<U>(ref U i, ref U j) 
{
    U temp = i;
    i = j;
    j = temp;
}
```

## 通过委托调用泛型方法
```cs
using System
namespace demo
{
    public delegate void mDlgt(ref int i, ref int j);
    public class Program
    {
        public static void swap<U>(ref U a, ref U b)
        {
            U temp = a;
            a = b;
            b = temp;
        }
        public static void Main(string[] args)
        {
            mDlgt d = new mDlgt(swap<int>);
        }
    }
}
```
