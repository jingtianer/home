---
title: cha44.管道和FIFO
date: 2023-8-30 12:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 管道和FIFO

- 通过`pipe`调用获取两个`fd`，`fd[0]`为管道的输入端，`fd[1]`为输出端，允许相关的进程之间通过管道相连
- 管道的使用的单项的，如果某些进程即读取管道又写入管道，可能会与其他读取/写入管道的进程产生竞态条件
- 对管道`read`时，如果管道另一端有进程打开且管道内没有内容，则会阻塞，直到另一端写入（此时读取到写入的数据），或另一端关闭（此时`read`返回`EOF`）
  - 利用这一特性，可以作为进程间的同步机制
- 一般子进程要关闭不需要的另一端
  - 当所有写入端都关闭时，从管道中读取，会返回`EOF`，帮助程序了解当前管道的使用状况
  - 当所有读取端都关闭时，向管道内写入数据，系统会向进程发送`SIGPIPE`，默认杀死进程。若修改`SIGPIPE`默认行为，则`write`失败，错误为`EPIPE`。若对`SIGPIPE`使用了`SA_RESTART`，`write`另一端已经关闭的管道，`write`也不会重启
- `stdio`对管道使用块缓冲
- `FIFO`通过`mkfifo`或`mknod`创建，类似于管道，区别在于
  - 通过文件名`open`后获取`fd`，`open`时指定read还是`write`
  - `open`时没有使用`O_NONBLOCK`时，打开另一端关闭的`FIFO`时，会阻塞
  - `open`时使用`O_NONBLOCK | O_WRONLY`时，向另一侧关闭的`FIFO`中写入时，导致`ENXIO`错误，使用`O_NONBLOCK | O_RDONLY`则立刻成功
  - 不使用`O_NONBLOCK`时`read`，情况等于管道，启用时，如果`FIFO`中没有数据，产生`EAGAIN`错误
  - `write`时读取端关闭，则产生`SIGPIPE`，返回`EPIPE`。其他情况比较复杂。

