---
title: cha4.文件IO:通用的I/O模型
date: 2023-3-22 18:05:00
tags: 
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 实现tee
> tee命令是从标准输入中读取数据，直至文件结尾，随后将数据写入标准输出和命令行参数所指定的文件。(44.7节讨论FIFO时，会展示使用tee命令的一个例子。)请使用IO系统调用实现tee命令。默认情况下，若已存在与命令行参数指定文件同名的文件，tee命令会将其覆盖。如文件已存在，请实现-a命令行选项`tee-a file`在文件结尾处追加数据。(请参考附录B中对getopt)函数的描述来解析命令行选项。

### 预处理与函数声明

```c
#include<string.h>

#include<sys/stat.h>
#include<fcntl.h>
#include<unistd.h>
#include<stdlib.h>

#include<errno.h> // 使用变量errno

#define bool char
#define false 0
#define true 1
#define strcmp(a,b) strcmp(a,b)==0

// exit code
#define UNSUPPORTED_ARG 1
#define FILE_OPEN_FAIL 2
#define STDOUT_WRITE_FAIL 3
#define STDERR_WRITE_FAIL 4
#define STDIN_READ_FAIL 5
#define PARTIAL_WRITE_OCCURED 6
#define FILE_CLOSE_FAIL 7
#define FILE_WRITE_FAIL 8

// 函数声明
void printHelp();
void printVersion();
void writeErr(const char* str);
void writeStdout(const char* str);
void exitErr(const char * err, int exitcode);
void release();

// 常量
#define MAX_FILE_COUNT 100
#define READ_BUFFER_SIZE 100

// 全局资源
char **files = NULL;
int *fds = NULL;
int fileCount = 0;
```

> 不引用c的库函数，直接使用系统调用对文件进行读写，不引入`stdio.h`

### 工具函数

```c
void release() {
    // 关闭文件
    for(int i = 0; i < fileCount; i++) {
        errno = 0;
        int success = close(fds[i]);
        if(success == -1) {
            exitErr(strcat("can not close file: ", files[i]), FILE_CLOSE_FAIL);
        }
    }
    free(files);
    free(fds);
}


void printHelp() {
    writeStdout("Usage: tee [-ai][--help][--version][files...]\n");
}
void printVersion() {
    writeStdout("Written by Jingtian Meow\n");
}

void exitErr(const char * err, int exitcode) {
    char *errstr = strerror(errno);
    writeErr("Error: ");
    writeErr(errstr);
    writeErr("\n");
    writeErr(err);
    writeErr("\n");
    release();
    exit(exitcode);
}

void writeStdout(const char* str) {
    errno = 0;
    int writeSize = write(STDOUT_FILENO, str, strlen(str));
    if(writeSize == -1) {
        exitErr("fail to write to stdout\n", STDOUT_WRITE_FAIL);
    }
}

void writeErr(const char* str) {
    errno = 0;
    int writeSize = write(STDERR_FILENO, str, strlen(str));
    if(writeSize == -1) {
        release();
        exit(STDERR_WRITE_FAIL);
    }
}
```

- 实现错误打印，正常输出
  - 对于错误，利用系统调用write，写入文件fd`STDERR_FILENO`指代的标准错误流中
  - 使用errno宏和strerror获取出错后的错误字符串，并打印其他提示信息
- 实现资源释放

### 资源分配
```c
// 保存文件名，打开文件的fd，文件总数
files = (char **)malloc(MAX_FILE_COUNT*sizeof(char *));
fds = (int *)malloc(MAX_FILE_COUNT*sizeof(int));
fileCount = 0;
```

### 参数处理
```c
int main(int argc, char **argv) {
    // 参数处理结果
    bool append = false;
    bool ignore_int = false;
    
    // 处理参数
    for(int i = 1; i < argc; i++) {
        if(argv[i][0] == '-') {
            if(strcmp(argv[i], "-a")) {
                append = true;
            } else if(strcmp(argv[i], "-i") || strcmp(argv[i], "--ignore-interrupts")) {
                ignore_int = true;
            } else if(strcmp(argv[i], "-ai") || strcmp(argv[i], "-ia") ) {
                append = true;
                ignore_int = true;
            } else if(strcmp(argv[i], "--help")) {
                printHelp();
            } else if(strcmp(argv[i], "--version")) {
                printVersion();
            } else {
                writeErr("Unsupported arg: ");
                writeErr(argv[i]);
                writeErr("\n");
                free(files);
                free(fds);
                exit(UNSUPPORTED_ARG);
            }
        } else {
            if(fileCount < MAX_FILE_COUNT-1) files[fileCount++] = argv[i];
        }
    }
    // other part of code
}
```
支持参数`-a, --help, --version`，处理结果保存至`append`和`ignore_int`

