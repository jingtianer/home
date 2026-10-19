---
title: HelloCS-10
date: 2019-9-11 21:15:36
tags:
    - CSharp
    - C#
categories: CSharp
toc: true
language: zh-CN
---

# 迭代器
## 步骤
### 非泛型迭代器
```using System.Collections;```
1. 实现非泛型迭代器的IEnumerable接口
2. 实现GetEnumerator()方法
### 泛型迭代器
1. 实现IEnumerable<T>接口
2. 实现IEnumerable<T>接口的GetEnumerator()方法
3. 实现IEnumerable接口的GetEnumerator()方法

## 例子（非泛型接口）
```cs
using System;
using System.Collections;
namespace HelloCSharp
{
    public class MyArray : IEnumerable
    {
        private int a, b, c, d, e, f, g, h, i, j;

        public MyArray(int a,int b,int c,int d,int e,int f,int g,int h,int i,int j)
        {
            this.a = a;
            this.b = b;
            this.c = c;
            this.d = d;
            this.e = e;
            this.f = f;
            this.g = g;
            this.h = h;
            this.i = i;
            this.j = j;
        }

        public int this[int index]
        {
            get
            {
                int val = 0;
                switch (index % 10)
                {
                    case 0:
                        val = a;break;
                    case 1:
                        val = b;break;
                    case 2:
                        val = c;break;
                    case 3:
                        val = d;break;
                    case 4:
                        val = e;break;
                    case 5:
                        val = f;break;
                    case 6:
                        val = g;break;
                    case 7:
                        val = h;break;
                    case 8:
                        val = i;break;
                    case 9:
                        val = j;break;
                }
                return val;
            }
            set
            {
                switch (index % 10)
                {
                    case 0:
                        a = value; break;
                    case 1:
                        b = value; break;
                    case 2:
                        c = value; break;
                    case 3:
                        d = value; break;
                    case 4:
                        e = value; break;
                    case 5:
                        f = value; break;
                    case 6:
                        g = value; break;
                    case 7:
                        h = value; break;
                    case 8:
                        i = value; break;
                    case 9:
                        j = value; break;
                }
            }
        }
        public IEnumerator GetEnumerator()
        {
            for (int i = 0; i < 100; i++)
            {
                yield return this[i];
            }
        }
    }
    class HelloCS10
    {
        static void Main(string[] args)
        {
            MyArray arr = new MyArray(1,2,3,4,5,6,7,8,9,10);
            foreach (var VARIABLE in arr)
            {
                Console.WriteLine(VARIABLE);
            }

            for (int i = 0; i < 1000000; i++)
            {
                Console.WriteLine(i + " : " + arr[i]);
            }

            Console.ReadLine();
        }
    }
}
```
## 例子（泛型迭代器）
```cs
using System;
using System.Collections;
using System.Collections.Generic;

namespace HelloCSharp
{
    public class MyArray<T> : IEnumerable<T>
    {
        private T a, b, c, d, e, f, g, h, i, j;

        public MyArray(T a, T b, T c, T d, T e, T f, T g, T h, T i, T j)
        {
            this.a = a;
            this.b = b;
            this.c = c;
            this.d = d;
            this.e = e;
            this.f = f;
            this.g = g;
            this.h = h;
            this.i = i;
            this.j = j;
        }

        public T this[int index]
        {
            get
            {
                T val;
                switch (index % 10)
                {
                    default:
                        val = a; break;
                    case 1:
                        val = b; break;
                    case 2:
                        val = c; break;
                    case 3:
                        val = d; break;
                    case 4:
                        val = e; break;
                    case 5:
                        val = f; break;
                    case 6:
                        val = g; break;
                    case 7:
                        val = h; break;
                    case 8:
                        val = i; break;
                    case 9:
                        val = j; break;
                }
                return val;
            }
            set
            {
                switch (index % 10)
                {
                    case 0:
                        a = value; break;
                    case 1:
                        b = value; break;
                    case 2:
                        c = value; break;
                    case 3:
                        d = value; break;
                    case 4:
                        e = value; break;
                    case 5:
                        f = value; break;
                    case 6:
                        g = value; break;
                    case 7:
                        h = value; break;
                    case 8:
                        i = value; break;
                    case 9:
                        j = value; break;
                }
            }
        }
        public IEnumerator<T> GetEnumerator()
        {
            for (int i = 0; i < 100; i++)
            {
                yield return this[i];
            }
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return GetEnumerator();
        }
    }
    class HelloCS10
    {
        static void Main(string[] args)
        {
            MyArray<int> arr = new MyArray<int>(1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
            foreach (var VARIABLE in arr)
            {
                Console.WriteLine(VARIABLE);
            }

            for (int i = 0; i < 1000000; i++)
            {
                Console.WriteLine(i + " : " + arr[i]);
            }
            var ie = arr.GetEnumerator();
            while (ie.MoveNext())
            {
                Console.WriteLine(ie.Current);
            }
            Console.ReadLine();
        }
    }
}
```

# 匿名方法
## 匿名事件
```cs
btn.Click += delegate 
{
    Console.WriteLine("这是一个匿名方法");
}
```

## 一般的匿名函数
```cs
using System;

namespace ACMethod
{
    class Program
    {
        public delegate bool cmp(int a, int b);

        public int[] Arr;

        public Program(int[] arr)
        {
            this.Arr = arr;
        }

        public void Sort(cmp fun)
        {
            QuickSort(0, Arr.Length, fun);
        }

        static void Main(string[] args)
        {
            Program p = new Program(new int[]
                {5, 77, 1, -13, 48, 1, 31, -9, 478, 1, 1, 8, 6, 6, -85, 0, 0, -135, 48, -9, 89, 12});
            p.Print();
            p.Sort(delegate(int a, int b) { return a > b; });
            p.Print();

            p = new Program(new int[]
                {5, 77, 1, -13, 48, 1, 31, -9, 478, 1, 1, 8, 6, 6, -85, 0, 0, -135, 48, -9, 89, 12});
            p.Print();
            p.Sort(delegate(int a, int b) { return a < b; });
            p.Print();
            Console.ReadLine();
        }

        void Print()
        {
            foreach (var item in Arr)
            {
                Console.Write(item + " ");
            }
            Console.WriteLine();
        }

        void QuickSort(int bgn, int end, cmp fun) //arr must be the reference of real param
        {
            //数组arr空or仅有一个元素则退出
            if (bgn >= end - 1)
                return;

            int leftIndex = bgn;
            int rightIndex = end - 1;
            int std = Arr[leftIndex];
            while (leftIndex < rightIndex)
            {
                while (leftIndex < rightIndex)
                {
                    if (fun(Arr[rightIndex], std))
                    {
                        Arr[leftIndex++] = Arr[rightIndex];
                        break;
                    }

                    --rightIndex;
                }

                while (leftIndex < rightIndex)
                {
                    if (!fun(Arr[leftIndex], std))
                    {
                        Arr[rightIndex--] = Arr[leftIndex];
                        break;
                    }

                    ++leftIndex;
                }
            }

            Arr[leftIndex] = std;
            QuickSort(bgn, leftIndex, fun);
            QuickSort(rightIndex + 1, end, fun);
        }
    }
}
```
