---
title: cha15.文件属性
date: 2023-5-16 18:05:00
tags: 
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 15.1
> 15.4节中描述了针对各种文件系统操作所需的权限。请使用shell命令或编写程序来回答或验证以下说法。
> a）将文件属主的所有权限“剥夺”后，即使“本组”和“其他”用户仍有访问权,属主也无法访问文件。
> b）在一个可读但无可执行权限的目录下，可列出其中的文件名，但无论文件本身的权限如何，也不能访问其内容。
> c）要创建一个新文件，打开一个文件进行读操作，打开及删除一个文件,父目录和文件本身分别需要具备何种权限?对文件执行重命名操作时，源及目标目录分别需要具备何种权限?若重命名操作的目标文件已存在，该文件需要具备何种权限?为目录设置sticky位(chmod +t)，将如何影响重命名和删除操作?

### a

由检查权限的方式可知，先检查`有效用户id`与`属主id`是否相同，不相同则检验`有效组id`与`属组gid`是否相同，仍不相同则按照其他用户的权限访问。但由于root用户用于所有能力，所以该命题在没有前提条件`属主不为root时`该命题为假，若有该前提条件，则可知`a)`为真。

```sh
touch tmp
chmod 066 tmp
echo aaa > tmp # Permission Denied
```

### b

文件夹是一个特殊文件，由`readdir`, `opendir`系统调用可知，其中的内容就是文件相关的信息。有读权限，则可知目录下存在哪些文件；有写权限，则可以对文件元数据修改；有搜索权限则可对其中文件进行访问。故`b`在不考虑`root`用户的情况下，也是正确的

```sh
mkdir dir
touch dir/tmp
echo aaa > dir/tmp
chmod +r,-w,-x dir
cat dir/tmp # Permission Denied 没有搜索权
mv dir/tmp dir/temp # Permission Denied 没有写入权
ls dir # Success 有读取权
```

### c


至少需要以下权限
|操作|父目录权限|文件权限|
|-|-|-|
|打开+读|搜索(+x)|读(+r)|
|打开+删除|搜索(+x) 写(+w)|无需权限|

|操作|源目录|目标目录|目标文件(若已存在)|
|-|-|-|-|
|重命名|写(+w) 搜索(+x)|写(+w) 搜索(+x)|无需权限|
|重命名(源 sticky)|写(+w) 搜索(+x)|写(+w) 搜索(+x)|无需权限|
|重命名(目标 sticky)||||
|重命名(源+目标 sticky)||||

> 在拥有sticky标志的目录下删除其他用户的文件，依然能删，只是会在删除时报错`rm: remove write-protected regular file 'tmp'? `，输入`y`即可

## 15.2

你认为系统调用stat()会改变文件3个时间戳中的任意之一吗?请解释原因。

> stat只获取的是文件的信息，而不是去访问文件，对于软连接，其内容就是另一个文件的“地址”，对其解引用的过程就是对文件的访问（但经过实验，并非这样）

## 15.3

在运行Linux 2.6的系统上修改程序清单15-1(t_stat.c)，令其可以纳秒级精度来显示文件时间戳。

