---
title: cha21.信号:信号处理器函数
date: 2023-5-23 18:05:00
tags: 
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 21.1
实现abort

```c
void __abort(void) {
    fflush(NULL);
    // 随便输出点什么吧
    void *buff = malloc(BUFSIZ);
    int cd = open("coredump", O_RDWR | O_CREAT, 0644);
    int mem = open("/proc/self/stack", O_RDONLY);
    size_t readsize;
    while((readsize = read(mem, buff, BUFSIZ)) > 0) {
        write(cd, buff, readsize);
    }
    close(cd);
    close(mem);
    // 后面这三行+fflush就够了吧
    printf("raise SIGABRT\n");
    raise(SIGABRT);
    printf("signal SIG_DFL\n");
    signal(SIGABRT, SIG_DFL);
    printf("raise SIGABRT\n");
    raise(SIGABRT);
    printf("__abort return\n");
}
```

## 读后感

### 可重入问题
这一章首先讲了信号处理器函数的可重入问题。这是由于执行信号处理器函数时，有可能再次触发信号，调用该函数。
1. 对于C库函数，大量存在对静态数据的修改，如printf，scanf
2. 对部分系统调用，也存在对静态数据的修改，如crypt，getpwnam等
3. 对全局变量，errno，对他们的修改都是不安全的。故而信号处理器函数中使用的全局变量必须定义为
```c
volatile sig_atomic __variable_name;
```
他们都是不可重入的，在信号处理器函数中使用都是不安全的。由此定义了`异步信号安全函数`，即 $$ 函数是可重入的或是信号处理器函数无法将其中断的 $$
POSIX，SUS指出了哪些函数是异步信号安全的函数，除此之外都是不安全的

值得注意的是:
- abort会对stdio流刷新，但依然是`异步信号安全的`。
- `exit`函数会对stdio流刷新，但不是`异步信号安全的`。（`_exit`安全）

### 终止信号处理函数

- _exit
- kill
- 非本地跳转（需要使用`sigsetjmp` `siglognjmp`，来保存sa_mask）
- abort

### 栈溢出

信号处理时，信号处理器函数的栈爆了，会产生SIGSEGV信号，为了保证这个信号的正常处理，分配一块"备选信号栈"。使用`sigaktstack`

### SA_SIGINFO
在使用sigaction时，如果使用SA_SIGINFO标志，会使其返回多余信息。`struct sigaction`中，函数指针位置是一个`union`，为两种函数签名之一（不带多余信息的和带多余信息的）。

### 系统调用的中断

- 使用while循环或宏

```c

while((cnt = read(xxx,xxx,xxx)) == -1 && errno == EINTR);
// or
#include <unistd.h>
NO_EINTR(cnt = read(xxx,xxx,xxx));
```

- SA_RESTART，使用该flag，部分系统调用，以及建立在其上的库函数，是可重启的；但某些系统调用，以及建立在其上的库函数，是绝对不会重启的。

某些Linux系统调用，未处理的停止信号会产生EINTR错误。当发生`SIGSTOP SIGTSTP SIGTTIN SIGTTOU`而进程停止，后有收到`SIGCONT`恢复进程后，就是产生这种错误。
- 对于sleep，也会被中断，但他不会产生错误，只是返回剩余秒数