---
title: 01-Kotlin的WhenElse一共有几种写法
date: 2025-10-21 21:15:36
tags: 
    Java基础
    字节码
categories: Java基础
toc: true
language: zh-CN
---

## Int等基本类型的WhenElse

```kotlin
private fun whenElseInt(intNumber: Int) {
    val number: String = when(intNumber) {
        0 -> "Zero"
        1 -> "One"
        2 -> "Two"
        else -> "Unknown"
    }
    println(number)
}
```

编译后的字节码
```java
private final static whenElseInt(I)V
   L0
    LINENUMBER 22 L0
    ILOAD 0
    TABLESWITCH
      0: L1
      1: L2
      2: L3
      default: L4
   L1
    LINENUMBER 23 L1
   FRAME SAME
    LDC "Zero"
    GOTO L5
   L2
    LINENUMBER 24 L2
   FRAME SAME
    LDC "One"
    GOTO L5
   L3
    LINENUMBER 25 L3
   FRAME SAME
    LDC "Two"
    GOTO L5
   L4
    LINENUMBER 26 L4
   FRAME SAME
    LDC "Unknown"
   L5
    LINENUMBER 22 L5
   FRAME SAME1 java/lang/String
    ASTORE 1
   L6
    LINENUMBER 28 L6
    GETSTATIC java/lang/System.out : Ljava/io/PrintStream;
    ALOAD 1
    INVOKEVIRTUAL java/io/PrintStream.println (Ljava/lang/Object;)V
   L7
    LINENUMBER 29 L7
    RETURN
   L8
    LOCALVARIABLE number Ljava/lang/String; L6 L8 1
    LOCALVARIABLE intNumber I L0 L8 0
    MAXSTACK = 2
    MAXLOCALS = 2
```

可以看到，编译器生成了`TABLESWITCH`指令，可以根据数值快速查表，找到跳转位置

如果是一下几种情况，则不会生成`TABLESWITCH`
- 可空的基本类型
- 使用Integer等包装类型

```kotlin
private fun whenElseNullableInt(int: Int?) {
    val out: String = when(int) { // 没有 TABLESWITCH 指令
        0 -> "Enum.Zero"
        1 -> "Enum.One"
        2 -> "Enum.Two"
        else -> "Enum.Unknown"
    }
    println(out)
}

private fun whenElseNullableInteger(int: Integer) {
    val out: String = when(int) { // 没有 TABLESWITCH 指令
        0 -> "Enum.Zero"
        1 -> "Enum.One"
        2 -> "Enum.Two"
        else -> "Enum.Unknown"
    }
    println(out)
}
```

```java
private final static whenElseNullableInt(Ljava/lang/Integer;)V
   L0
    LINENUMBER 115 L0
    ALOAD 0
    ASTORE 2
   L1
    LINENUMBER 116 L1
    ALOAD 2
    DUP
    IFNONNULL L2
    POP
    GOTO L3
   L2
   FRAME FULL [java/lang/Integer T java/lang/Integer] [java/lang/Integer]
    INVOKEVIRTUAL java/lang/Integer.intValue ()I
    IFNE L3
    LDC "Enum.Zero"
    GOTO L4
   L3
    LINENUMBER 117 L3
   FRAME SAME
    ALOAD 2
    ICONST_1
    ISTORE 3
    DUP
    IFNONNULL L5
    POP
    GOTO L6
   L5
   FRAME FULL [java/lang/Integer T java/lang/Integer I] [java/lang/Integer]
    INVOKEVIRTUAL java/lang/Integer.intValue ()I
    ILOAD 3
    IF_ICMPNE L6
    LDC "Enum.One"
    GOTO L4
   L6
    LINENUMBER 118 L6
   FRAME SAME
    ALOAD 2
    ICONST_2
    ISTORE 3
    DUP
    IFNONNULL L7
    POP
    GOTO L8
   L7
   FRAME SAME1 java/lang/Integer
    INVOKEVIRTUAL java/lang/Integer.intValue ()I
    ILOAD 3
    IF_ICMPNE L8
    LDC "Enum.Two"
    GOTO L4
   L8
    LINENUMBER 119 L8
   FRAME SAME
    LDC "Enum.Unknown"
   L4
    LINENUMBER 115 L4
   FRAME FULL [java/lang/Integer T java/lang/Integer] [java/lang/String]
    ASTORE 1
   L9
    LINENUMBER 121 L9
    GETSTATIC java/lang/System.out : Ljava/io/PrintStream;
    ALOAD 1
    INVOKEVIRTUAL java/io/PrintStream.println (Ljava/lang/Object;)V
   L10
    LINENUMBER 122 L10
    RETURN
   L11
    LOCALVARIABLE out Ljava/lang/String; L9 L11 1
    LOCALVARIABLE int Ljava/lang/Integer; L0 L11 0
    MAXSTACK = 2
    MAXLOCALS = 4
```

