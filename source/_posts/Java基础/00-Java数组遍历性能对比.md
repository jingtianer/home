---
title: 00-Java数组遍历性能对比
date: 2024-9-13 21:15:36
tags: Java基础
categories: Java基础
toc: true
language: zh-CN
---

## 三种遍历方式性能对比

1. 循环与数组的`length`比较
```java
public class JavaMain {
    static Object[] objs = new Object[10000000];
    static int zero() {
        int sum = 0;
        for(int i = 0; i < objs.length; i++) {
            sum ^= objs[i].hashCode();
        }
        return sum;
    }
}
```

2. 将数组`length`存在方法栈中

```java
public class JavaMain {
    static Object[] objs = new Object[10000000];
    static int one() {
        int sum = 0;
        int len = objs.length;
        for(int i = 0; i < len; i++) {
            sum ^= objs[i].hashCode();
        }
        return sum;
    }
}
```

3. for-each循环

```java
public class JavaMain {
    static Object[] objs = new Object[10000000];
    static int two() {
        int sum = 0;
        for (Object obj : objs) {
            sum ^= obj.hashCode();
        }
        return sum;
    }
}
```

### 测试速度
```java
public class JavaMain {
    static Object[] objs = new Object[10000000];
    static long run(IntSupplier f) {
        long start = System.currentTimeMillis();
        int result = 0;
        for(int i = 0; i < 100; i++) {
            result = f.getAsInt();
        }
        long end = System.currentTimeMillis();
        System.out.println("result = " + result + ", time = " + (end - start) / 1000.0);
        return  end - start;
    }
    public static void main(String[] args) {
        for (int i = 0; i < objs.length; i++) {
            objs[i] = new Object();
            objs[i].hashCode(); // 首次计算hashcode更慢，先缓存
        }
        for (int i = 0; i < 10; i++) {
            long zeroTime = run(JavaMain::zero);
            long oneTime = run(JavaMain::one);
            long twoTime = run(JavaMain::two);
            System.out.printf("2比1快: %.2f%%\n", ((double)oneTime - twoTime) / oneTime * 100);
            System.out.printf("2比0快: %.2f%%\n", ((double)zeroTime - twoTime) / zeroTime * 100);
            System.out.printf("1比0快: %.2f%%\n", ((double)zeroTime - oneTime) / oneTime * 100);
        }
    }
}
```

### 测试结果

```text
result = 360970567, time = 1.393
result = 360970567, time = 1.174
result = 360970567, time = 0.886
2比1快: 24.53%
2比0快: 36.40%
1比0快: 18.65%
```

## 对比字节码

使用`javap -c`查看字节🐴

```bytecode
static int zero();
Code:
    0: iconst_0
    1: istore_0
    2: iconst_0
    3: istore_1
    4: iload_1
    5: getstatic     #7                  // Field objs:[Ljava/lang/Object;
    8: arraylength
    9: if_icmpge     29
    12: iload_0
    13: getstatic     #7                  // Field objs:[Ljava/lang/Object;
    16: iload_1
    17: aaload
    18: invokevirtual #13                 // Method java/lang/Object.hashCode:()I
    21: ixor
    22: istore_0
    23: iinc          1, 1
    26: goto          4
    29: iload_0
    30: ireturn
```

- 数组的`length`并不是一个字段，没有通过`getfield`获取

```bytecode
static int one();
Code:
    0: iconst_0
    1: istore_0
    2: getstatic     #7                  // Field objs:[Ljava/lang/Object;
    5: arraylength
    6: istore_1
    7: iconst_0
    8: istore_2
    9: iload_2
    10: iload_1
    11: if_icmpge     31
    14: iload_0
    15: getstatic     #7                  // Field objs:[Ljava/lang/Object;
    18: iload_2
    19: aaload
    20: invokevirtual #13                 // Method java/lang/Object.hashCode:()I
    23: ixor
    24: istore_0
    25: iinc          2, 1
    28: goto          9
    31: iload_0
    32: ireturn
```