对于不是以`-`开头的参数，认为其是文件名，存储到`files`

### 打开文件
```c
// 打开文件，保存fd
for(int i = 0; i < fileCount; i++) {
    fds[i] = open(files[i], O_CREAT | O_WRONLY | (append == true ? O_APPEND : O_TRUNC));
    if(fds[i] == -1) {
        exitErr(strcat("Can not open file: ", argv[i]), FILE_OPEN_FAIL);
    }
}
```

- 将`files`中的文件打开，存储其`fd`

### 读取stdin，写入文件

```c
// 读取stdin
ssize_t readSize = 0;
char readBuffer[READ_BUFFER_SIZE+1]; // 需要手动添加'\0'， 故+1
while(1) {
    errno = 0;
    readSize = read(STDIN_FILENO, readBuffer, READ_BUFFER_SIZE);
    if(readSize == -1) {
        exitErr("read stdin fail", STDIN_READ_FAIL);
    }
    if(readSize == 0) { //EOF
        break;
    }
    readBuffer[readSize] = '\0'; //防止写入脏数据，但是write时有readSize限制，所以没必要
    for(int i = 0; i < fileCount; i++) {
        errno = 0;
        ssize_t writeSize = write(fds[i], readBuffer, readSize);
        if(writeSize == -1) { //先判断-1
            exitErr(strcat("file write failed on file: ", files[i]), FILE_WRITE_FAIL);
        }
        if(writeSize < readSize) { // 部分写
            exitErr(strcat("Partial write occured on file: ", files[i]), PARTIAL_WRITE_OCCURED);
        }
    }
}
```

- 循环读取文件，利用系统调用`read`，若其返回0，则是遇到`eof`，跳出循环，若返回`-1`，则读取错误，异常退出
- 读取时注意该系统调用不认为读取的文件一定是文本文件，不会将其处理成字符串，即在末尾添加`'\0'`，需要手动添加
- 从stdin读取后，一次写入待写入的文件中，并判断是否成功，是否发生部分写

### 收尾
```c
release();
```

