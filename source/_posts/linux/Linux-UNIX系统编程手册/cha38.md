---
title: cha38.编写安全的特权程序
date: 2023-8-1 22:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 38.1

用一个普通的非特权用户登录系统，创建一个可执行文件(或复制一个既有文件如`/bin/sleep`)，然后启用该文件的`set-user-ID`权限位(`chmod u+s`)。尝试修改这个文件(如`cat >>fle`)。当使用(`ls -l`)时文件的权限会发生什么情况呢?为何会发生这种情况?

现象：saved-user-id不见了
原因：通过下面的例子，猜测open时会清除set-usr-id标志位

```c
//
// Created by root on 8/1/23.
//

#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

static int exitcode = 0;

#define ERR(str...) do { fprintf(stderr, "%s:%d\n%s:", __FILE__, __LINE__, strerror(errno)); fprintf(stderr, str); fprintf(stderr, "\n"); exit(exitcode++); } while(0)

int main(int argc, char **argv) {
    if(argc < 3) {
        ERR("Usage: %s src dst [content..]", argv[0]);
    }
    char *file1 = argv[1];
    char *file2 = argv[2];
    int fd1 = open(file1, O_RDONLY);
    if(fd1 == -1) {
        ERR("file to open %s", file1);
    }
    struct stat stat1;
    if(fstat(fd1, &stat1) == -1) {
        ERR("fstat(fd1, &stat1)");
    }
    fprintf(stderr, "F_GETFL:%o\n", stat1.st_mode);
    int fd2 = open(file2, O_WRONLY | O_CREAT,  stat1.st_mode);
    if(fd2 == -1) {
        ERR("fail to open %s", file2);
    }

    char buffer[4096] = {0};
    ssize_t readsize = 0;
    while ((readsize = read(fd1, buffer, 4096)) > 0) {
        ssize_t writesize = write(fd2, buffer, readsize);
        if(writesize != readsize) {
            ERR("fail to write %s", file2);
        }
    }
    if(readsize < 0) {
        ERR("fail to read %s", file1);
    }
    for(int i = 3; i < argc; i++) {
        size_t len = strlen(argv[i]);
        if(write(fd2, argv[i], len) != len) {
            ERR("fail to write %s", file2);
        }
    }
    return 0;
}
```
## 38.2

编写一个与 sudo(8)程序类似的 set-user-ID-root 程序。这个程序应该像下面这样接收命令行选项和参数:
```sh
$ ./douser[ -u user ] program-file arg1 arg2
```
douser程序使用给定的参数执行 program-file，就像是被user 运行一样。(如果省略了-u选项，那么user 默认为root。)在执行 program-file之前，douser 应该请求 use
的密码并将密码与标准密码文件进行比较(参见程序清单8-2)，接着将进程的用户和组ID设置为与该用户对应的值。

