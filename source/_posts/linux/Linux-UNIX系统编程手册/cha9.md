---
title: cha9.进程凭证
date: 2023-4-13 18:05:00
tags: 
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 9.1 
9-1.在下列每种情况中，假设进程用户ID的初始值分别为real(实际) = 1000、effective(有效）= 0、saved（保存）= 0、file-system（文件系统）= 0。当执行这些调用后，用户ID的状态如何?
```c
setuid(2000);
setreuid(-1, 2000);
seteuid(2000);
setfsuid(2000);
setresuid(-1,2000,3000);
```

### 实验代码
```c
#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/fsuid.h>

int main(int argc, char *argv[]) {
    setresuid(1000, 0, 0);
    setfsuid(0);
    int test = atoi(argv[1]);
    uid_t r, e, s, fs;
    if(getresuid(&r, &e, &s) == -1) return 1;
    fs = setfsuid(0);
    printf("real = %u, effective = %u, save = %u, fs = %u\n", r, e, s, fs);
    switch (test) {
        case 1:
        printf("setuid(2000) = %d\n", setuid(2000));
        break;
        case 2:
        printf("setreuid(-1, 2000) = %d\n", setreuid(-1, 2000));
        break;
        case 3:
        printf("seteuid(2000) = %d\n", seteuid(2000));
        break;
        case 4:
        printf("setfsuid(2000) = %d\n", setfsuid(2000));
        break;
        case 5:
        printf("setresuid(-1, 2000, 3000) = %d\n", setresuid(-1, 2000, 3000));
        break;
    }
    if(getresuid(&r, &e, &s) == -1) return 1;
    fs = setfsuid(0);
    printf("real = %u, effective = %u, save = %u, fs = %u\n", r, e, s, fs);
    return 0;
}
```

### 环境准备
- 登录root用户，创建用户
```shell
useradd -m tmp -u 1000 -s /bin/bash # 创建tmp，创建home，指定登录shell
# passwd tmp
# usermod -a -G sudo tmp # sudo权限
```

- 编译程序，设置`set-user-id`标记
```shell
gcc practice9_1.c -o practice9_1
for i in `seq 5`; do ./practice9_1 $i; done
chmod +s practice9_1
su tmp
for i in `seq 5`; do ./practice9_1 $i; done
```

### 恢复环境
```shell
userdel tmp
rm -rf /home/tmp
```

### 执行结果
- root用户/root用户有set-user-id标志

|exec|real|effective|save|fs|解释|
|-|-|-|-|-|-|
|`setuid(2000);`|2000|2000|2000|2000|setuid会同时修改r,e,s|
|`setreuid(-1, 2000);`|1000|2000|2000|2000|这里s也跟着变了，是因为满足了s改变的条件|
|`seteuid(2000);`|1000|2000|0|2000|fs会随着e改变，上面也是这样|
|`setfsuid(2000);`|1000|0|0|2000|只改变fs|
|`setresuid(-1,2000,3000);`|1000|2000|3000|2000|很正常|

## 9.2

拥有如下用户ID的进程享有特权吗?请予解释。
real=0 effective=1000 saved=1000 file-system=1000

> 没有，但是可以seteuid(0)，拥有权限

```c
#define _GNU_SOURCE
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/fsuid.h>
#include <sys/wait.h>
#include <errno.h>

int checkPermission() {
    pid_t pid;
    pid = fork();
    int childret = 0;
    if(pid == 0) {
        char **argv = malloc(3 * sizeof(char *));
        argv[0] = "/usr/bin/ls";
        argv[1] = "/root/";
        argv[2] = NULL;
        int ret;
        if((ret = execv(argv[0], argv)) == -1) {
            fprintf(stderr, "fail to exec ls, error: %s, ret = %d\n", strerror(errno), ret);
        }
        return ret;
    } else {
        if(wait(&childret) != (pid_t)-1) {
            childret = WEXITSTATUS(childret);
            printf("child process stop, childret = %d\n", childret);
            if(childret == 0) {
                printf("permission granted\n");
            } else if(childret == WEXITSTATUS(-1)) {
                printf("exec fail\n");
            } else {
                printf("no permission\n");
            }
        } else {
            fprintf(stderr, "wait, error: %s\n", strerror(errno));
        }
    }
    return 0;
}

void printres() {
    uid_t r, e, s, fs;
    if(getresuid(&r, &e, &s) == -1) exit(-1);
    fs = setfsuid(0);
    printf("real = %u, effective = %u, save = %u, fs = %u\n", r, e, s, fs);
    checkPermission();
}

int main(int argc, char *argv[]) {
    printres();
    if(setresuid(0, 1000, 1000) == -1) return 1;
    printres();
    if(setfsuid(1000) == -1) return 2;
    printres();
    if(seteuid(0) == -1) return 3;
    printres();
    return 0;
}
```

> 创建子进程执行`ls /root`，没有特权会返回2，执行结果为0220

## 9.3

使用setgroups()及库函数从密码文件、组文件（参见8.4节)中获取信息，以实现initgroups()。请注意，欲调用setgroups，进程必须享有特权。

