---
title: 基础06-ViewGroup
date: 2025-5-09 21:15:36
tags: Android-官方源码
categories: 
    - Android
    - 手撸Android源码
toc: true
language: zh-CN
---

## dispatchTouchEvent

```mermaid
flowchart TD
    A[开始] --> B{过滤事件}
    B -->|true| C{是否ACTION_DOWN}
    B -->|false| D[返回false]
    C -->|true| E[清除TouchTargets，重置TouchState]
    C -->|false| F{111}
    E --> G[调用onInterceptTouchEvent]@{ shape: comment, label: "计算新事件的x，y，传递给child\n若child空，调用super.dispatchTouchEvent" }
    G --> J[处理hover事件]
    J --> F[遍历TouchTarget，调用dispatchTransformedTouchEvent传递event]
    F --> H[如果是up/cancel，重置TouchState]
    H --> I[返回是否handle]
```

### 过滤事件

- 如果this存在flag:`FILTER_TOUCHES_WHEN_OBSCURED`，event存在flag:`FLAG_WINDOW_IS_OBSCURED`，就丢掉
- window被上面的window遮住了，不管这个时间了

```java
public void setFilterTouchesWhenObscured(boolean enabled) {
    setFlags(enabled ? FILTER_TOUCHES_WHEN_OBSCURED : 0,
            FILTER_TOUCHES_WHEN_OBSCURED);
}
```

调用view的这个函数，就会设置这个flag
- 很神奇的是，很多系统的dialog会给positiveButton设置这个flag
    - PackageInstallerActivity
    - ConfirmDialog
    - MediaProjectionPermissionActivity

```java
// todo: 没找到什么时候set: FLAG_WINDOW_IS_OBSCURED
```