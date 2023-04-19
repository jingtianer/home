---
title: Kotlin学习笔记——Spinner
date: 2019-04-12 21:15:36
tags: Kotlin-Android
categories: Kotlin-Android
toc: true
language: zh-CN
---

## android提供的spinner
```kotlin
class MainActivity : AppCompatActivity() {
    val strs = arrayOf("1", "2","3","4","5", "6", "7","8","9","10","11","12","13","14","15","16")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        val sp = findViewById<View>(R.id.spinner) as Spinner
        val startAdapter = ArrayAdapter(this, R.layout.support_simple_spinner_dropdown_item, strs)
        startAdapter.setDropDownViewResource(R.layout.support_simple_spinner_dropdown_item)
        sp.prompt = "请选择"
        sp.adapter = startAdapter
        sp.setSelection(0)
        var listen = myItemClickListener()
        sp.onItemSelectedListener = listen
    }
    internal inner class myItemClickListener : AdapterView.OnItemSelectedListener {
        override fun onNothingSelected(parent: AdapterView<*>?) {

        }
        override fun onItemSelected(parent: AdapterView<*>?, view: View?, position: Int, id: Long) {
            toast("你的选择是：${strs[position]}")
        }
    }
}
```
### 步骤
1. 一个`ArrayAdapter`，参数分别是`this`，`R.layout.support_simple_spinner_dropdown_item`，`Array<String>`（到时候的item）
2. 刚才的`ArrayAdapter`设置效率视窗资源，调用`setDropDownViewResource`函数，参数是`R.layout.support_simple_spinner_dropdown_item`
3. 把`ArrayAdapter`赋值给`spinner`的`adapter`成员
4. 设置默认选项，`setSelection`
5. 如果想让spinner为对话框形式的，在xml文件中设置`android:spinnerMode="Dialog"`,`spinner`的`prompt`成员为设置对话框标题的接口
6. 新建一个内部类，监听下拉选择，继承`AdapterView.OnItemSelectedListener`，重载`onNothingSelected`和`onItemSelected`两个方法
7. 新建监听器对象，通过`spinner`的`onItemSelectedListener`设置为监听器
## anko库提供的spinner——selector
```kotlin
    val strs = Arrayof("1", "2", "3")
    aTextView.text = "假装这是一个spinner，其实我是TextView"
    aTextView.setOnClickListener {
        selector("请选择", strs) { i -> 
            toast("你的选择是：${strs[i]}")
        }
    }
```
