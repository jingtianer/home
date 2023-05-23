---
title: cha20.信号:基本概念
date: 2023-5-23 18:05:00
tags: 
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---


## 20.2
展示`SIG_IGN`一定不会收到信号
```c
//
// Created by root on 5/23/23.
//

#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main() {
    signal(SIGINT, SIG_IGN);
    printf("set SIGINT(%s) as SIG_IGN. always ignore ctrl-c\n", strsignal(SIGINT));
    for(int i = 16; i >= 0; i--) {
        sleep(1);
        printf("sleep %ds, try press ctrl-c\n", i);
    }
    signal(SIGINT, SIG_DFL);
    printf("set SIGINT(%s) as SIG_DFL. always take default action for ctrl-c\n", strsignal(SIGINT));
    for(;;) {
        usleep(500000);
        printf("try press ctrl-c\n");
    }
    return 0;
}
```

## 20.3

展示`sigaction`时，`sa_nodefer`和`sa_resethand`的作用

```c
//
// Created by root on 5/23/23.
//

#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

void sigint_handler(int sig) {
    if(sig != SIGINT) {
        return;
    }
    printf("喵！\n");
    sleep(1);
    // sa_nodefer处理过程中，不阻塞sigint
    // 此时连续按ctrl-c，可以喵很多次
    printf("汪！\n");
}


int main() {
    sigaction(SIGINT, &(struct sigaction){
            .sa_handler = sigint_handler,
            .sa_flags = SA_NODEFER,
    }, NULL);
    printf("set SIGINT(%s) as SA_NODEFER\n", strsignal(SIGINT));
    for(int i = 16; i >= 0; i--) {
        sleep(1);
        printf("sleep %ds, try press ctrl-c\n", i);
    }
    sigaction(SIGINT, &(struct sigaction){
            .sa_handler = sigint_handler,
            .sa_flags = SA_RESETHAND,
    }, NULL);
    printf("set SIGINT(%s) as SA_RESETHAND\n", strsignal(SIGINT));
    for(;;) {
        usleep(500000);
        printf("try press ctrl-c\n");
    }
    return 0;
}
```

### sa_nodefer


sa_nodefer处理过程中，不阻塞sigint，此时连续按ctrl-c，可以喵很多次

> sleep的信号好像也被sigint干扰了

#### sa_resethand

等于sa_oneshot，执行一次，恢复默认

## 20.4
sigaction实现siginterrupt

### siginterrupt
[来源](https://blog.csdn.net/zhizhengguan/article/details/117332391)

```c
NAME
    siginterrupt - 允许信号中断系统调用 

SYNOPSIS
    #include <signal.h>

    int siginterrupt(int sig, int flag);

DESCRIPTION
    当系统调用被信号sig中断时，siginterrupt（）函数将更改重新启动行为。 如果flag参数为false（0），
    则如果被指定的信号sig中断，则将重新启动系统调用。 这是Linux中的默认行为。 

    如果flag参数为true（1）并且未传输任何数据，则被信号sig中断的系统调用将返回-1，并且errno将设置为EINTR。

    如果flag参数为true（1）并且数据传输已开始，则系统调用将被中断，并将返回实际传输的数据量。 

RETURN VALUE
    siginterrupt（）函数成功返回0。 如果信号编号sig无效，则返回-1，并将errno设置为指示错误原因。 
```

### 代码
```c
//
// Created by root on 5/23/23.
//

#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>

#define true 1
#define false 0
#define isTrue(x) ((x) != 0)
#define isFalse(x) ((x) == 0)


void sigint_handler(int sig) {
    if(sig != SIGINT) {
        return;
    }
    printf("喵！\n");
    printf("汪！\n");
}

int __siginterrupt(int __sig, int __interrupt) {
    struct sigaction sigact, sigact1;
    sigaction(__sig, &sigact1, &sigact);
    if(isTrue(__interrupt)) {
        // add SA_RESTART
        sigact.sa_flags |= SA_RESTART;
    } else {
        // sub SA_RESTART
        sigact.sa_flags &= ~SA_RESTART;
    }
    return sigaction(__sig, &sigact, NULL);
}

int main() {
    void *buf[BUFSIZ];
    sigaction(SIGINT, &(struct sigaction) {
        .sa_handler = sigint_handler,
        .sa_flags = SA_NODEFER,
    }, NULL);
    __siginterrupt(SIGINT, false);

    pid_t pid = fork();

    if(pid == 0) {
        kill(getppid(), SIGINT);
    } else {
        int fd = open("/proc/self/status", O_RDONLY);
        size_t read_num = 0, write_num;
        if ((read_num = read(fd, buf, BUFSIZ)) == -1) {
            printf("read_num = %lu\n", read_num);
            printf("fail to read /proc/self/status, %s\n", strerror(errno));
            return errno;
        }
        if ((write_num = write(STDOUT_FILENO, buf, read_num)) != read_num) {
            printf("write_num = %lu\n", write_num);
            printf("fail to write STDOUT_FILENO, %s\n", strerror(errno));
            return errno;
        }
    }
    return 0;
}
```
验证不太成功，可以参考[这篇文章](https://blog.csdn.net/zhizhengguan/article/details/117332391)，创建并等待消息队列