### 完整代码
```c
#include<string.h>

#include<sys/stat.h>
#include<fcntl.h>
#include<unistd.h>
#include<stdlib.h>

#include<errno.h> // 使用变量errno


#define bool char
#define false 0
#define true 1
#define strcmp(a,b) strcmp(a,b)==0

// exit code
#define UNSUPPORTED_ARG 1
#define FILE_OPEN_FAIL 2
#define STDOUT_WRITE_FAIL 3
#define STDERR_WRITE_FAIL 4
#define STDIN_READ_FAIL 5
#define PARTIAL_WRITE_OCCURED 6
#define FILE_CLOSE_FAIL 7
#define FILE_WRITE_FAIL 8

// 函数声明
void printHelp();
void printVersion();
void writeErr(const char* str);
void writeStdout(const char* str);
void exitErr(const char * err, int exitcode);
void release();

// 常量
#define MAX_FILE_COUNT 100
#define READ_BUFFER_SIZE 100

char **files = NULL;
int *fds = NULL;
int fileCount = 0;

int main(int argc, char **argv) {
    // 参数处理结果
    bool append = false;
    bool ignore_int = false;

    // 保存文件名，打开文件的fd，文件总数
    files = (char **)malloc(MAX_FILE_COUNT*sizeof(char *));
    fds = (int *)malloc(MAX_FILE_COUNT*sizeof(int));
    fileCount = 0;
    
    // 处理参数
    for(int i = 1; i < argc; i++) {
        if(argv[i][0] == '-') {
            if(strcmp(argv[i], "-a")) {
                append = true;
            } else if(strcmp(argv[i], "-i") || strcmp(argv[i], "--ignore-interrupts")) {
                ignore_int = true;
            } else if(strcmp(argv[i], "-ai") || strcmp(argv[i], "-ia") ) {
                append = true;
                ignore_int = true;
            } else if(strcmp(argv[i], "--help")) {
                printHelp();
            } else if(strcmp(argv[i], "--version")) {
                printVersion();
            } else {
                writeErr("Unsupported arg: ");
                writeErr(argv[i]);
                writeErr("\n");
                free(files);
                free(fds);
                exit(UNSUPPORTED_ARG);
            }
        } else {
            if(fileCount < MAX_FILE_COUNT-1) files[fileCount++] = argv[i];
        }
    }

    // 打开文件，保存fd
    for(int i = 0; i < fileCount; i++) {
        fds[i] = open(files[i], O_CREAT | O_WRONLY | (append == true ? O_APPEND : O_TRUNC));
        if(fds[i] == -1) {
            exitErr(strcat("Can not open file: ", argv[i]), FILE_OPEN_FAIL);
        }
    }
    
    // 读取stdin
    ssize_t readSize = 0;
    char readBuffer[READ_BUFFER_SIZE+1]; // 需要手动添加'\0'， 故+1
    while(1) {
        errno = 0;
        readSize = read(STDIN_FILENO, readBuffer, READ_BUFFER_SIZE);
        if(readSize == -1) {
            exitErr("read stdin fail", STDIN_READ_FAIL);
        }
        if(readSize == 0) { //EOF
            break;
        }
        readBuffer[readSize] = '\0'; //防止写入脏数据，但是write时有readSize限制，所以没必要
        for(int i = 0; i < fileCount; i++) {
            errno = 0;
            ssize_t writeSize = write(fds[i], readBuffer, readSize);
            if(writeSize == -1) { //先判断-1
                exitErr(strcat("file write failed on file: ", files[i]), FILE_WRITE_FAIL);
            }
            if(writeSize < readSize) { // 部分写
                exitErr(strcat("Partial write occured on file: ", files[i]), PARTIAL_WRITE_OCCURED);
            }
        }
    }

    release();
    return 0;
}

void release() {
    // 关闭文件
    for(int i = 0; i < fileCount; i++) {
        errno = 0;
        int success = close(fds[i]);
        if(success == -1) {
            exitErr(strcat("can not close file: ", files[i]), FILE_CLOSE_FAIL);
        }
    }
    free(files);
    free(fds);
}


void printHelp() {
    writeStdout("Usage: tee [-ai][--help][--version][files...]\n");
}
void printVersion() {
    writeStdout("Written by Jingtian Meow\n");
}

void exitErr(const char * err, int exitcode) {
    char *errstr = strerror(errno);
    writeErr("Error: ");
    writeErr(errstr);
    writeErr("\n");
    writeErr(err);
    writeErr("\n");
    release();
    exit(exitcode);
}

void writeStdout(const char* str) {
    errno = 0;
    int writeSize = write(STDOUT_FILENO, str, strlen(str));
    if(writeSize == -1) {
        exitErr("fail to write to stdout\n", STDOUT_WRITE_FAIL);
    }
}

void writeErr(const char* str) {
    errno = 0;
    int writeSize = write(STDERR_FILENO, str, strlen(str));
    if(writeSize == -1) {
        release();
        exit(STDERR_WRITE_FAIL);
    }
}
```

## 实现cp
> 编写一个类似于cp命令的程序，当使用该程序复制一个包含空洞(连续的空字节)的普通文件时，要求目标文件的空洞与源文件保持一致。

- 这道题走了一点弯路，一直在探索如何保存文件空洞，不能和上面程序一样
  - 由于空洞是程序在文件结尾处`lseek`了一段大于磁盘`blocksize`的距离后继续写入造成的，那么需要与其进行相同的`lseek`操作
  - 如果读取出的内容全部为0，则记录全为0的长度，直到读取出不全为0的时候，先`lseek`，再写入
  - 需要保证buffer的大小小于blocksize

