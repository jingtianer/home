---
title: Kotlin学习笔记——TabLayout
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

```c++
    #define 小毛驴 xml
```
## 使用场景
如果想让ViewPager的tab标签和Toolbar合二为一的话，可以在Toolbar中嵌套TabLayout
## 使用方法
1. 编写好小毛驴文件，把TabLayout嵌套到Toolbar中，编写好每一页的小毛驴布局文件，写好传递数据的类
2. 编写Fragment
```kotlin
class BlankFragment : Fragment() {
    var ctx:Context? = null
    var mPosition:Int = 0
    var mInageId:Int = 0
    var mDesc:String = ""
    var title:String = ""

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        ctx = activity
        if (arguments != null) {
            mPosition = arguments!!.getInt("position", 0)
            mInageId = arguments!!.getInt("image_id", 0)
            mDesc = arguments!!.getString("desc")
            title = arguments!!.getString("title")
        }
        val view = inflater.inflate(R.layout.item, container, false)

        val pic:ImageView = view.findViewById(R.id.imageView)
        val desc:TextView = view.findViewById(R.id.textView)

        pic.setImageResource(mInageId)
        desc.text = mDesc
        return view
    }

    companion object {
        fun newInstance(position:Int, image_id:Int, desc:String, title:String) : BlankFragment {
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
3. 编写ViewPager的适配器
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
4. 给ViewPager添加适配器
```kotlin
class the_pics : AppCompatActivity() , TabLayout.OnTabSelectedListener {

    override fun onTabReselected(p0: TabLayout.Tab?) {}

    override fun onTabUnselected(p0: TabLayout.Tab?) {

    }

    override fun onTabSelected(p0: TabLayout.Tab?) {
        if (p0 != null)
            vp.currentItem = p0.position
            //如果用户点击了某个标签，把下面ViewPager也滚动到相应位置
            //以上三个重载函数都是Toolbar上的标签产生事件后相应的操作
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_the_pics)
        val bar:android.support.v7.widget.Toolbar = findViewById(R.id.bar)
        setSupportActionBar(bar)
        supportActionBar?.title = ""
        bar.setNavigationOnClickListener {
            setResult(Activity.RESULT_OK)
            finish()
        }//设置Toolbar的返回导航键的click监听器

        var data:MutableList<itemInfo> = mutableListOf()
        /*省略data的赋值过程*/

        tab_title.addOnTabSelectedListener(this)
        vp.adapter = infoPagerAdapter(supportFragmentManager, data)

        vp.addOnPageChangeListener(object : ViewPager.SimpleOnPageChangeListener() {
            override fun onPageSelected(position: Int) {
                tab_title.getTabAt(position)!!.select()//让标签栏的第position个变成被选择状态
                //这个重载函数是ViewPager上有Page的改变后调用的函数
            }
        })
    }
}
```
