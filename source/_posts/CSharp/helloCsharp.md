---
title: HelloCS-1
date: 2019-9-11 21:15:36
tags:
    - CSharp
    - C#
categories: CSharp
toc: true
language: zh-CN
---

```csharp
using System;
namespace HelloCSharp
{
    class Program
    {
        static void Main(string[] args)
        {
            Console.WriteLine(1f/0);
            Console.WriteLine(1d/0);
            //以上两个结果为∞
            //Console.WriteLine(1m / 0);
            //decimal类型不能除以0
            File x = File.Read | File.Write;
            Console.WriteLine(x);
            /*
             * 1.指针类型
             * 2.值类型——值类型的基础是ValueType，而ValueType本身是类类型
             *         ——分配在堆栈上
             * * 1.枚举类型——基础类型必须是除char以外的其他整数类型
             * * 2.结构类型
             * * * 1.自定义结构类型
             * * * 2.布尔类型
             * * * 3.数值类型
             * * * * 1.decimal
             * * * * 2.浮点类型
             * * * * * 1.float
             * * * * * 2.double
             * * * * 3.整数类型
             * * * * * 1.sbyte  ——有符号——8位
             * * * * * 2.byte   ——无符号——8位
             * * * * * 3.char   ——无符号——16位
             * * * * * 4.short  ——有符号——16位
             * * * * * 5.ushort ——无符号——16位
             * * * * * 6.int    ——有符号——32位
             * * * * * 7.uint   ——无符号——32位
             * * * * * 8.long   ——有符号——64位
             * * * * * 9.ulong  ——无符号——64位
             * 3.引用类型——分配在托管堆上
             * * 1.object
             * * 2.string
             * * 3.类
             * * 4.接口
             * * 5.委托——相当于函数指针
             * * 6.数组
             */
            /*
             * 装箱 值类型隐士转换为引用类型
             *     常见的装箱
             *         任何值类型到object类型
             *         任何值类型到ValueType类型
             *         任何值类型到值类型实现的任何接口类型
             *         任何枚举类型到System.Enum类型
             * 拆箱 引用类型隐式转换为值类型
             *     常见的拆箱
             *         object到任何值类型
             *         ValueType到任何值类型
             *         接口类型到任何实现了该接口类型的值类型
             *         System.Enum到任何枚举类型
             */
            /*
             * 静态变量
             * 实例变量   —— 在使用时才会进行内存分配的变量，比如类、结构体中定义的变量
             * 局部变量
             * 值参数     ——函数的参数列表中的参数
             * 引用参数   ——用ref修饰符声明的参数，在调用含有引用参数的函数时，也要在ref参数之前加ref修饰符
             * 输出参数   ——用out修饰符声明的参数，在调用含有输出参数的函数时，也要在out参数之前加out修饰符
             *  区别
             *      1、使用ref型参数时，传入的参数必须先被初始化。对out而言，必须在方法中对其完成初始化。
             *      2、out适合用在需要retrun多个返回值的地方，而ref则用在需要被调用的方法修改调用者的引用的时候。
             */
             
        }
    }
}
enum File
{
    None,
    Read,
    Write,
    Delete
}
```