## String的WhenElse

```kotlin
private fun whenElseString(str: String) {
    val resp = when(str) {
        "hello" -> "world"
        "bye" -> "bye"
        else -> "Unknown"
    }
    println(resp)
}
```

编译后的字节码
```java
private final static whenElseString(Ljava/lang/String;)V
   L0
    LINENUMBER 32 L0
    ALOAD 0
    ASTORE 2
   L1
    LINENUMBER 33 L1
    ALOAD 2
    LDC "hello"
    INVOKESTATIC kotlin/jvm/internal/Intrinsics.areEqual (Ljava/lang/Object;Ljava/lang/Object;)Z
    IFEQ L2
    LDC "world"
    GOTO L3
   L2
    LINENUMBER 34 L2
   FRAME APPEND [T java/lang/String]
    ALOAD 2
    LDC "bye"
    INVOKESTATIC kotlin/jvm/internal/Intrinsics.areEqual (Ljava/lang/Object;Ljava/lang/Object;)Z
    IFEQ L4
    LDC "bye"
    GOTO L3
   L4
    LINENUMBER 35 L4
   FRAME SAME
    LDC "Unknown"
   L3
    LINENUMBER 32 L3
   FRAME SAME1 java/lang/String
    ASTORE 1
   L5
    LINENUMBER 37 L5
    GETSTATIC java/lang/System.out : Ljava/io/PrintStream;
    ALOAD 1
    INVOKEVIRTUAL java/io/PrintStream.println (Ljava/lang/Object;)V
   L6
    LINENUMBER 38 L6
    RETURN
   L7
    LOCALVARIABLE resp Ljava/lang/String; L5 L7 1
    LOCALVARIABLE str Ljava/lang/String; L0 L7 0
    MAXSTACK = 2
    MAXLOCALS = 3
```

比较令人失望，被编译成了if-else语句，调用areEqual函数从上至下进行字符串比较

## Java对String类型switch时的优化

```java
public static void switchCaseString(String input) {
        String resp;
        switch (input) {
            case "hello": {
                resp = "world";
                break;
            }
            case "bye": {
                resp = "bye";
                break;
            }
            default: {
                resp = "Unknown";
                break;
            }
        }
        System.out.println(resp);
    }
```

编译后的字节码
```java
  public static switchCaseString(Ljava/lang/String;)V
   L0
    LINENUMBER 8 L0
    ALOAD 0
    ASTORE 2
    ICONST_M1
    ISTORE 3
    ALOAD 2
    INVOKEVIRTUAL java/lang/String.hashCode ()I
    LOOKUPSWITCH
      98030: L1
      99162322: L2
      default: L3
   L2
   FRAME APPEND [T java/lang/String I]
    ALOAD 2
    LDC "hello"
    INVOKEVIRTUAL java/lang/String.equals (Ljava/lang/Object;)Z
    IFEQ L3
    ICONST_0
    ISTORE 3
    GOTO L3
   L1
   FRAME SAME
    ALOAD 2
    LDC "bye"
    INVOKEVIRTUAL java/lang/String.equals (Ljava/lang/Object;)Z
    IFEQ L3
    ICONST_1
    ISTORE 3
   L3
   FRAME SAME
    ILOAD 3
    LOOKUPSWITCH
      0: L4
      1: L5
      default: L6
   L4
    LINENUMBER 10 L4
   FRAME SAME
    LDC "world"
    ASTORE 1
   L7
    LINENUMBER 11 L7
    GOTO L8
   L5
    LINENUMBER 14 L5
   FRAME SAME
    LDC "bye"
    ASTORE 1
   L9
    LINENUMBER 15 L9
    GOTO L8
   L6
    LINENUMBER 18 L6
   FRAME SAME
    LDC "Unknown"
    ASTORE 1
   L8
    LINENUMBER 22 L8
   FRAME FULL [java/lang/String java/lang/String] []
    GETSTATIC java/lang/System.out : Ljava/io/PrintStream;
    ALOAD 1
    INVOKEVIRTUAL java/io/PrintStream.println (Ljava/lang/String;)V
   L10
    LINENUMBER 23 L10
    RETURN
   L11
    LOCALVARIABLE resp Ljava/lang/String; L7 L5 1
    LOCALVARIABLE resp Ljava/lang/String; L9 L6 1
    LOCALVARIABLE input Ljava/lang/String; L0 L11 0
    LOCALVARIABLE resp Ljava/lang/String; L8 L11 1
    MAXSTACK = 2
    MAXLOCALS = 4
```

