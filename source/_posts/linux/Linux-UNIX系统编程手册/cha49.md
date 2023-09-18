---
title: cha49.内存映射
date: 2023-9-16 11:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 读书笔记

||文件映射|匿名映射|
|-|-|-|
|私有映射|老刘吃独食 (文件), 别人可以看 (读取同一块内存区域), 但是想吃 (修改, 写时复制)需要自己做一份一模一样的(修改不会反应到文件上)|老刘吃空气 (全0大块内存), 给儿子看, 儿子想吃需要自己做一份一样的 (写时复制), 不给老李家看, 不给老李家吃|
|共享映射|老刘吃饭 (文件), 给儿子吃 (子进程可访问 修改), 也给老李吃 (非相关进程也可访问 修改)(修改会反应到文件上)|老刘吃空气 (全0内存), 给儿子吃 (子进程可访问 修改), 不给老李家吃 (非相关进程不可访问 修改)|

## 创建公共头文件

为了减少每个练习中重复的定义，如logger, safe_free，定义一个头文件共所有程序使用
### utils.h

{% codeblock include/utils.h lang:c %}
#ifndef __MEOW_UTILS__
#define __MEOW_UTILS__
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
#include <sys/mman.h>


extern FILE *logfile;
extern bool syslog_enable;

#ifndef DEBUG_LEVEL
#define DEBUG_LEVEL LOG_DEBUG
#endif
#define STRING_MSG "\n"

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
        char *__syslog_enable__data; \
        alloc_sprintf(__syslog_enable__data, msg); \
        syslog(level, "%s", __syslog_enable__data); \
        safe_free(__syslog_enable__data); \
    } \
} while(0)

