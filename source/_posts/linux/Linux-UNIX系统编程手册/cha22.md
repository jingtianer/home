---
title: cha22.信号:高级特性
date: 2023-5-30 18:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 读书笔记

### 核心转储文件
- 特定信号会引发进程创建核心转储文件（工作目录）并终止。

- 核心转储文件(`core`)是内存映像的一个文件，利用调试器可以查看到退出时的代码、数据状态。

- P371展示了不会产生核心转储文件的情况，大致为
  - 没有写权限
  - 存在硬链接大于1的同名文件
  - 目录不存在
  - ulimit等限制为0
  - 二进制程序没有读权限
  - 工作目录的挂载方式为只读
  - set-user/group-ID程序运行者为非文件属主（组）

- /proc/sys/kenel/core_pattern中存储了核心转储文件的命名格式化字符串

### 信号处理、传递特殊情况

- SIGKILL和SIGSTOP的默认行为无法改变，无法阻塞。总是可以使用该信号处理失控进程。
  - 前面读书不认真
  - 信号阻塞即对该信号的传递延后，直到该信号从掩码中移除。
  - 除非是实时信号，否则不对阻塞信号排队，恢复信号后只传递该信号一次

- SIGCONT恢复停止的进程
  - SIGCONT总会恢复运行，不论该信号是否被阻塞或忽略
  - 在停止的进程恢复之前，若有其他进程传递其他信号，则该信号并未被真实传递。（除了sigkill）
  - 收到SIGCONT时，处于等待状态的停止信号将会被丢弃。反过来，收到停止信号后，等待状态的SIGCONT也会被丢弃

- 若由终端产生的信号（SIGHUP SIGINT SIGQUIT SIGTTIN SIGTTOU SIGTSTP）被忽略，则不应该改变其信号处置（处理函数）
  - 这个很难懂，后面34章会讲

### sigkill的力所不能及

进程休眠时，有两种休眠状态
- 可打断(TASK_INTERRUPTIBLE)，ps命令中标记为S。如等待终端输入
- 不可打断(TASK_UNINTERRUPTIBLE)，ps命令中标记为D。如等待磁盘IO完成

在不可打断休眠时，直到脱离这种状态，任何信号（包括sigkill）都不会被传递

如果由于各种BUG导致进程持续不可打断的方式kill，该进程只能通过重启的方式消灭

linux2.6加入了TASK_KILLABLE，类似于不可打断状态，但是可以由致命信号唤醒

### 硬件产生的信号

硬件异常产生的信号一般不设置能正常返回的信号处理器函数，也不将其忽略、阻塞。

若返回，将会重复触发异常
若忽略或阻塞，以除0错误为例，此时该如何继续运行呢

一般接受默认行为，或信号处理函数中longjmp或退出（不要正常返回）

### 信号的同步生成和异步生成
信号产生一般是异步的，也就是不确定是否会立刻传递信号
对于：
- 硬件产生信号
- raise, kill, killpg向自身发送的信号

是同步产生的，会立刻传递

### 信号传递的时机与顺序

#### 传递

- 同步信号
  - 硬件产生的信号会立即传递，raise在调用返回之前就会发出信号
- 异步信号
  - 进程再次获得调度，时间片开始时
  - 内核态到用户态的下一次切换时（系统调用的完成时）
    - 书上此处标注了信号的传递可能引起正在阻塞的系统调用过早地完成。不知道为啥要提到他

#### 解除多个信号的阻塞时

解除时，会立刻传递等待中的信号，并且按照信号升序传递

当一个处理器发生用户态和内核态的切换时，会转去调用第二个信号的函数

#### signal的实现

早期的signal实现
- 进入处理器函数，会自动恢复默认行为。可以手动再次调用signal，但会导致再次设置之前的信号依旧执行默认行为
- 信号处理器执行过程中不阻塞新信号。过多信号可能导致导致栈溢出
-  早期的实现不支持自动重启功能(SA_RESTART)

