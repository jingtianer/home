---
title: cha18.目录与链接
date: 2023-5-20 18:05:00
tags: 
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 18.1
4.3.2节曾指出，如果一个文件正处于执行状态，那么要将其打开以执行写操作是不可能的(open)调用返回-1，且将errno置为ETXTBSY。然而，在 shell 中执行如下操作却是可能的:
```sh
gcc -o longrunner longrunner.c$ ./longrunner &
# Leave running in background
vi longrunner.c
# Make some changes to the source code
gcc -o longrunner longrunner.c
```
最后一条命令覆盖了现有的同名可执行文件。原因何在?(提示:在每次编译后调用ls -li命令来查看可执行文件的i-node编号。)

### 解释

变异前后使用`ls -li`，inode确实变了。猜测`-o`参数会令编译程序将临时文件`rename`为对应名称，rename若`newpath`存在，则会覆盖。

## 18.2

### 测试
```c
//
// Created by root on 5/20/23.
//

#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>

int main() {
    mkdir("test", 0700);
    chdir("test");
    int fd = open("file", O_CREAT | O_RDWR, 0744);
    symlink("file", "../file");
    chmod("../file", 0111);
    printf("errno = %s\n", strerror(errno));
    return 0;
}
```

### 分析

打印出`errno`， 结果为：` Too many levels of symbolic links`。通过readlink读取该链接，其内容为`file`。

通过`ll`打印，该链接变成了指向自己的链接。chmod对其解引用，得到自身，导致解引用次数达到最大。
```sh
lrwxrwxrwx 1 root root 4 May 20 21:24 file -> file
```

## 18.3

实现realpath

```c
//
// Created by root on 5/20/23.
//

#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <sys/stat.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>

void parse(char *path, char *realpath) {
    char *end = NULL;
    while (path != NULL) {
        end = strchr(path, '/');
        if(end) *end = 0;
        if(path == end) {}
        else if (strcmp(path, ".") == 0) {

        } else if (strcmp(path, "..") == 0) {
            char *tmp = strrchr(realpath, '/');
            if (tmp) {
                *tmp = 0;
            }
        } else {
            strcat(realpath, "/");
            strcat(realpath, path);
        }
        if(end) path = end + 1;
        else path = NULL;
    }
}

int main(int argc, char **argv) {
    char *realpath = (char *) malloc(PATH_MAX + 1);
    char *buff = (char *) malloc(PATH_MAX + 1);
    realpath[0] = 0;
    buff[0] = 0;
    char *path = strdup(argv[1]);
    if(path[0] != '/') getcwd(realpath, NAME_MAX);
    parse(path, realpath);
    struct stat stat1;
    if(lstat(realpath, &stat1) == -1) {
        fprintf(stderr, "%s\n", strerror(errno));
    }
    if(S_ISLNK(stat1.st_mode)) {
        int readsize = readlink(realpath, buff, NAME_MAX);
        buff[readsize] = 0;
        struct stat stat2;
        if(stat(buff, &stat2) != -1) {
            char *tmp = strrchr(realpath, '/');
            if (tmp) {
                *tmp = 0;
            }
            parse(buff, realpath);
        }
    }
    printf("%s\n", realpath);
    return 0;
}
```

### 2023年6月3日更新