可以看到，Java提前计算了字符串的hashcode，根据字符串的hashcode进行跳转。跳转后，为避免hash冲突，调用equals进行字符串比较进行检查，最后根据比较结果跳转到最终的代码块

同时注意到，进入函数后直接调用了hashcode方法，并没有判空操作。

## enum的WhenElse

```kotlin
private fun whenElseNullableEnum(switchType: SwitchType?) {
    val enumStr: String = when(switchType) { // 没有 TABLESWITCH 指令
        SwitchType.A -> "Enum.Zero"
        SwitchType.B -> "Enum.One"
        SwitchType.C -> "Enum.Two"
        else -> "Enum.Unknown"
    }
    println(enumStr)
}
```

```java
private final static whenElseNullableEnum(Lswitchcase/SwitchCaseDemo$SwitchType;)V
   L0
    LINENUMBER 62 L0
    ALOAD 0
    DUP
    IFNONNULL L1
    POP
    ICONST_M1
    GOTO L2
   L1
   FRAME SAME1 switchcase/SwitchCaseDemo$SwitchType
    GETSTATIC switchcase/WhenDemoKt$WhenMappings.$EnumSwitchMapping$0 : [I
    SWAP
    INVOKEVIRTUAL switchcase/SwitchCaseDemo$SwitchType.ordinal ()I
    IALOAD
   L2
   FRAME SAME1 I
    TABLESWITCH
      1: L3
      2: L4
      3: L5
      default: L6
   L3
    LINENUMBER 63 L3
   FRAME SAME
    LDC "Enum.Zero"
    GOTO L7
   L4
    LINENUMBER 64 L4
   FRAME SAME
    LDC "Enum.One"
    GOTO L7
   L5
    LINENUMBER 65 L5
   FRAME SAME
    LDC "Enum.Two"
    GOTO L7
   L6
    LINENUMBER 66 L6
   FRAME SAME
    LDC "Enum.Unknown"
   L7
    LINENUMBER 62 L7
   FRAME SAME1 java/lang/String
    ASTORE 1
   L8
    LINENUMBER 68 L8
    GETSTATIC java/lang/System.out : Ljava/io/PrintStream;
    ALOAD 1
    INVOKEVIRTUAL java/io/PrintStream.println (Ljava/lang/Object;)V
   L9
    LINENUMBER 69 L9
    RETURN
   L10
    LOCALVARIABLE enumStr Ljava/lang/String; L8 L10 1
    LOCALVARIABLE switchType Lswitchcase/SwitchCaseDemo$SwitchType; L0 L10 0
    MAXSTACK = 2
    MAXLOCALS = 2
```

可以看到，通过ordinal函数的结果进行跳转，这一点和Java相同，然而需要注意的是，一下几种情况会导致whenElse退化为if-else
- 每个case并非字面量或静态fianl常量，也就是编译期间无法确定跳转每个分支的条件

```kotlin
private fun whenElseEnumMember(enum: SwitchType?) {
    enum ?: return
    val enumStr: String = when(enum.switchTypeInt) { // 没有 TABLESWITCH 指令
        SwitchType.A.switchTypeInt -> "Enum.Zero"
        SwitchType.B.switchTypeInt-> "Enum.One"
        SwitchType.C.switchTypeInt -> "Enum.Two"
        else -> "Enum.Unknown"
    }
    println(enumStr)
}
```

```kotlin
private fun whenElseWithConst(enum: SwitchType?) {
    val enumStr: String = when(enum.switchTypeInt) { // 有 TABLESWITCH 指令
        SwitchType.A_INT_VALUE -> "Enum.Zero"
        SwitchType.B_INT_VALUE -> "Enum.One"
        SwitchType.C_INT_VALUE -> "Enum.Two"
        else -> "Enum.Unknown"
    }
    println(enumStr)
}
```