当前提供的都是可靠信号，使用`OLD_SIGNAL`条件测试宏编译可展示早期的不可靠语义

最好使用`sigaction`（考虑到可移植性问题）

### 实时信号

实时信号在POSIX的信号基础上进行了扩展
- 信号范围更大
- 使用队列管理（长度有上限`sysconf(_SC_SIGQUEUE_MAX)`）
- 保证了信号到达的顺序，数量
- 可以在传递实时信号时同时传递一个整型值或一个指针
  - 为一个包含int和指针的union，对该union的解释交由程序处理
  - 必须使用`SA_SIGINFO`从中获取上面的union


## 题目

### 22.1
验证：对`SIGCONT`设置信号处理器并屏蔽，暂停该进程，发送`SIGCONT`恢复进程，当且仅当取取消对`SIGCONT`的屏蔽，才会调用其处理器

```c
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <time.h>

void handler(int sig) {
    printf("handler, received sig:%d, %s\n", sig, strsignal(sig));
}

int main() {
    sigset_t sigset, osigset;
    signal(SIGCONT, handler);
    sigemptyset(&sigset);
    sigaddset(&sigset, SIGCONT);
    sigprocmask(SIG_BLOCK, &sigset, &osigset);
    printf("block SIGCONT\npid = %u\n", getpid());
    for(time_t t = time(NULL); time(NULL) < t + 10;) {

    }
    printf("received SIGCONT\n");
    printf("unblock SIGCONT\n");
    sigprocmask(SIG_SETMASK, &osigset, NULL);
    return 0;
}
```

### 22.2

假设一个信号和一个实时信号都被阻塞了，当恢复阻塞后，传递顺序是怎样的

```c
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <time.h>
#include <sys/wait.h>

void handler(int sig, siginfo_t *siginfo, void *ucontext) {
    printf("handler, received sig:%d, %s, ", sig, strsignal(sig));
    printf("sig type = %s\n",
           (siginfo->si_code == SI_USER) ? "sig" : \
           (siginfo->si_code == SI_QUEUE) ? "rt-sig" : "other"
           );
}

int main() {
    sigset_t sigset, osigset;
    sigemptyset(&sigset);

    for(int i = 1; i < 64; i++) {
        sigaction(i, &(struct sigaction) {
            .sa_flags=SA_SIGINFO,
            .sa_sigaction=handler
        }, NULL);
        sigaddset(&sigset, i);
    }

    sigprocmask(SIG_BLOCK, &sigset, &osigset);
    printf("block\npid = %u\n", getpid());
    pid_t pid = fork();
    if(!pid) {
        pid_t ppid = getppid();
        int rtsig = SIGRTMIN+1;
        sigqueue(ppid, rtsig, (union sigval) {
                .sival_int=1
        });
        kill(ppid, SIGUSR1);
        printf("send rt_sig=%d, sig=%d to parent, ppid = %u\n", rtsig, SIGUSR1, ppid);

        rtsig = SIGRTMIN+2;
        kill(ppid, SIGUSR2);
        sigqueue(ppid, rtsig, (union sigval) {
                .sival_int=1
        });
        printf("send rt_sig=%d, sig=%d to parent, ppid = %u\n", rtsig, SIGUSR1, ppid);
        return 0;
    }
    for(time_t t = time(NULL); time(NULL) < t + 10;) { }
    printf("unblock\n");
    sigprocmask(SIG_SETMASK, &osigset, NULL);
    wait(NULL);
    return 0;
}
```

### 结论

先RT，再普通

```sh
block
pid = 31633
send rt_sig=35, sig=10 to parent, ppid = 31633
send rt_sig=36, sig=10 to parent, ppid = 31633
unblock
handler, received sig:36, Real-time signal 2, sig type = rt-sig
handler, received sig:35, Real-time signal 1, sig type = rt-sig
handler, received sig:17, Child exited, sig type = other
handler, received sig:12, User defined signal 2, sig type = sig
handler, received sig:10, User defined signal 1, sig type = sig
```

