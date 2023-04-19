---
title: Kotlin学习笔记——Activity活动跳转
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

## 传送配对字段数据
### 打开一个新页面
```kotlin
    startActivity<secondActivity>()
```
#### 注意
1. 这个函数需要anko库的支持
### 打开页面并向新页面传递参数
#### 使用关键字`to`
```kotlin
    startActivity<secondActivity>(
        "start_time" to currentTime.toString(),
        "message" to "good Morning"
        )
```
#### 使用Pair类
```kotlin
    startActivity<secondActivity> (
        Pair("start_time", currentTime.toString(),
        Pair("message", "good Morning")
    )
```
### 在新页面中获取参数
```kotlin
    val bundle = intent.extras
    val start_time = bundle.getString("start_time")
    val message = bundle.getString("message")
```
### 补充
#### 1. intent
参考：[Android组件系列----Intent详解](https://www.cnblogs.com/smyhvae/p/3959204.html)
##### Intent的概念：

Android中提供了Intent机制来协助应用间的交互与通讯，或者采用更准确的说法是，Intent不仅可用于应用程序之间，也可用于应用程序内部的activity, service和broadcast receiver之间的交互。Intent这个英语单词的本意是“目的、意向、意图”。

Intent是一种运行时绑定（runtime binding)机制，它能在程序运行的过程中连接两个不同的组件。通过Intent，你的程序可以向Android表达某种请求或者意愿，Android会根据意愿的内容选择适当的组件来响应。

activity、service和broadcast receiver之间是通过Intent进行通信的，而另外一个组件Content Provider本身就是一种通信机制，不需要通过Intent。我们来看下面这个图就知道了：

![intent](http://upload-images.jianshu.io/upload_images/16086048-47bd90de176c2be2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

如果Activity1需要和Activity2进行联系，二者不需要直接联系，而是通过Intent作为桥梁。通俗来讲，Intnet类似于中介、媒婆的角色。
#### 2. bundle
参考[Android中Bundle类的作用](https://blog.csdn.net/luman1991/article/details/52887533)

##### Android中Bundle类的作用

> Bundle类用作携带数据，它类似于Map，用于存放key-value名值对形式的值

根据google官方的文档（http://developer.android.com/reference/android/os/Bundle.html）

> Bundle类是一个key-value对，“A mapping from String values to various Parcelable types.”

### 传送序列化数据
```kotlin
    @Parcelize
    data class MessageInfo(val content: String, val send_time: String) : Parcelable {}
```
#### 注意
1. 注解`@Parcelize`不是没有用的，它可以告诉编译器，让编译器自动实现`writeToParcel`、`createFromParcel`、`newArray`、`describeContents`四个方法
2. 要在`build.gradle`的文件末尾添加如下几行
```kotlin
    androidExtensions {
        experimental = true
    }
```
这样以后，就可以在页面之间传递活动跳转的序列化数据了
```kotlin
    val request = MessageInfo("你好你好！", currentTime.toString())
    startActivity<secondActivity>("message" to request)
```
在跳转后的页面获取数据
```kotlin
    val request = intent.extras.getParcelabel<MessageInfo>("message)//获得数据
```
## 跳转时指定启动模式
|启动标志|对应anko库函数|说明|备注|
|-|-|-|-|
|Intent.FLAG_ACTIVITY_NEW_TAST|intent.newTask()|开启一个新任务。这个值类似于launchMode="standard"，不同之处在于，如果原来不存在活动栈，这个标志就会创建一个新栈||
|Intent.FLAG_ACTIVITY_SINGLE_TOP|intent.singleTop()|当栈顶为待跳转的activity实例时，重用栈顶的实例，该值等同于launchMode="singleTop"||
|Intent.FLAG_ACTIVITY_CLEAR_TOP|intent.clrarTop()|当栈中存在待跳转的activity实例时，重新创建一个新实例，并将原实例上方所有实例清除。该值与launchMode="singleTask"相似，但是launchMode="singleTask"采用onNewInten启用原任务，而这个标志先onDestroy再onCreate创建新任务||
|Intent.FLAG_ACTIVITY_NO_HISTORY|intent.noHistory()|这个标志与launchMode="standard"相似，但栈中不保存新启动的activity实例。下次无论使用哪种方法再启动该实例，都要走完standard的完整流程||
|Intent.FLAG_ACTIVITY_CLEAR_TAST|intent.clearTask()|这个标志非常暴力，跳转到新页面时，栈中原有实例都被清空。这个flag要结合newTask使用||

## 处理返回数据
当从一个页面跳转回原来的页面时，有可能要向上一个activity返回一些数据
1. 第一个页面打开第二个页面时，改用startActivityForResult
```kotlin
    val info =  MessageInfo("去吧！去吧！", currentTime.toString())
    startActivityForResult<secondActivity>(0, "go！go！go！" to info)//传递给第二个页面的数据
```
2. 第二个页面退出时，添加传送数据
```kotlin
    val info =  MessageInfo("回来了！回来了！", currentTime.toString())//返回给第一个页面的数据
    //MessageInfo类是之前写的继承Parcelable 的 data class
    val intent = Intent()
    intent.putExtra("back", info)
    setResult(Activity.RESULT_OK, intent)
    finish()
```
3. 上一个页面接受返回值
```kotlin
    override fun onActivityResult(RequestCode:Int, resultCode:Int, data:Intent?) {
        if (data != null) {
            val response = data.extras.getParcelable<MessageInfo>("back")
            //获取了MessageInfo类的对象
        }
    }
```

## onRestart()函数
参考：

[Activity的onRestart()方法调用时机](https://blog.csdn.net/zhuhai__yizhi/article/details/47419451)

[两分钟彻底让你明白Android Activity生命周期(图文)!](https://blog.csdn.net/android_tutor/article/details/5772285)

[https://blog.csdn.net/liuhe688/article/details/6733407](https://blog.csdn.net/liuhe688/article/details/6733407)
### 调用时机
1. 按下home键之后，然后切换回来，会调用onRestart()。
2. 从本Activity跳转到另一个Activity之后，按back键返回原来Activity，会调用onRestart();
3. 从本Activity切换到其他的应用，然后再从其他应用切换回来，会调用onRestart();

### 应用场景
在登录页面上，用户忘记密码，点击"忘记密码"并跳转到相应页面，当返回登录页面时，最好自动清空原来的密码，如果这个操作写在onActivityResult上，那么当用户打开"找回密码"页面，不属于调用onActivityResult的时机

### 实例
```kotlin
    override fun onRestart() {
        //do what u wanna do
        super.onRestart()
    }
```
