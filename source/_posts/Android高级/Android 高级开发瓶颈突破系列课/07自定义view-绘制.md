---
title: 07-自定义view-绘制
date: 2023-10-24 21:15:36
tags: Android 高级开发瓶颈突破系列课
categories: Android
toc: true
language: zh-CN
---

## 坐标轴

![](./images/canvas_axis.webp)

## 尺寸单位

- 一律为像素

## api

### Canvas
画布
```java
drawLine
drawCircle
drawOval
drawBitmap
drawPathdraw
drawArc // 以一个矩形空间为参考，指定起始角度和终止角度，画一个弧线

save // 保存画布状态（栈
translate // 移动画布，其他变换还有translate,scale,rotate,skew,concat or clipRect等
restore //弹栈，恢复画布
// 移动画布不会影响已经绘制的图形的位置，restore也是

saved = saveLayer() // 为画布新建图层，当使用xfermode融合图像时，如果直接在旧图层上绘制，旧图层会造成干扰
// 在新图层上操作
restoreToCount(saved) // 恢复画布到保存的状态
```

## Path
```java
addRect
addCircle
addOval
addRoundRect
```

通过`canvas.drawPath`将path绘制

### 绘制方向
```java
path.setFillType
```
```java
public enum FillType {
    // these must match the values in SkPath.h
    /**
     * Specifies that "inside" is computed by a non-zero sum of signed
     * edge crossings.
     */
    WINDING         (0),
    /**
     * Specifies that "inside" is computed by an odd number of edge
     * crossings.
     */
    EVEN_ODD        (1),
    /**
     * Same as {@link #WINDING}, but draws outside of the path, rather than inside.
     */
    INVERSE_WINDING (2),
    /**
     * Same as {@link #EVEN_ODD}, but draws outside of the path, rather than inside.
     */
    INVERSE_EVEN_ODD(3);

    FillType(int ni) {
        nativeInt = ni;
    }

    final int nativeInt;
}
```

### 作用


判断一个点是否在图形内部

从该点向任意方向发射射线，路径上所有相交而非相切的位置中，若从左侧穿过射线，cnt++，右侧穿过，cnt--。若使用WINDING，最终cnt为0，则是在外部，否则在内部；若使用EVEN_ODD，最终cnt为奇数，点在内部，为偶数，点在外部

如果使用WINDING，需要两个图形相减的操作，则将两个图形的绘制方向设为相反的，这样相交部分的点就被认为在图形外部，而不会被涂色。

如果使用EVEN_ODD，需要两个图形相减的操作，不需要处理其绘制方向

## View.onSizeChanged
每次layout尺寸改变时会调用

## PathMeasure
测量一个path，
```java
getLength // 整个图像的周长
getPosTan // 获得从起点触发，绘制某个长度后的点所咋位置的正切值
```
### 用处

比如要做一个仪表盘，在某个位置画刻度，需要总长度计算刻度的间隔

### misc

- java里也有类似kotlin的init{}，只要在类中直接使用`{}`即可

```java
class XXX {
  {
    // init codes
  }
}
```

- BitmapFactry.Options
  - options.inJustDecodeBounds, 只获取长宽，不加在资源
- Xfermode
  - 是一种图像混合模式
  - ![](./images/xfermode.jpeg)

## paint
画笔，定义绘制时的各种特性
```java
setPathEffect // 使用一个path作为绘制的效果
setStyle
```
## dp2px
```java
TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dip, Resources.getSystem().displayMetrics)
```

注意这里通过getSystem获取的Resources是无法获取应用中定义的colors，strings等资源的
[官方文档](https://developer.android.com/reference/android/content/res/Resources#getSystem())对其的描述是:

> Return a global shared Resources object that provides access to only system resources (no application resources), is not configured for the current screen (can not use dimension units, does not change based on orientation, etc), and is not affected by Runtime Resource Overlay.
>

## 练习

### PieChart

### DashBoard

### AvatarView(drawbitmap)