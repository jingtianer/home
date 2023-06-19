---
title: cha26.监控子进程
date: 2023-6-19 18:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 孤儿与僵尸

- 孤儿： 子进程结束前父进程未wait结束的进程。其父进程会变成1由init接管进行wait
- 僵尸： 父进程未结束，子进程已经结束，且父进程未执行wait。系统保留僵尸的进程表记录，以备未来父进程需要wait获取其结束状态
  - 无法被kill，只能kill其父进程

## 1

编写一程序以验证当一子进程的父进程终止时，调用getppid()将返回1（进程 init的进程ID)。

> 无聊，不弄

## 2

假设存在3个相互关联的进程（祖父、父及子进程)，祖父进程没有在父进程退出之后立即执行wait()，所以父进程变成僵尸进程。那么请指出孙进程何时被init进程收养（即孙进程调用getppid)将返回1)，是在父进程终止后，还是祖父进程调用wait()后?请编写程序验证结果。

```c
#include <stdio.h>
#include <sys/wait.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

#define CHECK(x) do {if(!(x)) {fprintf(stderr, "CHECK: %s\n", strerror(errno));} } while(0)

void son(pid_t child) {
    printf("son: pid = %d, ppid = %d\n", getpid(), getppid());
    kill(getppid(), SIGUSR2);
    sleep(1);
    for(int i = 0; i < 10; i++) {
        printf("son: pid = %d, ppid = %d\n", getpid(), getppid());
        sleep(1);
    }
}

void father(pid_t child) {
    printf("father: pid = %d, ppid = %d\n", getpid(), getppid());
    sleep(100);
}

void grandpa(pid_t child) {
    printf("grandpa: pid = %d, ppid = %d\n", getpid(), getppid());
    sleep(100);
}

void son_exit(int sig) {
    if(sig == SIGCHLD) {
        printf("gandpa: SIGCHLD\n");
        sleep(5);
        CHECK(wait(NULL) > 0);
        printf("gandpa: wait father\n");
        sleep(100);
    }
}

void killme(int sig) {
    if(sig == SIGUSR2) {
        printf("father: SIGUSR2, exit\n");
        _exit(0);
    }
}

int main() {
    sigaction(SIGCHLD, &(struct sigaction){
        .sa_handler=son_exit
    }, NULL);
    sigaction(SIGUSR2, &(struct sigaction) {
        .sa_handler=killme
    }, NULL);
    pid_t pid = fork();
    CHECK(pid >= 0);
    if(!pid) {
        pid_t pid1 = fork();
        CHECK(pid1 >= 0);
        if(!pid1) {
            son(pid1);
        } else {
            father(pid1);
        }
    } else {
        grandpa(pid);
    }
    return 0;
}
```

### 输出分析
```sh
grandpa: pid = 15308, ppid = 14448
father: pid = 15309, ppid = 15308
son: pid = 15310, ppid = 15309
father: SIGUSR2, exit
gandpa: SIGCHLD
son: pid = 15310, ppid = 38
son: pid = 15310, ppid = 38
son: pid = 15310, ppid = 38
son: pid = 15310, ppid = 38
gandpa: wait father
son: pid = 15310, ppid = 38
son: pid = 15310, ppid = 38
son: pid = 15310, ppid = 38
son: pid = 15310, ppid = 38
son: pid = 15310, ppid = 38
son: pid = 15310, ppid = 38
```

father退出后缺少被接管了，但是不是init

查了资料后发现是使用伪终端的原因

## 26.3
使用waitid()替换程序清单26-3 (child_status.c）中的 waitpid()。需要将对函数printWaitStatus()的调用替换为打印 waitid()所返回siginfo_t结构中相关字段的代码。

无聊，不搞

## 26.4
程序清单26-4(make_zombie.c）调用了sleep()，以便允许子进程在父进程执行函数system()前得到机会去运行并终止。这一方法理论上存在产生竞争条件的可能。修改此程序，使用信号来同步父子进程以消除该竞争条件。

fork前设置处理器函数，该函数longjmp到子进程执行位置
fork后父进程还原处理器函数，发送信号

就酱