### 22.3
22.10节指出，接收信号时，利用sigwaitinfo()调用要比信号处理器外加sigsuspend()调用的方法来得快。随本书发布的源码中提供的signals/sig_speed_ sigsuspend.c程序使用sigsuspend()在父、子进程之间交替发送信号。请对两进程间交换一百万次信号所花费的时间进行计时。(信号交换次数可通过程序命令行参数来提供。）使用sigwaitinfo()作为替代技术来对程序进行修改,并度量该版本的耗时。两个程序间的速度差异在哪里?

```c
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <sys/wait.h>
#include <stdbool.h>
#include <time.h>
#include <stdlib.h>
#ifndef SIGNUM
#define SIGNUM 100
#endif

void handler(int sig, siginfo_t *siginfo, void *ucontext) {
    printf("\"%s\", handler received sig:%d, from:%u, info:%d\n", strsignal(sig), sig, siginfo->si_pid, siginfo->si_value.sival_int);
}


int fork_main(pid_t pid, int sig, sigset_t *oset, sigset_t *sigset) {
#ifdef SIGWAITINFO
    siginfo_t *siginfo = malloc(sizeof(siginfo_t));
#endif
    sigqueue(pid, sig, (union sigval) {
            .sival_int = 0
    });
    printf("pid: %u, send to: %u\n", getpid(), pid);
    for(int i = 1; i < SIGNUM; i++) {
#ifdef SIGWAITINFO
        sigwaitinfo(sigset, siginfo);
        printf("\"%s\", sigwaitinfo received sig:%d, from:%u, info:%d\n", strsignal(sig), sig, siginfo->si_pid, siginfo->si_value.sival_int);
#endif
#ifdef SIGSUSPEND
        sigsuspend(oset);
#endif
        sigqueue(pid, sig, (union sigval) {
                .sival_int = i
        });
        printf("pid: %u, send to: %u\n", getpid(), pid);
    }
#ifdef SIGWAITINFO
    free(siginfo);
#endif
}


int main() {
    sigset_t sigset, oset;
    sigemptyset(&sigset);
    sigaddset(&sigset, SIGUSR1);
    sigaddset(&sigset, SIGUSR2);
    sigprocmask(SIG_BLOCK, &sigset, &oset);
    sigaction(SIGUSR1, &(struct sigaction) {
            .sa_flags = SA_SIGINFO,
            .sa_sigaction = handler
    }, NULL);
    sigaction(SIGUSR2, &(struct sigaction) {
            .sa_flags = SA_SIGINFO,
            .sa_sigaction = handler
    }, NULL);
    pid_t pid = fork();
    printf("pid = %u\n", pid);
    if(!pid) {
        fork_main(getppid(), SIGUSR2, &oset, &sigset);
    } else {
        fork_main(pid, SIGUSR1, &oset, &sigset);
        wait(NULL);
    }
    return 0;
}
```

### 分析

- 测试脚本
```sh
gcc -DSIGNUM=1000 -DSIGWAITINFO practice22.3.c -o practice22.3
time ./practice22.3 > SIGSUSPEND
gcc -DSIGNUM=1000 -DSIGSUSPEND practice22.3.c -o practice22.3
time ./practice22.3 > SIGSUSPEND
```

测试很多次，sigwaitinfo确实会快一点。偶尔系统时间很少，总体三个时间都小于sigsuspend
```sh
root@tt-surfacepro6:~/linux/cha22# ./practice22.3.sh 

real    0m0.076s
user    0m0.008s
sys     0m0.057s

real    0m0.084s
user    0m0.000s
sys     0m0.069s
root@tt-surfacepro6:~/linux/cha22# ./practice22.3.sh 

real    0m0.115s
user    0m0.000s
sys     0m0.076s

real    0m0.126s
user    0m0.018s
sys     0m0.067s

```