---
title: MIUISupermarket移植
date: 2024-07-13 11:28:00
tags: hexo
categories: misc
toc: true
language: zh-CN
---

## VerifyError
```java
java.lang.VerifyError: Verifier rejected class com.xiaomi.market.util.UIUtils: void com.xiaomi.market.util.UIUtils.setStatusBarDarkMode(android.app.Activity, boolean) failed to verify: void com.xiaomi.market.util.UIUtils.setStatusBarDarkMode(android.app.Activity, boolean): [0x15] type Undefined unexpected as arg to if-eqz/if-nez (declaration of 'com.xiaomi.market.util.UIUtils' appears in /data/app/~~pH0reBrzyfvMag1T-TAoDw==/com.xiaomi.market-EzZXS_MznmhQs5NCCbvqfA==/base.apk!classes2.dex)
```

- 一般出现VerifyError都是因为对smali代码修改，导致无法通过验证。当前遇到过的情况有：
  - 插入代码时无意覆盖了下面会用到的寄存器的值，导致寄存器类型不匹配等问题。
  - 对方法参数类型修改但未修改调用时传入的参数
  - 传递参数时传递了类型不匹配的参数

## ClassNotFound
在xiaomi商店中使用了`Lmiui/os/Build`类，该类继承`Landroid/os/Build`，且存在于小米系统中，导致类找不到。导致运行时闪退。

对于这类小米系统中才能获取到的类，采用等价替换的方法进行修复。如在`Lmiui/os/Build`中有：
- IS_INTERNATIONAL_BUILD
- IS_ALPHA_BUILD
- IS_DEVELOPMENT_VERSION
- IS_INTERNATIONAL_BUILD
- getRegion()
等字段和方法，可以在miui中查看一下对应的值，然后手动修改smali代码，将值替换为对应的值。

## Dex方法数限制
```java
org.jf.util.ExceptionWithContext: Error while writing instruction at code offset 0x2
```
在apktools打包smali时报错，
对smali修改时添加了很多方法，导致一个dex内方法数超过65,535，导致打包失败。

解决方法：在smali源码目录中新建文`sources_dex${n}`目录，将代码放入该位置，重新编译，即可将代码打包入新的dex文件中。

## 应用无法安装
MIUI魔改了PackageInstaller
当使用packageinstaller获取session写入安装包后，使用commit传入一个PendingIntent对象，用于接收应用安装结果的广播。而该通知的内容被魔改，导致收到原生系统的广播时，无法正确处理后续的逻辑，导致安装失败。

- 中间还尝试过使用`ACTION_VIEW`或`ACTION_INSTALL_PACKAGE`startActivity启动安装器，但这两个ACTION在安卓10后被废弃了，导致没有Activity响应该Intent，无法进行安装。
- 使用`ACTION`安装apk时，如果apk文件在私有存储空间内，要使用FileProvider。

## 未解决的问题
- 无法卸载
- 无法暂停任务
- 安装后没有调用session的abandon()方法
- 首页顶部标题栏与系统状态栏之间存在空白部分

## 另外

中间还有一个MIUISettingsProvider的类找不到，我当时直接把miui中的SettingsProvider替换到PixelOS的SettingsProvider中，导手机致变砖，救砖救了好久。