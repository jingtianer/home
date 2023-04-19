---
title: cha5.深入探究文件IO
date: 2023-3-23 18:05:00
tags: 
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 练习1

> 请使用标准文件IO系统调用(open()和lseek())和off_t数据类型修改程序清单5-3中的程序。将宏_FILE_OFFSET_BITS的值设置为64进行编译，并测试该程序是否能够成功创建一个大文件。

将xxx64改为xxx，off64_t改为off_t，可以创建大文件（使用 -m32编译）

```c++
// #define _LARGEFILE64_SOURCE
#define _FILE_OFFSET_BITS 64
#include<string.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<unistd.h>
#include<errno.h>
#include<stdlib.h>

#define debug
#ifdef debug
#include<stdio.h>
#endif
void writeErr(const char* str);

#ifdef _LARGEFILE64_SOURCE
int main(int argc, char **argv) {
    #ifdef debug
    printf("sizeof(long) = %d, sizeof(long long) = %d, sizeof(off_t) = %d, sizeof(off64_t) = %d\n", sizeof(long), sizeof(long long), sizeof(off_t), sizeof(off64_t));
    #endif
    if(argc !=3 || strcmp(argv[1], "--help") == 0) {
        writeErr(argv[0]);
        writeErr(" pathname offset\n");
        exit(3);
    }
    int fd = open64(argv[1], O_RDWR | O_CREAT, S_IRUSR|S_IWUSR);
    if(fd == -1) {
        writeErr("open64 fail");
        exit(2);
    }
    off64_t off = atoll(argv[2]);
    if(lseek64(fd, off, SEEK_SET) == -1) {
        writeErr("lseek64");
        exit(3);
    }
    if(write(fd, "test", 4) == -1) {
        writeErr("write");
        exit(4);
    }
    return 0;
}
#endif

#ifdef _FILE_OFFSET_BITS
int main(int argc, char **argv) {
    #ifdef debug
    printf("sizeof(long) = %d, sizeof(long long) = %d, sizeof(off_t) = %d\n", sizeof(long), sizeof(long long), sizeof(off_t));
    #endif
    if(argc !=3 || strcmp(argv[1], "--help") == 0) {
        writeErr(argv[0]);
        writeErr(" pathname offset\n");
        exit(3);
    }
    int fd = open(argv[1], O_RDWR | O_CREAT, S_IRUSR|S_IWUSR);
    if(fd == -1) {
        writeErr("open64 fail");
        exit(2);
    }
    off_t off = atoll(argv[2]);
    if(lseek(fd, off, SEEK_SET) == -1) {
        writeErr("lseek64");
        exit(3);
    }
    if(write(fd, "test", 4) == -1) {
        writeErr("write");
        exit(4);
    }
    return 0;
}

#endif
void writeErr(const char* str) {
    errno = 0;
    int writeSize = write(STDERR_FILENO, str, strlen(str));
    if(writeSize == -1) {
        exit(1);
    }
}
```

## 练习2

> 5-2.编写一个程序，使用O_APPEND标志并以写方式打开一个已存在的文件，且将文件偏移量置于文件起始处，再写入数据。数据会显示在文件中的哪个位置?为什么?

文件末尾，在write时，lseek失效了

## 练习3

> 本习题的设计目的在于展示为何以O_APPEND标志打开文件来保障操作的原子性是必要的。请编写一程序，可接收多达3个命令行参数:

> $ atomic_append filename num-bytes [x]

> 该程序应打开所指定的文件(如有必要，则创建之)，然后以每次调用write()写入一个字节的方式，向文件尾部追加num-bytes个字节。缺省情况下，程序使用O_APPEND标志打开文件，但若存在第三个命令行参数(x)，那么打开文件时将不再使用O_APPEND标志，代之以在每次调用write(前调用lseek(fd,0,SEEK_END))。同时运行该程序的两个实例，不带x参数，将100万个字节写入同一文件:
```sh
$ atomic_append f1 10000oo & atomic_append f1 1000000
```
> 重复上述操作，将数据写入另一文件，但运行时加入x参数:
```sh
$ atomic_append f2 1000000 x & atomic_append f2 1000000 x
```
> 使用ls-1命令检查文件f1和f2的大小，并解释两文件大小不同的原因,