## 验证
```c
//
// Created by root on 8/29/23.
//
#define _GNU_SOURCE
#include <stdio.h>
#include <dlfcn.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <wait.h>
#include <signal.h>

void error(const char *file, int line,const char *str, ...) {
    va_list fmt;
    va_start(fmt, str);
    fprintf(stderr, "error:%s %s:%d\n", strerror(errno), file, line);
    vfprintf(stderr, str, fmt);
    fprintf(stderr, "\n");
    va_end(fmt);
}

#define ERROR(...) do { error(__FILE__, __LINE__, __VA_ARGS__); exit(1); } while(0)
#define ERROR_PRINT(...) error(__FILE__, __LINE__, __VA_ARGS__)
#define FAIL(...) do { error(__FILE__, __LINE__, __VA_ARGS__); return -1; } while(0)

char *alloc_sprintf(const char * __format, ...) {
    va_list fmt;
    va_start(fmt, __format);
    int len = vsnprintf(NULL, 0, __format, fmt);
    va_end(fmt);
    char *str = malloc(len+1);
    if(str == NULL) ERROR("");
    va_start(fmt, __format);
    vsnprintf(str, len+1, __format, fmt);
    va_end(fmt);
    return str;
}

#define safe_free(ptr) do { if(ptr) { free(ptr); ptr = NULL;} } while(0)

char *fifo;
void cleanup() {
    safe_free(fifo);
}

#define test(flag) do { \
    int fd = open(fifo, flag); \
    if(fd == -1) { \
        error(__FILE__, __LINE__, "flag = %s",#flag); \
    } \
    close(fd); \
} while(0)

void pipehandler(int sig) {
    char *content = alloc_sprintf("pid:%d, received signal:%d(%s)\n", getpid(), sig, strsignal(sig));
    write(STDOUT_FILENO, content, strlen(content));
    safe_free(content);
}

int main(int argc, char **argv) {
    char buf[1024];
    atexit(cleanup);
    fifo = alloc_sprintf("%s-fifo", argv[0]);
    printf("fifo=%s\n", fifo);
    if(mkfifo(fifo, S_IRUSR | S_IWUSR | S_IWGRP) == -1 && errno != EEXIST) {
        ERROR("");
    }
    // 非阻塞，打开没有写入端的FIFO
    test(O_RDONLY | O_NONBLOCK);
    // 非阻塞，打开没有读取端的FIFO
    test(O_WRONLY | O_NONBLOCK);

    int pipefd[2] = {0};
    if(pipe(pipefd) == -1) ERROR("");
    if(sigaction(SIGPIPE, &(struct sigaction) {
        .sa_flags=0,
        .sa_handler=pipehandler }, NULL) == -1) ERROR("");
    if(sigaction(SIGUSR1, &(struct sigaction) {
            .sa_flags=SA_RESTART,
            .sa_handler=pipehandler }, NULL) == -1) ERROR("");
    if(sigaction(SIGUSR2, &(struct sigaction) {
            .sa_flags=0,
            .sa_handler=pipehandler }, NULL) == -1) ERROR("");

    ssize_t readsize = 0;
    pid_t pid;
    if((pid = fork()) != 0) {
        if((readsize = read(pipefd[0], buf, 1024)) < 0) {
            ERROR_PRINT("");
        } // SIGUSR1中断read，SIGUSR1有SA_RESTART，重启，成功读取
        if(write(STDOUT_FILENO, buf, readsize) != readsize) {
            ERROR("");
        }
        kill(pid, SIGUSR1);
        readsize = 0;
        if((readsize = read(pipefd[0], buf, 1024)) < 0) {
            ERROR_PRINT("");
        } // SIGUSR2中断read，SIGUSR2没有SA_RESTART，不重启，没有成功读取
        if(write(STDOUT_FILENO, buf, readsize) != readsize) {
            ERROR("");
        }
    } else {
        close(pipefd[0]);
        kill(getppid(), SIGUSR1);
        sleep(1);
        write(pipefd[1], &(char[]){'o', 'k', '!', '\n'}, 4);
        pause();
        sleep(1);
        kill(getppid(), SIGUSR2);
        sleep(1);
        write(pipefd[1], &(char[]){'o', 'j', 'b', 'k', '!', '\n'}, 6);
        close(pipefd[1]);
        exit(0);
    }
    wait(NULL);
    close(pipefd[0]);
    close(pipefd[1]);
    if(pipe(pipefd) == -1) ERROR("");
    close(pipefd[1]);
    if((readsize = read(pipefd[0], buf, 1024)) < 0) {
        ERROR_PRINT("");
    } // 向写入端已经关闭的一端读取
    printf("向写入端已经关闭的一端读取, readsize = %lu\n", readsize);
    close(pipefd[0]);

    if(pipe(pipefd) == -1) ERROR("");
    close(pipefd[0]);
    if(write(pipefd[1], "12345", 5) != 5) {
        ERROR_PRINT("");
    } // 向读取端已经关闭的一端写入,SIGPIPE有SA_RESTART但是此时不重启
    close(pipefd[1]);

    return 0;
}
```

书上有一些不清楚的地方，用这个代码可以验证一下

## 44.1
编写一个程序使之使用两个管道来启用父进程和子进程之间的双向通信。父进程应该循环从标准输入中读取一个文本块并使用其中一个管道将文本发送给子进程，子进程将文本转换成大写并通过另一个管道将其传回给父进程。父进程读取从子进程过来的数据并在继续下一个循环之前将其反馈到标准输出上。

