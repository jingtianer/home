---
title: cha48.System V 共享内存
date: 2023-9-14 11:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 48.1

使用事件标记来替换程序清单48-2(svshm_xfr_writerc)和程序清单48-3(svshm_xfr_reader.c)中的二元信号量。(就是27节的event flag)
```c
//
// Created by root on 9/14/23.
//
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <fcntl.h>
#include <pthread.h>
#include <unistd.h>
#include <signal.h>
#include <stdbool.h>
#include <stddef.h>
#include <syslog.h>
#include <wait.h>
#include <sys/stat.h>
#include <sys/ipc.h>
#include <sys/sem.h>
#include <sys/shm.h>

#define DEBUG_LEVEL LOG_DEBUG

#ifndef DEBUG_LEVEL
#define DEBUG_LEVEL LOG_INFO
#endif
#define STRING_MSG "MSG"
FILE *logfile = NULL;
bool syslog_enable = false;
void __attribute__ ((constructor)) init() {
    syslog_enable = false;
    logfile = stderr;
}

#define alloc_sprintf(__alloc_sprintf_str, __format...) do { \
    int __alloc_sprintf_len = snprintf(NULL, 0, __format); \
    (__alloc_sprintf_str) = malloc(__alloc_sprintf_len+1);                     \
    if(__alloc_sprintf_str != NULL) \
        snprintf(__alloc_sprintf_str, __alloc_sprintf_len+1, __format); \
} while(0)

#define logger(level, msg...) do { \
    if(level <= DEBUG_LEVEL) {     \
        fprintf(logfile, "[%ld] ", (long) getpid()); \
        fprintf(logfile, msg); \
        fprintf(logfile, "\n"); \
    } \
    if(syslog_enable) { \
        char *data; \
        alloc_sprintf(data, msg); \
        syslog(level, "%s", data); \
        safe_free(data); \
    } \
} while(0)

#define COND_RET(x, ret, msg...) \
        do {                     \
            if(!(x)) {           \
                if(errno != 0) logger(LOG_ERR, "Error(%d): %s", errno, strerror(errno)); \
                logger(LOG_ERR, "%s:%d", __FILE__, __LINE__);   \
                logger(LOG_ERR, "unmet condition:\"%s\"", #x); \
                logger(LOG_ERR, msg);        \
                ret; \
            }    \
            errno = 0; \
        } while(0)

#define CHECK(x, msg...) COND_RET(x, return -1;, msg)
#define CHECK_EXIT(x, msg...) COND_RET(x, exit(EXIT_FAILURE);, msg)
#define CHECK_LOG(x, msg...) COND_RET(x, ;, msg)

#define safe_free(__safe_free_ptr) do { if(__safe_free_ptr) { free(__safe_free_ptr); (__safe_free_ptr) = NULL;} } while(0)

#define BUFFER_SIZE 4096

union semun {
    int val;
    struct semid_ds *buf;
    unsigned short *array;
#if defined(__linux__)
    struct seminfo *__buf;
#endif
};

typedef struct {
    int semid;
}EventFlag_t;

int incrsem(int sem_id, int semnum, short incr, short flg) {
    struct sembuf sembuf;
    sembuf = (struct sembuf){
            .sem_num=semnum,
            .sem_flg=flg,
            .sem_op=incr
    };
    return semop(sem_id, &sembuf, 1);
}

int P(int sem_id) {
    return incrsem(sem_id, 0, -1, 0);
}

int V(int sem_id) {
    return incrsem(sem_id, 0, 1, 0);
}

int waitFor(int sem_id) {
    return incrsem(sem_id, 1, 0, 0);
}

int getsem(int sem_id, int semnum, short *n) {
    union semun arg;
    int ret = semctl(sem_id, semnum, GETVAL, arg);
    *n = ret;
    return ret;
}

int setsem(int sem_id, int semnum, short n) {
    union semun arg;
    arg.val = n;
    return semctl(sem_id, semnum, SETVAL, arg);
}

int notifyAll(int sem_id) {
    return setsem(sem_id, 1, 0);
}
EventFlag_t *newEventFlag(const char *file, char x) {
    EventFlag_t eventFlag;
    key_t key = ftok(file, x);
    eventFlag.semid = semget(key, 4, IPC_CREAT | IPC_EXCL | 0666); // sem[0] as mutex, sem[1] as notifier, sem[2]|sem[3] as flag
    union semun arg;
    if(eventFlag.semid == -1) {
        if(errno == EEXIST) {
            eventFlag.semid = semget(key, 4, 0666);
            COND_RET(eventFlag.semid != -1, return NULL, STRING_MSG);
            struct semid_ds ds;
            arg.buf = &ds;
            COND_RET(semctl(eventFlag.semid, 0, IPC_STAT, arg) != -1, return NULL, STRING_MSG);
            while (ds.sem_otime == 0) {
                logger(LOG_INFO, "waiting for sem init");
                sleep(1);
                COND_RET(semctl(eventFlag.semid, 0, IPC_STAT, arg) != -1, return NULL, STRING_MSG);
            }
            logger(LOG_INFO, "semget get old");
        } else {
            CHECK_LOG(false, STRING_MSG);
            return NULL;
        }
    } else {
        arg.array = (unsigned  short  *)&(unsigned short[]){0, 0, 0, 0}; // sem[0] = 1, sem[1] = 0
        if(semctl(eventFlag.semid, 0, SETALL, arg) == -1) {
            CHECK_LOG(false, STRING_MSG);
            CHECK_LOG(semctl(eventFlag.semid, 0, IPC_RMID) != -1, STRING_MSG);
            return NULL;
        }
        if(incrsem(eventFlag.semid, 0,1,0) == -1) {
            CHECK_LOG(false, STRING_MSG);
            CHECK_LOG(semctl(eventFlag.semid, 0, IPC_RMID) != -1, STRING_MSG);
            return NULL;
        }
        logger(LOG_INFO, "semget create new");
    }
    return memcpy(malloc(sizeof(EventFlag_t)), &eventFlag, sizeof(EventFlag_t));
}

int __setEventFlag(EventFlag_t *eventFlag, int flag) {
    short currentFlag;

    CHECK(getsem(eventFlag->semid, 2, &currentFlag) != -1, STRING_MSG);
    CHECK(setsem(eventFlag->semid, 2, currentFlag | (flag & 0xffff)) != -1, STRING_MSG);

    CHECK(getsem(eventFlag->semid, 3, &currentFlag) != -1, STRING_MSG);
    CHECK(setsem(eventFlag->semid, 3, currentFlag | ((flag >> 16) & 0xffff)) != -1, STRING_MSG);

    CHECK(notifyAll(eventFlag->semid) != -1, STRING_MSG);
}

int setEventFlag(EventFlag_t *eventFlag, int flag) {
    CHECK(P(eventFlag->semid) != -1, STRING_MSG);
    CHECK(__setEventFlag(eventFlag, flag) != -1, STRING_MSG);
    CHECK(V(eventFlag->semid) != -1, STRING_MSG);
    return 0;
}

int __clearEventFlag(EventFlag_t *eventFlag, int flag) {
    short currentFlag;

    CHECK(getsem(eventFlag->semid, 2, &currentFlag) != -1, STRING_MSG);
    CHECK(setsem(eventFlag->semid, 2, currentFlag & ~(flag & 0xffff)) != -1, STRING_MSG);

    CHECK(getsem(eventFlag->semid, 3, &currentFlag) != -1, STRING_MSG);
    CHECK(setsem(eventFlag->semid, 3, currentFlag & ~((flag >> 16) & 0xffff)) != -1, STRING_MSG);
//    CHECK(notifyAll(eventFlag->semid) != -1, STRING_MSG);
    return 0;
}
int clearEventFlag(EventFlag_t *eventFlag, int flag) {
    CHECK(P(eventFlag->semid) != -1, STRING_MSG);
    CHECK(__clearEventFlag(eventFlag, flag) != -1, STRING_MSG);
    CHECK(V(eventFlag->semid) != -1, STRING_MSG);
    return 0;
}

int __getEventFlag(EventFlag_t *eventFlag, int *flag) {
    if(flag) {
        short currentFlag = 0;
        int ret = 0;
        CHECK(getsem(eventFlag->semid, 2, &currentFlag) != -1, STRING_MSG);
        ret |= currentFlag;
        CHECK(getsem(eventFlag->semid, 3, &currentFlag) != -1, STRING_MSG);
        ret |= currentFlag << 16;
        *flag = ret;
        return 0;
    }
    return -1;
}

int getEventFlag(EventFlag_t *eventFlag, int *flag) {
    CHECK(P(eventFlag->semid) != -1, STRING_MSG);
    CHECK_LOG(__getEventFlag(eventFlag, flag) != -1, STRING_MSG);
    CHECK(V(eventFlag->semid) != -1, STRING_MSG);
    return 0;
}
#define waitForMethod(eventFlag, flag, method) do { \
        int currentFlag;\
    CHECK(P(eventFlag->semid) != -1, STRING_MSG);\
    __getEventFlag(eventFlag, &currentFlag); \
    while (method) {\
        CHECK(V(eventFlag->semid) != -1, STRING_MSG);\
        CHECK(waitFor(eventFlag->semid) != -1, STRING_MSG);\
        CHECK(P(eventFlag->semid) != -1, STRING_MSG);\
        __getEventFlag(eventFlag, &currentFlag); \
    }\
    CHECK(V(eventFlag->semid) != -1, STRING_MSG);\
} while(0)

int waitForAny(EventFlag_t *eventFlag, int flag) {
    waitForMethod(eventFlag, flag, (currentFlag & flag) == 0);
    return 0;
}
int waitForAll(EventFlag_t *eventFlag, int flag) {
    waitForMethod(eventFlag, flag, (currentFlag & flag) != flag);
    return 0;
}

int waitForAllAndClear(EventFlag_t *eventFlag, int flag) {
    int currentFlag;
    CHECK(P(eventFlag->semid) != -1, STRING_MSG);
    __getEventFlag(eventFlag, &currentFlag);
    while ((currentFlag & flag) != flag) {
        CHECK(V(eventFlag->semid) != -1, STRING_MSG);
        CHECK(waitFor(eventFlag->semid) != -1, STRING_MSG);
        CHECK(P(eventFlag->semid) != -1, STRING_MSG);
        __getEventFlag(eventFlag, &currentFlag);
    }
    __clearEventFlag(eventFlag, flag);
    CHECK(V(eventFlag->semid) != -1, STRING_MSG);
    return 0;
}
void destroyEventFlag(EventFlag_t **eventFlag) {
    if(eventFlag) {
        if(*eventFlag) {
            semctl((*eventFlag)->semid, 0, IPC_RMID);
        }
        safe_free(*eventFlag);
    }
}

#define WRITE_FLAG 1
#define READ_FLAG 2
struct ShmStruct {
    ssize_t len;
    char buf[BUFFER_SIZE - sizeof(int)];
};

void onExitEventFlag(int status, void *arg) {
    destroyEventFlag((EventFlag_t **)&arg);
    logger(LOG_INFO, "onExitEventFlag, status = %d", status);
}

void onExitSHM(int status, void *id) {
    shmctl(*(int *)id, IPC_RMID, NULL);
    logger(LOG_INFO, "onExitSHM, status = %d", status);
}

void onExitSHMdt(int status, void *ptr) {
    shmdt(ptr);
    logger(LOG_INFO, "onExitSHMdt, status = %d", status);
}

void handler(int sig) {
    exit(0);
}
int main(int argc, char **argv) {
    CHECK_EXIT(argc == 2, "Usage: %s writer|reader", argv[0]);
    signal(SIGINT, handler);
    signal(SIGTERM, handler);
    signal(SIGHUP, handler);
    EventFlag_t *eventFlag = newEventFlag(argv[0], 'a');
    on_exit(onExitEventFlag, eventFlag);
    key_t key = ftok(argv[0], 'c');
    CHECK_EXIT(key != -1, STRING_MSG);
    int shmid = shmget(key, BUFFER_SIZE, IPC_CREAT | IPC_EXCL | 0666);
    int savedErrno = errno;
    CHECK_EXIT(shmid != -1 || errno == EEXIST, STRING_MSG);
    if(shmid != -1) {
        setEventFlag(eventFlag, WRITE_FLAG);
    } else {
        if(savedErrno == EEXIST) {
            shmid = shmget(key, BUFFER_SIZE, 0666);
        } else {
            CHECK_EXIT(false, "code will never reach");
        }
    }
    on_exit(onExitSHM, &shmid);
    struct ShmStruct *shmp = shmat(shmid, NULL, 0);
    CHECK_EXIT(shmp != NULL, STRING_MSG);
    on_exit(onExitSHMdt, shmp);
    if(!strcmp(argv[1], "writer")) {
        size_t size = 0;
        bool stop = false;
        for(int i = 0; !stop ;i++) {
            CHECK_EXIT(waitForAllAndClear(eventFlag, WRITE_FLAG) != -1, STRING_MSG);
            logger(LOG_INFO, "write start");
            CHECK_EXIT((shmp->len = read(STDIN_FILENO, shmp->buf, BUFFER_SIZE - sizeof(int))) >= 0, STRING_MSG);
            size += shmp->len;
            if(shmp->len == 0) {
                stop = true;
            }
            CHECK_EXIT(setEventFlag(eventFlag, READ_FLAG) != -1, STRING_MSG);
            logger(LOG_INFO, "write end: i = %d, size = %lu", i, size);
        }
    } else {
        size_t size = 0;
        bool stop = false;
        for(int i = 0; !stop ;i++) {
            CHECK_EXIT(waitForAllAndClear(eventFlag, READ_FLAG) != -1, STRING_MSG);
            logger(LOG_INFO, "read start");
            CHECK_EXIT(write(STDIN_FILENO, shmp->buf, shmp->len) == shmp->len, STRING_MSG);
            size += shmp->len;
            if(shmp->len == 0) {
                stop = true;
            }
            CHECK_EXIT(setEventFlag(eventFlag, WRITE_FLAG) != -1, STRING_MSG);
            logger(LOG_INFO, "read end: i = %d, size = %lu", i, size);
        }

    }
}
```
## 48.2