```c
//
// Created by root on 5/17/23.
//
#include <stdio.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>

void showlstat(const char *file) {
    struct stat stat1;
    if(lstat(file, &stat1) == -1) {
        exit(1);
    }
    char accesstime[1024] = {0};
    strftime(accesstime, 1024, "%Y-%b-%a %H:%M:%S", localtime(&stat1.st_atime));

    char modifitime[1024] = {0};
    strftime(modifitime, 1024, "%Y-%b-%a %H:%M:%S", localtime(&stat1.st_mtime));

    char statustime[1024] = {0};
    strftime(statustime, 1024, "%Y-%b-%a %H:%M:%S", localtime(&stat1.st_ctime));

    printf("device-id\t : %lu\n", stat1.st_dev);
    printf("inode    \t : %lu\n", stat1.st_ino);
    printf("file-type\t : %o\n", stat1.st_mode);
    printf("hard-link\t : %lu\n", stat1.st_nlink);
    printf("owner-uid\t : %u\n", stat1.st_uid);
    printf("owner-gid\t : %u\n", stat1.st_gid);
    printf("st_rdev  \t : %lu\n", stat1.st_rdev);
    printf("file-size\t : %ld\n", stat1.st_size);
    printf("block-size\t : %ld\n", stat1.st_blksize);
    printf("block-number\t : %ld\n", stat1.st_blocks);
    printf("last-access\t : %s.%ld\n", accesstime, stat1.st_atim.tv_nsec);
    printf("last-modify\t : %s.%ld\n", modifitime, stat1.st_mtim.tv_nsec);
    printf("last-stat\t : %s.%ld\n", statustime, stat1.st_ctim.tv_nsec);
}

void showstat(const char *file) {
    struct stat stat1;
    if(stat(file, &stat1) == -1) {
        exit(1);
    }
    char accesstime[1024] = {0};
    strftime(accesstime, 1024, "%Y-%b-%a %H:%M:%S", localtime(&stat1.st_atim));

    char modifitime[1024] = {0};
    strftime(modifitime, 1024, "%Y-%b-%a %H:%M:%S", localtime(&stat1.st_mtim));

    char statustime[1024] = {0};
    strftime(statustime, 1024, "%Y-%b-%a %H:%M:%S", localtime(&stat1.st_ctim));

    printf("device-id\t : %lu\n", stat1.st_dev);
    printf("inode    \t : %lu\n", stat1.st_ino);
    printf("file-type\t : %o\n", stat1.st_mode);
    printf("hard-link\t : %lu\n", stat1.st_nlink);
    printf("owner-uid\t : %u\n", stat1.st_uid);
    printf("owner-gid\t : %u\n", stat1.st_gid);
    printf("st_rdev  \t : %lu\n", stat1.st_rdev);
    printf("file-size\t : %ld\n", stat1.st_size);
    printf("block-size\t : %ld\n", stat1.st_blksize);
    printf("block-number\t : %ld\n", stat1.st_blocks);
    printf("last-access\t : %s\n", accesstime);
    printf("last-modify\t : %s\n", modifitime);
    printf("last-stat\t : %s\n", statustime);
}

int main(int argc, char **argv) {
    for(int i = 1; i < argc; i++) {
        showstat(argv[i]);
        showlstat(argv[i]);
    }
    return 0;
}
```

## 15.4
```c
//
// Created by root on 5/17/23.
//
#include <unistd.h>
#include <sys/stat.h>
#include <stdio.h>
#include <string.h>

int check_mode(int mask1, int mask2, int mask3, uid_t euid, gid_t egid, struct stat *stat1) {
    int granted = 0;
    if(stat1->st_uid == euid) {
        if(stat1->st_mode&mask1) {
            granted++;
        }
    } else if (stat1->st_gid == egid) {
        if(stat1->st_mode&mask2) {
            granted++;
        }
    } else {
        if(stat1->st_mode&mask3) {
            granted++;
        }
    }
    return granted > 0;
}

int eaccess(const char *pathname, int mode) {
//    if(mode&F_OK) {
//        if(access(pathname, F_OK) == -1) {
//            return -1;
//        }
//    }
// F_OK为0
    struct stat stat1;
    if(stat(pathname, &stat1) == -1) {
        return -1;
    }
    uid_t euid = geteuid();
    gid_t egid = getegid();
    if(mode&R_OK) {
        if(!check_mode(0400, 040, 04, euid, egid, &stat1)) {
            return -1;
        }
    }

    if(mode&W_OK) {
        if(!check_mode(0200, 020, 02, euid, egid, &stat1)) {
            return -1;
        }
    }
    if(mode&X_OK) {
        if(!check_mode(0100, 010, 01, euid, egid, &stat1)) {
            return -1;
        }
    }
    return 0;
}

int main(int argc, char **argv) {
    if(argc !=  3) return -1;
    int mode = *argv[2] - '0';
    char *ok = "ok";
    char smode[1024] = {0};
    if(eaccess(argv[1], mode) == -1) {
        ok = "fail";
    }
    if(mode&R_OK) {
        strcat(smode, "r");
    }
    if(mode&W_OK) {
        strcat(smode, "w");
    }
    if(mode&X_OK) {
        strcat(smode, "x");
    }

    printf("access for %s : %s\n", smode ,ok);
    return 0;
}
```
## 15.5