### 创建文件空洞
```c
#include<string.h>
#include<sys/stat.h>
#include<fcntl.h>
#include<unistd.h>
#include<stdlib.h>

#define BLOCKSIZE 4096

void writeContent(int fd, const char * content);

int main(int argc, char **argv) {
    int fd = argc >= 2 ? open(argv[1], O_WRONLY | O_CREAT) : STDOUT_FILENO;
    int fd1 = argc >= 2 ? open(strcat(argv[1],".normal"), O_WRONLY | O_CREAT) : STDOUT_FILENO;
    int holeNum = argc == 3 ? atoi(argv[2]) : 1;
    if(fd == -1) {
        return 1;
    }
    char *content;
    char blank[BLOCKSIZE*2] = {0};
    memset(blank, ' ', sizeof(blank));
    blank[BLOCKSIZE*2-1] = 0;
    for(int i = 0; i < holeNum; i++) {
        content = "Content before the file hole!!!!!\n";
        writeContent(fd, content);
        writeContent(fd1, content);

        // make a hole
        lseek(fd, BLOCKSIZE*2, SEEK_CUR);
        writeContent(fd1, blank);

        content = "Content after the file hole!!!!!\n";
        writeContent(fd, content);
        writeContent(fd1, content);
    }

    if(close(fd) == -1) {
        exit(4);
    }
    if(close(fd1) == -1) {
        exit(4);
    }
    return 0;

}

void writeContent(int fd, const char * content) {
    size_t contentLen = strlen(content) + 1;
    int writeSize = write(fd, content, contentLen);
    if(writeSize == -1 || writeSize < contentLen) {
        exit(2);
    }
}
```

- 打开两个文件用作对比，fd通过lseek制造空洞，fd1写入相同大小的空格

### 使用命令`stat`比较生成的两个文件

```sh
root@tt-surfacepro6:~/linux# stat -c %b abc
16
```

abc的块数是16

```sh
root@tt-surfacepro6:~/linux# stat -c %b abc.normal 
24
```

abc.normal的块数的24

### 预处理
```c
#include<string.h>

#include<sys/stat.h>
#include<fcntl.h>
#include<unistd.h>
#include<stdlib.h>
#include<errno.h>

// #define debug
#ifdef debug
#include<stdio.h>
#endif

#define bool char
#define false 0
#define true 1
#define strcmp(a,b) strcmp(a,b)==0

// exit code
#define UNSUPPORTED_ARG 1
#define FILE_OPEN_FAIL 2
#define STDOUT_WRITE_FAIL 3
#define STDERR_WRITE_FAIL 4
#define STDIN_READ_FAIL 5
#define PARTIAL_WRITE_OCCURED 6
#define FILE_CLOSE_FAIL 7
#define FILE_WRITE_FAIL 8
#define FILE_READ_FAIL 10
#define INVALID_ARG 9

// 函数声明
void printHelp();
void printVersion();
void writeErr(const char* str);
void writeStdout(const char* str);
void fileErrClose(const char * filename, const char *err, int exitCode); 

#define READ_BUFF_SIZE 1023
```

### 工具函数
```c
void fileErrClose(const char * filename, const char *err, int exitCode) {
    const char *errstr = strerror(errno);
    writeErr("Error: ");
    writeErr(errstr);
    writeErr("\n");
    writeErr(err);
    writeErr(filename);
    writeErr("\n");
    exit(exitCode);
}

void printHelp() {
    writeStdout("Usage: cp [--help][--version][src dest]\n");
}
void printVersion() {
    writeStdout("Written by Jingtian Meow\n");
}

void writeStdout(const char* str) {
    errno = 0;
    int writeSize = write(STDOUT_FILENO, str, strlen(str));
    if(writeSize == -1) {
        char *errstr = strerror(errno);
        writeErr("Error: ");
        writeErr(errstr);
        writeErr("\n");
        writeErr("fail to write to stdout\n");
        exit(STDOUT_WRITE_FAIL);
    }
}

void writeErr(const char* str) {
    errno = 0;
    int writeSize = write(STDERR_FILENO, str, strlen(str));
    if(writeSize == -1) {
        exit(STDERR_WRITE_FAIL);
    }
}

```

