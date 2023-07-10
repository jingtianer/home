---
title: cha34.进程组、会话和作业控制
date: 2023-7-10 20:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 读书笔记

## 34.1

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>

void handler(int sig){
    printf("%d, received %d(%s)\n", getpid(), sig, strsignal(sig));
}

int main() {
    sigset_t set;
    sigemptyset(&set);
    sigaddset(&set, SIGUSR1);
    signal(SIGUSR1, handler);
    for(int i = 0; i < 10; i++) {
        pid_t pid;
        if((pid = fork()) == 0) {
            pause();
            return 0;
        } else {
            printf("child-%d: %d\n", i, pid);
        }
    }
    signal(SIGUSR1, SIG_IGN);
    killpg(getpgrp(), SIGUSR1);
    waitpid(-1, NULL, 0);
}
```

- 假设不发送SIGUSER时
  - 当不使管道时，可以看到有小于等于10个子进程显示收到`SIGUSER1`
  - 如果使用管道，会发现`child-%d: %d`被重复输出了多次，这是由于`stdout`被重定向后变成了全缓冲，fork的子进程退出后fflush()时会将fork前未flush的数据打印出来。
- 假设执行该命令`./practice34.1 | cat`，输出会是`User defined signal 1`，即`cat`与程序同属一个进程组，cat也会收到该信号，导致无法正常执行（非预期内）

## 34.2

```c
//
// Created by root on 7/10/23.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>
#include <sys/wait.h>
#include <errno.h>

pid_t pid;
void parent_handler(int sig) {
    printf("pid = %d, recv sig-%d(%s), setpgid pid=%d, pgid=%d\n", getpid(), sig, strsignal(sig), pid, getpgid(getpid()));
    if(setpgid(pid, getpgid(getpid())) == -1) {
        printf("setpgid fail, %d， err:%s\n", __LINE__, strerror(errno));
    }
    printf("newpgid pid=%d, pgid=%d\n", pid, getpgid(pid));
    kill(pid, SIGUSR1);
}

int main(int argc, char **argv) {
    if(argc == 1) {
        printf("before fork, pgid=%d\n", getpgid(getpid()));
        if((pid = fork()) == 0) {
            printf("before exec, pid = %d, gid = %d\n", getpid(), getpgrp());
            fflush(stdout);
            int len = snprintf(NULL, 0, "%d", getppid());
            char *spid = malloc(len + 1);
            sprintf(spid, "%d", getppid());
            if(spid) {
                fflush(stdout);
                if(execl(argv[0], argv[0], spid) == -1) {
                    printf("execl error!\n");
                }
            } else {
                printf("error: malloc, len = %d\n", len);
            }
        } else {
            // 父进程先执行
            signal(SIGUSR1, parent_handler);
            setpgid(pid, 0);
//            kill(pid, SIGUSR1);
            wait(NULL);
        }
    } else {
        printf("exec pid = %d, gid = %d\n", getpid(), getpgrp());
        kill(atoi(argv[1]), SIGUSR1);
        pause();
    }
}
```

可以看到，在`parent_handler`中，对子进程修改pgid后再次查询其pgid，并没有改变
报错为`Permission denied`