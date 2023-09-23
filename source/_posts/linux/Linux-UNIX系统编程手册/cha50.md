---
title: cha50.虚拟内存操作
date: 2023-9-19 11:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 50.1
编写一个程序使其为RLIMITMEMLOCK资源限制设置一个值之后将数量超过这个限制的内存锁进内存来验证RLIMITMEMLOCK资源限制的作用。
```c
//
// Created by root on 7/18/23.
//
#include <utils.h>

#include <limits.h>
#include <sys/resource.h>
#include <sys/mman.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <signal.h>

#define USER 10087

void test(__rlimit_resource_t res, const char *name,void (*task)(__rlimit_resource_t res, struct rlimit *)) {
    logger(LOG_INFO, "test: %d(%s)", res, name);
    pid_t pid;
    CHECK_RET((pid = fork()) != -1, return;);
    if(!pid) {
        struct rlimit lim;
        CHECK_RET(getrlimit(res, &lim) != -1, return;);
        logger(LOG_INFO, "soft=%lu, hard=%lu", lim.rlim_cur, lim.rlim_max);
        task(res, &lim);
        logger(LOG_INFO, "soft=%lu, hard=%lu", lim.rlim_cur, lim.rlim_max);
        exit(0);
    }
    int status;
    CHECK_RET(waitpid(pid, &status, 0) != -1, return;);
    if(WIFSIGNALED(status)) logger(LOG_INFO, "status:%d, coredump:%d, term sig:%s(%d)", WEXITSTATUS(status), WCOREDUMP(status), strsignal(WTERMSIG(status)), WTERMSIG(status));
    else if(WIFSTOPPED(status)) logger(LOG_INFO, "status:%d, coredump:%d, term sig:%s(%d)", WEXITSTATUS(status), WCOREDUMP(status), strsignal(WSTOPSIG(status)), WSTOPSIG(status));
    else logger(LOG_INFO, "status:%d, coredump:%d", WEXITSTATUS(status), WCOREDUMP(status));
    CHECK_RET(WEXITSTATUS(status) != 0 || WCOREDUMP(status) || WIFSTOPPED(status) || WIFSIGNALED(status), return;);
}

#define invoke_test(res) test(res, #res, f##res)

#define fun(name) void f##name(__rlimit_resource_t res, struct rlimit *lim)

fun(RLIMIT_MEMLOCK) {
    long pagesize = sysconf(_SC_PAGESIZE);
    bool error_occured = false;
    lim->rlim_cur = lim->rlim_max = pagesize * 2; // = pagesize时，lock一个也会出错，可能已经默认有一页的内存被lock了（比如代码段，数据段
    CHECK_EXIT(setrlimit(res, lim) != -1);
    CHECK_EXIT(setuid(USER) != -1);
    void *mem;
    mem = malloc(pagesize*2);
    CHECK_LOG(mem != NULL);
    if(mlock(mem, pagesize) == -1) { //success
        CHECK_LOG(false);
        error_occured = true;
    }
    CHECK_LOG(munlock(mem, pagesize) != -1);
    safe_free(mem);
    
    mem = malloc(pagesize*3);
    CHECK_LOG(mem != NULL);
    if(mlock(mem, pagesize*2) == -1) { //fail
        CHECK_LOG(false);
        error_occured = true;
    }
    CHECK_LOG(munlock(mem, pagesize *2) != -1);
    safe_free(mem);
    
    if((mem = mmap(NULL, pagesize *3, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_ANONYMOUS | MAP_LOCKED, -1, 0)) == MAP_FAILED) { //fail
        CHECK_LOG(false);
        error_occured = true;
    } else {
        CHECK_LOG(munmap(mem, pagesize *3) != -1);
    }
    
    CHECK_LOG((mem = mmap(NULL, pagesize *3, PROT_READ | PROT_WRITE, MAP_SHARED | MAP_ANONYMOUS, -1, 0)) != MAP_FAILED);
    if(mlock(mem, pagesize*3) == -1) { //fail
        CHECK_LOG(false);
        error_occured = true;
    }
    CHECK_LOG(munmap(mem, pagesize *3) != -1);

    
    if(error_occured) {
        exit(1);
    }
    exit(0);
}

#define BUFFER_SIZE 2048
struct msgType {
    long mtype;
    char mcontent[BUFFER_SIZE];
};
#define REQ_SIZE (BUFFER_SIZE)

void on_exit_msg(int status, void *id) {
    CHECK_LOG(msgctl(*(int *)id, IPC_RMID, NULL) != -1);
}
void timeout(int sig) {
    logger(LOG_INFO, "received sig(%d):%s", sig, strsignal(sig));
    exit(1);
    // CHECK_LOG(signal(SIGALRM, SIG_DFL) != SIG_ERR);
    // raise(SIGALRM);
}
fun(RLIMIT_MSGQUEUE) {
    struct msgType msg;
    msg.mtype = 1;
    strcpy(msg.mcontent, "Meow!!");
    int id;
    CHECK_EXIT((id = msgget(IPC_PRIVATE, IPC_CREAT | 0666)) != -1);
    CHECK_EXIT(msgsnd(id, &msg, REQ_SIZE, 0) != -1);
    CHECK_EXIT(msgctl(id, IPC_RMID, NULL) != -1);

    lim->rlim_cur = lim->rlim_max = BUFFER_SIZE/2;
    CHECK_EXIT(setrlimit(res, lim) != -1);
    CHECK_EXIT(setuid(USER) != -1);
    on_exit(on_exit_msg, &id);
    CHECK_EXIT(signal(SIGALRM, timeout) != SIG_ERR);
    CHECK_EXIT((id = msgget(IPC_PRIVATE, IPC_CREAT | 0666)) != -1);
    CHECK_EXIT(msgsnd(id, &msg, REQ_SIZE, 0) != -1);
    CHECK_EXIT(msgsnd(id, &msg, REQ_SIZE, 0) != -1);
    CHECK_EXIT(msgsnd(id, &msg, REQ_SIZE, 0) != -1);
    CHECK_EXIT(msgsnd(id, &msg, REQ_SIZE, 0) != -1);
    CHECK_EXIT(msgsnd(id, &msg, REQ_SIZE, 0) != -1);
    CHECK_EXIT(msgsnd(id, &msg, REQ_SIZE, 0) != -1);
    CHECK_EXIT(msgsnd(id, &msg, REQ_SIZE, 0) != -1);
    CHECK_EXIT(msgsnd(id, &msg, REQ_SIZE, 0) != -1);
    CHECK_EXIT(alarm(1) != -1);
    CHECK_EXIT(msgsnd(id, &msg, REQ_SIZE, 0) != -1);

}

fun(RLIMIT_RSS);

int main(int argc, char ** argv) {
   invoke_test(RLIMIT_MEMLOCK); //还没学
   invoke_test(RLIMIT_MSGQUEUE); //还没学

//    invoke_test(RLIMIT_RSS); //linux没作用
}
```

## 50.2

写一个程序来验证madvise MADV DONTNEED操作在一个可写MAP_PRIVATE映射上的操作。

```c
//
// Created by root on 7/18/23.
//
#include <utils.h>

#include <limits.h>
#include <sys/resource.h>
#include <sys/mman.h>

int main(int argc, char ** argv) {
    long pagesize = sysconf(_SC_PAGESIZE);
    char *mem;
    CHECK_EXIT((mem = mmap(NULL, pagesize, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0)) != MAP_FAILED);
    memset(mem, 'a', pagesize);
    CHECK_EXIT(madvise(mem, pagesize, MADV_DONTNEED) != -1);
    for(int i = 0; i < pagesize; i++) {
        if(mem[i] == 0) logger(LOG_INFO, "mem:%p filled with '\\0'", mem);
        else if(mem[i] == 'a') logger(LOG_INFO, "mem:%p remains to be 'a'", mem);
        else logger(LOG_INFO, "mem:%p contains dirty data", mem);
    }
    CHECK_EXIT(munmap(mem, pagesize) != -1);
}
```