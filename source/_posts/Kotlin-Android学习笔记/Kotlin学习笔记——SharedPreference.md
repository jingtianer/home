---
title: Kotlin学习笔记——SharedPreference
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

```c++
    #define 小毛驴 xml
    #define SPS SharedPreferences
```
## 知识补充
### 模板类
1. Any类——相当于java中的Object类
2. <*>——相当于java中的<?>表示不同于模板类的`T`
### 委托属性
待补充
### lazy修饰符
让变量在首次使用的时候赋值
- 与`lateinit`的区别：
  - lateinit是在创建变量时不赋值，想编译器保证在使用之前会赋值，这样这个变量仍然会被当做非空变量
  - lazy是创建变量时"赋值"，但是真正赋值是在首次使用的时候才赋值
### with函数
```kotlin
    with(函数头语句){函数体语句}
```
- 函数头语句先于函数体语句执行，函数头语句会返回一个值
- 函数体语句会在头语句的返回对象的命名空间中执行，体语句可以直接调用头部返回的类的方法

## 使用场景
SharedPreferences是Android中最简单的数据储存方式
## 使用方法
### 方法一览
SharedPreferences类的方法（注意最后有一个s）
|方法|参数|解释|
|-|-|-|
|getSharedPreferences|String + MODD|初始化一个SPS。第一个String是文件名，与str.xml文件共享参数。第二个参数是参数的操作模式，是Context类中的静态常量（这个函数不是SPS的方法，是Context的，但是为了方便起见写在这里）|
|getString|key-value|obviously|
|getInt|key-value|obviously|
|getBoolean|key-value|obviously|
|getFloat|key-value|obviously|
|getLong|key-value|obviously|
### 编写一个Util类
```kotlin
class SharedPreferencesUtil<T>(val context: Context, val name:String, val default:T) : ReadWriteProperty<Any?, T> {
    val prefs: SharedPreferences by lazy {
        context.getSharedPreferences("default", Context.MODE_PRIVATE)
    }


    override fun getValue(thisRef: Any?, property: KProperty<*>): T {
        return findPreference(name, default)
    }

    override fun setValue(thisRef: Any?, property: KProperty<*>, value: T) {
        putPreference(name, value)
    }

    private fun findPreference(name:String, default: T) : T  = with(prefs){
        return when (default) {
            is Long -> getLong(name, default)
            is String -> getString(name, default)
            is Int -> getInt(name, default)
            is Boolean -> getBoolean(name, default)
            is Float -> getFloat(name, default)
            else -> throw IllegalArgumentException("Unsupport type")
        } as T
    }

    private fun <T> putPreference(name:String, value:T) = with(prefs.edit()) {
        when (value) {
            is Long -> putLong(name, value)
            is String -> putString(name, value)
            is Int -> putInt(name, value)
            is Boolean -> putBoolean(name, value)
            is Float -> putFloat(name, value)
            else -> throw IllegalArgumentException("Unsupport type")
        }.apply()
        //commit和apply都表示提交
        //应该是对when-else语句的返回值调用apply方法
    }

}
```

### 使用
```kotlin
    var name:String by SharedPreferencesUtil(this, "name", "")
    var age:Int by SharedPreferencesUtil(this, "age", 0)
    var marriage:Boolean by SharedPreferencesUtil(this, "marriage", true)
    //以上三个变量就被“本地化”保存了
```