```c
//
// Created by root on 8/29/23.
//
#include <stdio.h>
#include <dlfcn.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <unistd.h>
#include <signal.h>

void error(const char *file, int line,const char *str, ...) {
    va_list fmt;
    va_start(fmt, str);
    fprintf(stderr, "error:%s %s:%d\n", strerror(errno), file, line);
    vfprintf(stderr, str, fmt);
    fprintf(stderr, "\n");
    va_end(fmt);
}

#define ERROR(...) do { error(__FILE__, __LINE__, __VA_ARGS__); exit(1); } while(0)
#define ERROR_PRINT(...) error(__FILE__, __LINE__, __VA_ARGS__)
#define FAIL(...) do { error(__FILE__, __LINE__, __VA_ARGS__); return -1; } while(0)

#define safe_free(ptr) do { if(ptr) { free(ptr); ptr = NULL;} } while(0)


void wPrintf(int fd, const char * format, ...) {
    va_list fmt;
    va_start(fmt, format);
    int len = vsnprintf(NULL, 0, format, fmt);
    char *str = malloc(len+1);
    va_end(fmt);
    va_start(fmt, format);
    if(str == NULL) ERROR("");
    vsnprintf(str, len+1, format, fmt);
    va_end(fmt);
    if(write(fd, str, len) != len) {
        ERROR("");
    }
    safe_free(str);
}

pid_t childpid = -1;
#define BUFFER_SIZE 2048
int main2child[2];
int child2main[2];
void cleanup() {
    wPrintf(STDOUT_FILENO, "pid:%d, cleaning up\n", getpid());
    if(childpid > 1)
        kill(childpid,SIGKILL);
}

void child_process() {
    char buf[BUFFER_SIZE];
    ssize_t readsize;
    if(close(main2child[1]) == -1) ERROR("");
    if(close(child2main[0]) == -1) ERROR("");
    while ((readsize = read(main2child[0], buf, BUFFER_SIZE-1)) > 0) {
        buf[readsize] = 0;
        wPrintf(STDOUT_FILENO, "child read: %s\n", buf);
        for(int i = 0; i < readsize; i++) {
            if((buf[i] >= 'a' && buf[i] <= 'z') ) {
                buf[i] += 'A' - 'a';
            } else if((buf[i] >= 'A' && buf[i] <= 'Z')) {
                buf[i] += 'a' - 'A';
            }
        }
        if(write(child2main[1], buf, readsize) != readsize) {
            ERROR("");
        }
    }
    if(readsize < 0) {
        ERROR("");
    } else {
        wPrintf(STDOUT_FILENO, "main2child closed!\n");
    }
    if(close(main2child[0]) == -1) ERROR("");
    if(close(child2main[1]) == -1) ERROR("");

}
void main_process() {
    char buf[BUFFER_SIZE];
    ssize_t readsize;
    if(close(main2child[0]) == -1) ERROR("");
    if(close(child2main[1]) == -1) ERROR("");
    while ((readsize = read(STDIN_FILENO, buf, BUFFER_SIZE-1)) > 0) {
        buf[readsize] = 0;
        wPrintf(STDOUT_FILENO, "main read: %s\n", buf);
        if(write(main2child[1], buf, readsize) != readsize) {
            ERROR("");
        }
        readsize = read(child2main[0], buf, BUFFER_SIZE-1);
        buf[readsize] = 0;
        if(readsize == 0) {
            wPrintf(STDOUT_FILENO, "child2main closed!\n");
            exit(0);
        } else if(readsize < 0) {
            ERROR("");
        } else {
            wPrintf(STDOUT_FILENO, "main read from child: %s\n", buf);
        }
    }
    if(readsize < 0) {
        ERROR("");
    }
    if(close(main2child[1]) == -1) ERROR("");
    if(close(child2main[0]) == -1) ERROR("");
}

void handler(int sig) {
    wPrintf(STDOUT_FILENO, "pid:%d, received sig:%d(%s)\n", getpid(), sig, strsignal(sig));
    exit(1);
}

int main(int argc, char *argv[]) {
    atexit(cleanup);
    if(pipe(main2child) == -1) ERROR("");
    if(pipe(child2main) == -1) ERROR("");
    switch((childpid = fork())) {
        case -1:
            ERROR("");
            break;
        case 0:
            child_process();
            return 0;
            break;
        default:
            if(signal(SIGINT, handler) == SIG_ERR) ERROR("");
            if(signal(SIGPIPE, handler) == SIG_ERR) ERROR("");
            main_process();
            return 0;
            break;
    }
}
```
## 44.2
实现popen和pclose。尽管这些函数因无需完成在system实现(参见27.7节)中的信号处理而得到了简化，但需要小心地将管道两端正确绑定到各个进程的文件流上并确保关闭所有引用管道两端的未使用的描述符。由于通过多个 popen调用
创建的子进程可能会同时运行，因此需要需要维护一个将 popen0分配的文件流与相应的子进程ID关联起来的数据结构。从这个结构中取得正确的进程ID使得pclose能够选择需等待的子进程。这个结构还满足了SUSv3的要求，即在新的子进程中必须要关闭所有通过之前的popen调用仍然打开着的文件流。

