---
title: Kotlin学习笔记——RecyclerView
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

```c++
    #define 小毛驴 xml
```
## 布局管理器
## LinearLayoutManager
类似于线性布局
|构造|
|-|
|(Context context)|
|(Context context,int orientation,boolean reverseLayout)|
|(Context context, AttributeSet attrs, int defStyleAttr,int defStyleRes)|

|参数|解释|
|-|-|
|Context context|上下文，初始化时，构造方法内部加载资源用|
|int orientation|方向，垂直和水平，默认为垂直|
|boolean reverseLayout|是否倒序，设置为True，从最后一个item开始，倒序加载。此时，RecyclerView第一个item是添加进Adapter中的最后一个，最后一个item是第一个加进Adapter的数据,RecyclerView会自动滑到末尾|

参考[英勇青铜5](https://www.jianshu.com/p/8e578d8ebe5f)
## GridLayoutManager
类似GridView
|构造|解释|
|-|-|
|(Context context, int spanCount)|spanCount为列数|
|(Context context, int spanCount, int orientation,boolean reverseLayout)|orientation在GridLayoutManager中有静态常量|
## StaggeredGridLayoutManager
瀑布流
|构造|解释|
|-|-|
|(int spanCount, int orientation)|显然法|
## 使用方法
1. 写一个基础适配器
```kotlin
//abstract抽象类作为基类
abstract class RecyclerBaseAdapter<VH: RecyclerView.ViewHolder>(val context:Context)
    : RecyclerView.Adapter<RecyclerView.ViewHolder>(), AdapterView.OnItemClickListener, AdapterView.OnItemLongClickListener {
    //与小毛驴文件绑定
    val inflater:LayoutInflater = LayoutInflater.from(context)

    override abstract fun getItemCount(): Int

    override abstract fun onCreateViewHolder(p0: ViewGroup, p1: Int): RecyclerView.ViewHolder

    override fun getItemViewType(position: Int): Int = 0

    override fun getItemId(position: Int): Long = position.toLong()

    var itemClickListener:AdapterView.OnItemClickListener? = null
    fun setOnItemClickListener(listener:AdapterView.OnItemClickListener) {
        this.itemClickListener = listener
    }

    var itemLongClickListener: AdapterView.OnItemLongClickListener? = null
    fun setOnItemLongClickLostenner(listener: AdapterView.OnItemLongClickListener) {
        this.itemLongClickListener = listener
    }

    override fun onItemClick(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {

    }

    override fun onItemLongClick(parent: AdapterView<*>?, view: View?, position: Int, id: Long): Boolean {
        return true
    }
}
```
2. 设计好item的小毛驴文件，写好传送数据的类
2. 完成业务逻辑的适配器
```kotlin
class RecyclerGridAdapter(context:Context, private val infos:MutableList<RecyclerInfo>) :
        RecyclerBaseAdapter<RecyclerView.ViewHolder>(context) {
        //继承刚才的基础类
    override fun getItemCount(): Int = infos.size

    override fun onCreateViewHolder(p0: ViewGroup, p1: Int): RecyclerView.ViewHolder {
        val view: View = inflater.inflate(R.layout.layout ,p0, false)
        return ItemHoder(view)
    }

    override fun onBindViewHolder(p0: RecyclerView.ViewHolder, p1: Int) {
        val vh = p0 as ItemHoder
        vh.pic.setImageResource(infos[p1].pic)
        vh.text.text = infos[p1].text
    }

    inner class ItemHoder(view:View): RecyclerView.ViewHolder(view) {
        val ll = view.findViewById<ConstraintLayout>(R.id.ll)
        var pic = view.findViewById<ImageView>(R.id.pic)
        var text = view.findViewById<TextView>(R.id.text)
    }

}
```
4. 为RecyclerView添加布局管理器和适配器
```kotlin
class MainActivity : AppCompatActivity() {
    var l:RecyclerView? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        var data:MutableList<RecyclerInfo> = mutableListOf()
        //省略为data赋值的代码
        l  = findViewById(R.id.l)
        l?.layoutManager = LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false)
        val adapter = RecyclerGridAdapter(this, data)
        adapter.setOnItemClickListener(adapter)
        adapter.setOnItemLongClickLostenner(adapter)

        l?.adapter = adapter
        l?.itemAnimator = DefaultItemAnimator()
        l?.addItemDecoration(SpacesItemDecoration(30))
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menu?.add("LinearLayoutManager(线性)")
        menu?.add("GridLayoutManager(网格)")
        menu?.add("StaggeredGridLayoutManager(瀑布流)")
        return super.onCreateOptionsMenu(menu)
    }

    override fun onOptionsItemSelected(item: MenuItem?): Boolean {
        if (item != null) {//菜单中选择各种布局
            when(item.title) {
                "LinearLayoutManager(线性)" -> l?.layoutManager = LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false)
                "GridLayoutManager(网格)" -> l?.layoutManager = GridLayoutManager(this, 2)
                "StaggeredGridLayoutManager(瀑布流)" -> l?.layoutManager = StaggeredGridLayoutManager(2, StaggeredGridLayoutManager.VERTICAL)
                else -> toast("error")
            }
        }
        return super.onOptionsItemSelected(item)
    }
}
```
