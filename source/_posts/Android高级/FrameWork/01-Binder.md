---
title: 01-Binder
date: 2024-3-24 21:15:36
tags: Android FrameWork
categories: Android
toc: true
language: zh-CN
---

> 看源码的时候可以用uml图辅助理解

## 多进程

### 为什么多进程

- 突破内存限制：Android系统在内存不足时，会优先杀占用内存多的**进程**
- 功能稳定性：把一些功能放到独立的进程中，保证进程功能的纯粹性和稳定性
- 规避系统内存泄漏：独立的WebView进程阻隔内存泄漏问题
- 隔离风险：不稳定功能放到子进程，保证主进程的稳定性


## Android中的进程间通信
- Binder
  - aidl
- Socket
- 管道：handler
- 共享内存
  - fresco，mmkv（匿名）
- 信号：
  - ANR监控
  - matrix、xcrash、友盟apm

## binder的优势

- 一次拷贝
  - 将内核空间内存映射到用户空间
  - a发送数据到b，binder直接将数据拷贝到与b共享的内存空间中
- cs架构，稳定性好
- 安全，有身份验证（交换pid，由内核完成

## AIDL

- DSL
  - aidl将dsl文件编译成Java

## 四大组件

- init启动
  - zygote
  - servicemanager

### bindService一共几次IPC

1. 客户端与ServiceManager交互获得AMS的IBinder
2. 客户端通过AMS的IBinder请求bindService
3. AMS与服务进程通信，调用onBind，获取IBinder
4. 服务端把IBinder交给AMS，先ServiceManager交互获得AMS的IBinder
5. 服务端通过AMS的IBinder发布自己的IBinder给AMS
6. AMS与客户端通信，转发服务端的IBinder（代理BinderProxy）

![](./images/bindService.png)

### binder数据传输的大小限制
- 1024*1024-4096*2
- BIND_VM_SIZE = 1M - sysconf(_SC_PAGE_SIZE) * 2
- aidl
  - 异步传输：oneway，BIND_VM_SIZE/2
  - 同步传输：BIND_VM_SIZE
### Binder其他知识
- 四棵红黑树
- Binder线程池

## Binder驱动

### binder_init
通过misc_register注册特殊设备

```c
static const struct file_operations binder_fops = {
    .owner = THIS_MODULE,
    .poll = binder_poll,
    .unlocked_ioctl = binder_ioctl,
    .compat_ioctl = binder_ioctl,
    .mmap = binder_mmap,
    .open = binder_open,
    .flush = binder_flush,
    .release = binder_release,
}; // 系统调用与驱动的对应关系

static struct miscdevice binder_miscdev = {
    .minor = MISC_DYNAMIC_MINOR, //次设备号 动态分配
    .name = "binder",     //设备名
    .fops = &binder_fops  //设备的文件操作结构，这是file_operations结构
};
```

### open -> binder_open

- 创建binder_proc结构并初始化
  - 保存进程信息
  - 加锁，计数++，hlist_add_head
- filp文件指针的private_data指向binder_proc

### mmap -> binder_mmap

```c
//地址偏移量 = 用户虚拟地址空间 - 内核虚拟地址空间
proc->user_buffer_offset = vma->vm_start - (uintptr_t)proc->buffer;
//异步可用空间大小为buffer总大小的一半。
proc->free_async_space = proc->buffer_size / 2;
```

### ioctl -> binder_ioctl

|ioctl命令|	数据类型|	操作|使用场景|
|-|-|-|-|
|BINDER_WRITE_READ|	struct binder_write_read	|收发Binder IPC数据|Binder读写交互场景，IPC.talkWithDriver|
|BINDER_SET_MAX_THREADS|	__u32	|设置Binder线程最大个数||
|BINDER_SET_CONTEXT_MGR|	__s32	|设置Service Manager节点|servicemanager进程成为上下文管理者，binder_become_context_manager()|
|BINDER_THREAD_EXIT|	__s32	|释放Binder线程||
|BINDER_VERSION|	struct binder_version	|获取Binder版本信息||

```c
static long binder_ioctl(struct file *filp, unsigned int cmd, unsigned long arg) {
    //进入休眠状态，直到中断唤醒
    ret = wait_event_interruptible(binder_user_error_wait, binder_stop_on_user_error < 2);
    binder_lock(__func__);
    //获取binder_thread
    thread = binder_get_thread(proc);

    switch (cmd) {
      case BINDER_WRITE_READ:  //进行binder的读写操作
          ret = binder_ioctl_write_read(filp, cmd, arg, thread);
          if (ret)
              goto err;
          break;
      // case ....:
        // xxxx  
    }
err:
    if (thread)
        thread->looper &= ~BINDER_LOOPER_STATE_NEED_RETURN;
    binder_unlock(__func__);
    wait_event_interruptible(binder_user_error_wait, binder_stop_on_user_error < 2);
err_unlocked:
    trace_binder_ioctl_done(ret);
    return ret;
}
```