linux内核提供了`current_umask()`函数，在头文件`#include <linux/fs.h>`中

## 15.6
实现chmod的`X`功能
### chmod
chmod的大写`X`表示:
> execute/search only if the file is a directory or already has execute permission for some user (X)

也就是若某些用户已经有了执行权限时，为其赋予执行/搜索权限

### 代码
```c
#include <stdio.h>
#include <sys/stat.h>
#include <string.h>
#include <stdbool.h>
#include <errno.h>
#include <unistd.h>

mode_t MODE = 0;
mode_t UMASK = 0;
int operation = 0; // bits from high to low represents, -/+/= ugo
bool flag_X = false;

void step41(char *arg) {
    if(arg == NULL || *arg == 0) return;
    if(*arg == 'r') {
        if(operation&01) {
            MODE |= 04;
        }
        if(operation&02) {
            MODE |= 040;
        }
        if(operation&04) {
            MODE |= 0400;
        }
        step41(arg+1);
    } else if(*arg == 'w') {
        if(operation&01) {
            MODE |= 02;
        }
        if(operation&02) {
            MODE |= 020;
        }
        if(operation&04) {
            MODE |= 0200;
        }
        step41(arg+1);
    } else if(*arg == 'x') {
        if(operation&01) {
            MODE |= 01;
        }
        if(operation&02) {
            MODE |= 010;
        }
        if(operation&04) {
            MODE |= 0100;
        }
        step41(arg+1);
    } else if(*arg == 'X') {
        flag_X = true;
        step41(arg+1);
    } else if(*arg == 's') {
        // u+s, g+s
        if(operation&02) {
            MODE |= 02000;
        }
        if(operation&04) {
            MODE |= 04000;
        }
        step41(arg+1);
    } else if(*arg == 't') {
        MODE |= 01000;
        step41(arg+1);
    } else {
        // undefined behavior
    }
}

void step42(char *arg) {
    if(arg == NULL || *arg == 0) return;
    int flag = *arg - '0';
    if(operation&01) {
        MODE |= flag;
    }
    if(operation&02) {
        MODE |= flag<<3;
    }
    if(operation&04) {
        MODE |= flag<<6;
    }
    step42(arg+1);
}


// parse: [rwxXst]+|[0-7]+
void step3(char * arg) {
    if(arg == NULL || *arg == 0) return;
    if(*arg == 'r' || *arg == 'w' || *arg == 'x' || *arg == 'X' || *arg == 's' || *arg == 't') {
        step41(arg);
    } else if(*arg >= '0' && *arg <= '7') {
        step42(arg);
    } else {
        // undefined behavior
    }
}

// parse: [-+=]([rwxXst]+|[0-7]+)
void step2(char * arg) {
    if(arg == NULL || *arg == 0) return;
    if(*arg == '-') {
        operation |= 010;
        step3(arg+1);
    } else if(*arg == '+') {
        operation |= 020;
        step3(arg+1);
    } else if(*arg == '=') {
        operation |= 030;
        step3(arg+1);
    } else {
        // undefined behavior
    }
}

// 原本的表达式是: [ugoa]*([-+=]([rwxXst]*|[ugo]))+|[-+=][0-7]+，简化为
// parse: [ugoa]*[-+=]([rwxXst]+|[0-7]+)
void step1(char * arg) {
    if(arg == NULL || *arg == 0) return;
    if(*arg == 'u') {
        operation = 4;
        step1(arg+1);
    } else if(*arg == 'g') {
        operation = 2;
        step1(arg+1);
    } else if(*arg == 'o') {
        operation = 1;
        step1(arg+1);
    } else if(*arg == 'a') {
        operation = 7;
        step1(arg+1);
    } else {
        if(operation == 0) {
            operation = 7;

        }
        step2(arg);
    }

}

mode_t apply_mod(mode_t mode) {
    fprintf(stderr, "MODE = %o\n", MODE);
    mode_t mask = ((operation&07) == 0) ? UMASK : 0;
    fprintf(stderr, "op = %o\n", operation);
    MODE = MODE & (~mask);
    //00 0
    //01 0
    //10 1
    //11 0
    //
    //( a & ~b ) 逻辑减法
    if((operation&00070) == 010) {
        // -
        mode = mode & (~MODE);
        if(flag_X && (mode&0111)) {
            mode = (~(0111) & mode); // 三个xxx全都变成0，其余不变
        }
    } else if ((operation&00070) == 020) {
        // +
        mode = mode | MODE;

        if(flag_X && (mode&0111)) {
            if(operation&01) {
                mode |= 01;
            }
            if(operation&02) {
                mode |= 010;
            }
            if(operation&04) {
                mode |= 0100;
            }
        }
    } else if ((operation&00070) == 030) {
        // =
        fprintf(stderr, "flagX = %d, mode = %o\n", flag_X, mode);
        if(flag_X && (mode&0111)) {
            if(operation&01) {
                MODE |= 01;
            }
            if(operation&02) {
                MODE |= 010;
            }
            if(operation&04) {
                MODE |= 0100; //这里的大MODE，防止一会mode被MODE覆盖
            }
        } // incase: chmod =X
        if(operation&01) {
            mode = (07&MODE) | ((~07)&mode);
        }
        if(operation&02) {
            mode = (070&MODE) | ((~070)&mode);
        }
        if(operation&04) {
            mode = (0700&MODE) | ((~0700)&mode);
        }
        mode = (07000&MODE) | ((~07000)&mode);
        //000 0
        //010 0
        //100 1
        //110 0
        //001 0
        //011 1
        //101 1
        //111 1
        //
        //( b & c )|( ~b & a ) // 根据掩码b置位

        if(flag_X && (mode&0111)) {
            if(operation&01) {
                mode |= 01;
            }
            if(operation&02) {
                mode |= 010;
            }
            if(operation&04) {
                mode |= 0100;
            }
        }
    } else {

    }
    operation = 0;
    MODE = 0;
    flag_X = false;
    return mode;
}

// parse_mod: split by ','
mode_t parse_mod(char * arg, mode_t mode) {
    fprintf(stderr, "old Mode = %o\n", mode);
    char *end = NULL;
    while((end = strchr(arg, ',')) != NULL) {
        *end = 0;
        step1(arg);
        mode = apply_mod(mode);
        fprintf(stderr, "new Mode = %o\n", mode);
        arg = end+1;
    }
    step1(arg);
    mode = apply_mod(mode);
    fprintf(stderr, "new Mode = %o\n", mode);
    return mode;
}

mode_t current_umask() {
    mode_t old = umask(0);
    umask(old);
    return old;
}

int main(int argc, char **argv) {
#ifndef DEBUG
    freopen("/dev/null", "w", stderr);
#endif
    int i = 1;
    UMASK = current_umask();
    char *mode = NULL;
    for(; i < argc-1; i++) {
        if(argv[i][0] == '-' && argv[i][1] == '-') {
            // argument or --reference
            fprintf(stderr, "unsupported argument: %s\n", argv[i]);
        } else if(argv[i][0] >= '0' && argv[i][0] <= '9') {
            // octal-mode
            while (*argv[i] != NULL) {
                MODE *= 8;
                MODE += *argv[i] - '0';
                argv[i]++;
            }
            i++;
            break;
        } else {
            // mod
            mode = argv[i];
//            parse_mod(argv[i]);
            i++;
            break;
        }
    }
    fprintf(stderr, "argv[i] = %s\n", argv[i]);
    fprintf(stderr, "mode = %s\n", mode);
    // chmod
    if(mode == NULL) {
        for(; i < argc; i++) {
            chmod(argv[i], MODE);
        }
    } else {
        for(; i < argc; i++) {
            struct stat filestat;
            if (stat(argv[i], &filestat) == -1) {
                fprintf(stderr, "stat, error: %s\n", strerror(errno));
            }
            mode_t newMode = parse_mod(mode, filestat.st_mode);
            if (chmod(argv[i], newMode) == -1) {
                fprintf(stderr, "chmod, error: %s\n", strerror(errno));
            }
        }
    }
    return 0;
}

// chmod u=s,g=s tmp.c的行为与chmod不同(仅为=s时不同，其他含有多个等号时相同)
```

