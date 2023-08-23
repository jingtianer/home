---
title: cha39.能力
date: 2023-8-22 12:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 读书笔记

### 进程能力分为：
|类型|解释|
|-|-|
|许可集|进程可使用的能力，删除一个能力是不可逆的|
|有效集|进程当前能使用的能力|
|可继承集|exec之后，可以继承、进入许可集的能力集（规定被exec的文件可以继承哪些能力）|

### 文件能力分为：
|类型|解释|
|-|-|
|许可集|exec时添加到进程的许可集|
|有效集|1位，关闭，则exec后进程有效集为空；开启，exec后有效集为许可集|
|可继承集|文件可继承集与进程可继承集相交后，作为exec后可被继承、进入许可集的能力集合（规定被exec的文件可以继承哪些能力）|

### exec前后计算公式
![](./images/capability_formular.png)

cap_bset为能力边界集

## 39.1
使用capability修改35-2
```c
#include <sys/capability.h>

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sched.h>

void error(const char *file, int line,const char *str, ...) {
    va_list fmt;
    va_start(fmt, str);
    fprintf(stderr, "error:%s %s:%d\n", strerror(errno), file, line);
    vfprintf(stderr, str, fmt);
    fprintf(stderr, "\n");
    va_end(fmt);
}

#define ERROR(...) error(__FILE__, __LINE__, __VA_ARGS__); exit(1)
#define FAIL(...) error(__FILE__, __LINE__, __VA_ARGS__); return -1

int raiseCap(int cap) {
    cap_value_t caplist[1];
    cap_t capability = cap_get_proc();
    if(capability == NULL) {
        FAIL("");
    }
    caplist[0] = cap;
    if(cap_set_flag(capability, CAP_EFFECTIVE, 1, caplist, CAP_SET) == -1) {
        cap_free(capability);
        FAIL("");
    }
    if(cap_set_proc(capability) == -1) {
        cap_free(capability);
        FAIL("");
    }
    if(cap_free(capability) == -1) {
        FAIL("");
    }
    return 0;
}

int main(int argc, char *argv[]) {
    if(raiseCap(CAP_SYS_NICE) == -1) { ERROR("");}
    int j, policy;
    struct sched_param sp;

    if(argc < 3 || strrchr("rfo", argv[1][0]) == NULL) {
        ERROR("usage: %s policy priority pid...\n"
        "\tpolicy is r(RR), f(FIFO), "
        #ifdef SCHED_BATCH
            "b(BATCH), "
        #endif
        #ifdef SCHED_IDLE
            "i(IDLE), "
        #endif
        "or o(OTHER)"
        , argv[0]);
    }
    switch (argv[1][0]) {
        case 'r':
            policy = SCHED_RR;
            break;
        case 'f':
            policy = SCHED_FIFO;
            break;
#ifdef SCHED_BATCH
            case 'b':
            policy = SCHED_BATCH;
            break;
#endif
#ifdef SCHED_IDLE
            case 'i':
            policy = SCHED_IDLE;
            break;
#endif
        case 'o':
            policy = SCHED_OTHER;
            break;
        default:
            ERROR("unsupported policy:%s\n", argv[1]);
            break;
    }
    sp.sched_priority = atoi(argv[2]);
    for(int j = 3; j < argc; j++) {
        pid_t pid = atoi(argv[j]);
        if(sched_setscheduler(pid, policy, &sp) == -1) {
            ERROR("");
        }
    }
}
```

```sh
gcc practice39.1.c -o practice39.1 -lcap
sudo setcap "cap_sys_nice=pe" practice39.1
```