---
title: cha6.进程
date: 2023-3-25 18:05:00
tags: 
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 练习1
> 编译程序清单6-1中的程序(mem_segments.c)，使用1s-l命令显示可执行文件的大小。虽然该程序包含一个大约10MB的数组，但可执行文件大小要远小于此,为什么?

- 局部变量，分配在栈中，运行时分配

## 练习2

> 编写一个程序，观察当使用 longjmp()函数跳转到一个已经返回的函数时会发生什么?

- 开优化会无限递归，不开优化也有可能无限递归

## 练习3

> 使用getenv()函数、putenv()函数，必要时可直接修改environ，来实现setenv()函数和unsetenv()函数。此处的unsetenv()函数应检查是否对环境变量进行了多次定义，如果是多次定义则将移除对该变量的所有定义(glibc版本的unsetenv()函数实现了这-功能)


```c
#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include<errno.h>
extern char **environ;
int __setenv(const char *, const char *, int overwrite);
// overwrite = 0, 已存在则不改变, return 0/-1

int __unsetenv(const char *);
// return 0/-1

#define setenv(a,b,c) errno = 0; \
if(__setenv(a, b, c) == -1) { \
    perror("setenv"); \
    exit(1); \
}

#define unsetenv(a) errno = 0; \
if(__unsetenv(a) == -1) { \
    perror("unsetenv"); \
    exit(1); \
}

// #define GETENV

void printEnv();

int main(int argc, char **argv) {
    clearenv();
    environ = (char **)malloc(argc*sizeof(char *));
    for(int i = 1; i < argc; i++) {
        environ[i-1] = argv[i];
        environ[i-1] = argv[i];
    }
    environ[argc-1] = NULL;
    printEnv();
    setenv("Jingtianer", "pretty", 1);
    setenv("Jingtianer", "handsome", 1);
    setenv("Meeow", "handsome", 0);
    setenv("Meeow", "pretty", 0);
    printEnv();
    unsetenv("Meeow");
    unsetenv("Jingtianer");
    unsetenv("A");
    printEnv();
    return 0;
}

void printEnv() {
    printf("environ=%p\n", environ);
    if(environ != NULL)
        for(char **env=environ; *env; env++) {
            printf("%s\n", *env);
        }
}

int __setenv(const char *name, const char *val, int overwrite) {
    #ifndef GETENV
    size_t nameLen = strlen(name);
    char **env=environ;
    if(env)
        for(; *env; env++) {
            if(strncmp(name, *env, nameLen) == 0) {
                if(overwrite == 0) return 0;
                else break;
            }
        }
    char * envstr = (char *) malloc((nameLen+strlen(val)+1+1)*sizeof(char));
    sprintf(envstr, "%s=%s", name, val);
    if(env != NULL && *env != NULL) {
        *env = envstr;
    } else {
        return putenv(envstr);
    }
    return 0;
    #endif

    #ifdef GETENV
    char *env;
    if(env=getenv(name) != NULL && overwrite == 0) {
        return 0;
    }
    
    size_t nameLen = strlen(name);
    char * envstr = (char *) malloc((nameLen+strlen(val)+1+1)*sizeof(char));
    sprintf(envstr, "%s=%s", name, val);
    return putenv(envstr);
    #endif

}

int __unsetenv(const char *name) {
    #ifndef GETENV
    if(environ == NULL) return 0;
    size_t nameLen = strlen(name);
    char **env=environ, **move = environ;
    for(; *env; env++) {
        if(strncmp(name, *env, nameLen) != 0) {
            *move = *env;
            move++;
        }
    }
    *move = NULL;
    return 0;
    #endif
    
    #ifdef GETENV
    char *env;
    if(env=getenv(name) != NULL) {
        return putenv(name); //并非标准实现
    }
    #endif
}
```