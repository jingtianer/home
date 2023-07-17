---
title: cha35.进程优先级和调度
date: 2023-7-17 20:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 35.1
实现nice命令
```c
//
// Created by root on 7/17/23.
//
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/resource.h>

void error(const char *file, int line,const char *str, ...) {
    va_list fmt;
    va_start(fmt, str);
    fprintf(stderr, "error:%s %s:%d\n", strerror(errno), file, line);
    vfprintf(stderr, str, fmt);
    fprintf(stderr, "\n");
    va_end(fmt);
    exit(1);
}

#define ERROR(...) error(__FILE__, __LINE__, __VA_ARGS__)

int main(int argc, char **argv) {
    int prio = getpriority(PRIO_PROCESS, 0);
    if(argc == 1) {
        printf("%d\n", prio);
        return 0;
    }
    int cmd = 1;
    int n = 10;
    for(; cmd < argc; cmd++) {
        if(argv[cmd][0] == '-') {
            if(argv[cmd][1] == '-') {
                if(argv[cmd][2] == 'a') { // adjustment
                    char *end;
                    if((end = strchr(argv[cmd], '=')) != NULL) {
                        n = atoi(end+1);
                    }
                } else if (argv[cmd][2] == 'h') { // help
                    printf("Usage: nice [OPTION] [COMMAND [ARG]...]\n");
                } else if (argv[cmd][2] == 'v') { // version
                    printf("Written by MeowMeow Liu.\n");
                } else {
                    ERROR("未知的参数:%s", argv[cmd]);
                }
            } else {
                n = atoi(argv[cmd]+1);
            }
        } else {
            break;
        }
    }
    if(cmd < argc) {
        if(setpriority(PRIO_PROCESS, 0, prio + n) == -1)
            ERROR("setpriority");
        if(execvp(argv[cmd], &argv[cmd]) == -1)
            ERROR("execv");
    } else {
        ERROR("%s: a command must be given with an adjustment", argv[0]);
    }
    return 0;
}
```

## 35.2

编写一个与nice(1)命令类似的实时调度程序set-user-ID-root程序。这个程序的命令
行界面如下所示:
# ./rtsched policy priority command arg..
在上面的命令中，policy 中r表示SCHED RR，f表示SCHED FIFO。基于在9.7.1
节和38.3 节中描述的原因，这个程序在执行命令前应该丢弃自己的特权ID。

```c
//
// Created by root on 7/17/23.
//

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/resource.h>
#include <sched.h>

void error(const char *file, int line,const char *str, ...) {
    va_list fmt;
    va_start(fmt, str);
    fprintf(stderr, "error:%s %s:%d\n", strerror(errno), file, line);
    vfprintf(stderr, str, fmt);
    fprintf(stderr, "\n");
    va_end(fmt);
    exit(1);
}

#define ERROR(...) error(__FILE__, __LINE__, __VA_ARGS__)
const char *pol2str(int policy) {
    return policy == SCHED_RR ? "RR" : 
    policy == SCHED_FIFO ? "FIFO\n" : 
    #ifdef SCHED_BATCH 
    policy == SCHED_BATCH ? "BATCH" :
    #endif 
    #ifdef SCHED_IDLE 
    policy == SCHED_IDLE ? "IDLE" : 
    #endif 
    policy == SCHED_OTHER ? "OTHER" : "UNKNOWN";
}
int main(int argc, char **argv) {
    int argi = 1;

    if (argc < 3){
        printf("policy = %s\n", pol2str(sched_getscheduler(getpid())));
        printf("Usage: %s policy priority [--help] command...\npolicy:\n"
              "r\tRR\n"
              "f\tFIFO\n"
#ifdef SCHED_BATCH
                      "b\tBATCH\n"
#endif
#ifdef SCHED_IDLE
                      "i\tIDLE\n"
#endif
                      "o\tOTHER\n", argv[0]
        );
    return 0;
}
    int policy = 0;
    switch (argv[argi][0]) {
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
            ERROR("unsupported policy:%s\n", argv[argi]);
            break;
    }
    argi++;
    struct sched_param schedParam;
    schedParam.sched_priority = atoi(argv[argi]);
    argi++;
    if(argv[argi][0] == '-') { // --help -h
        ERROR("policy=%s, min=%d, max=%d", pol2str(policy), 
                sched_get_priority_min(policy), sched_get_priority_max(policy));
        argi++;
    }
    setuid(getuid());
    if(sched_setscheduler(0, policy, &schedParam) == -1) {
        ERROR("sched_setscheduler");
    }
    if(execvp(argv[argi], &argv[argi]) == -1) {
        ERROR("execvp");
    }
    return 0;
}
```
## 35.3

