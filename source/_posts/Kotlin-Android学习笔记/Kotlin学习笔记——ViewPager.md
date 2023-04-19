---
title: Kotlin学习笔记——ViewPager
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
0. 在活动页面添加ViewPager，如果需要tab标签，在ViewPager里嵌套PagerTabStrip或PagerTitleStrip
1. 设计传送数据的类（一张图和一个标题就足够）
2. 编写ViewPager的适配器
```kotlin
class ImagePagerAdapter(val context: Context, val itemList:MutableList<itemInfo>) : PagerAdapter() {
    val views = mutableListOf<ImageView>()
    init {
        for (item in itemList) {
            val view = ImageView(context)
            //view.layoutParams = ActionBar.LayoutParams(ActionBar.LayoutParams.MATCH_PARENT, ActionBar.LayoutParams.WRAP_CONTENT)
            view.layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)

            view.setImageResource(item.pic)
            view.scaleType = ImageView.ScaleType.FIT_CENTER
            views.add(view)
        }
    }
    override fun isViewFromObject(p0: View, p1: Any): Boolean = (p0 === p1)

    override fun getCount(): Int = views.size

    override fun destroyItem(container: ViewGroup, position: Int, `object`: Any) {
        container.removeView(views[position])
    }

    override fun instantiateItem(container: ViewGroup, position: Int): Any {
        container.addView(views[position])
        return views[position]
    }

    override fun getPageTitle(position: Int): CharSequence? {
        return itemList[position].desc
    }//与PagerTabStrip或配合使用

}
```
3. 给PagerView添加适配器和页面改变的Listener
```kotlin
class MainActivity : AppCompatActivity(), ViewPager.OnPageChangeListener {
    override fun onPageScrollStateChanged(p0: Int) {
    }

    override fun onPageScrolled(p0: Int, p1: Float, p2: Int) {

    }


    override fun onPageSelected(p0: Int) {
        Toast.makeText(this, p0.toString(), Toast.LENGTH_SHORT).show()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        //supportActionBar?.hide()
        var vp:ViewPager = findViewById(R.id.vp)
        val pics = arrayOf(R.mipmap.basic, R.mipmap.close, R.mipmap.debug, R.mipmap.edit)
        val list:MutableList<itemInfo> = mutableListOf()
        for (i in pics.indices) {
            list.add(itemInfo((i+1).toString(), pics[i]))
        }
        vp.adapter = ImagePagerAdapter(this, list)
        vp.currentItem = 0
        vp.addOnPageChangeListener(this)

        var title: PagerTabStrip = findViewById(R.id.title)

        title.setTextSize(TypedValue.COMPLEX_UNIT_SP, 20f)
        title.setTextColor(Color.RED)
    }
}
```
