---
title: cha14.系统编程概念
date: 2023-4-28 18:05:00
tags: 
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 14.1

编写一程序，试对在单目录下创建和删除大量1字节文件所需的时间进行度量。该程序应以xNNNNNN命名格式来创建文件，其中 NNNNNN为随机的6位数字。文件的创建顺序与生成文件名相同，为随机方式，删除文件则按数字升序操作（删除与创建的顺序不同)。文件的数量(FN)和文件所在目录应由命令行指定。针对不同的NF值（比如，在1000和20000之间取值）和不同的文件系统（比如 ext2、ext3和 XFS)来测量时间。随着NF的递增,每个文件系统下耗时的变化模式如何?不同文件系统之间，情况又是如何呢?如果按数字升序来创建文件（x000001、x000001、x0000002等)，然后以相同顺序加以删除，结果会改变吗?如果会，原因何在?此外，上述结果会随文件系统类型的不同而改变吗?

### c
```c
#include <stdio.h>
#include <limits.h>
#include <string.h>
#include <stdbool.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <time.h>
#include <stdlib.h>
#include <sys/times.h>
#include <sys/time.h>

#define CHECK(flag, msg, ...) do { \
        if(!(flag)) {\
            fprintf(stderr, "FATAL: "); \
            fprintf(stderr, msg, ##__VA_ARGS__); \
            fprintf(stderr, " ERROR: %s\n", strerror(errno)); \
            exit(2); \
        } \
    } while(0)


bool str2int(const char *num, int *ret) {
    errno = 0;
    char *end;
    *ret = strtol(num, &end, 10);
    return !(end == num || *end != '\0' || errno != 0);
}

int *seqArr(int len) {
    int *nums = malloc(len * sizeof(int));
    for(int i = 0; i < len; i++) {
        nums[i] = i;
    }
    return nums;
}

int* randArr(int len) {
    int *visited = malloc(len * sizeof(int));
    int *nums = malloc(len * sizeof(int));
    memset(visited, 0, len * sizeof(int));
    for(int i = 0; i < len; i++) {
        int uniq;
        while(visited[(uniq = rand() % len)]);
        visited[uniq] = 1;
        nums[i] = uniq;
    }
    free(visited);
    return nums;
}

char *path = NULL;
void creatFiles(int *arr, int fn) {
    char *filename = (char *) malloc((9 + strlen(path))*sizeof(char));
    for(int i = 0; i < fn; i++) {
        sprintf(filename, "%s/x%06d", path, arr[i]);
        int fd = open(filename, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
        CHECK(fd != -1, "fail to open file %s, fd = %d", filename, fd);
        write(fd, " ", 1);
//        fsync(fd); // Synchronized I/O file integrity completion
        close(fd);
    }
    free(filename);

}

struct RmFilesArgs {
    int *arr;
    int fn;
};

void rmFiles(void *args) {
    int *arr = ((struct RmFilesArgs*)args)->arr;
    int fn = ((struct RmFilesArgs*)args)->fn;
    char filename[8] = {0};
    for(int i = 0; i < fn; i++) {
        sprintf(filename, "x%06d", arr[i]);
        unlink(filename);
    }
}

long clockTic = 0;

// clock_t long int
// time_t long int
void timeIt(void (*test)(void *args), void *args, double *system, double *user, double *process, double *real) {
    clock_t processStart, processEnd;
    struct timeval realStart, realEnd;
    struct tms start, end;
    processStart = clock();
    CHECK(processStart != (clock_t)-1, "fail to get clock, ERROR: %s", strerror(errno));
    CHECK(gettimeofday(&realStart, NULL) != -1, "fail to get timeofday, ERROR: %s", strerror(errno));
    CHECK(times(&start) != (clock_t)-1, "fail to get times, ERROR: %s", strerror(errno));
    test(args);
    processEnd = clock();
    CHECK(processEnd != (clock_t)-1, "fail to get clock, ERROR: %s", strerror(errno));
    CHECK(gettimeofday(&realEnd, NULL) != -1, "fail to get timeofday, ERROR: %s", strerror(errno));
    CHECK(times(&end) != (clock_t)-1, "fail to get times, ERROR: %s", strerror(errno));
    // real time 没必要做错误检查（传入NULL不会出错）
    *process = (double)(processEnd - processStart) / CLOCKS_PER_SEC;
    *real = (double)(realEnd.tv_usec - realStart.tv_usec) / 1000.0;
    *user = (double)((end.tms_utime - start.tms_utime)) / (double)clockTic;
    *system = (double)((end.tms_stime - start.tms_stime)) / (double)clockTic;
#ifdef DEBUG
    char *format = "system = %lfs, user = %lfs, process = %lfs, real = %lfms\n";
    printf(format, *system, *user, *process, *real);
#endif
}

int NOP(const char * command) {
    return 0;
}

int main(int argc, char **argv) {
    int fn = 0;
    char *format = "system = %.4lfms, user = %.4lfms, process = %.4lfms, real = %.4lfms\n";

    int (*bash)(const char *) = system;
#ifndef COMMAND
    bash = NOP;
#endif
    double system, user, process, real;
    for(int i = 1; i < argc; i++) {
        if(strcmp(argv[i], "-fn") == 0) {
            CHECK(i + 1 < argc, "no enough args\n");
            const char *num = argv[++i];
            CHECK(str2int(num, &fn), "%s is not a integer!\n", num);
        } else if(strcmp(argv[i], "-path") == 0) {
            CHECK(i + 1 < argc, "no enough args\n");
            path = argv[++i];
        }
    }
    clockTic = sysconf(_SC_CLK_TCK);
    CHECK(clockTic != -1, "fail to get sysconf: _SC_CLK_TCK, ERROR:%s", strerror(errno));

    int *randIntArr = randArr(fn);
    int *seqIntArr = seqArr(fn);

    creatFiles(randIntArr, fn);bash("ls -lh");
    timeIt(rmFiles, &(struct RmFilesArgs){
        .arr=seqIntArr,
        .fn=fn
    }, &system, &user, &process, &real);bash("ls -lh");
    printf(format, system * 1000, user * 1000, process * 1000, real);

    creatFiles(seqIntArr, fn);bash("ls -lh");
    timeIt(rmFiles, &(struct RmFilesArgs){
            .arr=seqIntArr,
            .fn=fn
    }, &system, &user, &process, &real);bash("ls -lh");
    printf(format, system * 1000, user * 1000, process * 1000, real);

    free(seqIntArr);
    free(randIntArr);
    return 0;
}
```
> 没有刻意复杂化，被测函数执行相同的函数保证测试的相对准确性

### 结果
```sh
gcc -O3 practice14.1.c -o practice14.1 
./practice14.1 -fn 1000 -path .
system = 20.0000ms, user = 0.0000ms, process = 18.7450ms, real = 18.7320ms
system = 20.0000ms, user = 0.0000ms, process = 37.0100ms, real = 38.6430ms
```
> O3优化掉CHECK多余的`while(0)`循环，计时更精确


### 解释
磁盘分区的结构为：引导块 超级块 i节点表 数据块

假设i节点表使用数组管理，删除文件时需要删除`i-node`。如果按照与创建顺序相同的顺序删除文件，那么数组在这个过程中需要移动 $ \sum_{i=0}^{n-1}i $ 次。

如果随机删除，则移动次数一定小于$ \sum_{i=0}^{n-1}i $ 次。