```c
//
// Created by root on 8/29/23.
//
#include <stdio.h>
#include <dlfcn.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <unistd.h>
#include <signal.h>

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
#define FAIL(val, msg...) ERROR_EXIT(return val;, msg)
#define PRINT_ERROR_STR(msg...) FAIL(, msg)

#define safe_free(ptr) do { if(ptr) { free(ptr); ptr = NULL;} } while(0)


void wPrintf(int fd, const char * format, ...) {
    va_list fmt;
    va_start(fmt, format);
    int len = vsnprintf(NULL, 0, format, fmt);
    char *str = malloc(len+1);
    va_end(fmt);
    va_start(fmt, format);
    if(str == NULL) ERROR("");
    vsnprintf(str, len+1, format, fmt);
    va_end(fmt);
    if(write(fd, str, len) != len) {
        ERROR("");
    }
    safe_free(str);
}
#include <limits.h>
#include <wait.h>
static pid_t *fd2pid = NULL;
int _pclose(FILE *file) {
    if(fd2pid == NULL) {
        fd2pid = malloc(INT_MAX * sizeof(pid_t));
        return -1;
    }
    int fd = fileno(file);
    if(fclose(file) == -1) FAIL(-1, "");
//    if(close(fd) == -1) FAIL(-1, ""); // 不需要，fclose就会调用close
    if(waitpid(fd2pid[fd], NULL, 0) == -1) FAIL(-1, "");
    return 0;
}
FILE *_popen(const char *command, const char *mode) {
    if(fd2pid == NULL) {
        fd2pid = malloc(INT_MAX * sizeof(pid_t));
    }

    FILE *ret = NULL;
    int pipefd[2] = {0}; // retfd, dupfd
    int replacefd = -1;
    if(strcmp("r", mode) != 0 && strcmp("w", mode) != 0) {
        FAIL(NULL, "mode: r/w");
    }
    if(pipe(pipefd) == -1) FAIL(NULL, "");
    if(mode[0] == 'r') {
        ret = fdopen(pipefd[0], "r");
        if(ret == NULL) FAIL(NULL, "");
        replacefd = STDOUT_FILENO;

    } else {
        ret = fdopen(pipefd[1], "w");
        int fdt = pipefd[0];
        pipefd[0] = pipefd[1];
        pipefd[1] = fdt;
        replacefd = STDIN_FILENO;
    }
    pid_t pid;
    switch(pid = fork()) {
        case -1:
            FAIL(NULL, "");
            break;
        case 0:
            if(close(pipefd[0]) == -1) FAIL(NULL, "");
            if(dup2(pipefd[1], replacefd) == -1) {
                ERROR("");
            }
            system(command);
            if(close(pipefd[1]) == -1) FAIL(NULL, "");
            exit(0);
            break;
        default:
            if(close(pipefd[1]) == -1) FAIL(NULL, "");
            break;
    }
    fd2pid[pipefd[0]] = pid;
    return ret;
}

int main(int argc, char *argv[]) {
    FILE *f;
    f = _popen("tee > abc.txt", "w");
    for(int i = 0; i < argc; i++) {
        fprintf(f, "%s\n", argv[i]);
    }
    _pclose(f);
    f = _popen("cat abc.txt", "r");
    char buf[2048] = {0};
    while (fgets(buf, 2048, f) != NULL) {
        printf("%s", buf);
    }
    _pclose(f);
}
```