- 每次使用`arraylength`获取数组长度会更慢，具体`arraylength`做了什么可以看这篇文章[JVM是如何得到数组长度的](https://blog.csdn.net/scjava/article/details/108219216)
- `zero`和`one`对比
  - `zero`每次循环前，要依次执行`iload_1`, `getstatic`, `arraylength`, `if_icmpge`
  - `one`每次循环前，要依次执行`iload_2`, `iload_1`, `if_icmpge`
  - `one`只需要虚拟机读取两个操作数进行比较就可以，而`zero`需要通过`getstatic`获取数组对象，`arraylength`获取长度

```bytecode
static int two();
Code:
    0: iconst_0
    1: istore_0
    2: getstatic     #7                  // Field objs:[Ljava/lang/Object;
    5: astore_1
    6: aload_1
    7: arraylength
    8: istore_2
    9: iconst_0
    10: istore_3
    11: iload_3
    12: iload_2
    13: if_icmpge     35
    16: aload_1
    17: iload_3
    18: aaload
    19: astore        4
    21: iload_0
    22: aload         4
    24: invokevirtual #13                 // Method java/lang/Object.hashCode:()I
    27: ixor
    28: istore_0
    29: iinc          3, 1
    32: goto          11
    35: iload_0
    36: ireturn
```

- `one`和`two`对比
  - 在循环前，两者都是通过`iload`读取数组长度和当前index对比
  - 在循环体中
    - `one`每次需要`getstatic`获取数组对象，然后根据偏移量取出对应位置的对象
    - `two`在循环开始前，就将数组对象存在本地方法栈中，不需要使用`getstatic`来获取数组对象

> 强烈怀疑是`getstatic`性能过于拉胯，导致三者循环速度差异大

## 将数组对象作为参数传递到函数中

### 测试代码

```java
public class JavaMain {
    static Object[] objs = new Object[10000000];
    static int zero(Object[] objs) {
        int sum = 0;
        for(int i = 0; i < objs.length; i++) {
            sum ^= objs[i].hashCode();
        }
        return sum;
    }
    static int one(Object[] objs) {
        int sum = 0;
        int len = objs.length;
        for(int i = 0; i < len; i++) {
            sum ^= objs[i].hashCode();
        }
        return sum;
    }
    static int two(Object[] objs) {
        int sum = 0;
        for (Object obj : objs) {
            sum ^= obj.hashCode();
        }
        return sum;
    }
    static long run(Function<Object[], Integer> f) {
        long start = System.currentTimeMillis();
        int result = 0;
        for(int i = 0; i < 100; i++) {
            result = f.apply(objs);
        }
        long end = System.currentTimeMillis();
        System.out.println("result = " + result + ", time = " + (end - start) / 1000.0);
        return  end - start;
    }
    public static void main(String[] args) {
        for (int i = 0; i < objs.length; i++) {
            objs[i] = new Object();
            objs[i].hashCode();
        }
        for (int i = 0; i < 10; i++) {
            long zeroTime = run(JavaMain::zero);
            long oneTime = run(JavaMain::one);
            long twoTime = run(JavaMain::two);
            System.out.printf("2比1快: %.2f%%\n", ((double)oneTime - twoTime) / oneTime * 100);
            System.out.printf("2比0快: %.2f%%\n", ((double)zeroTime - twoTime) / zeroTime * 100);
            System.out.printf("1比0快: %.2f%%\n", ((double)zeroTime - oneTime) / oneTime * 100);
        }
    }
}
```

### 比较结果
```text
result = 360970567, time = 0.85
result = 360970567, time = 0.871
result = 360970567, time = 0.873
2比1快: -0.23%
2比0快: -2.71%
1比0快: -2.41%
result = 360970567, time = 0.864
result = 360970567, time = 0.847
result = 360970567, time = 0.849
2比1快: -0.24%
2比0快: 1.74%
1比0快: 2.01%
result = 360970567, time = 0.851
result = 360970567, time = 0.849
result = 360970567, time = 0.862
2比1快: -1.53%
2比0快: -1.29%
1比0快: 0.24%
```

> 三种方法难分伯仲

### 字节码对比

```bytecode
Compiled from "JavaMain.java"
public class test.JavaMain {
  static java.lang.Object[] objs;

  public test.JavaMain();
    Code:
       0: aload_0
       1: invokespecial #1                  // Method java/lang/Object."<init>":()V
       4: return

  static int zero(java.lang.Object[]);
    Code:
       0: iconst_0
       1: istore_1
       2: iconst_0
       3: istore_2
       4: iload_2
       5: aload_0
       6: arraylength
       7: if_icmpge     25
      10: iload_1
      11: aload_0
      12: iload_2
      13: aaload
      14: invokevirtual #7                  // Method java/lang/Object.hashCode:()I
      17: ixor
      18: istore_1
      19: iinc          2, 1
      22: goto          4
      25: iload_1
      26: ireturn

  static int one(java.lang.Object[]);
    Code:
       0: iconst_0
       1: istore_1
       2: aload_0
       3: arraylength
       4: istore_2
       5: iconst_0
       6: istore_3
       7: iload_3
       8: iload_2
       9: if_icmpge     27
      12: iload_1
      13: aload_0
      14: iload_3
      15: aaload
      16: invokevirtual #7                  // Method java/lang/Object.hashCode:()I
      19: ixor
      20: istore_1
      21: iinc          3, 1
      24: goto          7
      27: iload_1
      28: ireturn

  static int two(java.lang.Object[]);
    Code:
       0: iconst_0
       1: istore_1
       2: aload_0
       3: astore_2
       4: aload_2
       5: arraylength
       6: istore_3
       7: iconst_0
       8: istore        4
      10: iload         4
      12: iload_3
      13: if_icmpge     36
      16: aload_2
      17: iload         4
      19: aaload
      20: astore        5
      22: iload_1
      23: aload         5
      25: invokevirtual #7                  // Method java/lang/Object.hashCode:()I
      28: ixor
      29: istore_1
      30: iinc          4, 1
      33: goto          10
      36: iload_1
      37: ireturn

  static {};
    Code:
       0: ldc           #77                 // int 10000000
       2: anewarray     #2                  // class java/lang/Object
       5: putstatic     #17                 // Field objs:[Ljava/lang/Object;
       8: return
}
```

> 三者区别不大，总体耗时区别也不大，可见`arraylength`指令并不是性能瓶颈，而是`getstatic`有较大影响
> 同样，我也测试了不通过函数参数传递，而将数组和三个方法改成非`static`修饰的，三者差异较大，可见`getField`指令的性能开销也要比`load`大

## 结论
在遍历数组时，不论是使用数组的`length`，提前存储数组长度，还是使用`for-each`，差别不大，重要的是先将数组对象放到本地方法栈，避免频繁执行`getstatic`和`getfield`指令，造成性能影响。

和八股[安卓性能优化](https://github.com/francistao/LearningNotes/blob/master/Part1/Android/Android%E6%80%A7%E8%83%BD%E4%BC%98%E5%8C%96.md)所归咎的原因稍有不同。