### 代码
```c
#include<string.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<unistd.h>
#include<errno.h>
#include<stdlib.h>

#define debug
#ifdef debug
#include<stdio.h>
#endif
void writeErr(const char* str);

ssize_t writeMeow(int __fd, const void *__buf, size_t __n, int argc);

int main(int argc, char **argv) {
    if((argc !=4 && argc != 5) || strcmp(argv[1], "--help") == 0) {
        writeErr(argv[0]);
        writeErr(" pathname string num [x]\n");
        exit(3);
    }
    int fd = open(argv[1], O_RDWR | O_CREAT | (argc == 5 ? 0 : O_APPEND), S_IRUSR|S_IWUSR);
    if(fd == -1) {
        writeErr("open64 fail");
        exit(2);
    }
    long long off = atoll(argv[3]);
    int argv2len = strlen(argv[2]);
    for(int i = 0; i < off; i++)
        if(writeMeow(fd, argv[2], argv2len, argc) == -1) {
            writeErr("writeMeow");
            exit(4);
        }
    return 0;
}
void writeErr(const char* str) {
    errno = 0;
    int writeSize = write(STDERR_FILENO, str, strlen(str));
    if(writeSize == -1) {
        exit(1);
    }
}

ssize_t writeMeow(int __fd, const void *__buf, size_t __n, int argc) {
    if(argc == 5) lseek(__fd, 0, SEEK_END);
    write(__fd, __buf, __n);
}
```

### 运行结果
```sh
$ ./practice5.3 f5.3 "Meow " 1048576 & ./practice5.3 f5.3 "Woof " 1048576
$ ./practice5.3 f5.3x "Meow " 1048576 x & ./practice5.3 f5.3x "Woof " 1048576 x
$ ll -h
-rw------- 1 root root  10M Mar 23 20:17 f5.3
-rw------- 1 root root 5.9M Mar 23 20:17 f5.3x
```

### 解释原因
不加x的10M，加x的5.9M

通过计算，如果所有数据正常写入，那么文件大小应该刚好是10M

加X的指针移动和写入不具有原子性，可能存在两个进程同时向同一偏移量处写入数据，相互覆盖，导致文件大小偏小。

不加X的具有原子性，指针移动和写入不会打断，不会在同一位置写入

## 练习4

> 使用fcntl()和 close()(若有必要)来实现 dupO和 dup2()。(对于某些错误，dup2()和fentl()返回的errno值并不相同，此处可不予考虑。)务必牢记dup2()需要处理的一种特殊情况，即 oldfd与 newfd相等。这时，应检查oldfd是否有效，测试fcntl(oldfd，F_GETFL)是否成功就能达到这一目的。若oldfd无效，则dup2()将返回-1，并将errno置为EBADF。