## 44.3 44.4 44.6
在44.7的基础上改动：
- 加入功能：每次给client赋值时，都会与一个文件同步记录最新的数值，服务器启动时读取这个数值，并从这个数值开始提供服务
- 加入功能：在收到SIGINT, SIGTERM时删除服务器并终止
- 加入功能：防止恶意程序攻击（恶意程序创建但不打开自己的CLIENT_FIFO，导致server始终阻塞。

```c
//
// Created by root on 8/29/23.
//
#include <stdio.h>
#include <dlfcn.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>

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

#define safe_free(ptr) do { if(ptr) { free(ptr); ptr = NULL;} } while(0)

char *alloc_sprintf(const char * __format, ...) {
    va_list fmt;
    va_start(fmt, __format);
    int len = vsnprintf(NULL, 0, __format, fmt);
    va_end(fmt);
    char *str = malloc(len+1);
    if(str == NULL) ERROR("");
    va_start(fmt, __format);
    vsnprintf(str, len+1, __format, fmt);
    va_end(fmt);
    return str;
}

char *__client_fifo = NULL;
void __attribute__((destructor)) cleanup() { // atexit更合适
    safe_free(__client_fifo);
}

#define SERVER_FIFO "server-fifo"
#define CLIENT_FIFO (__client_fifo == NULL ? (__client_fifo = alloc_sprintf("client-fifo-%d", getpid())) : __client_fifo)
#define GET_CLIENT_FIFO(pid) alloc_sprintf("client-fifo-%d", pid)
#define GLOBAL_NUMBER_FILE "global_number_file"
struct client_info {
    pid_t pid;
    int incr;
};

unsigned long long int number = 0;
void sync_global(unsigned long long int *old, unsigned long long int *new) {
    unsigned long long int buf;
    int global_numberfd = open(GLOBAL_NUMBER_FILE, O_RDWR | O_SYNC | O_CREAT, 0666);
    if(global_numberfd == -1) FAIL(return;,"");

    ssize_t readsize = read(global_numberfd, &buf, sizeof(unsigned long long int));
    if(readsize < 0) PRINT_ERROR_STR("");
    lseek(global_numberfd, 0, SEEK_SET);
    if(old) {
        if(write(global_numberfd, old, sizeof(unsigned long long int)) != sizeof(unsigned long long int))
            PRINT_ERROR_STR("");
    }
    if(readsize > 0 && new) *new = buf;
    close(global_numberfd);
}

int server_fd;
int dummy_fd;
void on_server_exit() {
    close(server_fd);
    close(dummy_fd);
    unlink(SERVER_FIFO);
    sync_global(&number, NULL);
}
void handler(int sig) {
    printf("server, sig:%s\n", strsignal(sig));
    on_server_exit();
    signal(sig, SIG_DFL);
    raise(sig);
}

void destroy(int sig) {
    printf("server, sig:%s\n", strsignal(sig));
    on_server_exit();
    unlink(GLOBAL_NUMBER_FILE);
    _exit(0);
}

int server(int argc, char *argv[]) {
    atexit(on_server_exit);
    signal(SIGPIPE, handler);
    signal(SIGINT, destroy);
    signal(SIGTERM, destroy);
    signal(SIGHUP, handler);
    signal(19, handler);
    if(mkfifo(SERVER_FIFO, 0666) == -1) ERROR("");
    if((server_fd = open(SERVER_FIFO, O_RDONLY)) == -1) ERROR("");
    if((dummy_fd = open(SERVER_FIFO, O_WRONLY)) == -1) ERROR(""); // dummy可以防止读取到EOF，防止cpu空转
    struct client_info buf;
    ssize_t rd_size;
    sync_global(NULL, &number);
    printf("number = %llu\n", number);
    for(int i = 0 ;; i++) { // dummy可以防止cpu在这里空转
        printf("i = %d\n", i);
        while ((rd_size = read(server_fd, &buf, sizeof(struct client_info))) > 0) {
            printf("server: handling request from %d,%d\n", buf.pid, buf.incr);
            char *client_fifo = GET_CLIENT_FIFO(buf.pid);
            if(access(client_fifo, F_OK | W_OK) != 0) ERROR_EXIT(goto cleanup_noaction;, "");

            int client_fd;
            if ((client_fd = open(client_fifo, O_WRONLY | O_NONBLOCK)) == -1) ERROR_EXIT(goto cleanup_noaction;, ""); //防止阻塞
            int flag;
            if((flag = fcntl(client_fd, F_GETFL)) == -1) ERROR_EXIT(goto cleanup;, "");
            flag &= ~O_NONBLOCK; // 去掉O_NONBLOCK
            if(fcntl(client_fd, F_SETFL, flag) == -1) ERROR_EXIT(goto cleanup;, ""); // write使用阻塞语义
            sigset_t sigset, oldset;
            if(sigemptyset(&sigset) == -1) ERROR_EXIT(goto cleanup_nomask;, "");
            if(sigemptyset(&oldset) == -1) ERROR_EXIT(goto cleanup_nomask;, "");
            if(sigaddset(&sigset, SIGPIPE) == -1) ERROR_EXIT(goto cleanup_nomask;, "");
            if(sigprocmask(SIG_SETMASK, &sigset, &oldset) == -1) ERROR_EXIT(goto cleanup_nomask;, ""); //写入端没打开，产生SIGPIPE和EPIPE，屏蔽SIGPIPE
            if (write(client_fd, &(unsigned long long int[1]) {number}, sizeof(unsigned long long int[1])) !=
                sizeof(unsigned long long int[1])) ERROR_EXIT(goto cleanup;, "");
            number += buf.incr;
            cleanup:
            if(sigprocmask(SIG_SETMASK, &oldset, NULL) == -1) ERROR_EXIT(goto cleanup;, ""); // 还原
            cleanup_nomask:
            sync_global(&number, NULL);
            close(client_fd);
            cleanup_noaction:
            safe_free(client_fifo);
        }
        if(rd_size < 0) ERROR("");
    }
    return 0;
}
int client(int argc, char *argv[]) {
    int client_fd;
    if((server_fd = open(SERVER_FIFO, O_WRONLY)) == -1) ERROR("");
    if(mkfifo(CLIENT_FIFO, 0666) == -1) ERROR("");
    struct client_info info = {
            .incr=atoi(argv[1]),
            .pid=getpid()
    };
    printf("client write\n");
    if(write(server_fd, &info, sizeof(struct client_info)) != sizeof(struct client_info)) {
        ERROR("");
    }
    unsigned long long int n;
    printf("client read\n");
    printf("client open1\n");
    if((client_fd = open(CLIENT_FIFO, O_RDONLY)) == -1) ERROR("");
    if(read(client_fd, &n, sizeof(unsigned long long int)) != sizeof(unsigned long long int)) {
        ERROR("");
    }
    printf("get id: %llu\n", n);
    close(server_fd);
    close(client_fd);
    unlink(CLIENT_FIFO);
}

int malicious(int argc, char *argv[]) {
    if((server_fd = open(SERVER_FIFO, O_WRONLY)) == -1) ERROR("");
    if(mkfifo(CLIENT_FIFO, 0666) == -1) ERROR("");
    struct client_info info = {
            .incr=atoi(argv[1]),
            .pid=getpid()
    };
    printf("client write\n");
    if(write(server_fd, &info, sizeof(struct client_info)) != sizeof(struct client_info)) {
        ERROR("");
    }
}
int main(int argc, char *argv[]) {
    argv++;
    argc--;
    if(!strcmp("server", argv[0])) {
        server(argc, argv);
    } else if(!strcmp("client", argv[0])) {
        client(argc, argv);
    } else if (!strcmp("malicious", argv[0])) {
        malicious(argc, argv);
    }
    return 0;
}
```

