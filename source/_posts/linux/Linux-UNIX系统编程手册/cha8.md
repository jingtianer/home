---
title: cha8.用户和组
date: 2023-4-10 18:05:00
tags: 
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 8.1

运行下面代码，为什么输出会相同？

```c
#include <stdio.h>
#include <unistd.h>
#include <pwd.h>
int main() {
    struct passwd * p1 = getpwnam("redis");
    struct passwd * p2 = getpwnam("sshd");
    printf("getpwnam(\"redis\")->pw_uid = %u, getpwnam(\"sshd\")->pw_uid = %u\n", p1->pw_uid, p2->pw_uid);
    printf("getpwnam(\"redis\") = %p, getpwnam(\"sshd\") = %p\n", p1, p2);
    return 0;
}
```

> getpwnam和getpwuid返回的指针指向由静态分配的的内存，地址都是相同的，所以会导致相同。

## 8.2

用getpwent，setpwent，endpwent实现getpwnam

```c
#include <stdio.h>
#include <pwd.h>
#include <string.h>

struct passwd getpwnamRet;

struct passwd *__getpwnam(const char *name) {
    struct passwd *pwd = NULL;
    while((pwd = getpwent()) != NULL) {
        if(!strcmp(name, pwd->pw_name)) {
            break;
        }
    }
    endpwent();
    if(pwd != NULL) {
        memcpy(&getpwnamRet, pwd, sizeof(struct passwd));
        return &getpwnamRet;
    }
    return NULL;
}

void printpwd(struct passwd *pwd) {
    if(pwd == NULL) {
        printf("User not Found!\n");
        return;
    }
    printf("Login name:\t%s\n", pwd->pw_name);
    printf("Login passwd:\t%s\n", pwd->pw_passwd);
    printf("User uid:\t%u\n", pwd->pw_uid);
    printf("User gid:\t%u\n", pwd->pw_gid);
    printf("User info:\t%s\n", pwd->pw_gecos);
    printf("Work dir:\t%s\n", pwd->pw_dir);
    printf("Login shell:\t%s\n", pwd->pw_shell);
}

int main(int argc, char *argv[]) {
    printpwd(__getpwnam(argv[1]));
    return 0;
}
```

> 事实上，没有必要为了定义全局变量getpwnamRet，因为getpwent的返回值本身就是静态区的

```c
#include <stdio.h>
#include <pwd.h>
#include <string.h>

struct passwd *__getpwnam(const char *name) {
    struct passwd *pwd = NULL;
    while((pwd = getpwent()) != NULL) {
        if(!strcmp(name, pwd->pw_name)) {
            break;
        }
    }
    endpwent();
    return pwd;
}

void printpwd(struct passwd *pwd) {
    if(pwd == NULL) {
        printf("User not Found!\n");
        return;
    }
    printf("Login name:\t%s\n", pwd->pw_name);
    printf("Login passwd:\t%s\n", pwd->pw_passwd);
    printf("User uid:\t%u\n", pwd->pw_uid);
    printf("User gid:\t%u\n", pwd->pw_gid);
    printf("User info:\t%s\n", pwd->pw_gecos);
    printf("Work dir:\t%s\n", pwd->pw_dir);
    printf("Login shell:\t%s\n", pwd->pw_shell);
}

int main(int argc, char *argv[]) {
    struct passwd *p1 = __getpwnam(argv[1]), *p2 = __getpwnam(argv[2]);
    printpwd(p1);
    printpwd(p2);
    return 0;
}
```