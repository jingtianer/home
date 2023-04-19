---
title: Kotlin学习笔记——Fragment
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
Fragment与ViewPager搭配，实现翻页，实现每页多个控件
1. 写好每个item的小毛驴文件和数据传送类
2. 继承Fragment类，自定义一个fragment
```kotlin
class BlankFragment : Fragment() {
    var ctx:Context? = null
    var mPosition:Int = 0
    var mInageId:Int = 0
    var mDesc:String = ""
    var title:String = ""

    val colorNames = listOf<String>("红色","黄色","绿色","青色","蓝色")
    val colors = intArrayOf(Color.RED, Color.YELLOW, Color.GREEN, Color.CYAN, Color.BLUE)
    var mSeq:Int = 0
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        ctx = activity
        if (arguments != null) {
            mPosition = arguments!!.getInt("position", 0)
            mInageId = arguments!!.getInt("image_id", 0)
            mDesc = arguments!!.getString("desc")
            title = arguments!!.getString("title")
        }//获取数据
        val view = inflater.inflate(R.layout.show_info, container, false)

        view.findViewById<ImageView>(R.id.imageView).setImageResource(mInageId)
        view.findViewById<TextView>(R.id.textView).text = mDesc
        //显示数据
        return view
    }

    companion object {
        fun newInstance(position:Int, image_id:Int, desc:String, title:String) : BlankFragment {//调用这个函数，创建新的fragment

            val fragment = BlankFragment()
            val bundle = Bundle()
            bundle.putInt("position", position)
            bundle.putInt("image_id", image_id)
            bundle.putString("desc", desc)
            bundle.putString("title", title)
            fragment.arguments = bundle
            return fragment
        }
    }
}
```
3. ViewPager的适配器
```kotlin
class infoPagerAdapter(val fragManger: FragmentManager, val itemList:MutableList<itemInfo>) : FragmentStatePagerAdapter(fragManger) {
    override fun getCount(): Int = itemList.size
    override fun getItem(p0: Int): Fragment {
        val item = itemList[p0]
        return BlankFragment.newInstance(p0, item.pic, item.desc, item.name)
    }

    override fun getPageTitle(position: Int): CharSequence? {
        return itemList[position].name
    }
}
```
4.给ViewPager添加适配器
```kotlin
class MainActivity : FragmentActivity(){
//这个时候，继承的是FragmentActivity
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        var vp:ViewPager = findViewById(R.id.vp)
        var title: PagerTabStrip = findViewById(R.id.title)
        val list:MutableList<itemInfo> = mutableListOf()
        //省略中间给list赋值的过程
        vp.adapter = infoPagerAdapter(supportFragmentManager, list)
        vp.currentItem = 0
    }
}
```
