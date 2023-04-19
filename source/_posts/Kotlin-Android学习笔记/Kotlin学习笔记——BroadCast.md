---
title: Kotlin学习笔记——BroadCast
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

```c++
    #define 小毛驴 xml
```
## 收发广播
使用场景：Fragment想要向外传递信息
1. 在Fragment中发送广播
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
        }
        val view = inflater.inflate(R.layout.show_info, container, false)

        view.findViewById<ImageView>(R.id.imageView).setImageResource(mInageId)
        view.findViewById<TextView>(R.id.textView).text = mDesc
        view.findViewById<Button>(R.id.se).setOnClickListener {
            ctx!!.selector("选择颜色", colorNames) {
                mSeq = it

                val intent = Intent(BlankFragment.EVENT)
                intent.putExtra("seq", it)
                intent.putExtra("color", colors[it])
                ctx!!.sendBroadcast(intent)//发送广播
            }
        }
        return view
    }

    companion object {
        const val EVENT:String = "changeColor"//const，编译期常量
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
2. 在要接收广播的页面注册receiver
```kotlin
class MainActivity : FragmentActivity(){
    private var BGChangeRecever:myBgChangeRecever? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        var vp:ViewPager = findViewById(R.id.vp)
        var title: PagerTabStrip = findViewById(R.id.title)

        val pics = arrayOf(R.mipmap.basic, R.mipmap.close, R.mipmap.debug, R.mipmap.edit)
        val list:MutableList<itemInfo> = mutableListOf()
        for (i in pics.indices) {
            list.add(itemInfo((i+1).toString(), pics[i], ((i+1)*(i+1)).toString()))
        }
        vp.adapter = infoPagerAdapter(supportFragmentManager, list)
        vp.currentItem = 0
    }

    public override fun onStart() {
        super.onStart()
        BGChangeRecever = myBgChangeRecever()

        val filiter = IntentFilter(BlankFragment.EVENT)//广播过滤器，过滤掉参数以外的广播
        registerReceiver(BGChangeRecever,filiter)//开始时注册接收器

    }

    public override fun onStop() {
        unregisterReceiver(BGChangeRecever)//结束前注销接收器
        super.onStop()
    }

    private inner class myBgChangeRecever : BroadcastReceiver() {//广播接收器
        override fun onReceive(context: Context?, intent: Intent?) {//接收广播后执行的操作
            if (intent != null) {
                val color = intent.getIntExtra("color", Color.GREEN)
                textView2.setTextColor(color)
            }
        }

    }
}
```
## 接收系统广播
### 静态注册
没学会
### 动态注册
```kotlin
class MainActivity : AppCompatActivity() {
    var receiver:broadCastRecever = broadCastRecever()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }

    override fun onDestroy() {
        super.onDestroy()
        receiver.unRegiste()
    }

    override fun onStart() {
        super.onStart()
        receiver.registe(this)
    }

    inner class broadCastRecever : BroadcastReceiver() {
        private var isRegisted = false
        var allBroadCast = arrayOf(Intent.ACTION_TIME_TICK, Intent.ACTION_SCREEN_ON, Intent.ACTION_SCREEN_OFF)
        var registTo:Context? = null
        override fun onReceive(context: Context?, intent: Intent?) {
            text.append("收到：${(intent?.action?:"empty")}\n")
        }
        fun registe(context: Context) {
            if (!isRegisted) {
                var filter:IntentFilter = IntentFilter()
                for (item in allBroadCast) {
                    filter.addAction(item)
                }
                context.registerReceiver(this@broadCastRecever, filter)
                isRegisted = true
                registTo = context
            }
        }
        fun unRegiste() {
            if (isRegisted) {
                registTo?.unregisterReceiver(this@broadCastRecever)
                isRegisted = false
            }
        }
    }
}

```
