---
title: Kotlin学习笔记——ListView
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

```c++
    #define 小毛驴 xml
```
## 使用方法
1. 设计好界面
2. 新建一个小毛驴文件，这个小毛驴文件是ListView中，每一个Item的界面布局文件
3. （可选）编写一个数据类，用来保存每个item中的数据，用`data class`可以很方便
4. 编写一个继承`BaseAdapter`适配器的类
```kotlin
class ListViewAdapter(private val context: Context, private val strList:MutableList<myItems>, private val background:Int) : BaseAdapter() {
    override fun getView(position: Int, convertView: View?, parent: ViewGroup?): View {
        var view = convertView
        val holder:ViewHolder
        if (convertView == null) {
            view = LayoutInflater.from(context).inflate(R.layout.item, null)
            //我猜这个函数的作用是指定这个类所对应的小毛驴文件
            holder = ViewHolder()
            holder.ll_item = view.findViewById<LinearLayout>(R.id.ll_item)
            holder.iv_icon = view.findViewById<ImageView>(R.id.iv_icon)
            holder.tv_name = view.findViewById<TextView>(R.id.tv_name)
            holder.tv_desc = view.findViewById<TextView>(R.id.tv_desc)
            view.tag = holder
        } else {
            holder = (view?.tag) as ViewHolder
        }
        //以上是固定格式
        val myItem = strList[position]
        //传进来的数据数组，适配器根据数组大小反复调用这个函数构造ViewList
        //position是当前位置，对应数组下标
        holder.ll_item.setBackgroundColor(background)
        holder.iv_icon.setImageResource(myItem.image)
        holder.tv_name.text = myItem.name
        holder.tv_desc.text = myItem.desc
        //以上是自定义每个控件的显示内容，根据之前传进来的List里面的数据
        return view!!
    }

    override fun getItem(position: Int): Any = strList[position]
    override fun getItemId(position: Int): Long = position.toLong()
    override fun getCount(): Int = strList.size

    inner class ViewHolder {
        lateinit var ll_item:LinearLayout
        lateinit var iv_icon:ImageView
        lateinit var tv_name:TextView
        lateinit var tv_desc:TextView
    }
}
```
5. 如果编写了数据类（起了一个`c++`中`结构体`的作用，因为数组只能传递一个），创建对应的List并且赋值
6. 给ListView添加适配器
```kotlin
        var item:MutableList<myItems> = mutableListOf()
        val imageIds = arrayOf(R.mipmap.a, R.mipmap.b, R.mipmap.c, R.mipmap.d, R.mipmap.e)
        var name = arrayOf("超级大帅哥刘甜甜", "还是超级大帅哥刘甜甜", "可爱的橘猫", "性感裸男","周周")
        var desc = arrayOf("是他是他就是他，我们的大帅哥，刘天天", "是他是他还是他，我们的大帅哥，刘天天", "刘天天最想养的橘猫", "刘天天最喜欢的性感裸男","刘天天最喜欢的大明星周周")
        //各种数据
        setContentView(R.layout.activity_clickhere)
        for (i in imageIds.indices) {
            item.add(myItems(name[i], desc[i], imageIds[i]))
        }
        //初始化要传递的List

        var list:ListView = findViewById<ListView>(R.id.list)
        list.adapter = ListViewAdapter(this,item ,Color.WHITE)//你刚才自己写的适配器类
        //为ListView添加适配器
```
