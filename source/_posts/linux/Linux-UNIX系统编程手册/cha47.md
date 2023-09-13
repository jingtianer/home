---
title: cha46.System V 信号量
date: 2023-9-13 19:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---
## 47.2 47.3 47.4
- 使用信号量，实现进程间的同步
- 验证`SEM_UNDO`是否会改变`sempid`
- 实现`P V`操作，实现`testP`（在程序清单47-l0给出的代码(binary_sems.c)中增加一个reserveSemNBO函数来使用PC_NOWAIT标记实现有条件的预留操作。）
```c
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>
#include <sys/sem.h>
#include <sys/ipc.h>
#include <stdbool.h>
#include <stddef.h>
#include <syslog.h>
#include <wait.h>


#define DEBUG_LEVEL LOG_DEBUG

#ifndef DEBUG_LEVEL
#define DEBUG_LEVEL LOG_INFO
#endif
FILE *logfile = NULL;
bool syslog_enable = false;

#define alloc_sprintf(__alloc_sprintf_str, __format...) do { \
    int __alloc_sprintf_len = snprintf(NULL, 0, __format); \
    (__alloc_sprintf_str) = malloc(__alloc_sprintf_len+1);                     \
    if(__alloc_sprintf_str != NULL) \
        snprintf(__alloc_sprintf_str, __alloc_sprintf_len+1, __format); \
} while(0)

#define logger(level, msg...) do { \
    if(level <= DEBUG_LEVEL) {     \
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
            if(!(x)) { \
                if(errno == 0)logger(LOG_ERR, "%s:%d\nunmet condition:\"%s\"\n", __FILE__, __LINE__, #x); \
                else logger(LOG_ERR, "%s:%d\nerror: %s\nunmet condition:\"%s\"\n", __FILE__, __LINE__,strerror(errno), #x); \
                logger(LOG_ERR, msg);                                                                                  \
                logger(LOG_ERR, "\n");                                                                    \
                ret \
            }    \
        } while(0)

#define CHECK(x, msg...) COND_RET(x, return -1;, msg)
#define CHECK_EXIT(x, msg...) COND_RET(x, exit(EXIT_FAILURE);, msg)
#define CHECK_LOG(x, msg...) COND_RET(x, ;, msg)

#define safe_free(__safe_free_ptr) do { if(__safe_free_ptr) { free(__safe_free_ptr); (__safe_free_ptr) = NULL;} } while(0)

#define BUFFER_SIZE 4096


key_t sem_key = 0;
int sem_id = 0;
void rmsem() {
    CHECK_LOG(semctl(sem_id, 0, IPC_RMID) != -1, "");
}

union semun {
    int val;
    struct semid_ds *buf;
    unsigned short *array;
#if defined(__linux__)
    struct seminfo *__buf;
#endif
};

pid_t taskid = 0;

int safe_atoi(const char *num) {
    const char *ptr = num;
    while (ptr && *ptr) {
        CHECK_EXIT(*ptr >= '0' && *ptr <= '9', "");
        ptr++;
    }
    return atoi(num);
}

int incrsem(int semnum, short incr, short flg) {
    struct sembuf sembuf;
    sembuf = (struct sembuf){
            .sem_num=semnum,
            .sem_flg=flg,
            .sem_op=incr
    };
    return semop(sem_id, &sembuf, 1);
}
void siginthandler(int sig) {
    rmsem();
}

int initAvai(int semnum) {
    union semun arg;
    arg.val = 1;
    if(semctl(sem_id, semnum, SETVAL, arg) == -1) return -1;
    return incrsem(semnum, 1, 0);
}


int initInUse(int semnum) {
    union semun arg;
    arg.val = 0;
    if(semctl(sem_id, semnum, SETVAL, arg) == -1) return -1;
    return incrsem(semnum, 0, 0);
}


int P(int semnum) {
    int ret;
    do {
        ret = incrsem(semnum, -1, 0);
    } while (ret == -1 && errno == EINTR);
    return ret;
}

int testP(int semnum) { // return 1 if sem would be blocked, return 0 if sem would not be blocked.
    int ret = incrsem(semnum, -1, IPC_NOWAIT);
    if(ret == -1) {
        if(errno == EAGAIN)return 1;
        else return ret;
    }
    return 0;
}

int V(int semnum) {
    return incrsem(semnum, 1, 0);
}

void init(int argc, char *argv[]) {
    logfile = stderr;
    sem_key = ftok(argv[0], 'x');
//    taskid = safe_atoi(argv[1]); // 1, 2
    taskid = fork();
    logger(LOG_INFO, "PID = %ld, taskID = %d", (long)getpid(), taskid);
    CHECK_EXIT(taskid != -1, "");
    union semun arg;
    if((sem_id = semget(sem_key, 3, IPC_CREAT | IPC_EXCL | 0666)) != -1) {
        atexit(rmsem);
        signal(SIGINT, siginthandler);
        arg.array = (unsigned  short  *)&(unsigned short[]){0, 0, 0}; // sem[0] = 1, sem[1] = 0
        CHECK_EXIT(semctl(sem_id, 0, SETALL, arg) != -1, "");
        CHECK_EXIT(initInUse(1) != -1, "");
        CHECK_EXIT(initAvai(0) != -1, "");
    } else {
        if(errno != EEXIST) {
            CHECK_EXIT(false, "");
        }
        sem_id = semget(sem_key, 3,  0666);
    }
    struct semid_ds ds;
    arg.buf = &ds;
    CHECK_EXIT(semctl(sem_id, 0, IPC_STAT, arg) != -1, "");
    while (ds.sem_otime == 0) {
        logger(LOG_INFO, "waiting for sem init");
        sleep(1);
        CHECK_EXIT(semctl(sem_id, 0, IPC_STAT, arg) != -1, "");
    }
    logger(LOG_INFO, "finish init. PID = %ld, taskID = %d", (long)getpid(), taskid);
}

pid_t printsem(int semnum) {
    pid_t pid;
    CHECK_EXIT((pid = semctl(sem_id, semnum, GETPID)) != -1, "");
    logger(LOG_INFO, "semnum=%d, last semop pid=%ld", semnum, (long) pid);
    return pid;
}


int main(int argc, char *argv[]) {
    init(argc, argv);
    switch (taskid) {
        case 0:
            CHECK_EXIT(P(2) != -1, "");
            CHECK_EXIT(incrsem(0, -1, SEM_UNDO) != -1, "");
            CHECK_EXIT(V(1) != -1, "");
            CHECK_EXIT(P(2) != -1, "");
            break;
        default:
            printsem(0);
            CHECK_EXIT(V(2) != -1, "");
            CHECK_EXIT(P(1) != -1, "");
            printsem(0);
            CHECK_EXIT(incrsem(0, 1, 0) != -1, "");
            printsem(0);
            CHECK_EXIT(V(2) != -1, "");
            wait(NULL);
            pid_t lastpid = printsem(0);
            if(lastpid == taskid) {
                logger(LOG_INFO, "IPC_UNDO will change last pid");
            } else if (lastpid == getpid()) {
                logger(LOG_INFO, "IPC_UNDO will not change last pid");
            } else {
                logger(LOG_INFO, "other process change sem");
            }

            break;
    }
}
```

