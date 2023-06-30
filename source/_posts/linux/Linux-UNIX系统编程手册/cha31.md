---
title: cha31.线程安全和每线程存储
date: 2023-6-29 18:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 读书笔记

- pthread提供了一种所有线程只执行一次（用于所有线程只初始化一次）的方法`pthread_once(pthread_once_t*, void (*)(void));`
- pthread提供了每线程存储，即每个线程有独立与其他线程的存储，使用k-v存储
  - `int pthread_key_create(pthread_key_t *, void (*)(void *));`每个线程都存储一份，第一个参数为一个全局变量的指针，第二个参数为线程终止时自动调用的析构函数
  - `int pthread_setspecific(pthread_key_t, const void *)`指定key所对应的内存区域，进程终止时会将第二个参数送入析构函数
  - `void * pthread_getspecific(pthread_key_t)`获取key所对应的内存区域

## 31.1
实现pthread_once
```c
//
// Created by root on 6/29/23.
//

#include <pthread.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>

void init() {
    printf("init\n");
}
typedef struct {
    pthread_mutex_t mutex;
    bool call;
} _pthread_once_t;
_pthread_once_t once = {
        .mutex=PTHREAD_MUTEX_DEFAULT,
        .call=false
};
int _pthread_once(_pthread_once_t *once_ctrl, void (*init)(void)) {
    bool ok;
    if(pthread_mutex_lock(&once_ctrl->mutex) == 0) {
        ok = !once_ctrl->call;
        once_ctrl->call = true;
        pthread_mutex_unlock(&once_ctrl->mutex);
    } else {
        return -1;
    }
    if(ok) {
        init();
    }
    return 0;
}

void *fun(void *arg) {
    printf("Thread-%d start\n", *(int*)arg);
    if(_pthread_once(&once, init) == 0){
        printf("Thread-%d _pthread_once Success\n", *(int*)arg);
    }
    free(arg);
    return NULL;
}

int main() {
    pthread_t t;
    for(int i = 1; i <= 100; i++)
        pthread_create(&t, NULL, fun, memcpy(malloc(sizeof(int)), &i, sizeof(int)));
    pthread_exit(NULL);
}
```
## 31.2
实现线程安全版本的`dirname`,`basename`

```c
//
// Created by root on 6/29/23.
//

#include <stdio.h>
#include <pthread.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>
#include <libgen.h>

static __thread char dirname_buf[PATH_MAX];
static pthread_key_t basename_key;
static pthread_once_t basename_once = PTHREAD_ONCE_INIT;
char *dirname_r(const char *path) {
    const char *lastSlash = strrchr(path, '/');
    if(!lastSlash) {
        strncpy(dirname_buf, ".", 1);
    } else {
        strncpy(dirname_buf, path,  lastSlash - path);
    }
    dirname_buf[PATH_MAX-1] = 0;
    return dirname_buf;
}

void destroy_basename(void * buf) {
    free(buf);
}

void init_basename() {
    pthread_key_create(&basename_key, destroy_basename);
}

char *basename_r(const char *path) {
    pthread_once(&basename_once, init_basename);
    char *_basename_buf = (char *)pthread_getspecific(basename_key);
    if(_basename_buf == NULL) {
        _basename_buf = malloc(sizeof(char) * PATH_MAX);
        pthread_setspecific(basename_key, _basename_buf);
    }
    const char *lastSlash = strrchr(path, '/');
    if(!lastSlash) {
        lastSlash = path;
    } else {
        lastSlash++;
    }
    strncpy(_basename_buf, lastSlash, PATH_MAX-1);
    _basename_buf[PATH_MAX-1] = 0;
    return _basename_buf;
}


void *threadfn(void *arg) {
    if(!arg) return NULL;
    char *dir = (char *)arg;
    printf("dir = %s\nSAFE  :basename = %s, dirname = %s\n", dir, basename_r(dir), dirname_r(dir));
    printf("UNSAFE:basename = %s, dirname = %s\n", basename(dir), dirname(dir));
    return NULL;
}

int main(int argc, char *argv[]) {
    for(int i = 1; i < argc; i++) {
        pthread_t t;
        pthread_create(&t, NULL, threadfn, argv[i]);
    }
    pthread_exit(NULL);
}
```