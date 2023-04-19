---
title: Kotlin学习笔记——Button
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

## 实现短按长按的方法
### 调用函数
| 方法                   | 参数         | 参数解释                                                                                                                 | 返回值 | 备注                                             |
|------------------------|--------------|--------------------------------------------------------------------------------------------------------------------------|--------|--------------------------------------------------|
| setOnClickListener     | lambda表达式 | lambda的参数为发生点击动作的View，返回值Unit                                                                             | Unit   | 相当于`override fun onClickListener(v:View)`     |
| setOnLongClickListener | lambda表达式 | lambda的参数为发生点击动作的View，返回值Boolean(true表示这个事件已经消耗完了，false表示事件继续传递，会触发一次短按事件) | Unit   | 相当于`override fun onLongClick(v:View):Boolean` |
#### 例子
```kotlin
    btn.setOnClickListener {
        toast("click")
    }
    btn.setOnLongClickListener {
        toast("Long Click")
        true
    }
```
### 使用内部类
#### 例子
```kotlin
    //在Activity类里面
    /*
    inner 关键字，访问外部类的数据
    继承View.onClickListener
    */
    private inner class MyClickListener : View.onClickListener {
        override fun onClick(v:View) {
            toast.("您点击了：${(v as Button).text}")
        }
    }
```
### 实现接口
让当前Activity实现`OnClickListener`和`OnLongClickListener`两个接口
#### 例子
```kotlin
    class MainActivity : AppCompatActivity() , OnClickListener, OnLongClickListener {
        override fun onClick(v: View?) {
            var text:TextView = findViewById(R.id.text)
            text.append("hello world\n")
        }

        override fun onLongClick(v: View?): Boolean {
            toast("哎呀，一直按着人家干什么啦~~")
            return true
        }

        override fun onCreate(savedInstanceState: Bundle?) {
            super.onCreate(savedInstanceState)
            setContentView(R.layout.activity_main)
            var start:FloatingActionButton = findViewById(R.id.start)
            start.setOnLongClickListener(this)
            start.setOnClickListener(this)
        }
    } 
```
