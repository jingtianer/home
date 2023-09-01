---
title: cha45.System V IPC
date: 2023-8-30 19:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 45.1 45.2

- 编写一个程序来验证ftok0所采用的算法是否如45.2节中描述的那样使用了文件的i-node号、次要设备号以及proj值。(通过几个例子打印出所有这些值以及ftok的返回值的十六进制形式即可)。
- 实现ftok

```c
//
// Created by root on 8/30/23.
//

#define _GNU_SOURCE          /* See feature_test_macros(7) */
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ipc.h>

void error(const char *file, int line,const char *str, ...) {
    va_list fmt;
    va_start(fmt, str);
    fprintf(stderr, "error:%s %s:%d\n", strerror(errno), file, line);
    vfprintf(stderr, str, fmt);
    fprintf(stderr, "\n");
    va_end(fmt);
}

#define ERROR_EXIT(ret, msg...) do { error(__FILE__, __LINE__, msg); ret } while(0)

#define ERROR(msg...) ERROR_EXIT(exit(1);, msg)
#define FAIL(ret, msg...) ERROR_EXIT(ret, msg)
#define PRINT_ERROR_STR(msg...) FAIL(;, msg)


key_t _ftok(const char *file, int proj) {
    struct statx filestat;
    int dirfd = open(".", O_RDONLY);
    if(statx(dirfd, file, 0, 0, &filestat) == -1) FAIL(return -1;, "");
    close(dirfd);
    return ((proj&0xff) << 24) | ((filestat.stx_dev_minor & 0xff) << 16) | ((filestat.stx_ino & 0xffff));
}

int main(int argc, char **argv) {
    char *file = argv[1];
    struct statx filestat;
    int dirfd = open(".", O_RDONLY);
    if(statx(dirfd, file, 0, 0, &filestat) == -1) ERROR("");
    for(int proj = 1; proj <= 255; proj++) {
        printf("proj:%02X, dev:%02X, i-node:%04X, ", proj, filestat.stx_dev_minor & 0xff, filestat.stx_ino & 0xffff);
        printf("ftok:%08X\n", ftok(file, proj));
        printf("_ftok:%08X\n", _ftok(file, proj));
    }
    close(dirfd);
}
```



## 45.3
验证(通过实验)45.5节中有关用于生成System VIPC标识符的算法的声明。
```c

#define _GNU_SOURCE          /* See feature_test_macros(7) */

#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/msg.h>

#define IPCMNI 32768

int main(int argc, char *argv[]) {
    key_t key = ftok(argv[0], 0x6a);
    int id = msgget(key, IPC_CREAT | 0666), calid;
    struct msqid_ds msqidDs;
    msgctl(id, IPC_STAT, &msqidDs);
    calid = msqidDs.msg_perm.__seq * IPCMNI;
    FILE *filemsg = fopen("/proc/sysvipc/msg", "r");
    char msgline[2048];
    int index = 0;
    fgets(msgline, 2048, filemsg);
    key_t keyi;
    do {
        char *nextline = fgets(msgline, 2048, filemsg);
        if (nextline == NULL) {
            break;
        }
        sscanf(nextline, "%ld", &keyi);
        index++;
    } while (keyi != key);
    calid += index;
    if (calid == id) {
        printf("true!\n");
    } else {
        printf("false?\n");
    }
    msgctl(id, IPC_RMID, &msqidDs);
}
```

> index获取的不对，没办法直接读内核内存中的那个数据

### 更新

获取index的方法,`msgctl`的cmd使用`IPC_INFO`

```c

#define _GNU_SOURCE          /* See feature_test_macros(7) */

#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/msg.h>

#define IPCMNI 32768

int main(int argc, char *argv[]) {
    key_t key = ftok(argv[0], 0x6a);
    int id = msgget(key, IPC_CREAT | 0666), calid;
    struct msqid_ds msqidDs;
    int index = msgctl(id, IPC_INFO, &msqidDs);
    msgctl(id, IPC_STAT, &msqidDs);
    calid = index + msqidDs.msg_perm.__seq * IPCMNI;
    if (calid == id) {
        printf("true!\n");
    } else {
        printf("false?\n");
    }
    msgctl(id, IPC_RMID, &msqidDs);
}
```