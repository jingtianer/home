---
title: cha33.线程：更多细节
date: 2023-6-29 20:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 33.1

编写程序以便证明:作为函数sigpending()的返回值，同一个进程中的的不同线程可以拥有不同的 pending信号。可以使用函数pthread_kill(分别发送不同的信号给阻塞这些信号的两个不同的线程,接着调用sigpending()方法并显示这些pending信号的信息。(可能会发现程序清单20-4中函数的作用。)

```c
//
// Created by root on 7/2/23.
//
#define _GNU_SOURCE
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>

#define CHECK(x) do { if(!(x)) { fprintf(stderr, "ERROR: %s\nfile=%s, line=%d\n", strerror(errno), __FILE__, __LINE__); exit(1); } } while(0)
#define THREAD_CNT 5
pthread_mutex_t sig_mutex;
pthread_cond_t sig_cond;
int thread_ready_count;

void handler(int sig, siginfo_t *info, void *context) {
    printf("recv sig = %d: %s, from = %d\n", sig, strsignal(sig), info->si_value.sival_int);
}

pthread_t tid2pthread[THREAD_CNT];

int tid2sig(int tid) {
    return SIGRTMAX - 1 - tid;
}

void *fun_thread(void *arg) {
    int tid  = *(int *)arg;
    free(arg);
    sigset_t set;
    CHECK(sigemptyset(&set) == 0);
    CHECK(sigaddset(&set, tid2sig(tid)) == 0);
    CHECK(pthread_sigmask(SIG_SETMASK, &set, NULL) == 0);
    CHECK(sigaction(tid2sig(tid), &(struct sigaction) {
        .sa_sigaction   =handler,
        .sa_flags       = SA_SIGINFO,
        .sa_mask        = 0
    }, NULL) == 0);
    printf("Thread-%d, sigaction %d\n", tid, tid2sig(tid));
    CHECK(pthread_mutex_lock(&sig_mutex) == 0);
    thread_ready_count++;
    tid2pthread[tid] = pthread_self();
    CHECK(pthread_mutex_unlock(&sig_mutex) == 0);
    CHECK(pthread_cond_broadcast(&sig_cond) == 0);

    CHECK(pthread_mutex_lock(&sig_mutex) == 0);
    while(thread_ready_count < THREAD_CNT){
        CHECK(pthread_cond_wait(&sig_cond, &sig_mutex) == 0);
    }
    CHECK(pthread_mutex_unlock(&sig_mutex) == 0);
    int sig = tid2sig((tid + 1) % THREAD_CNT);
    printf("Thread-%d send %d(%s) to %d\n", tid, sig, strsignal(sig), (tid + 1) % THREAD_CNT);
    CHECK(pthread_sigqueue(tid2pthread[(tid + 1) % THREAD_CNT], sig, (union sigval) {
        .sival_int=tid
    }) == 0);
    do {
        printf("Thread-%d sig not pending %d\n", tid, tid2sig(tid));
        sleep(1);
        CHECK(sigemptyset(&set) == 0);
        CHECK(sigpending(&set) == 0);
    } while(sigismember(&set, tid2sig(tid)) == 0);
    printf("Thread-%d sig pending %d\n", tid, tid2sig(tid));
    CHECK(sigemptyset(&set) == 0);
    CHECK(pthread_sigmask(SIG_SETMASK, &set, NULL) == 0);
    CHECK(sigpending(&set) == 0);
    sig = -1;
    while(sig != tid2sig(tid)) CHECK(sigwait(&set, &sig) == 0);
    printf("Thread-%d exit\n", tid);
    return NULL;
}

int main(int argc, char *argv[]) {
    CHECK(pthread_mutex_init(&sig_mutex, NULL) == 0);
    CHECK(pthread_cond_init(&sig_cond, NULL) == 0);
    thread_ready_count = 0;
    for(int i = 0; i < THREAD_CNT; i++) {
        pthread_t thread;
        int *data = malloc(sizeof(int));
        *data = i;
        CHECK(pthread_create(&thread, NULL, fun_thread, data) == 0);
    }
    pthread_exit(NULL);
}
```

## 33.2

假设一个线程使用fork()创建了一个子进程。当子进程终止时，可以保证由此产生的SIGCHLD信号一定会发送给调用fork()的线程吗(可以用进程中的其他线程做对比)?

```c
//
// Created by root on 7/2/23.
//
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <sys/wait.h>

#define CHECK(x) do { if(!(x)) { fprintf(stderr, "ERROR: %s\nfile=%s, line=%d\n", strerror(errno), __FILE__, __LINE__); exit(1); } } while(0)

sigset_t set;

void handler(int sig, siginfo_t *info, void *context) {
    printf("recv sig = %d: %s, my tid is %ld\n", sig, strsignal(sig), pthread_self());
}

void *fn(void *arg) {
    CHECK(sigaction(SIGCHLD, &(struct sigaction) {
            .sa_mask = 0,
            .sa_flags = SA_SIGINFO,
            .sa_sigaction=handler
    }, NULL) == 0);
    if(*(int *)arg) {
        printf("I am %ld, I fork\n", pthread_self());
        if(!fork()) {
            exit(0);
        }
//        wait(NULL);
    } else {
        printf("I am %ld, I sleep\n", pthread_self());
        sleep(10);
    }
    free(arg);
    return NULL;
}

int main() {
    CHECK(sigemptyset(&set) == 0);
    CHECK(sigaddset(&set, SIGCHLD) == 0);
    CHECK(sigaction(SIGCHLD, &(struct sigaction) {
        .sa_mask = 0,
        .sa_flags = SA_SIGINFO,
        .sa_sigaction=handler
    }, NULL) == 0);
    pthread_t tid;
    int ok = 0;
    CHECK(pthread_create(&tid, NULL, fn, memcpy(malloc(sizeof(int)), &ok, sizeof(int))) == 0);
    ok = 1;
    CHECK(pthread_create(&tid, NULL, fn, memcpy(malloc(sizeof(int)), &ok, sizeof(int))) == 0);
    pthread_exit(NULL);
}
```