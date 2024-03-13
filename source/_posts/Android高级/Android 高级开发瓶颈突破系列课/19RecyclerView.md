---
title: 19-RecyclerView
date: 2024-03-12 11:15:36
tags: Android 高级开发瓶颈突破系列课
categories: Android
toc: true
language: zh-CN
---
## RecyclerView

- flexible:
- limited: 有限屏幕中显示
- large: 大量内容

## RecyclerView的优势
- Linear, Grid, Staggered Grid三种布局
- itemAnimator接口
- 强制实现ViewHolder
- 解耦设计
- 性能更好

### listView的局限
- 只能纵向列表
- 没有动画api
- api设计太个性了，和其他view设计的重复
- 性能不好

- 三个帮手
  - LayoutManager: 负责布局Views
  - ItemAnimator: 负责给View加动画
  - Adaptor: 提供views

## ViewHolder
- 一个ItemView对应一个Viewholder（缓存view，防止反复findViewById）

## RecycclerView缓存机制
- 对ViewHolder进行缓存，四级缓存，从上到下
  - scrap: 屏幕内的ItemView, 通过position找到，且数据依然有效，可以直接复用
  - cache: 默认为2,刚出屏幕的Item进行缓存，数据也是clean的，通过pos找到
  - ViewCacheExtension: 缓存几个固定不变的，复杂的item，每次可以重复使用
  - RecycledViewPool: dirty数据，需要重新绑定数据，根据view type缓存

### 对item展示次数的统计
- ListView: getView统计
- RecyclerView: onViewAttachedToWindow统计

### 性能优化
1. item监听：onCreateViewHolder时创建（全部共享一个、每个对象一个）
2. LinearLayoutManager.setInitialPrefetchItemCount():
   1. 需要在ItemView中创建子RecyclerView
   2. RenderThread（做渲染的线程）中，会做RecyclerView的prefetch
   3. 指定初始看到时需要显示的item数目
   4. 在内部嵌套的view中调用
3. RecyclerView.setHasFixedSize()
   1. RecyclerView有数据插入、删除时，根据这个flag选择是否重绘整个RecyclerView
   2. 如果Adapter数据变化不会影响RecyclerView的大小变化时，设置为true
4. 多个RecyclerView有相同的viewType，多个RecyclerView共享RecycledViewPool
5. DiffUtil
   1. 计算两个list的区别并生成把A列表转换为B列表的操作
   2. 解决的问题：最小化更新页面的操作，节省计算资源
      1. notifyItemXXX不适用于所有情况
      2. notifyDateSetChange: 整个list重新绘制+动画丢失
   3. 在列表很大时，异步计算diff
      1. Thread， handler
      2. RxJava
      3. ListAdapter， AsyncListDiffer


## payloads
## View Type
## ItemDecoration

- 画分割线
- 高亮
- 分组
## RecyclerView各种用法的demo
<a src="https://advancedrecyclerview.h6ah4i.com">AdvancedRecyclerView</a>
<iframe id="RecyclerViewIframe" src="https://advancedrecyclerview.h6ah4i.com" title="AdvancedRecyclerView" style="width:100%;"></iframe>


<script>
function resize_iframe(div) {
  const width = div.offsetWidth; 
  div.style.height = div.offsetWidth*4.0/3.0 + 'px';
  // console.log("resize height : " + div.style.height)
}
const div = document.getElementById('RecyclerViewIframe');
resize_iframe(div);
window.addEventListener('resize', function() {
  resize_iframe(div);
});
</script>