```c
#include<string.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<unistd.h>
#include<errno.h>
#include<stdlib.h>
#include<stdarg.h>

#define debug
#ifdef debug
#include<stdio.h>
#endif

void exitErr(int exitCode, const char *format, ...);
int __dup(int oldfd);
int __dup2(int oldfd, int newfd);

int main(int argc, char **argv) {
    int dupStdout = __dup(STDOUT_FILENO);
    write(STDOUT_FILENO, "Jingtianer\n", strlen("Jingtianer\n"));
    write(dupStdout, "Jingtianer\n", strlen("Jingtianer\n"));
    dupStdout = __dup2(STDOUT_FILENO, dupStdout);
    write(STDOUT_FILENO, "Jingtianer\n", strlen("Jingtianer\n"));
    write(dupStdout, "Jingtianer\n", strlen("Jingtianer\n"));
    char tmpfile[] = "JingtianTmpXXXXXX";
    int tmpfd = mkstemp(tmpfile);
    dupStdout = __dup2(STDOUT_FILENO, tmpfd);
    write(STDOUT_FILENO, "Jingtianer\n", strlen("Jingtianer\n"));
    write(tmpfd, "Jingtianer\n", strlen("Jingtianer\n"));
    unlink(tmpfile);
    close(tmpfd);
    return 0;
}

int __dup(int oldfd) {
    return fcntl(oldfd, F_DUPFD, oldfd);
}

int __dup2(int oldfd, int newfd) {
    if(oldfd != newfd) {
        close(newfd);
    } else if(fcntl(oldfd, F_GETFL) == -1) {
        errno = EBADF;
        return -1;
    }
    return fcntl(oldfd, F_DUPFD, newfd);
}

void exitErr(int exitCode, const char *format, ...) {
    va_list va;
    va_start(va, format);
    fprintf(stderr, format, va);
    va_end(va);
    exit(exitCode);
}
```

## 练习5

> 编写一程序，验证文件描述符及其副本是否共享了文件偏移量和打开文件的状态标志。


```c
#include<string.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<unistd.h>
#include<errno.h>
#include<stdlib.h>
#include<stdarg.h>

#define bool char
#define true '\1'
#define false '\0'

#define debug
#ifdef debug
#include<stdio.h>
#endif

void exitErr(int exitCode, const char *format, ...);
bool check(int fd1, int fd2);
void exitErr(int exitCode, const char *format, ...);

#define bool2str(x) (x == true ? "true" : "false")

int main(int argc, const char **argv) {
    if(argc != 3) {
        exitErr(1, "Usage: %s file1 file2\n", argv[0]);
    }
    int fd1 = open(argv[1], O_CREAT | O_RDWR);
    int fd2 = open(argv[2], O_CREAT | O_RDWR);
    if(fd1 == -1 || fd2 == -1) {
        exitErr(2, "open fail\n");
    } 
    int fd1dup = dup(fd1);
    bool check1 = check(fd1, fd1dup); //true
    bool check2 = check(fd1, fd2); // false
    #ifdef debug
    fprintf(stdout, "check1 == %s, check2 == %s\n", bool2str(check1), bool2str(check2));
    #endif
    return check1 + check2 - 1;
}

bool check(int fd1, int fd2) {
    if(lseek(fd1, 0, SEEK_CUR) != lseek(fd2, 0, SEEK_CUR)) {
        return false;
    } else {
        lseek(fd1, 1, SEEK_CUR);
        if(lseek(fd1, 0, SEEK_CUR) != lseek(fd2, 0, SEEK_CUR)) {
            lseek(fd1, -1, SEEK_CUR);
            return false;
        }
        lseek(fd1, -1, SEEK_CUR);
    }
    
    if(fcntl(fd1, F_GETFL) != fcntl(fd2, F_GETFL)) {
        return false;
    } else {
        const int flag = fcntl(fd1, F_GETFL);
        fcntl(fd1, F_SETFL, 0);
        if(fcntl(fd1, F_GETFL) != fcntl(fd2, F_GETFL)) {
            fcntl(fd1, F_SETFL, flag);
            return false;
        }
        fcntl(fd1, F_SETFL, flag);
    }
    return true;
}

void exitErr(int exitCode, const char *format, ...) {
    #ifdef debug
    va_list va;
    va_start(va, format);
    fprintf(stderr, format, va);
    va_end(va);
    #endif
    exit(exitCode);
}
```

## 练习6
> 说明下列代码中每次执行 write()后，输出文件的内容是什么，为什么。
```c
fd1 = open(file, O_RDNR | O_CREAT | O_TRUNC，S_IRUSR | S_IMUSR);
fd2 = dup(fd1);
fd3 = open(file，O_RDWR);
write(fd1,"Hello,"，6); // Hello
write(fd2,"world", 6); // Helloworld fd2由fd1复制而来，共享文件指针，fd1write后，文件指针后移，fd2也后移
lseek(fd2, 0, SEEK_SET);
write(fd1,"HELLO,"，6); // HELLOworld fd2移动到文件开头，fd1也移动，共享文件指针和状态标志、inode指针
write(fd3,"Gidday"， 6); // Giddayworld，fd3不是dup*而来，不共享指针，其指针还在0，写入0
```