### 参数处理
```c
int main(int argc, char **argv) {
    // src文件，dest文件
    char *filesrc = NULL, *filedest = NULL;

    // 处理参数
    for(int i = 1; i < argc; i++) {
        if(argv[i][0] == '-') {
            if(strcmp(argv[i], "--help") || strcmp(argv[i], "-h")) {
                printHelp();
            } else if(strcmp(argv[i], "--version") || strcmp(argv[i], "-v")) {
                printHelp();
            } else {
                writeErr("Unsupported arg: ");
                writeErr(argv[i]);
                writeErr("\n");
                exit(UNSUPPORTED_ARG);
            }
        } else {
            if(filesrc == NULL) {
                filesrc = argv[i];
            } else if(filedest == NULL) {
                filedest = argv[i];
            } else {
                writeErr("Invalid arguments: ");
                writeErr(argv[i]);
                writeErr("\n");
                exit(INVALID_ARG);
            }
        }
    }
    // other part ...
}
```

不允许`-r`等操作，只允许对文件进行复制

### 文件打开
```c
errno = 0;
int srcFd = open(filesrc, O_RDONLY);
if(srcFd == -1) {
    fileErrClose(filesrc, "Can not open file: ", FILE_OPEN_FAIL);
}
errno = 0;
int descFd = open(filedest, O_WRONLY | O_TRUNC | O_CREAT);
if(descFd == -1) {
    fileErrClose(filedest, "Can not open file: ", FILE_OPEN_FAIL);
}
```
分别打开输入和输出文件

### 文件读写
```c
char * readBuffer[READ_BUFF_SIZE+1];
char allzero[READ_BUFF_SIZE+1] = {0};
off_t offdest = 0;
while(1) {
    errno = 0;
    ssize_t readSize = read(srcFd, readBuffer, READ_BUFF_SIZE);
    if(readSize == -1) {
        fileErrClose(filesrc, "Can not read file: ", FILE_READ_FAIL);
    }
    #ifdef debug
    printf("readsize = %ld\n", readSize);
    #endif
    if(readSize == 0) {
        #ifdef debug
        writeStdout("Read finish\n");
        #endif
        break;
    }
    readBuffer[readSize] = 0;
    offdest += readSize;
    if(memcmp(readBuffer, allzero, readSize) == 0) {
        #ifdef debug
        printf("hole, readsize = %ld, off = %ld\n", readSize, offdest);
        #endif
        continue;
    }
    if(offdest > 0)lseek(descFd, offdest, SEEK_CUR);
    offdest = 0;
    errno = 0;
    int writeSize = write(descFd, readBuffer, readSize);
    if(writeSize == -1) {
        fileErrClose(filedest, "Write Fail on file: ", FILE_WRITE_FAIL);
    }
    if(writeSize < readSize) {
        fileErrClose(filedest, "Partial write occured on file: ", PARTIAL_WRITE_OCCURED);
    }
}
```

- 当某次读出数据全为0时，则此处是空洞，记录空洞的累计长度
- 直到某次读取不全为0时，空洞结束，先lseek空洞长度，再写入

### 善后
```c
errno = 0;
if(close(srcFd) == -1) {
    fileErrClose(filesrc, "Can not close file: ", FILE_CLOSE_FAIL);
}

errno = 0;
if(close(descFd) == -1) {
    fileErrClose(filedest, "Can not close file: ", FILE_CLOSE_FAIL);
}
return 0;
```

### 复制文件

```sh
gcc cp.c -o cp && ./cp abc abc.cp
stat -c %b abc.cp
```

编译该cp工具，使用它复制带有空洞文件，可发现其成功复制，并输出块数也为16

