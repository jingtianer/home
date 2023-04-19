---
title: Kotlin学习笔记——TextView
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

## 文本属性设置函数
|方法|说明|备注|
|-|-|-|
|text|当前文本内容|可以直接赋值，更改内容，可以当做变量，获取内容|
|textSize|文本大小|Float类型|
|setTextColor|设置文本颜色|与Color类一起使用|
|setBackgroundColor|设置背景色|与Color类一起使用|
|gravity|设置对齐方式|与Gravity一起使用，多种对齐方式用`or`连接|
|ellipsize|多余文本的省略方式|与TruncateAt一起使用|
|setSingleLine|是否单行显示|参数Boolean|
|isFocusable|是否可获得焦点|可赋值，更改属性，可以取值|
|isFocusableInTouchMode|是否在触摸时获得焦点|可赋值，更改属性，可以取值|
### 补充
#### Color
Color类中的常用静态成员
|名称|参数|作用|
|-|-|-|
|rgb|三个r、g、b值|返回一个对应rgb的Color对象|
|其他静态成员常量|无|yellow、green、red、grey等对应颜色的Color对象|
#### Gravity
Color类中的常用静态成员
|名称|作用|
|-|-|
|LEFT|左对齐|
|RIGHT|右对齐|
|CENTER|居中|
#### TruncateAt
Color类中的常用静态成员
|名称|作用|
|-|-|
|START|省略号在开头|
|MIDDLE|省略号在中间|
|END|省略号在末尾|
|MARQUEE|跑马灯显示，一定要设置为单行显示|

## 特定效果
### 跑马灯显示，自动滚动，不需要获得焦点
1. 重载isFocused函数，让其永远返回true，默认一直在获得焦点
2. 设置单行显示
3. 设置Focusable
```kotlin
class MyTextView : TextView {
    init {
        this.gravity = Gravity.LEFT or Gravity.CENTER
        this.ellipsize = TextUtils.TruncateAt.MARQUEE
        this.setSingleLine(true)
        this.isFocusable = true
        this.isFocusableInTouchMode = true
    }
    constructor(context: Context) : super(context)
    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)
    constructor(context: Context, attrs: AttributeSet?, style: Int) : super(context, attrs, style)

    override fun isFocused(): Boolean {
        return true
    }
}
```
