---
title: Kotlin学习笔记——GridView
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

## Kotlin学习笔记——GridView
```c++
    #define 小毛驴 xml
```
## 使用方法
 1. 设计好界面
 2. 新建一个小毛驴文件，这个小毛驴文件是GridView中，每一个Item的界面布局文件
 3. （可选）编写一个数据类，用来保存每个item中的数据，用`data class`可以很方便
 4. 编写一个继承`BaseAdapter`适配器的类
```kotlin
class GridAdapter(private val context: Context, private val strList:MutableList<myItems>, private val background:Int) : BaseAdapter() {
    override fun getView(position: Int, convertView: View?, parent: ViewGroup?): View {
        var view = convertView
        val holder:ViewHolder
        if (convertView == null) {
            view = LayoutInflater.from(context).inflate(R.layout.item, null)
            //我猜这个函数的作用是指定这个类所对应的小毛驴文件
            holder = ViewHolder()
            holder.myLayout = view.findViewById<LinearLayout>(R.id.all)
            holder.desc = view.findViewById<TextView>(R.id.textView)
            holder.pic = view.findViewById<ImageView>(R.id.imageView)
            view.tag = holder
        } else {
            holder = (view?.tag) as ViewHolder
        }
        //以上是固定格式
        val myItem = strList[position]
        //传进来的数据数组，适配器根据数组大小反复调用这个函数构造ViewList
        //position是当前位置，对应数组下标
        //holder.myLayout.setBackgroundColor(background)
        holder.desc.text = myItem.desc
        holder.pic.setImageResource(myItem.image)
        //以上是自定义每个控件的显示内容
        return view!!
    }

    override fun getItem(position: Int): Any = strList[position]
    override fun getItemId(position: Int): Long = position.toLong()
    override fun getCount(): Int = strList.size

    inner class ViewHolder {
        lateinit var myLayout:LinearLayout
        lateinit var desc: TextView
        lateinit var pic: ImageView
    }
}
```
5. 如果编写了数据类（起了一个`c++`中`结构体`的作用，因为数组只能传递一个），创建对应的List并且赋值
6. 给GridView添加适配器
```kotlin
    var grid:GridView = findViewById(R.id.panel)
    var pics = arrayOf(R.mipmap.a, R.mipmap.b, R.mipmap.c, R.mipmap.d, R.mipmap.e, R.mipmap.f, R.mipmap.g, R.mipmap.h)
    var descs = arrayOf("超级大帅哥刘甜甜", "刘甜甜最喜欢的大明星周周", "刘甜甜最喜欢的性感裸男", "刘甜甜最想养的橘猫", "还是超级大帅哥刘甜甜", "刘甜甜最喜欢的动画人物米奇", "还是刘甜甜最喜欢的动画人物米奇", "用来凑数的发际线哥")
    var data:MutableList<myItems> = mutableListOf()
    for (i in pics.indices) {
        data.add(myItems(descs[i], pics[i]))
    }
    grid.adapter = GridAdapter(this, data, Color.GRAY)
    grid.numColumns = 2//设置列数
```