```c
#define _GNU_SOURCE
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <grp.h>
#include <limits.h>
#include <errno.h>

#define BUFFSIZE 0xffff
// #define BUFFSIZE 2

#define CHECK(x) if(!(x)) {fprintf(stderr, "error: %s\n", strerror(errno)); exit(errno); }

char *strAllocCat(char *str1, const char *str2, int *len1, int len2) {
    char *ret = malloc((*len1 + len2 + 1) * sizeof(char));
    strncpy(ret, str1, *len1);
    strncpy(ret + *len1, str2, len2);
    free(str1);
    *len1 += len2;
    return ret;
} // 复制且分配内存，最后一位加上0，处理成c语言字符串，释放str1内存，更新字符串长度

char *readline(int fileno, int *readsize) {
    static char buf[BUFFSIZE+1];
    static char *off = buf;
    static int eof = 0;
    char *line = malloc(sizeof(char));
    int lineSize = 0;
    char *move = off;
    if(off - buf >= eof) {
        eof = read(fileno, buf, BUFFSIZE);
        if(eof == 0) {
            *readsize = 0;
            return NULL;
        }
        CHECK(eof != -1)
        buf[eof] = 0;
        off = buf;
        move=off;
    }
    while(*move && *move != '\n') {
        move++;
    }
    line = strAllocCat(line, off, &lineSize, move - off);
    off = move+1;
    if(*move == 0) {
        int extrasize = 0;
        char *extra = readline(fileno, &extrasize);
        line = strAllocCat(line, extra, &lineSize, extrasize);
    }
    *readsize = lineSize;
    return line;
} // 一次读一行

gid_t parse_group(char *line, const char *user, const int usersize) {
    char *group_name = line;
    char *gpwd = strchr(line, ':');
    *gpwd = 0;gpwd++;
    char *sgid = strchr(gpwd, ':');
    *sgid = 0;sgid++;
    char *userlist = strchr(sgid, ':');
    *userlist = 0;userlist++;
    // 处理groups里的数据，按照冒号分隔
    
    while(strncmp(userlist, user, usersize) != 0) {
        userlist = strchr(userlist, ',');
        if(userlist == NULL) {
            return -1;
        }
        userlist++;
    } // 读userlist，有没有user
    if(userlist[usersize] != ',' && userlist[usersize] != '\0') return -1;
    // rootttt 与 root 比较的情况
    return atol(sgid);
}

// 系统调用读行
int __initgroups(const char *user, gid_t group) {
    int file_group = open("/etc/groups", O_CREAT | O_RDWR);
    CHECK(file_group != -1)
    int size = 0;
    char *line = NULL;
    gid_t groups[NGROUPS_MAX+1];
    int groupscount = 0;
    groups[groupscount++] = group;
    // 参数group存入

    int usersize = strlen(user);
    while((line = readline(file_group, &size)) != NULL) {
        write(STDOUT_FILENO, "read line: ", strlen("read line: "));
        write(STDOUT_FILENO, line, size);
        write(STDOUT_FILENO, "\n", 1);
        gid_t isid = parse_group(line, user, usersize);
        if(isid != (gid_t)-1 && isid != group) {// 存在且不是参数的gid，则存入
            groups[groupscount++] = isid;
            printf("gid = %u contails user %s\n", isid, user);
            if(groupscount > NGROUPS_MAX) {
                return -1; // 总数超过limits
            }
        }

    }
    return setgroups(groupscount, groups);
}

// sscanf读行
int ___initgroups(const char *user, gid_t group) {
    FILE *file_groups = fopen("/etc/groups", "rw");
    char line[BUFFSIZE+1];
    int usersize = strlen(user);
    gid_t groups[NGROUPS_MAX+1];
    int groupscount = 0;
    groups[groupscount++] = group;
    while(fscanf(file_groups, "%s\n", line) != EOF) {
        printf("%s\n", line);
        gid_t iuid = parse_group(line, user, usersize);
        if(iuid != (gid_t)-1 && iuid != group) {
            groups[groupscount++] = iuid;
            printf("gid = %u contails user %s\n", iuid, user);
            if(groupscount > NGROUPS_MAX) {
                return -1; // 总数超过limits
            }
        }
    }
    return setgroups(groupscount, groups);
}

// 系统调用 getgrent setgrent endgrent
int ____initgroups(const char *user, gid_t group) {
    struct group *grp =  NULL;
    int usersize = strlen(user);
    gid_t groups[NGROUPS_MAX+1];
    int groupscount = 0;
    groups[groupscount++] = group;
    while((grp = getgrent()) != NULL) {
        while(*grp->gr_mem) {
            if(strcmp(user, *grp->gr_mem) == 0 && grp->gr_gid != group) {
                groups[groupscount++] = grp->gr_gid;
                printf("gid = %u contails user %s\n", grp->gr_gid, user);
                if(groupscount > NGROUPS_MAX) {
                    return -1; // 总数超过limits
                }
                break;
            }
            grp->gr_mem++;
        }
    }
    endgrent();
    return setgroups(groupscount, groups);
}

int main() {
    CHECK(____initgroups(getenv("USER"), getgid()) != -1);
    gid_t groups[NGROUPS_MAX+1];
    int size = getgroups(NGROUPS_MAX, groups);
    for(int i = 0; i < size; i++) {
        struct group *g = getgrgid(groups[i]);
        printf("getgroups(%u): %s:%s:%u", groups[i], g->gr_name, g->gr_passwd, g->gr_gid);
        // 读取的是 groups，这里与前面不一样正常，gid一样就好
        if(*g->gr_mem) {
            printf(":%s", *g->gr_mem);
            g->gr_mem++;
        }
        while(*g->gr_mem) {
            printf(",%s", *g->gr_mem);
            g->gr_mem++;
        }
        printf("\n");
    }
}
```

## 9.4
假设某进程的所有用户标识均为X，执行了用户D为Y的set-user-ID程序，且Y为非0值,对进程凭证的设置如下:

```c
#define _GNU_SOURCE
#include <unistd.h>

#include <stdio.h>

int main() {
    uid_t r,e,s;
    getresuid(&r, &e, &s);
    printf("r = %u, e = %u, s = %u\n", r, e, s);
    seteuid(r);
    getresuid(&r, &e, &s);
    printf("r = %u, e = %u, s = %u\n", r, e, s);
    seteuid(s);
    getresuid(&r, &e, &s);
    printf("r = %u, e = %u, s = %u\n", r, e, s);

    setuid(r);
    getresuid(&r, &e, &s);
    printf("r = %u, e = %u, s = %u\n", r, e, s);
    return setuid(0); // 希望最后一个失败，返回255(-1)
}
```

### 环境准备
```shell
gcc practice9_4.c -o practice9_4
sudo chown root practice9_4
chmod u+s practice9_4
su tmp
./practice9_4
```

### 9.5
root最后一句成功，非root最后一句不成功