#define CHECK_RET_MSG(x, ret, msg...) \
        logger(LOG_DEBUG, "checking: \"%s\"", #x); \
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


#define CHECK_MSG(x, msg...) CHECK_RET_MSG(x, return -1;, msg)
#define CHECK_EXIT_MSG(x, msg...) CHECK_RET_MSG(x, exit(EXIT_FAILURE);, msg)
#define CHECK_LOG_MSG(x, msg...) CHECK_RET_MSG(x, ;, msg)

#define CHECK_RET(x, ret) CHECK_RET_MSG(x, ret;, STRING_MSG)
#define CHECK(x) CHECK_RET_MSG(x, return -1;, STRING_MSG)
#define CHECK_EXIT(x) CHECK_RET_MSG(x, exit(EXIT_FAILURE);, STRING_MSG)
#define CHECK_LOG(x) CHECK_RET_MSG(x, ;, STRING_MSG)
int safe_atoi(const char *num, int *ret);
#define safe_free(__safe_free_ptr) do { if(__safe_free_ptr) { free(__safe_free_ptr); (__safe_free_ptr) = NULL;} } while(0)
#endif
{% endcodeblock %}

### utils.c
{% codeblock utils/utils.h lang:c %}
#include "utils.h"
FILE *logfile = NULL;
bool syslog_enable = false;
void __attribute__ ((constructor)) init() {
    syslog_enable = false;
    logfile = stderr;
}

int safe_atoi(const char *num, int *ret) {
    CHECK(ret != NULL);
    CHECK(num != NULL);
    const char *ptr = num;
    while (*ptr) {
        CHECK(*ptr >= '0' && *ptr <= '9');
        ptr++;
    }
    *ret = atoi(num);
    return 0;
}
{% endcodeblock %}

### 生成CMakeLists.txt并编译
代码文件全部放入目录`chaXX/src`下，并且一个练习只用一个文件

{% codeblock build.sh lang:bash %}
OUTPUT=CMakeLists.txt
function writer() {
    echo $@ | tee -a $OUTPUT
}
rm $OUTPUT
writer "cmake_minimum_required(VERSION 3.25.0)"

writer "aux_source_directory(../utils SRC_UTILS)"
writer "include_directories(../include)"
for file in `ls src`; do
    out=`echo $file | awk ' { len=split($0, arr, "."); printf arr[1];for(i = 2; i < len; i++) printf "."arr[i] } '`
    writer "add_executable($out src/$file \${SRC_UTILS})"
done

for arg in $@; do
    if [ ${arg:0:2} == "-D" ]; then
        writer "ADD_DEFINITIONS($arg)"
    fi
done

cmake .
make
{% endcodeblock %}
## 49.1

使用mmap和memcpy调用(不是read0或write0)编写一个类似于cp的程序来将一个源文件复制到目标文件。使用 fstat获取输入文件的大小，然后可以使用这个大小来设置所需的内存映射的大小，使用 fruncate设置输出文件的大小。
```c
//
// Created by root on 9/14/23.
//
#include "utils.h"

int main(int argc, char *argv[]) {
    CHECK_EXIT(argc == 3, "Usage: %s src dest", argv[0]);

    int src_fd = open(argv[1], O_RDONLY);
    CHECK_EXIT(src_fd != -1, STRING_MSG);
    int dest_fd = open(argv[2], O_RDWR | O_CREAT, 0666);
    CHECK_EXIT(dest_fd != -1, STRING_MSG);

    struct stat src_stat;
    CHECK_EXIT(fstat(src_fd, &src_stat) != -1, STRING_MSG);    
    CHECK_EXIT(ftruncate(dest_fd, src_stat.st_size) != -1, STRING_MSG);    

    void *src_map = mmap(NULL, src_stat.st_size, PROT_READ, MAP_SHARED, src_fd, 0);
    void *dest_map = mmap(NULL, src_stat.st_size, PROT_WRITE, MAP_SHARED, dest_fd, 0);
    memcpy(dest_map, src_map, src_stat.st_size);

    
    CHECK_EXIT(close(src_fd) != -1, STRING_MSG);
    CHECK_EXIT(close(dest_fd) != -1, STRING_MSG);
    CHECK_EXIT(munmap(src_map, src_stat.st_size) != -1, STRING_MSG);
    CHECK_EXIT(munmap(dest_map, src_stat.st_size) != -1, STRING_MSG);
    return 0;
}
```

## 49.2

重写程序清单48-2(svshm_xf_writer.c)和程序清单48-3(svshm xfr_reader.c)使它们使用共享内存映射来取代SystemV共享内存

### 创建pvutil工具

{% codeblock include/pvutils.h lang:c %}
#ifndef __MEOW_PV_UTILS__
#define __MEOW_PV_UTILS__
#include <sys/sem.h>
#include <sys/ipc.h>

union semun {
    int val;
    struct semid_ds *buf;
    unsigned short *array;
#if defined(__linux__)
    struct seminfo *__buf;
#endif
};

int P(int semnum);

int testP(int semnum);

int V(int semnum);

int initPVByFile(const char *filename, char x, int semcnt);

int initPVByKey(key_t key, int semcnt);

int initAvai(int semnum);

int initInUse(int semnum);

int rmPV();
#endif
{% endcodeblock %}

{% codeblock utils/pvutils.c lang:c %}
#include "pvutils.h"
#include "utils.h"
static key_t __sem_key = -1;
static int __sem_id = -1;
int rmPV() {
    int id = __sem_id;
    __sem_key = -1;
    __sem_id = -1;
    
    return semctl(id, 0, IPC_RMID);
}

int incrsem(int semnum, short incr, short flg) {
    struct sembuf sembuf;
    sembuf = (struct sembuf){
            .sem_num=semnum,
            .sem_flg=flg,
            .sem_op=incr
    };
    return semop(__sem_id, &sembuf, 1);
}


int setVal(int n, int semnum) {
    union semun arg;
    arg.val = n;
    CHECK(semctl(__sem_id, semnum, SETVAL, arg) != -1);
    return 0;
}

int initAvai(int semnum) {
    CHECK(setVal(0, semnum) != -1);
    CHECK(incrsem(semnum, 1, 0) != -1);
    return 0;
}

int initInUse(int semnum) {
    CHECK(setVal(0, semnum) != -1);
    CHECK(incrsem(semnum, 0, 0) != -1);
    return 0;
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

int setAll(unsigned short *array) {
    union semun arg;
    arg.array = array;
    CHECK(semctl(__sem_id, 0, SETALL, arg) != -1);
    return 0;
}

int __initPV(int semcnt) {
    semcnt++; // sem[0] for waiting init, sem[1...n] for user
    if((__sem_id = semget(__sem_key, semcnt, IPC_CREAT | IPC_EXCL | 0666)) != -1) {
        unsigned short *array = malloc(semcnt * sizeof(unsigned short));
        memset(array, 0, semcnt * sizeof(unsigned short));
        CHECK(array != NULL);
        CHECK(setAll(array) != -1);
        CHECK(initInUse(0) != -1);
        free(array);
    } else {
        CHECK(errno == EEXIST);
        __sem_id = semget(__sem_key, semcnt,  0666);
        struct semid_ds ds;
        union semun arg;
        arg.buf = &ds;
        CHECK(semctl(__sem_id, 0, IPC_STAT, arg) != -1);
        while (ds.sem_otime == 0) {
            logger(LOG_DEBUG, "waiting for sem init");
            sleep(1);
            CHECK(semctl(__sem_id, 0, IPC_STAT, arg) != -1);
        }
    }
    logger(LOG_DEBUG, "finish init. PID = %ld", (long)getpid());
}

int initPVByFile(const char *filename, char x, int semcnt) {
    __sem_key = ftok(filename, x);
    if(__initPV(semcnt) == -1) {
        rmPV();
        return -1;
    }
    return 0;
}

int initPVByKey(key_t key, int semcnt) {
    __sem_key = key;
    if(__initPV(semcnt) == -1) {
        rmPV();
        return -1;
    }
    return 0;
}
{% endcodeblock %}

### 主程序
```c
#include "utils.h"
#include "pvutils.h"

void handler(int sig) {
    logger(LOG_INFO, "received signal(%d):%s", sig, strsignal(sig));
    exit(0);
}
#define BUFFER_SIZE 2048
struct MmapStruct {
    ssize_t len;
    char buf[BUFFER_SIZE];
};

void cleanupMmap(int status, void *buf) {
    CHECK_LOG(munmap(buf, sizeof(struct MmapStruct)) != -1);
}
void cleanupPV(int status, void *buf) {
    CHECK_LOG(rmPV() != -1);
}

int main(int argc, char *argv[]) {
    CHECK_EXIT_MSG(argc == 3, "Usage: %s writer|reader file", argv[0]);
    char *outfile = argv[2];
    int fd = open(outfile, O_RDWR | O_CREAT, 0666);
    CHECK_EXIT(ftruncate(fd, sizeof(struct MmapStruct)) != -1);
    CHECK_EXIT(fd != -1);
    CHECK_EXIT(initPVByFile(argv[1], 'a', 2) != -1);
    signal(SIGINT, handler);
    signal(SIGTERM, handler);
    signal(SIGHUP, handler);
    struct MmapStruct *mmapP = mmap(NULL, sizeof(struct MmapStruct), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);;
    
    CHECK_EXIT(mmapP != MAP_FAILED);
    CHECK_EXIT(close(fd) != -1);
    on_exit(cleanupMmap, mmapP);
    on_exit(cleanupPV, NULL);
    CHECK_EXIT(initAvai(1) != -1);
    if(!strcmp(argv[1], "writer")) {
        size_t size = 0;
        bool stop = false;
        for(int i = 0; !stop ;i++) {
            CHECK_EXIT(P(1) != -1);
            logger(LOG_INFO, "write start");
            CHECK_EXIT((mmapP->len = read(STDIN_FILENO, mmapP->buf, BUFFER_SIZE - sizeof(int))) >= 0);
            size += mmapP->len;
            if(mmapP->len == 0) {
                stop = true;
            }
            CHECK_EXIT(V(2) != -1);
            logger(LOG_INFO, "write end: i = %d, size = %lu", i, size);
        }
    } else {
        size_t size = 0;
        bool stop = false;
        for(int i = 0; !stop ;i++) {
            CHECK_EXIT(P(2) != -1);
            logger(LOG_INFO, "read start");
            CHECK_EXIT(write(STDOUT_FILENO, mmapP->buf, mmapP->len) == mmapP->len);
            size += mmapP->len;
            if(mmapP->len == 0) {
                stop = true;
            }
            CHECK_EXIT(V(1) != -1);
            logger(LOG_INFO, "read end: i = %d, size = %lu", i, size);
        }

    }
}
```

### 49.3

编写程序验证在49.4.3节中描述的情况下会产生SIGBUS和SIGSEGV信号

```c

#include "utils.h"
#define BUFFER_SIZE 2048
void handler(int sig) {
    logger(LOG_INFO, "received: signal(%d):%s", sig, strsignal(sig));
    CHECK_LOG(signal(sig, SIG_DFL) != SIG_ERR);
    fflush(NULL);
    raise(sig);
    return;
}
void testcase(const char *file, int filesize, int mmapsize, int access) {
    pid_t pid;
    CHECK_RET((pid = fork()) != -1, return;);
    if(!pid) {
        CHECK_EXIT(signal(SIGBUS, handler) != SIG_ERR);
        CHECK_EXIT(signal(SIGSEGV, handler) != SIG_ERR);
        logger(LOG_INFO, "filesize=%d, mmapsize=%d, access=%d", filesize, mmapsize, access);
        int fd = open(file, O_RDWR | O_CREAT | O_SYNC, 0666);
        // CHECK_EXIT(ftruncate(fd, 0) != -1);
        // CHECK_EXIT(fsync(fd) != -1);
        CHECK_EXIT(ftruncate(fd, filesize) != -1);
        CHECK_EXIT(fsync(fd) != -1);
        CHECK_EXIT(fd != -1);
        char *mmapP = mmap(NULL, mmapsize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
        CHECK_EXIT(mmapP != MAP_FAILED);
        CHECK_EXIT(close(fd) != -1);
        logger(LOG_INFO, "mmapP=%p, access:%p", mmapP, (mmapP + access));
        mmapP[access] = 'b';
        CHECK_LOG(munmap(mmapP, mmapsize) != -1);
        exit(0);
    }
    int status;
    CHECK_RET(waitpid(pid, &status, 0) != -1, return;);
    logger(LOG_INFO, "exit status=%d, exit sig=(%d)%s", WEXITSTATUS(status), WSTOPSIG(status), strsignal(WSTOPSIG(status)));
}
int main(int argc, char *argv[]) {
    setbuf(stderr, NULL);
    setbuf(stdout, NULL);
    if(argc == 2) {
        long pagesize = sysconf(_SC_PAGESIZE);
        logger(LOG_INFO, "pagesize = %ld", pagesize);
        testcase(argv[1], pagesize*3, pagesize / 2+pagesize, 0);
        testcase(argv[1], pagesize*3, pagesize / 2+pagesize, pagesize / 2+pagesize);
        testcase(argv[1], pagesize*3, pagesize / 2+pagesize, pagesize*2); // sigsegv but do not receive it here

        testcase(argv[1], pagesize/2, pagesize*2, 0);
        testcase(argv[1], pagesize/2, pagesize*2, pagesize / 2);
        testcase(argv[1], pagesize/2, pagesize*2, pagesize); // sigbus
        testcase(argv[1], pagesize/2, pagesize*2, pagesize*2); // sigsegv but do not receive it here
 
        testcase(argv[1], pagesize/2, pagesize, pagesize); // sigsegv

    } else {
        CHECK_EXIT_MSG(argc == 5, "Usage: %s filename filesize mmapsize access", argv[0]);
        int filesize, mmapsize, access;
        CHECK_EXIT_MSG(safe_atoi(argv[2], &filesize) != -1, "safe_atoi filesize=%s", argv[2]);
        CHECK_EXIT_MSG(safe_atoi(argv[3], &mmapsize) != -1, "safe_atoi mmapsize=%s", argv[3]);
        CHECK_EXIT_MSG(safe_atoi(argv[4], &access) != -1, "safe_atoi access=%s", argv[4]);
        testcase(argv[1], filesize, mmapsize, access);
    }
}
```

> 不知道为什么，本应出现`sigsegv`的地方并没有收到信号，只有分配一个页面后越界的情况会产生`sigsegv`

### 2023年9月18日更新

产生`sigsegv`的根本原因是试图访问无法访问的内存地址，现在的`mmap`实现可能为了速度与安全的考虑，会多分配一部分内存。只要分配时多分配一页，再将多分配的部分回收，就可以触发`sigsegv`了
```c

#include "utils.h"
#define BUFFER_SIZE 2048
void handler(int sig) {
    logger(LOG_INFO, "received: signal(%d):%s", sig, strsignal(sig));
    CHECK_LOG(signal(sig, SIG_DFL) != SIG_ERR);
    fflush(NULL);
    raise(sig);
    return;
}
int offalign(int off, int size) {
    return (off%size > 0 ? (size - off%size) : 0);
} // 令off与size对其所需的调整量

long pagesize;
void testcase(const char *file, int filesize, int mmapsize, int access) {
    pid_t pid;
    CHECK_RET((pid = fork()) != -1, return;);
    if(!pid) {
        CHECK_EXIT(signal(SIGBUS, handler) != SIG_ERR);
        CHECK_EXIT(signal(SIGSEGV, handler) != SIG_ERR);
        logger(LOG_INFO, "filesize=%d, mmapsize=%d, access=%d", filesize, mmapsize, access);
        int fd = open(file, O_RDWR | O_CREAT | O_SYNC, 0666);
        // CHECK_EXIT(ftruncate(fd, 0) != -1);
        // CHECK_EXIT(fsync(fd) != -1);
        CHECK_EXIT(ftruncate(fd, filesize) != -1);
        CHECK_EXIT(fsync(fd) != -1);
        CHECK_EXIT(fd != -1);
        char *mmapP = mmap(NULL, mmapsize+pagesize, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
        if(offalign(mmapsize,pagesize) > 0) 
            CHECK_LOG(munmap(mmapP+offalign(mmapsize,pagesize) + mmapsize, pagesize - offalign(mmapsize,pagesize)) != -1);
            //mmap多分配一页，然后把多分配的部分去掉
        CHECK_EXIT(mmapP != MAP_FAILED);
        CHECK_EXIT(close(fd) != -1);
        logger(LOG_INFO, "mmapP=%p, access:%p", mmapP, (mmapP + access));
        mmapP[access] = 'b';
        CHECK_LOG(munmap(mmapP, mmapsize) != -1);
        exit(0);
    }
    int status;
    CHECK_RET(waitpid(pid, &status, 0) != -1, return;);
    logger(LOG_INFO, "exit status=%d, exit sig=(%d)%s", WEXITSTATUS(status), WSTOPSIG(status), strsignal(WSTOPSIG(status)));
}
int main(int argc, char *argv[]) {
    setbuf(stderr, NULL);
    setbuf(stdout, NULL);
    pagesize = sysconf(_SC_PAGESIZE);
    if(argc == 2) {
        logger(LOG_INFO, "pagesize = %ld", pagesize);
        testcase(argv[1], pagesize*3, pagesize / 2+pagesize, 0);
        testcase(argv[1], pagesize*3, pagesize / 2+pagesize, pagesize / 2+pagesize);
        testcase(argv[1], pagesize*3, pagesize / 2+pagesize, pagesize*2); // sigsegv but do not receive it here

        testcase(argv[1], pagesize/2, pagesize*2, 0);
        testcase(argv[1], pagesize/2, pagesize*2, pagesize / 2);
        testcase(argv[1], pagesize/2, pagesize*2, pagesize); // sigbus
        testcase(argv[1], pagesize/2, pagesize*2, pagesize*2); // sigsegv but do not receive it here
        
        testcase(argv[1], pagesize/2, pagesize, pagesize); // sigsegv

    } else {
        CHECK_EXIT_MSG(argc == 5, "Usage: %s filename filesize mmapsize access", argv[0]);
        int filesize, mmapsize, access;
        CHECK_EXIT_MSG(safe_atoi(argv[2], &filesize) != -1, "safe_atoi filesize=%s", argv[2]);
        CHECK_EXIT_MSG(safe_atoi(argv[3], &mmapsize) != -1, "safe_atoi mmapsize=%s", argv[3]);
        CHECK_EXIT_MSG(safe_atoi(argv[4], &access) != -1, "safe_atoi access=%s", argv[4]);
        testcase(argv[1], filesize, mmapsize, access);
    }
}
```