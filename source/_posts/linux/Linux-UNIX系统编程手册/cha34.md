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
假设一个父进程执行了下面的步骤。
这个应用程序设计可能会碰到什么问题?考虑 shell 管道。
如何避免此类问题的发生?
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

### 避免
记录每个子进程的pid，依次给每个pid发送信号，避免使用killpg或kill时使用负值pid

## 34.2
编写一个程序来验证父进程能够在子进程执行exec0之前修改子进程的进程组ID
但无法在执行exec0之后修改子进程的进程组ID。
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

## 34.3

编写一个程序来验证在进程组首进程中调用setsid会失败

```c
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
int main() {
    if(setsid() == -1) {
        fprintf(stderr, "error: %s\n", strerror(errno));
    }
}
```

### 结果

```sh          
error: Operation not permitted
```

## 34.4

修改程序清单34-4 (disc_SIGHUP.c)来验证当控制进程在收到 SIGHUP 信号而不终止时，内核不会向前台进程组中的成员发送SIGHUP信号。

```c
#include <stdio.h>
#include <errno.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>
#define CHECK(x) do { if(!(x)) { fprintf(stderr, "CHECK: %s, %s:%d\n", strerror(errno), __FILE__, __LINE__); } } while(0)

void handler(int sig) {
    printf("PID=%ld received signal: %d(%s)\n", (long) getpid(), sig, strsignal(sig));
}

int main(int argc, char **argv) {
    setbuf(stdout, NULL);
    if(argc < 2) {
        printf("Usage: exec %s [enable-sighup|disable-sighup] [d|s]...\n", argv[0]);
    }
    printf("PID=%ld, PGID=%ld (parent)\n", (long)getpid(), (long) getpgrp());
    if(argv[1][0] == 'd') {
        CHECK(signal(SIGHUP, handler) != SIG_ERR);
    }
    for(int i = 2; i < argc; i++) {
        pid_t pid;
        CHECK((pid = fork()) != -1);
        if(!pid) {
            if(argv[i][0] == 'd') {
                CHECK(setpgid(0, 0) != -1);
            }
            CHECK(signal(SIGHUP, handler) != SIG_ERR);
            break;
        }
    }
    printf("PID=%ld, PGID=%ld\n", (long)getpid(), (long) getpgrp());
    alarm(60);
    for(;;) pause();
    getpgid(getpid());
}
```

### 总结
嗯，确实是这样

- 复习知识
  - alarm到期发送SIGALARM，默认行为是结束进程
  - getpgrp是获取当前进程的进程组id，getpgid是获得参数pid指定进程的进程组id
  - signal函数失败时的返回值是`SIG_ERR`


## 34.5

假设将程序清单34-6中的信号处理器中解除阻塞SIGTSTP信号的代码移动到处理器的开头部分。这样做会导致何种竞争条件?