编写一个运行于SCHED FIFO调度策略下的程序，然后创建一个子进程。在两个
进程中都执行一个能导致进程最多消耗3秒CPU时间的函数。(这可以通过使用
一个循环并在循环中不断使用 times()系统调用来确定累积消耗的CPU时间来完
成。每当消耗了 1/4秒的CPU时间之后，函数应该打印出一条显示进程ID和迄
今消耗的CPU时间的消息。每当消耗了1秒的CPU 时间之后，函数应该调用
sched yield0来将CPU释放给其他进程另一种方法是进程使用sched setparam(
提升对方的调度策略。)从程序的输出中应该能够看出两个进程交替消耗了1秒
的CPU时间。(注意在35.3.2节中给出的有关防止失控实时进程占住CPU的建
议。)

```c
#include <stdio.h>
#include <sched.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/times.h>
#include <stdlib.h>
#include <limits.h>
#include <signal.h>
#include <time.h>
#include <sys/wait.h>

#define CHECK(x) do { if(!(x)) { fprintf(stderr, "%s:%d\nerror: %s\n", __FILE__, __LINE__, strerror(errno)); } } while(0)

void handler(int sig) {
    printf("PID:%d received signal:%d(%s)\n", getpid(), sig, strsignal(sig));
    exit(0);
}

int main() {
    CHECK(signal(SIGALRM, handler) != SIG_ERR);
    timer_t timerid;
    CHECK(sched_setscheduler(0, SCHED_FIFO, &(struct sched_param){.sched_priority=sched_get_priority_max(SCHED_FIFO)}) != -1);
    long tck = sysconf (_SC_CLK_TCK) >> 2;
    pid_t pid;
    CHECK((pid = fork()) != -1);
    struct tms *cputm, *oldtm;
    cputm = malloc(sizeof(struct tms));
    oldtm = malloc(sizeof(struct tms));
    CHECK(times(oldtm) != (clock_t) -1);
    CHECK(timer_create(CLOCK_PROCESS_CPUTIME_ID, &(struct sigevent) {
        .sigev_signo=SIGALRM,
        .sigev_notify=SIGEV_SIGNAL

    }, &timerid) != -1);
    CHECK(timer_settime(timerid, 0, &(struct itimerspec) {
            .it_interval = {.tv_nsec = 0,.tv_sec = 0},
            .it_value = {.tv_sec = 13,.tv_nsec = 0}
    }, NULL) != -1);
    for(long i = 0; i < 12;) {
        CHECK(times(cputm) != (clock_t) -1);
        long inc = ((cputm->tms_utime + cputm->tms_stime) - (oldtm->tms_utime + oldtm->tms_stime)) / tck;
        if(inc >= 1) {
            struct tms *t = cputm;
            cputm = oldtm;
            oldtm = t;
            i += inc;
            fprintf(stderr, "PID=%d, CPU=%.2lfs\n", getpid(), i/4.0);
        }
        if(i % 4 == 0) {
            CHECK(sched_yield() != -1);
        }
    }
    CHECK(timer_settime(timerid, 0, &(struct itimerspec) {
            .it_interval = {.tv_nsec = 0,.tv_sec = 0},
            .it_value = {.tv_sec = 0,.tv_nsec = 0}
    }, NULL) != -1);
    CHECK(timer_delete(timerid) != -1);
    if(!pid) CHECK(wait(NULL) != -1);
    return 0;
}
```

## 35.4

如果两个进程在一个多处理器系统上使用管道来交换大量数据，那么两个进程
运行在同一个CPU上的通信速度应该要快于两个进程运行在不同的CPU上
其原因是当两个进程运行在同一个 CPU 上时能够快速地访问管道数据，因为
管道数据可以保留在 CPU的高速缓冲器中。相反，当两个进程运行在不同的
CPU上时将无法享受CPU高速缓冲器带来的优势。读者如果拥有多处理器系
统可以编写一个使用sched setaffinity0强制将两个进程运行在同一个CPU上
或运行在两个不同的CPU上的程序来演示这种效果。(第44 章描述了管道的
使用。)

```c
//
// Created by root on 7/17/23.
//

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <sched.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#define CHECK(x,...) do { if(!(x)) { fprintf(stderr, "%s:%d\n", __FILE__, __LINE__); fprintf(stderr, __VA_ARGS__); exit(2); } } while(0)
#define CHECKERR(x) do { if(!(x)) { fprintf(stderr, "%s:%d\nerror: %s\n", __FILE__, __LINE__, strerror(errno)); exit(1); } } while(0)

int main(int argc, char **argv) {
    char buffer[4096];
    CHECK(argc == 2, "Usage:%s cpuid\n", argv[0]);
    int cpuid = atoi(argv[1]);
    cpu_set_t *set = malloc(sizeof(cpu_set_t));
    CPU_ZERO(set);
    CPU_SET(cpuid, set);
    CHECKERR(sched_setaffinity(0, 1, set) != -1);
    ssize_t readsize;
    while((readsize = read(STDIN_FILENO, buffer, 4096)) > 0) {

        CHECKERR(write(STDOUT_FILENO, buffer, readsize) == readsize);
    }
    CHECKERR(readsize == 0);
    free(set);
    return 0;
}
```

### 测试

```sh
time `find / | ./practice35.4 1 | ./practice35.4 1`
time `find / | ./practice35.4 2 | ./practice35.4 3`
```

经过几次测试，确实同一个cpu会快一点