解释为何程序清单48-3在 for 循环被修改成如下形式时会错误地报告了传输字节数。
```c
for (xfrs =0,bytes = 0; shmp->cnt != 0; xfrs++,bytes += shmp->cnt) {
    reserveSem(semid,READ SEM); /*Wait for return*/
    if(write(STDOUT_FILENO,shmp->buf,shmp->cnt) != shmp->cnt)
        fatal("write");
    releaseSem(semid,WRITE SEM); /*Give writer a return*/
}
```

原版代码

```c
for (xfrs =0; shmp->cnt != 0; xfrs++) {
    reserveSem(semid,READ SEM); /*Wait for return*/
    if(write(STDOUT_FILENO,shmp->buf,shmp->cnt) != shmp->cnt)
        fatal("write");
    bytes += shmp->cnt;
    releaseSem(semid,WRITE SEM); /*Give writer a return*/
}
```

> 很显然，他将`bytes`的自增放在了Sem锁定区域之外，由于`shmp`指向的是共享内存，在`releaseSem`到`bytes`增加之间，`shmp`指向的区域内存中的值可能已经发生改变，造成统计不准确。

## 48.5

编写一个目录服务使之使用一个共享内存段来发布名称-值对。程序需要提供一个API来允许调用者创建新名称、修改一个既有名称、删除一个既有名称以及获取与个名称相关联的值。使用信号量来确保一个执行共享内存段更新操作的进程能够互斥地访问段。

