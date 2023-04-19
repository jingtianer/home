---
title: Kotlin学习笔记——EditText
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

## 输入监听器
方便起见，在activity的内部写一个内部类，用来监听输入
### 编写监听器
```kotlin
    inner class EditWatcher : TextWatcher {
        override fun afterTextChanged(s:Editable) {

        }
        override fun beforeTextChanged(s:CharSequence, start:Int, count:Int, after:Int) {

        }
        override fun onTextChanged(s:CharSequence, start:Int, count:Int, after:Int) {
            
        }
    }
```
注意
1. 把Editable直接toString()就是用户当前的输入

### 使用监听器
```kotlin
    et.addTextChangedListener(EditWatcher())
```

## 效果
### 1. 自动隐藏输入法面板
```kotlin
    private inner class EditWatcher(val type:String, val len:Int, val edit:EditText) : TextWatcher {
        override fun afterTextChanged(s:Editable) {
            var str:String = s.toString()
            if (str.indexOf("\n") >= 0 || str.indexOf("\r") >= 0 || str.indexOf(" ") >= 0) {
                str = str.replace("\r", "").replace("\n", "").replace(" ", "")
            }
            if (str.length > len) {
                toast("${type}最长${len}位！")
                edit.setText(str.substring(0, len))
                //大于len的时候再截取子串
                val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                //软键盘如果已经打开则关闭之
                if (imm.isActive) {
                    imm.toggleSoftInput(0, InputMethodManager.HIDE_NOT_ALWAYS)
                }
            }
        }
        override fun beforeTextChanged(s:CharSequence, start:Int, count:Int, after:Int) {

        }
        override fun onTextChanged(s:CharSequence, start:Int, count:Int, after:Int) {

            
        }
    }
```