## 47.6
使用命名管道实现一个二元信号量协议。提供函数来预留、释放以及有条件地预留信号量。

### 需要共享fd
```c
//
// Created by root on 9/13/23.
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


#define DEBUG_LEVEL LOG_DEBUG

#ifndef DEBUG_LEVEL
#define DEBUG_LEVEL LOG_INFO
#endif
FILE *logfile = NULL;
bool syslog_enable = false;
void __attribute__ ((constructor)) init() {
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
            if(!(x)) { \
                if(errno == 0)logger(LOG_ERR, "%s:%d\nunmet condition:\"%s\"\n", __FILE__, __LINE__, #x); \
                else logger(LOG_ERR, "%s:%d\nerror: %s\nunmet condition:\"%s\"\n", __FILE__, __LINE__,strerror(errno), #x); \
                logger(LOG_ERR, msg);                                                                                  \
                logger(LOG_ERR, "\n");                                                                    \
                ret \
            }    \
        } while(0)

#define CHECK(x, msg...) COND_RET(x, return -1;, msg)
#define CHECK_EXIT(x, msg...) COND_RET(x, exit(EXIT_FAILURE);, msg)
#define CHECK_LOG(x, msg...) COND_RET(x, ;, msg)

#define safe_free(__safe_free_ptr) do { if(__safe_free_ptr) { free(__safe_free_ptr); (__safe_free_ptr) = NULL;} } while(0)

#define BUFFER_SIZE 4096


key_t sem_key = 0;
int sem_id = 0;

pid_t taskid = 0;

int safe_atoi(const char *num) {
    const char *ptr = num;
    while (ptr && *ptr) {
        CHECK_EXIT(*ptr >= '0' && *ptr <= '9', "");
        ptr++;
    }
    return atoi(num);
}
typedef struct {
    char id[L_tmpnam];
    int rfd, wfd;
}PvFifo_t;
#include <time.h>
PvFifo_t *newPvFifo() {
    PvFifo_t *pvFifo = malloc(sizeof(PvFifo_t));
    char *id;
    alloc_sprintf(id, "PvFifo%d", rand());
    strcpy(pvFifo->id, id);
    pvFifo->rfd = pvFifo->wfd = -1;
    if(mkfifo(id, 0666) == -1) {
        CHECK_LOG(false, "");
        return NULL;
    }
    logger(LOG_INFO, "new fifo: %s", id);
    return pvFifo;
}

int P(PvFifo_t *pvFifo) {
    CHECK(pvFifo != NULL, "pvFifo is NULL");
    pvFifo->wfd = open(pvFifo->id, O_WRONLY);
    close(pvFifo->wfd);
    close(pvFifo->rfd);
    pvFifo->wfd = -1;
    return 0;
}


int V(PvFifo_t *pvFifo) {
    CHECK(pvFifo != NULL, "pvFifo is NULL");
    pvFifo->rfd = open(pvFifo->id, O_RDONLY | O_NONBLOCK);
    return 0;
}
PvFifo_t *initAvai() {
    PvFifo_t *pvFifo = newPvFifo();
    if(!pvFifo) {
        CHECK_LOG(false, "");
    } else if(V(pvFifo) != 0) {
        CHECK_LOG(false, "");
        safe_free(pvFifo);
    }
    logger(LOG_INFO, "init :%s", pvFifo->id);
    return pvFifo;
}


PvFifo_t *initInUse() {
    return newPvFifo();
}

int destroy(PvFifo_t *id) {
    if(id->rfd != -1) close(id->rfd);
    if(id->wfd != -1) close(id->wfd);
    return unlink(id->id);
}
#define CRITICAL_LEN 1024
int critial_cnt = -1;
int criticalArea[CRITICAL_LEN];
PvFifo_t *id = NULL;
void rmPvFifo() {
    if(id) destroy(id);
}

pthread_t producer_t, consumer_t;
void exithandler(int sig) {
    pthread_kill(producer_t, SIGKILL);
    pthread_kill(consumer_t, SIGKILL);
    if(sig == SIGHUP)exit(0);
    else exit(1);
}

void *consumer(void *args) {
    while(1) {
        int n;
        bool ok = false;
        CHECK_EXIT(P(id) != -1, "");
        if(critial_cnt >= 0) {
            n = criticalArea[critial_cnt--];
            ok = true;
        }
        CHECK_EXIT(V(id) != -1, "");
        if(ok) logger(LOG_INFO, "consume: %d", n);
        else sleep(1);
    }
}

void *producer(void *arg) {
    atexit(rmPvFifo);
    while(1) {
        int n;
        bool ok = false;
        CHECK_EXIT(P(id) != -1, "");
        if(critial_cnt < CRITICAL_LEN - 1) {
            critial_cnt++;
            n = critial_cnt;
            criticalArea[critial_cnt] = n;
            ok = true;
        }
        CHECK_EXIT(V(id) != -1, "");
        if(ok) logger(LOG_INFO, "produce: %d", n);
        else sleep(1);
    }
}

int main(int argc, char **argv) {
    srand(time(NULL));
    logfile = stderr;
    id = initAvai();
    CHECK_EXIT(id != NULL, "");
    signal(SIGHUP, exithandler);
    signal(SIGTERM, exithandler);
    signal(SIGALRM, exithandler);
    alarm(10);
    pthread_create(&producer_t, NULL, producer, NULL);
    pthread_create(&consumer_t, NULL, consumer, NULL);
//    pthread_exit(NULL);
    pthread_join(producer_t, NULL);
    pthread_join(consumer_t, NULL);
}
```