- binder_get_thread
  - 从一颗红黑树上根据pid找当前线程
  - 如果没有，则创建节点
- binder_ioctl_write_read
  - copy_from_user读取bwr
  - 检查读写缓存中是否有数据，如果有，就执行读写
  - copy_to_user将bwr写回用户空间


### Binder层次结构

![](http://gityuan.com/images/binder/binder_dev/binder_ipc.jpg)

### Binder通信模型

![](http://gityuan.com/images/binder/binder_dev/binder_transaction_ipc.jpg)

#### 通信码
- 从ICP层至内核：`BC_`请求码
- 从内核到IPC层：`BR_`响应码

#### 过程

![](http://gityuan.com/images/binder/binder_dev/binder_protocol.jpg)

##### binder_thread_write
循环根据cmd处理请求
- `BC_FREE_BUFFER`
  - 通过mmap映射内存，ServiceManager映射空间为128K，Binder应用进程为`1M-8K`
  - allocated_buffers和free_buffers是两棵红黑树，分别存放已分配内存和未分配内存。分配内存时使用最佳适应算法。
- `BC_TRANSACTION`
  - 最常见的码，将交易转化成binder_work
  - Client向Binder驱动发送请求数据
- `BC_REPLY`
  - Server向Binder驱动发送请求数据

##### binder_thread_read

- 根据work和当前状态生成响应码，接下来由用户态进行处理

## ServiceManager

- servicemanager是操作系统的一个可执行文件，在init.rc中启动

### main

```c
int main(int argc, char **argv) {
    struct binder_state *bs;
    //打开binder驱动，申请128k字节大小的内存空间 
    bs = binder_open(128*1024); // 不是上面binder driver的binder_open
    //成为上下文管理者 
    binder_become_context_manager(bs);
    // 调用ioctl(bs->fd, BINDER_SET_CONTEXT_MGR, 0);
    //进入无限循环，处理client端发来的请求
    binder_loop(bs, svcmgr_handler);
    return 0;
}
```

#### binder_open

```c
struct binder_state *binder_open(size_t mapsize)
{
    struct binder_state *bs;
    struct binder_version vers;

    bs = malloc(sizeof(*bs));

    //通过系统调用陷入内核，打开Binder设备驱动
    bs->fd = open("/dev/binder", O_RDWR);
    // 调用上面驱动的binder_open，打开驱动，初始化，返回文件描述符

     //通过系统调用，ioctl获取binder版本信息
    // ioctl发送BINDER_VERSION，获取版本号与用户空间的版本号比较

    bs->mapsize = mapsize;
    //通过系统调用，mmap内存映射，mmap必须是page的整数倍
    bs->mapped = mmap(NULL, mapsize, PROT_READ, MAP_PRIVATE, bs->fd, 0);
    // 调用驱动的binder_mmap，建立内存映射
    return bs;
}
```

#### binder_become_context_manager

```c
ioctl(bs->fd, BINDER_SET_CONTEXT_MGR, 0);
->
binder_ioctl()
->
binder_ioctl_set_ctx_mgr()
->
// 创建binder_new_node，weak、strong引用数++，将节点加入proc红黑树
```

#### binder_loop

```c
readbuf[0] = BC_ENTER_LOOPER;
binder_write(bs, readbuf, sizeof(uint32_t));// 通过binider_write通知进入loop
for(;;) {
  res = ioctl(bs->fd, BINDER_WRITE_READ, &bwr);
  res = binder_parse(bs, 0, (uintptr_t) readbuf, bwr.read_consumed, func);
}
```

##### binder_write

```c
int binder_write(struct binder_state *bs, void *data, size_t len) {
    struct binder_write_read bwr;
    int res;

    bwr.write_size = len;
    bwr.write_consumed = 0;
    bwr.write_buffer = (uintptr_t) data; //此处data为BC_ENTER_LOOPER
    bwr.read_size = 0;
    bwr.read_consumed = 0;
    bwr.read_buffer = 0;
    res = ioctl(bs->fd, BINDER_WRITE_READ, &bwr);
    return res;
} 
// 就是通过ioctl传递消息，最终在驱动中找到thread，设置标志
// thread->looper |= BINDER_LOOPER_STATE_ENTERED;
```

##### binder_parse

```c
int binder_parse(struct binder_state *bs, struct binder_io *bio,
                 uintptr_t ptr, size_t size, binder_handler func) {
   // 分析binder的返回值
}
```