## 练习7
> 使用read()、write()以及 malloc函数包（见7.1.2节）中的必要函数以实现readv()和 writev()功能。

```c
#include<string.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<unistd.h>
#include<errno.h>
#include<stdlib.h>
#include<stdarg.h>
#include<sys/uio.h> //iovec
#define bool char
#define true '\1'
#define false '\0'

#define debug
#ifdef debug
#include<stdio.h>
#endif

ssize_t __writev(int fd, const struct iovec *iov, int iovcount);
ssize_t __readv(int fd, const struct iovec *iov, int iovcount);

int main(int argc, const char **argv) {
    int fdw = open(argv[1], O_CREAT | O_TRUNC | O_RDWR);
    int fdr = open(argv[1], O_CREAT | O_TRUNC | O_RDWR);
    int contentCount = argc - 2;
    struct iovec *vecArr = (struct iovec*)malloc(2 * contentCount * sizeof(struct iovec));
    for(int i = 2; i < argc; i++) {
        vecArr[2*(i-2)].iov_base = argv[i];
        vecArr[2*(i-2)].iov_len = strlen(argv[i]);
        vecArr[2*(i-2)+1].iov_base = "\n";
        vecArr[2*(i-2)+1].iov_len = 1;
    }
    writev(fdw, vecArr, 2 * contentCount);
    free(vecArr);
    vecArr = (struct iovec*)malloc(contentCount * sizeof(struct iovec));
    for(int i = 2; i < argc; i++) {
        int size = strlen(argv[i])+1;
        vecArr[i-2].iov_base = malloc(size * sizeof(char) + 1);
        vecArr[i-2].iov_len = size;
    }
    errno=0;
    int read = readv(fdr, vecArr,  contentCount);
    if(read == -1) {
        const char *err = strerror(errno);
        write(STDOUT_FILENO, err, strlen(err));
        write(STDOUT_FILENO, "\n", 1);
        return read;
    }
    writev(STDOUT_FILENO, vecArr, contentCount);
    close(fdw);
    close(fdr);
    free(vecArr);
    return 0;
}

ssize_t __writev(int fd, const struct iovec *iov, int iovcount) {
    ssize_t writeSize = 0;
    for(int i = 0; i < iovcount; i++) {
        ssize_t writeSize1 = write(fd, iov[i].iov_base, iov[i].iov_len);
        writeSize += writeSize1;
        if(writeSize1 == -1 || writeSize1 < iov[i].iov_len) {
            return writeSize1;
        }
    }
    return iovcount;
}
ssize_t __readv(int fd, const struct iovec *iov, int iovcount) {
    ssize_t readSize = 0;
    for(int i = 0; i < iovcount; i++) {
        ssize_t readSize1 = read(fd, iov[i].iov_base, iov[i].iov_len);
        readSize += readSize1;
        if(readSize1 == -1 || readSize1 < iov[i].iov_len) {
            return readSize;
        } else if(readSize == 0) {
            return i+1;
        }
    }
    return iovcount;
}
```

学习的`read`，`write`，`readv`，`writev`，`preadv`，`pwritev`，其输入输出的内容不必都是字符串，由`iovec`的定义以及他们的函数原型可见，写入读取数据的类型为`void *`或`const void *`，是不限制输入输出的数据类型的。

此外，`pread*`和`pwrite*`具有原子性，可以代替`lseek + write/read`的组合，防止多个进程相互读写同一文件时，出现读写位置出错的情况，如果常出现`lseek + write/read`的组合，使用`pread*`和`pwrite*`可以大量减少系统调用的使用，提高性能