之前没有考虑到目录也可以有软链接
```c
//
// Created by root on 5/20/23.
//

#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <sys/stat.h>
#include <string.h>
#include <stdlib.h>
#include <limits.h>



void parse(char *path, char *realpath, char *buff) {
    char *end = NULL;
    while (path != NULL && *path) {
        end = strchr(path, '/');
        if(end) *end = 0;
        if(end == path) {
        } else if (strcmp(path, ".") == 0) {
        } else if (strcmp(path, "..") == 0) {
            char *tmp = strrchr(realpath, '/');
            if (tmp) {
                *tmp = 0;
            }
        } else {
            strcat(realpath, "/");
            strcat(realpath, path);
            struct stat stat1;
            if(lstat(realpath, &stat1) == -1) {
                fprintf(stderr, "%s:%s\n", strerror(errno), realpath);
                exit(1);
            }
            if(S_ISLNK(stat1.st_mode)) {
                ssize_t readsize = readlink(realpath, buff, NAME_MAX);
                buff[readsize] = 0;
//                printf("%s is link to: %s\n", realpath, buff);
                if(buff[0] == '/') {
                    realpath[0] = 0;
                } else {
                    char *tmp = strrchr(realpath, '/');
                    if (tmp) {
                        *tmp = 0;
                    } else {
                        realpath[0] = 0; //不需要，相对路径已经变成绝对路径了
                    }
                }
                parse(buff, realpath, buff);
            }
        }
        if(end) path = end + 1;
        else path = NULL;
    }
}

int main(int argc, char **argv) {
    char *realpath = (char *) malloc(PATH_MAX + 1);
    char *buff = (char *) malloc(PATH_MAX + 1);
    char *cwd = (char *) malloc(PATH_MAX + 1);
    cwd[0] = 0;
    realpath[0] = 0;
    buff[0] = 0;
    char *argpath = strdup(argv[1]);
    if(argpath[0] != '/') getcwd(cwd, NAME_MAX);
    parse(cwd, realpath, buff);
    parse(argpath, realpath, buff);
    printf("%s\n", realpath);
    return 0;
}
```

## 18.4

把18.4换成readdir_r

### 代码
懒得写，无聊

## 18.5

实现getcwd
```c
//
// Created by root on 5/21/23.
//

#include <stdio.h>
#include <fcntl.h>
#include <dirent.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

struct list {
    char name[NAME_MAX+1];
    struct list *next;
} * head;

struct list *new_list(const char *name, struct list *next) {
    struct list *ret = malloc(sizeof(struct list));
    strcpy(ret->name, name);
    ret->next = next;
    return ret;
}

bool samestat(struct stat* stat1, struct stat* stat2) {
    return stat1->st_ino == stat2->st_ino && stat1->st_dev == stat2->st_dev;
}

int main() {
    head = new_list("", NULL);

    long namemax = pathconf(".", _PC_NAME_MAX);
    char *buff = alloca(namemax + 1);
    buff[0] = 0;
    strcat(buff, "../");
    while (true) {
        struct stat pwdstat, parentstat;
        stat(".", &pwdstat);
        stat("..", &parentstat);
        if (samestat(&pwdstat, &parentstat)) {
            break;
        }
        DIR *parent = opendir("..");
        struct dirent *parent_rent = NULL;
        while ((parent_rent = readdir(parent)) != NULL) {
            buff[3] = 0;
            strcat(buff + 3, parent_rent->d_name);
            struct stat readstat;
            stat(buff, &readstat);
            if (samestat(&readstat, &pwdstat)) {
                printf("match! :%s\n", parent_rent->d_name);
                head->next = new_list(parent_rent->d_name, head->next);
                break;
            }
        }
        fchdir(dirfd(parent));
        closedir(parent);
    }

    struct list *p = head;
    while (p) {
        printf("%s/", p->name);
        p = p->next;
    }
    printf("\n");
    return 0;
}
```

## 18.6 18.7 18.8
实现nftw

懒得写

## 18.9

如果程序不知道当前工作目录，且在当前目录和目标目录下都打开了文件，其文件fd为`fd1`和`fd2`那么，`fchdir`效率更高。

- chdir: $ pwd=getcwd(), chdir(dir1), chdir(pwd), chdir(dir1), chdir(pwd), ... $
- fchdir $ fchdir(fd2), fchdir(fd1), fchdir(fd2), fchdir(fd1), ... $

跟据Flawfinder的输出，chdir, chown等函数依靠路径名，攻击者在调用前将文件移走，会导致chown，chdir失败，使用fchown，fchdir会更安全。

即，少调用一次`getpwd`

若在当前目录下打开了文件，而没有目标目录下的文件
- $ chdir(dir1), fchdir(fd), chdir(dir1), fchdir(fd), ... $