### 完整代码
```c
#include<string.h>

#include<sys/stat.h>
#include<fcntl.h>
#include<unistd.h>
#include<stdlib.h>
#include<errno.h>

// #define debug
#ifdef debug
#include<stdio.h>
#endif

#define bool char
#define false 0
#define true 1
#define strcmp(a,b) strcmp(a,b)==0

// exit code
#define UNSUPPORTED_ARG 1
#define FILE_OPEN_FAIL 2
#define STDOUT_WRITE_FAIL 3
#define STDERR_WRITE_FAIL 4
#define STDIN_READ_FAIL 5
#define PARTIAL_WRITE_OCCURED 6
#define FILE_CLOSE_FAIL 7
#define FILE_WRITE_FAIL 8
#define FILE_READ_FAIL 10
#define INVALID_ARG 9

// 函数声明
void printHelp();
void printVersion();
void writeErr(const char* str);
void writeStdout(const char* str);
void fileErrClose(const char * filename, const char *err, int exitCode); 

#define READ_BUFF_SIZE 1023

int main(int argc, char **argv) {
    // src文件，dest文件
    char *filesrc = NULL, *filedest = NULL;

    // 处理参数
    for(int i = 1; i < argc; i++) {
        if(argv[i][0] == '-') {
            if(strcmp(argv[i], "--help") || strcmp(argv[i], "-h")) {
                printHelp();
            } else if(strcmp(argv[i], "--version") || strcmp(argv[i], "-v")) {
                printHelp();
            } else {
                writeErr("Unsupported arg: ");
                writeErr(argv[i]);
                writeErr("\n");
                exit(UNSUPPORTED_ARG);
            }
        } else {
            if(filesrc == NULL) {
                filesrc = argv[i];
            } else if(filedest == NULL) {
                filedest = argv[i];
            } else {
                writeErr("Invalid arguments: ");
                writeErr(argv[i]);
                writeErr("\n");
                exit(INVALID_ARG);
            }
        }
    }
    errno = 0;
    int srcFd = open(filesrc, O_RDONLY);
    if(srcFd == -1) {
        fileErrClose(filesrc, "Can not open file: ", FILE_OPEN_FAIL);
    }
    errno = 0;
    int descFd = open(filedest, O_WRONLY | O_TRUNC | O_CREAT);
    if(descFd == -1) {
        fileErrClose(filedest, "Can not open file: ", FILE_OPEN_FAIL);
    }

    char * readBuffer[READ_BUFF_SIZE+1];
    char allzero[READ_BUFF_SIZE+1] = {0};
    off_t offdest = 0;
    while(1) {
        errno = 0;
        ssize_t readSize = read(srcFd, readBuffer, READ_BUFF_SIZE);
        if(readSize == -1) {
            fileErrClose(filesrc, "Can not read file: ", FILE_READ_FAIL);
        }
        #ifdef debug
        printf("readsize = %ld\n", readSize);
        #endif
        if(readSize == 0) {
            #ifdef debug
            writeStdout("Read finish\n");
            #endif
            break;
        }
        readBuffer[readSize] = 0;
        offdest += readSize;
        if(memcmp(readBuffer, allzero, readSize) == 0) {
            #ifdef debug
            printf("hole, readsize = %ld, off = %ld\n", readSize, offdest);
            #endif
            continue;
        }
        if(offdest > 0)lseek(descFd, offdest, SEEK_CUR);
        offdest = 0;
        errno = 0;
        int writeSize = write(descFd, readBuffer, readSize);
        if(writeSize == -1) {
            fileErrClose(filedest, "Write Fail on file: ", FILE_WRITE_FAIL);
        }
        if(writeSize < readSize) {
            fileErrClose(filedest, "Partial write occured on file: ", PARTIAL_WRITE_OCCURED);
        }
    }

    errno = 0;
    if(close(srcFd) == -1) {
        fileErrClose(filesrc, "Can not close file: ", FILE_CLOSE_FAIL);
    }

    errno = 0;
    if(close(descFd) == -1) {
        fileErrClose(filedest, "Can not close file: ", FILE_CLOSE_FAIL);
    }
    return 0;
}

void fileErrClose(const char * filename, const char *err, int exitCode) {
    const char *errstr = strerror(errno);
    writeErr("Error: ");
    writeErr(errstr);
    writeErr("\n");
    writeErr(err);
    writeErr(filename);
    writeErr("\n");
    exit(exitCode);
}

void printHelp() {
    writeStdout("Usage: cp [--help][--version][src dest]\n");
}
void printVersion() {
    writeStdout("Written by Jingtian Meow\n");
}

void writeStdout(const char* str) {
    errno = 0;
    int writeSize = write(STDOUT_FILENO, str, strlen(str));
    if(writeSize == -1) {
        char *errstr = strerror(errno);
        writeErr("Error: ");
        writeErr(errstr);
        writeErr("\n");
        writeErr("fail to write to stdout\n");
        exit(STDOUT_WRITE_FAIL);
    }
}

void writeErr(const char* str) {
    errno = 0;
    int writeSize = write(STDERR_FILENO, str, strlen(str));
    if(writeSize == -1) {
        exit(STDERR_WRITE_FAIL);
    }
}
```