```java
  private final static whenElseEnum(Lswitchcase/SwitchCaseDemo$SwitchType;)V
   L0
    LINENUMBER 55 L0
    ALOAD 0
    DUP
    IFNONNULL L1
    POP
    ICONST_M1
    GOTO L2
   L1
   FRAME SAME1 switchcase/SwitchCaseDemo$SwitchType
    GETSTATIC switchcase/WhenDemoKt$WhenMappings.$EnumSwitchMapping$0 : [I
    SWAP
    INVOKEVIRTUAL switchcase/SwitchCaseDemo$SwitchType.ordinal ()I
    IALOAD
   L2
   FRAME SAME1 I
    TABLESWITCH
      1: L3
      2: L4
      3: L5
      default: L6
   L3
    LINENUMBER 56 L3
   FRAME SAME
    LDC "Enum.Zero"
    GOTO L7
   L4
    LINENUMBER 57 L4
   FRAME SAME
    LDC "Enum.One"
    GOTO L7
   L5
    LINENUMBER 58 L5
   FRAME SAME
    LDC "Enum.Two"
    GOTO L7
   L6
    LINENUMBER 59 L6
   FRAME SAME
    LDC "Enum.Unknown"
   L7
    LINENUMBER 55 L7
   FRAME SAME1 java/lang/String
    ASTORE 1
   L8
    LINENUMBER 61 L8
    GETSTATIC java/lang/System.out : Ljava/io/PrintStream;
    ALOAD 1
    INVOKEVIRTUAL java/io/PrintStream.println (Ljava/lang/Object;)V
   L9
    LINENUMBER 62 L9
    RETURN
   L10
    LOCALVARIABLE enumStr Ljava/lang/String; L8 L10 1
    LOCALVARIABLE enum Lswitchcase/SwitchCaseDemo$SwitchType; L0 L10 0
    MAXSTACK = 2
    MAXLOCALS = 2
```

- `SwitchType.A_INT_VALUE`, `SwitchType.B_INT_VALUE` 和 `SwitchType.C_INT_VALUE`是`const val`/`private static final`的，可以生成`TABLESWITCH`指令
- Kotlin枚举可以不判空，可以自动生成判空的代码

## 类型判断
```kotlin
private fun whenElseClassCheck(obj: Any) {
    val typeStr = when (obj) {
        is String -> "String"
        is Int -> "Int"
        is Long -> "Long"
        else -> "Unknown"
    }
    println(typeStr)
}
```

没有翻译成`TABLESWITCH`
```java
  private final static whenElseClassCheck(Ljava/lang/Object;)V
   L0
    LINENUMBER 139 L0
    ALOAD 0
    ASTORE 2
   L1
    LINENUMBER 140 L1
    ALOAD 2
    INSTANCEOF java/lang/String
    IFEQ L2
    LDC "String"
    GOTO L3
   L2
    LINENUMBER 141 L2
   FRAME APPEND [T java/lang/Object]
    ALOAD 2
    INSTANCEOF java/lang/Integer
    IFEQ L4
    LDC "Int"
    GOTO L3
   L4
    LINENUMBER 142 L4
   FRAME SAME
    ALOAD 2
    INSTANCEOF java/lang/Long
    IFEQ L5
    LDC "Long"
    GOTO L3
   L5
    LINENUMBER 143 L5
   FRAME SAME
    LDC "Unknown"
   L3
    LINENUMBER 139 L3
   FRAME SAME1 java/lang/String
    ASTORE 1
   L6
    LINENUMBER 145 L6
    GETSTATIC java/lang/System.out : Ljava/io/PrintStream;
    ALOAD 1
    INVOKEVIRTUAL java/io/PrintStream.println (Ljava/lang/Object;)V
   L7
    LINENUMBER 146 L7
    RETURN
   L8
    LOCALVARIABLE typeStr Ljava/lang/String; L6 L8 1
    LOCALVARIABLE obj Ljava/lang/Object; L0 L8 0
    MAXSTACK = 2
    MAXLOCALS = 3
```

## 无参数的WhenElse

## 总结
- 在Java中，switch-case语句总是可以被翻译成`TABLESWITCH`，实现跳转，然而其语法限制较多
    - 可接收的类型受限，char, byte, short, int, Character, Byte, Short, Integer, String, or an enum
    - 每个case必须是字面量、常量，或枚举
- Java的switch-case如果是字符串，会自动调用hashcode函数，且没有判空，需要注意空指针问题
- Java的switch-case如果是枚举，会自动调用oridinal，且没有判空，需要注意空指针问题
- Java的switch-case如果是Integer等包装类型，会调用intValue等函数拆箱，没有进行判空，也需要注意空指针问题

- 在Kotlin中，WhenElse语句只有在特定情况下会被优化为`TABLESWITCH`语句，大多数时间下是一种增强型的if-else。在一些情况下，会编译为if-else，如：
    - 可空的基本类型
    - 使用Integer等包装类型
    - 使用String
    - 使用Java的switch-case所不支持的类型
    - 某些case并非常数、字面量
    - 类型判断
    - 无参数的whenElse

## Tips
- 在使用switch-case前，如果是String，枚举，包装类型，需要主要判空
- 在使用WhenElse语句时，要注意
    - 如果是可空的基本类型，要判空，否则无法生成`TABLESWITCH`语句（枚举可以不判空）
    - 对于字符串，如果每个case都是字符串常量，尽量不要使用WhenElse判断字符串，使用Java的switch-case更佳
    - 尽可能的保证每个case都是常量、字面量、枚举常量