## 15.7

实现chattr简化版

```c
//
// Created by root on 5/18/23.
//

// chattr [-+=aAcCdDeijPsStTuFx] [-v version] files...
//A：即Atime，告诉系统不要修改对这个文件的最后访问时间。
//S：即Sync，一旦应用程序对这个文件执行了写操作，使系统立刻把修改的结果写到磁盘。
//a：即Append Only，系统只允许在这个文件之后追加数据，不允许任何进程覆盖或截断这个文件。如果目录具有这个属性，系统将只允许在这个目录下建立和修改文件，而不允许删除任何文件。
//b：不更新文件或目录的最后存取时间。
//c：将文件或目录压缩后存放。
//d：当dump程序执行时，该文件或目录不会被dump备份。
//D:检查压缩文件中的错误。
//i：即Immutable，系统不允许对这个文件进行任何的修改。如果目录具有这个属性，那么任何的进程只能修改目录之下的文件，不允许建立和删除文件。
//s：彻底删除文件，不可恢复，因为是从磁盘上删除，然后用0填充文件所在区域。
//u：当一个应用程序请求删除这个文件，系统会保留其数据块以便以后能够恢复删除这个文件，用来防止意外删除文件或目录。
//t:文件系统支持尾部合并（tail-merging）。
//X：可以直接访问压缩文件的内容。
#include <unistd.h>
#include <linux/fs.h>
#include <fcntl.h>
#include <sys/ioctl.h>

#define SUB 0
#define ADD 1
#define SET 2
int main(int argc, char **argv) {
    int OP = -1;
    if(argv[1][0] == '-') {
        OP = 0;
    } else if (argv[1][0] == '+') {
        OP = 1;
    } else if(argv[1][0] == '=') {
        OP = 2;
    }
    int new_attr = 0;
    while (*argv[1]) {
        switch (*argv[1]) {
            case 'a':
                new_attr |= FS_APPEND_FL;
                break;
            case 'c':
                new_attr |= FS_COMPR_FL;
                break;
            case 'D':
                new_attr |= FS_DIRSYNC_FL;
                break;
            case 'i':
                new_attr |= FS_IMMUTABLE_FL;
                break;
            case 'j':
                new_attr |= FS_JOURNAL_DATA_FL;
                break;
            case 'A':
                new_attr |= FS_NOATIME_FL;
                break;
            case 'd':
                new_attr |= FS_NODUMP_FL;
                break;
            case 't':
                new_attr |= FS_NOTAIL_FL;
                break;
            case 's':
                new_attr |= FS_SECRM_FL;
                break;
            case 'S':
                new_attr |= FS_SYNC_FL;
                break;
            case 'T':
                new_attr |= FS_TOPDIR_FL;
                break;
            case 'u':
                new_attr |= FS_UNRM_FL;
                break;
            case 'C':
                break;
            case 'e':
                break;
            case 'E':
                break;
            case 'F':
                break;
            case 'I':
                break;
        }
        argv[1]++;
    }
    for(int i = 2; i < argc; i++) {
        int fd = open(argv[i], O_RDONLY);
        if (fd == -1) continue;
        int attr;
        if (ioctl(fd, FS_IOC_GETFLAGS, &attr) == -1) {
            continue;
        }
        if(OP==SUB) {
            attr = attr & (~new_attr);
        }else if(OP == ADD) {
            attr = attr | new_attr;
        } else if(OP == SET) {
            attr = new_attr;
        }
        if (ioctl(fd, FS_IOC_SETFLAGS, &attr) == -1) {
            continue;
        }
        close(fd);
    }
    return 0;
}
```