## 44.5
程序清单44-7中的服务器(fifoseqnum_server.c)在 FIFO上执行第二次带O_WRONLY标记的打开操作使之在从FIFO的读取描述符(serverFd)中读取数据时永远不会看到文件结束。除了这种做法之外，还可以尝试另一种方法:当服务器
在读取描述符中看到文件结束时关闭这个描述符，然后再次打开 FIFO以便读取数据。(这个打开操作将会阻塞直到下一个客户端因写入而打开FIFO为止。这种方法错在哪里了?

1. 增加不必要的系统调用，导致额外的系统开销
2. 若`server`的优先级较低，`open`始终无法调用，则client也会阻塞在`open`上
3. 在读到EOF与下一次`open`之间，可能有其他进程向`FIFO`中写入数据，导致这些进程无法得到服务


```c
//
// Created by root on 8/29/23.
//
#include <stdio.h>
#include <dlfcn.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>

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

#define safe_free(ptr) do { if(ptr) { free(ptr); ptr = NULL;} } while(0)

char *alloc_sprintf(const char * __format, ...) {
    va_list fmt;
    va_start(fmt, __format);
    int len = vsnprintf(NULL, 0, __format, fmt);
    va_end(fmt);
    char *str = malloc(len+1);
    if(str == NULL) ERROR("");
    va_start(fmt, __format);
    vsnprintf(str, len+1, __format, fmt);
    va_end(fmt);
    return str;
}

char *__client_fifo = NULL;
void __attribute__((destructor)) cleanup() { // atexit更合适
    safe_free(__client_fifo);
}

#define SERVER_FIFO "server-fifo"
#define CLIENT_FIFO (__client_fifo == NULL ? (__client_fifo = alloc_sprintf("client-fifo-%d", getpid())) : __client_fifo)
#define GET_CLIENT_FIFO(pid) alloc_sprintf("client-fifo-%d", pid)
#define GLOBAL_NUMBER_FILE "global_number_file"
struct client_info {
    pid_t pid;
    int incr;
};

unsigned long long int number = 0;
void sync_global(unsigned long long int *old, unsigned long long int *new) {
    unsigned long long int buf;
    int global_numberfd = open(GLOBAL_NUMBER_FILE, O_RDWR | O_SYNC | O_CREAT, 0666);
    if(global_numberfd == -1) FAIL(return;,"");

    ssize_t readsize = read(global_numberfd, &buf, sizeof(unsigned long long int));
    if(readsize < 0) PRINT_ERROR_STR("");
    lseek(global_numberfd, 0, SEEK_SET);
    if(old) {
        if(write(global_numberfd, old, sizeof(unsigned long long int)) != sizeof(unsigned long long int))
            PRINT_ERROR_STR("");
    }
    if(readsize > 0 && new) *new = buf;
    close(global_numberfd);
}

int server_fd;
int dummy_fd;
void on_server_exit() {
    close(server_fd);
    close(dummy_fd);
    unlink(SERVER_FIFO);
    sync_global(&number, NULL);
}
void handler(int sig) {
    printf("server, sig:%s\n", strsignal(sig));
    on_server_exit();
    signal(sig, SIG_DFL);
    raise(sig);
}

void destroy(int sig) {
    printf("server, sig:%s\n", strsignal(sig));
    on_server_exit();
    unlink(GLOBAL_NUMBER_FILE);
    _exit(0);
}

int server(int argc, char *argv[]) {
    atexit(on_server_exit);
    signal(SIGPIPE, handler);
    signal(SIGINT, destroy);
    signal(SIGTERM, destroy);
    signal(SIGHUP, handler);
    signal(19, handler);
    if(mkfifo(SERVER_FIFO, 0666) == -1) ERROR("");
//    if((server_fd = open(SERVER_FIFO, O_RDONLY)) == -1) ERROR("");
//    if((dummy_fd = open(SERVER_FIFO, O_WRONLY)) == -1) ERROR(""); // dummy可以防止读取到EOF，防止cpu空转
    struct client_info buf;
    ssize_t rd_size;
    sync_global(NULL, &number);
    printf("number = %llu\n", number);
    for(int i = 0 ;; i++) { // dummy可以防止cpu在这里空转
        if((server_fd = open(SERVER_FIFO, O_RDONLY)) == -1) ERROR("");
        printf("i = %d\n", i);
        while ((rd_size = read(server_fd, &buf, sizeof(struct client_info))) > 0) {
            printf("server: handling request from %d,%d\n", buf.pid, buf.incr);
            char *client_fifo = GET_CLIENT_FIFO(buf.pid);
            if(access(client_fifo, F_OK | W_OK) != 0) ERROR_EXIT(goto cleanup_noaction;, "");

            int client_fd;
            if ((client_fd = open(client_fifo, O_WRONLY | O_NONBLOCK)) == -1) ERROR_EXIT(goto cleanup_noaction;, ""); //防止阻塞
            int flag;
            if((flag = fcntl(client_fd, F_GETFL)) == -1) ERROR_EXIT(goto cleanup;, "");
            flag &= ~O_NONBLOCK; // 去掉O_NONBLOCK
            if(fcntl(client_fd, F_SETFL, flag) == -1) ERROR_EXIT(goto cleanup;, ""); // write使用阻塞语义
            sigset_t sigset, oldset;
            if(sigemptyset(&sigset) == -1) ERROR_EXIT(goto cleanup_nomask;, "");
            if(sigemptyset(&oldset) == -1) ERROR_EXIT(goto cleanup_nomask;, "");
            if(sigaddset(&sigset, SIGPIPE) == -1) ERROR_EXIT(goto cleanup_nomask;, "");
            if(sigprocmask(SIG_SETMASK, &sigset, &oldset) == -1) ERROR_EXIT(goto cleanup_nomask;, ""); //写入端没打开，产生SIGPIPE和EPIPE，屏蔽SIGPIPE
            if (write(client_fd, &(unsigned long long int[1]) {number}, sizeof(unsigned long long int[1])) !=
                sizeof(unsigned long long int[1])) ERROR_EXIT(goto cleanup;, "");
            number += buf.incr;
            cleanup:
            if(sigprocmask(SIG_SETMASK, &oldset, NULL) == -1) ERROR_EXIT(goto cleanup;, ""); // 还原
            cleanup_nomask:
            sync_global(&number, NULL);
            close(client_fd);
            cleanup_noaction:
            safe_free(client_fifo);
        }
        sleep(1);
        close(server_fd);
        if(rd_size < 0) ERROR("");
    }
    return 0;
}
void clientdestroy(int sig) {
    printf("client %d, sig:%s\n", getpid(), strsignal(sig));
    unlink(CLIENT_FIFO);
    signal(sig, SIG_DFL);
    raise(sig);
}
int client(int argc, char *argv[]) {
    int client_fd;
    signal(SIGHUP, clientdestroy);
    setbuf(stdout, NULL);
    printf("client %d open\n", getpid());
    if((server_fd = open(SERVER_FIFO, O_WRONLY)) == -1) ERROR("");
    if(mkfifo(CLIENT_FIFO, 0666) == -1) ERROR("");
    struct client_info info = {
            .incr=atoi(argv[1]),
            .pid=getpid()
    };
    printf("client %d write\n", getpid());
    if(write(server_fd, &info, sizeof(struct client_info)) != sizeof(struct client_info)) {
        ERROR("");
    }
    unsigned long long int n;
    printf("client %d read\n", getpid());
    printf("client %d open1\n", getpid());
    if((client_fd = open(CLIENT_FIFO, O_RDONLY)) == -1) ERROR("");
    if(read(client_fd, &n, sizeof(unsigned long long int)) != sizeof(unsigned long long int)) {
        ERROR("");
    }
    printf("client %d get id: %llu\n", getpid(), n);
    close(server_fd);
    close(client_fd);
    unlink(CLIENT_FIFO);
}

int main(int argc, char *argv[]) {
    argv++;
    argc--;
    if(!strcmp("server", argv[0])) {
        server(argc, argv);
    } else if(!strcmp("client", argv[0])) {
        client(argc, argv);
    }
    return 0;
}
```

```sh
killall -HUP practice44.5
../practice44.5 server & > log
for i in `seq 20`; do ../practice44.5 client $i && hexdump global_number_file & done  > log
```

通过分析log可以直到，client容易长期阻塞在对`CLIENT_FIFO`的`open`上，也就是`server`收到请求，但是client没有打开读取端，导致server没有写入返回数据，稍后client阻塞在第二个open上，等待server。
