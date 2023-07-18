---
title: cha36.进程资源
date: 2023-7-18 20:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 36.1
编写一个程序使用getrusage0 RUSAGE CHILDREN标记获取wait调用所等待的
子进程相关的信息。(让程序创建一个子进程并使子进程消耗一些 CPU 时间，接着
让父进程在调用wait0前后都调用getrusage0。
```c
//
// Created by root on 7/18/23.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/wait.h>
#include <sys/times.h>
#include <unistd.h>
#include <limits.h>
#include <sys/resource.h>

#define CHECK(x) \
        do {     \
            if(!(x)) { \
                fprintf(stderr, "%s:%d\nerror: %s\n", __FILE__, __LINE__,strerror(errno)); \
                exit(0); \
            }    \
        } while(0)



#define rcputime(rusage, xtime) rusage.xtime.tv_sec + rusage.xtime.tv_usec/1000000.0
int main(int argc, char **argv) {
    long tic = sysconf(_SC_CLK_TCK);
    long tottm = 0;
    for(int i = 1; i < argc; i++) {
        char *end = NULL;
        long sec = strtol(argv[i], &end, 10);
        tottm += sec;
        CHECK(end != argv[i] && errno == 0);
        if(!fork()) {
            struct tms tms, start;
            CHECK(times(&start) != (clock_t) -1);
            CHECK(times(&tms) != (clock_t) -1);
            for(; (tms.tms_utime + tms.tms_stime)/tic - (start.tms_utime + start.tms_stime)/tic <= sec;) {
                CHECK(times(&tms) != (clock_t) -1);
            }
            exit(0);
        }
    }
    printf("total time:%ld\n", tottm);
    struct rusage rusage;
    CHECK(getrusage(RUSAGE_CHILDREN, &rusage) != -1);
    printf("child use:\n\tcpu time:%.2lfs (user)\n\tcpu time:%.2lfs (system)\ntotal:%.2lfs\n", rcputime(rusage, ru_utime), rcputime(rusage, ru_stime), rcputime(rusage, ru_utime) + rcputime(rusage, ru_stime));
    for(;;)
        if(waitpid(-1, NULL, 0) == -1 && errno == 10) break;
    CHECK(getrusage(RUSAGE_CHILDREN, &rusage) != -1);
    printf(""
            "child use:\n"
            "\tcpu time:\n"
            "\t\tcpu time:%.2lfs (user)\n"
            "\t\tcpu time:%.2lfs (system)\n"
            "\ttotal:%.2lfs\n"
            "\tMax resident set:%ldKB\n"
           "\tIntegral shared text mem:%ldkB/s\n"
           "\tIntegral shared data mem:%ldkB/s\n"
           "\tIntegral shared stack mem:%ldkB/s\n"
           "\tsoft page fault:%ld\n"
           "\thard page fault:%ld\n"
           "\tswaps out of physical mem:%ld\n"
           "\tfile input block:%ld\n"
           "\tfile output block:%ld\n"
           "\tIPC msg send:%ld\n"
           "\tIPC msg recv:%ld\n"
           "\tsignal recv:%ld\n"
           "\tvoluntary context switch:%ld\n"
           "\tinvoluntary context switch:%ld\n",
           rcputime(rusage, ru_utime),
           rcputime(rusage, ru_stime),
           rcputime(rusage, ru_utime) + rcputime(rusage, ru_stime),
           rusage.ru_maxrss,
           rusage.ru_ixrss,
           rusage.ru_idrss,
           rusage.ru_isrss,
           rusage.ru_minflt,
           rusage.ru_majflt,
           rusage.ru_nswap,
           rusage.ru_inblock,
           rusage.ru_oublock,
           rusage.ru_msgsnd,
           rusage.ru_msgrcv,
           rusage.ru_nsignals,
           rusage.ru_nvcsw,
           rusage.ru_nivcsw);
}
```

## 36.2
编写一个程序来执行一个命令，接着显示其当前的资源使用。这个程序与 time(1)
命令的功能类似，因此可以像下面这样使用这个程序:
```sh
$ ./rusage command arg...
```

```c
//
// Created by root on 7/18/23.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/wait.h>
#include <sys/times.h>
#include <unistd.h>
#include <limits.h>
#include <sys/resource.h>

#define CHECK(x) \
        do {     \
            if(!(x)) { \
                fprintf(stderr, "%s:%d\nerror: %s\n", __FILE__, __LINE__,strerror(errno)); \
                exit(0); \
            }    \
        } while(0)

#define rcputime(rusage, xtime) rusage.xtime.tv_sec + rusage.xtime.tv_usec/1000000.0

int main(int argc, char **argv) {
    struct rusage rusage;
    pid_t pid;
    if((pid = fork()) == 0) {
        CHECK(execvp(argv[1], &argv[1]) != 0);
    }
    CHECK(waitpid(pid, NULL, 0) != -1);
    CHECK(getrusage(RUSAGE_CHILDREN, &rusage) != -1);
    printf(""
           "child use:\n"
           "\tcpu time:\n"
           "\t\tcpu time:%.2lfs (user)\n"
           "\t\tcpu time:%.2lfs (system)\n"
           "\ttotal:%.2lfs\n"
           "\tMax resident set:%ldKB\n"
           "\tIntegral shared mem:(kB/s)\n"
           "\t\ttext\tmem:%ldkB/s\n"
           "\t\tdata\tmem:%ldkB/s\n"
           "\t\tstack\tmem:%ldkB/s\n"
           "\tpage fault:\n"
           "\t\tsoft:%ld\n"
           "\t\thard:%ld\n"
           "\tswaps out of physical mem:%ld\n"
           "\tfile input  block:%ld\n"
           "\tfile output block:%ld\n"
           "\tIPC msg:\n"
           "\t\tsend:%ld\n"
           "\t\trecv:%ld\n"
           "\tsignal recv:%ld\n"
           "\tvoluntary context switch:%ld\n"
           "\tinvoluntary context switch:%ld\n",
           rcputime(rusage, ru_utime),
           rcputime(rusage, ru_stime),
           rcputime(rusage, ru_utime) + rcputime(rusage, ru_stime),
           rusage.ru_maxrss,
           rusage.ru_ixrss,
           rusage.ru_idrss,
           rusage.ru_isrss,
           rusage.ru_minflt,
           rusage.ru_majflt,
           rusage.ru_nswap,
           rusage.ru_inblock,
           rusage.ru_oublock,
           rusage.ru_msgsnd,
           rusage.ru_msgrcv,
           rusage.ru_nsignals,
           rusage.ru_nvcsw,
           rusage.ru_nivcsw);
}
```

## 36.3

编写一个程序来确定当进程所消耗的各种资源超出通过 setrlimit0调用设置的软限
制时会发生什么事情。

```c
//
// Created by root on 7/18/23.
//
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <errno.h>
#include <sys/wait.h>
#include <sched.h>

#include <sys/times.h>
#include <unistd.h>
#include <limits.h>
#include <sys/resource.h>
#include <fcntl.h>

#define CONDITION(x) \
        do {     \
            if(!(x)) { \
                fprintf(stderr, "%s:%d\nunmet condition:\"%s\"\n", __FILE__, __LINE__, #x); \
                exit(2); \
            }    \
        } while(0)

#define CHECK(x) \
        do {     \
            if(!(x)) { \
                fprintf(stderr, "%s:%d\nerror: %s\nunmet condition:\"%s\"\n", __FILE__, __LINE__,strerror(errno), #x); \
                exit(1); \
            }    \
        } while(0)

#define USER 10087

void test(__rlimit_resource_t res, const char *name,void (*task)(__rlimit_resource_t res, struct rlimit *)) {
    printf("test: %d(%s)\n", res, name);
    pid_t pid;
    CHECK((pid = fork()) != -1);
    if(!pid) {
        struct rlimit lim;

        CHECK(getrlimit(res, &lim) != -1);
        printf("soft=%lu, hard=%lu\n", lim.rlim_cur, lim.rlim_max);
        task(res, &lim);
        printf("soft=%lu, hard=%lu\n", lim.rlim_cur, lim.rlim_max);
        exit(0);
    }
    int status;
    CHECK(waitpid(pid, &status, 0) != -1);
    CONDITION(WEXITSTATUS(status) != 0 || WCOREDUMP(status));
}

#define invoke_test(res) test(res, #res, f##res)

#define fun(name) void f##name(__rlimit_resource_t res, struct rlimit *lim)

fun(RLIMIT_AS) {
    lim->rlim_cur = 1024;
    CHECK(setrlimit(res, lim) != -1);
    CHECK(sbrk(1024 + 1) != (void *) -1);
}

fun(RLIMIT_CORE) {
    pid_t pid;
    CHECK((pid = fork()) != -1);
    if(!pid) {
        CONDITION(lim->rlim_cur != 0);
        lim->rlim_cur = 1;
        CHECK(setrlimit(res, lim) != -1);
        CHECK(sbrk(lim->rlim_cur + 1) != (void *) -1);
        abort();
    }
    int status;
    CHECK(waitpid(pid, &status, 0) != -1);
    CONDITION(WCOREDUMP(status)); // 超过limit，则不产生core dump文件
}

void signal_RLIMIT_CPU(int sig) {
    printf("pid=%ld, received signal:%d(%s)\n", (long)getpid(), sig, strsignal(sig));
    exit(1);
}
fun(RLIMIT_CPU) {
    CHECK(signal(SIGXCPU, signal_RLIMIT_CPU) != SIG_ERR);
    lim->rlim_cur = 1;
    CHECK(setrlimit(res, lim) != -1);
    for(;;);
}
fun(RLIMIT_DATA) {
    lim->rlim_cur = 1;
    CHECK(setrlimit(res, lim) != -1);
    CHECK(sbrk(lim->rlim_cur + 1) != (void *)-1);
}
fun(RLIMIT_FSIZE) {
    lim->rlim_cur = 1;
    char buf[1024];
    CHECK(setrlimit(res, lim) != -1);
    char *file = tmpnam(NULL);
    CHECK(file != NULL);
    printf("create tmp file:%s\n", file);
    int fd = open(file, O_CREAT|O_RDWR, 0611);
    CHECK(fd != -1);
    ssize_t writesize;
    if((writesize = write(fd, buf, 1024)) != 1024) {
        CHECK(writesize != -1);
        printf("incomplete write, write %lu byte\n", writesize);
    } else {
        printf("write, write %lu byte\n", writesize);
    }
    CHECK(close(fd) != -1);
    CHECK(unlink(file) != -1);
    CONDITION(writesize == 1024);
}
fun(RLIMIT_MEMLOCK);
fun(RLIMIT_MSGQUEUE);

fun(RLIMIT_NICE) {
//    CHECK(setpriority(PRIO_PROCESS, 0, 0) != -1);
    CHECK(setuid(10087) != -1); //切换到非root用户
    lim->rlim_cur = 5;
    lim->rlim_max = 5;
    CHECK(setrlimit(res, lim) != -1);
    errno = 0;
    int prio = getpriority(PRIO_PROCESS, 0);
    CHECK(!(prio == -1 && errno != 0));
    printf("current prio = %d\n", prio);
    CHECK(setpriority(PRIO_PROCESS, 0, 14) != -1);
    CHECK(setpriority(PRIO_PROCESS, 0, 16) != -1);
}
fun(RLIMIT_NOFILE) {
    lim->rlim_cur = 0;
    lim->rlim_max = 0;
    CHECK(setrlimit(res, lim) != -1);
    char *file = tmpnam(NULL);
    CHECK(file != NULL);
    printf("create tmp file:%s\n", file);
    int fd = open(file, O_CREAT|O_RDWR, 0611);
    CHECK(fd != -1);
    CHECK(close(fd) != -1);
}
fun(RLIMIT_NPROC) {
    CHECK(setuid(10087) != -1); //切换到非root用户
    lim->rlim_cur = 0;
    lim->rlim_max = 0;
    CHECK(setrlimit(res, lim) != -1);
    CHECK(fork() != -1);
}
fun(RLIMIT_RSS);
fun(RLIMIT_RTPRIO) {
    CHECK(setuid(0) != -1);
    lim->rlim_cur = 50;
    lim->rlim_max = 50;
    CHECK(setrlimit(res, lim) != -1);
    CHECK(setuid(10087) != -1);
    CHECK(sched_setscheduler(0, SCHED_FIFO, &(struct sched_param) {
            .sched_priority=50
    }) != -1);
    CHECK(sched_setscheduler(0, SCHED_FIFO, &(struct sched_param) {
        .sched_priority=51
    }) != -1);

}
fun(RLIMIT_RTTIME) {
    CHECK(sched_setscheduler(0, SCHED_FIFO, &(struct sched_param) {
            .sched_priority=sched_get_priority_max(SCHED_FIFO)
    }) != -1);
    CHECK(signal(SIGXCPU, signal_RLIMIT_CPU) != SIG_ERR);
    lim->rlim_cur = 1;
    CHECK(setrlimit(res, lim) != -1);
    for(;;);

}

fun(RLIMIT_SIGPENDING) {
    lim->rlim_cur = 1;
    char buf[1024] = {0};
    sprintf(buf, "/proc/%d/status", getpid());
    if(!fork()) {
        execlp("cat", "cat", buf, NULL);
    }
    wait(NULL);
    CHECK(setrlimit(res, lim) != -1);
    sigset_t set;
    CHECK(sigemptyset(&set) != -1);
    CHECK(sigaddset(&set, SIGRTMAX-2) != -1);
    CHECK(sigaddset(&set, SIGRTMAX-1) != -1);
    CHECK(sigprocmask(SIG_BLOCK, &set, NULL) != -1);
//    CHECK(sigqueue(getpid(), SIGUSR1, (union sigval){.sival_int=0}) != -1);
//    CHECK(sigqueue(getpid(), SIGUSR2, (union sigval){.sival_int=0}) != -1); // 不是说标准信号和实时信号都行吗？
    CHECK(sigqueue(getpid(), SIGRTMAX - 1, (union sigval){.sival_int=0}) != -1);
    CHECK(sigqueue(getpid(), SIGRTMAX - 2, (union sigval){.sival_int=0}) != -1);
//    CHECK(sigqueue(getpid(), SIGUSR2, (union sigval){.sival_int=0}) != -1); // 不是说标准信号和实时信号都行吗？
    if(!fork()) {
        execlp("cat", "cat", buf, NULL);
    }
    wait(NULL);
}


void handlerRLIMIT_STACK(int sig) {
    printf("pid:%ld received a signal:%d(%s)\n", (long) getpid(), sig, strsignal(sig));
    exit(1);
}

void stackoverflow() {
    char buf[MINSIGSTKSZ*MINSIGSTKSZ] = {0}; // 反正这里要足够大
    // 参考这里: https://stackoverflow.com/questions/4118016/set-stack-size-with-setrlimit-and-provoke-a-stack-overflow-segfault
    buf[MINSIGSTKSZ+1] = 0;
}

fun(RLIMIT_STACK) {
//    CHECK(signal(SIGSEGV, handlerRLIMIT_STACK) != SIG_ERR);
    CHECK(sigaltstack(&(stack_t) {
            .ss_flags=0,
            .ss_size=SIGSTKSZ,
            .ss_sp=malloc(SIGSTKSZ)
    }, NULL) != -1);
    sigset_t sigset;
    CHECK(sigemptyset(&sigset) != -1);
    CHECK(sigaction(SIGSEGV, &(struct sigaction) {
        .sa_flags = SA_ONSTACK, // sigaltstack要搭配这个flag
        .sa_mask = sigset,
        .sa_handler=handlerRLIMIT_STACK
        },NULL) != -1);
    lim->rlim_cur = MINSIGSTKSZ;
//    lim->rlim_max = 0;
    CHECK(setrlimit(res, lim) != -1);
    stackoverflow();
}



int main(int argc, char ** argv) {
    invoke_test(RLIMIT_AS);
    invoke_test(RLIMIT_CORE);
    invoke_test(RLIMIT_CPU);
    invoke_test(RLIMIT_DATA);
    invoke_test(RLIMIT_FSIZE);
//    invoke_test(RLIMIT_MEMLOCK); //还没学
//    invoke_test(RLIMIT_MSGQUEUE); //还没学
//
    invoke_test(RLIMIT_NICE);
    invoke_test(RLIMIT_NOFILE);
    invoke_test(RLIMIT_NPROC);
//    invoke_test(RLIMIT_RSS); //linux没作用
    invoke_test(RLIMIT_RTPRIO);
    invoke_test(RLIMIT_RTTIME);
    invoke_test(RLIMIT_SIGPENDING);
    invoke_test(RLIMIT_STACK);
}
```