### 不需要共享fd
```c
//
// Created by root on 9/13/23.
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


#define DEBUG_LEVEL LOG_DEBUG

#ifndef DEBUG_LEVEL
#define DEBUG_LEVEL LOG_INFO
#endif
FILE *logfile = NULL;
bool syslog_enable = false;
void __attribute__ ((constructor)) init() {
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
        fprintf(logfile, msg); \
        fprintf(logfile, "\n"); \
    } \
    if(syslog_enable) { \
        char *__data; \
        alloc_sprintf(__data, msg); \
        syslog(level, "%s", __data); \
        safe_free(__data); \
    } \
} while(0)

#define COND_RET(x, ret, msg...) \
        do {                     \
            if(!(x)) { \
                if(errno == 0)logger(LOG_ERR, "%s:%d\nunmet condition:\"%s\"\n", __FILE__, __LINE__, #x); \
                else logger(LOG_ERR, "%s:%d\nerror: %s\nunmet condition:\"%s\"\n", __FILE__, __LINE__,strerror(errno), #x); \
                logger(LOG_ERR, msg);                                                                                  \
                logger(LOG_ERR, "\n");                                                                    \
                ret \
            }    \
        } while(0)

#define CHECK(x, msg...) COND_RET(x, return -1;, msg)
#define CHECK_EXIT(x, msg...) COND_RET(x, exit(EXIT_FAILURE);, msg)
#define CHECK_LOG(x, msg...) COND_RET(x, ;, msg)

#define safe_free(__safe_free_ptr) do { if(__safe_free_ptr) { free(__safe_free_ptr); (__safe_free_ptr) = NULL;} } while(0)

#define BUFFER_SIZE 4096


key_t sem_key = 0;
int sem_id = 0;

pid_t taskid = 0;

int safe_atoi(const char *num) {
    const char *ptr = num;
    while (ptr && *ptr) {
        CHECK_EXIT(*ptr >= '0' && *ptr <= '9', "");
        ptr++;
    }
    return atoi(num);
}
typedef struct {
    char id[L_tmpnam];
    int rfd, wfd;
}PvFifo_t;

int openPvfifo(char *id, int rw) {
    int fd = open(id, rw | O_NONBLOCK);
    CHECK(fd != -1, "");
    int flag;
    if((flag = fcntl(fd, F_GETFL)) == -1) {
        CHECK_LOG(false, "");
        close(fd);
        return -1;
    }
    flag &= ~O_NONBLOCK;
    if(fcntl(fd, F_SETFL, flag) == -1) {
        CHECK_LOG(false, "");
        close(fd);
        return -1;
    }
    return fd;
}
PvFifo_t *newPvFifo(char *id) {
    PvFifo_t *pvFifo = malloc(sizeof(PvFifo_t));
    strcpy(pvFifo->id, id);
    if(mkfifo(id, 0666) == -1) {
        if(errno != EEXIST) {
            CHECK_LOG(false, "");
            return NULL;
        }
    }
    pvFifo->rfd = openPvfifo(id, O_RDONLY);
    pvFifo->wfd = -1;
    logger(LOG_INFO, "new fifo: %s", id);
    return pvFifo;
}

int P(PvFifo_t *pvFifo) {
    CHECK(pvFifo != NULL, "pvFifo is NULL");
    int ret = 0;
    bool buf;
    if((ret = read(pvFifo->rfd, &buf, sizeof(bool)) != sizeof(bool))) {
        CHECK_LOG(false, "");
    } else ret = 0;
    return ret;
}


int V(PvFifo_t *pvFifo) {
    CHECK(pvFifo != NULL, "pvFifo is NULL");
    pvFifo->wfd = openPvfifo(pvFifo->id, O_WRONLY);
    CHECK(pvFifo->wfd != -1, "");
    int ret = 0;
    if((ret = write(pvFifo->wfd, &(bool[]){true}, sizeof(bool)) != sizeof(bool))) {
        CHECK_LOG(false, "");
    } else ret = 0;
    close(pvFifo->wfd);
    return ret;
}
PvFifo_t *initAvai(char *id) {
    PvFifo_t *pvFifo = newPvFifo(id);
    if(!pvFifo) {
        CHECK_LOG(false, "");
    } else if(V(pvFifo) != 0) {
        CHECK_LOG(false, "");
        safe_free(pvFifo);
    }
    logger(LOG_INFO, "init :%s", pvFifo->id);
    return pvFifo;
}


PvFifo_t *initInUse(char *id) {
    return newPvFifo(id);
}

int destroy(PvFifo_t *id) {
    if(id->rfd != -1) close(id->rfd);
    if(id->wfd != -1) close(id->wfd);
    return unlink(id->id);
}
PvFifo_t *id = NULL;
void rmPvFifo() {
    if(id) destroy(id);
}

char *fn = NULL;
void exithandler(int sig) {
    if(fn) unlink(fn);
    if(sig == SIGHUP)exit(0);
    else exit(1);
}
int comm_file;
#define MAX 65536
void *consumer(void *args) {
    while(1) {
        CHECK_EXIT(P(id) != -1, "");
        int offset;
        CHECK_EXIT(pread(comm_file, &offset, sizeof(int), 0) == sizeof(int), "");
        if(offset > 1) {
            int data;
            CHECK_EXIT(pread(comm_file, &data, sizeof(int), (offset - 1) * sizeof(int)) == sizeof(int), "");
            logger(LOG_INFO, "consume: %d", data);
            offset--;
            CHECK_EXIT(pwrite(comm_file, &offset, sizeof(int), 0) == sizeof(int), "");
        } else sleep(1);
        CHECK_EXIT(V(id) != -1, "");
    }
}

void *producer(void *arg) {
    atexit(rmPvFifo);
    while(1) {
        int offset;
        CHECK_EXIT(P(id) != -1, "");
        CHECK_EXIT(pread(comm_file, &offset, sizeof(int), 0) == sizeof(int), "");
        if(offset < MAX) {
            int data = offset;
            CHECK_EXIT(pwrite(comm_file, &data, sizeof(int), offset * sizeof(int)) == sizeof(int), "");
            offset++;
            CHECK_EXIT(pwrite(comm_file, &offset, sizeof(int), 0) == sizeof(int), "");
            logger(LOG_INFO, "produce: %d", data);
        } else sleep(1);
        CHECK_EXIT(V(id) != -1, "");
    }
}

int main(int argc, char **argv) {
    CHECK_EXIT(argc > 1, "");
    id = initAvai("meoww");
    CHECK_EXIT(id != NULL, "");
    signal(SIGHUP, exithandler);
    signal(SIGTERM, exithandler);
    signal(SIGINT, exithandler);
    signal(SIGALRM, exithandler);
    alloc_sprintf(fn, "%s-comm", argv[0]);
    comm_file = open(fn, O_CREAT | O_EXCL | O_RDWR, 0666);
    if(comm_file == -1) {
        if(errno == EEXIST) {
            comm_file = open(fn, O_RDWR, 0666);
        } else {
            CHECK_LOG(false, "");
        }
    } else {
        CHECK_EXIT(pwrite(comm_file, &(int[]){1}, sizeof(int), 0) == sizeof(int), "");
    }
    if(!strcmp(argv[1], "producer")) {
        producer(NULL);
    } else {
        consumer(NULL);
    }
}
```