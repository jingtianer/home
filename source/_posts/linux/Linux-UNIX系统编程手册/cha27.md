---
title: cha27.进程执行
date: 2023-6-20 18:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## exec()

- 带e的可以指定环境变量，否则继承
- 带p的允许只提供文件名，允许提供不带`"/"`的路径，在path中寻找
  - 若无`env PATH`默认为`.:/usr/bin/:/bin`
  - 从左往右搜索，直到找到为止
- 带l的用不定长参数（参数列表），以NULL结尾
  - execle在NULL后面接envp数组

## exec执行脚本

当exec第一个参数文件以`"#!"`开始，则会读取该行进行解析

```sh
#!<interpreter-path> [arg] <script> <script-args...> 
```

如
```sh
#!/bin/bash --debug
```

若
```c
execl("xxx.sh", "argv1", "argv2", ..., NULL);
```

则实际调用为

```c
execl("/bin/bash", "--debug", "xxx.sh", "argv1", "argv2", ..., NULL);
```

```sh
#!/bin/awk -f
```

## 信号与exec

exec时，会将设置了信号处理器函数的信号置为SIG_DFL，将SA_ONSTACK位清除

但是对于置为SIG_IGN的SIGCHLD是否会置为SIG_DFL，susv3并未规定

信号掩码（就是SA_INFO， SA_NODEFER那些东西）与挂起信号的设置会被保存

## 27.1

```sh
export PATH=/usr/local/bin:/usr/bin:/bin/:./dir1:./dir2
ls -l dir1
-rw-r--r-- 1 mtk users 7860 Jun 13 11:55 xyz
ls -l dir2
-rwxr-xr-x 1 mtk users 27860 Jun 13 11:55 xyz
xyz # 执行这里，结果如何？
```

执行失败？搜索到dir1下，但是没有执行权限？

## 结果
执行成功，访问到dir2下的xyz

## 27.2

用execve实现execlp
```c
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdarg.h>
#include <errno.h>
#include <stdarg.h>
#include <stdlib.h> 

extern char **environ;
#define CHECK(x) do { \
                    if(!(x)) { \
                        fprintf(stderr, "CHECK: %s\n", strerror(errno)); \
                        exit(1); \
                    } \
                  } while(0);
int _execlp(const char *file, const char *args, ...) {
    
    const int malloc_step = 128;
    unsigned int args_size = malloc_step;
    const char **arglist = malloc(sizeof(const char *) * args_size);
    CHECK(arglist != NULL);
    const char **arglist_ptr = arglist;
    const char **arglist_endptr = arglist + args_size;
    va_list va_args;
    *(arglist_ptr++) = args;
    va_start(va_args, args);
    while((*(arglist_ptr++) = va_arg(va_args, const char *)) != NULL) {
        if(arglist_ptr == arglist_endptr) {
            args_size += malloc_step;
            unsigned offset = arglist_ptr - arglist;
            arglist = realloc(arglist, args_size);
            CHECK(arglist != NULL);
            arglist_ptr = arglist + offset;
        }
    }
    va_end(va_args);
    char *end;
    if(strchr(file, '/') != NULL) {
        execve(file, arglist, environ);
        free(arglist);
        CHECK(0);
        return -1;
    }
    
    char *path = getenv("PATH");
    if(path) {
        path = strdup(path);
    } else {
        path = strdup(".:/usr/bin:/bin");
    }
    char *path_ptr = path;
    while((end = strchr(path, ':')) != NULL || (end = strchr(path, '\0')) != NULL) {
        if(end == path) {
            break;
        }
        *end = '\0';
        int len = snprintf(NULL, 0, "%s/%s", path, file);
        CHECK(len >= 0);
        char *target = malloc(len+1);
        snprintf(target, len+1, "%s/%s", path, file);
        printf("try exec: %s\n", target);
        execve(target, arglist, environ);
        CHECK(errno == ENOENT); // ENOENT调用失败只能是由于文件不存在
        path = end+1;
        free(target);
    }
    free(path_ptr);
    free(arglist);
    return -1;
}

int main(int argc, char **argv) {
    switch(argc) {
        case 2:
            _execlp(argv[1], argv[1], NULL);
            break;
        case 3:
            _execlp(argv[1], argv[1], argv[1], argv[2], NULL);
            break;
        case 4:
            _execlp(argv[1], argv[1], argv[1], argv[2], argv[3], NULL);
            break;
        case 5:
            _execlp(argv[1], argv[1], argv[1], argv[2], argv[3], argv[4], NULL);
            break;
        case 6:
            _execlp(argv[1], argv[1], argv[2], argv[3], argv[4], argv[5], NULL);
            break;
        default:
            printf("not support arg num: %d\n", argc);
            break;
    }
    return 0;
}
```

## 27.3
27-3.如果赋予如下脚本可执行权限并以exec()运行，输出结果如何?
```shell
#!/bin/cat -n
Hello world
```
打印文件内容并显示行号

## 27.4
下列代码会有什么效果?在何种情况下会起作用?
```c
childPid = fork();
if (childPid == -1)
  errExit( "fork1");
if (childPid == 0){/* Child*/
  switch (fork()){
  case -1: errExit("fork2");
    /* Grandchild*/
  case 0:
    /*----- Do real work here ----- */
    exit(EXIT_SUCCESS); /* After doing real work*/
  default:
    exit(EXIT_SUCCESS);
    /*Make grandchild an orphan*/
  }
}
/* Parent falls through to here*/
if (waitpid(childPid，&status, 0) == -1)
  errExit("waitpid");
/* Parent carries on to do other things*/
```

创建一个孤儿进程，执行真正的任务

作用：比如创建服务器的守护进程


## 27.5

27-5.运行如下程序时无输出。试问原因何在?
```c
int main(int argc,char *argv[]){
  printf("Hello world");
  execlp("sleep" , "sleep" ,"o",(char *) NULL);
}

```

还没有fflush，stdio的缓存还未写入系统的缓冲（因为printf没加`'\n'`），进程就被替换了。

## 27.6

假设父进程为信号SIGCHLD创建了一处理器程序,同时阻塞该信号。随后，其某一子进程退出，父进程接着执行 wait)以获取该子进程的状态。当父进程解除对SIGCHLD的阻塞时，会发生什么?编写一个程序来验证答案。这一结果与调用system()函数的程序之间有什么关联?

```c
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>
#include <stdarg.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <errno.h>

int fwritef(int fd, const char *fmt, ...) {
    va_list vl;
    va_start(vl, fmt);
    int n = vsnprintf(NULL, 0, fmt, vl);
    va_end(vl);
    if(n < 0) return -1;
    char *out = malloc(n+1);
    if(!out) return -1;
    va_start(vl, fmt);
    vsnprintf(out, n+1, fmt, vl);
    va_end(vl);
    int ret = 0;
    if(write(fd, out, n) != n) {
        ret = -1;
    }
    free(out);
    return ret;
}
#define CHECK(x) do { \
                        if(!(x)) { \
                            fwritef(STDERR_FILENO, "error: %s\n", strerror(errno));     \
                            _exit(1); \
                        }      \
                    } while(0)

void sigchld_handler(int sig) {
    fwritef(STDOUT_FILENO, "sigchld_handler: child exit, sig = %d, %s\n", sig, strsignal(sig));
}

void sigusr1_hander(int sig) {
    pid_t pid = wait(NULL);
    fwritef(STDOUT_FILENO, "wait child, %d\n", pid);
    sigset_t sigset;
    CHECK(sigemptyset(&sigset) == 0);
    CHECK(sigaddset(&sigset, SIGCHLD) == 0);
    CHECK(sigprocmask(SIG_UNBLOCK, &sigset, NULL) == 0);
}

int main() {
    if(sigaction(SIGCHLD, &(struct sigaction) {
        .sa_handler=sigchld_handler
    }, NULL) == -1) return 1;

    if(sigaction(SIGUSR1, &(struct sigaction) {
            .sa_handler=sigusr1_hander
    }, NULL) == -1) return 1;
    sigset_t sigset;
    CHECK(sigemptyset(&sigset) == 0);
    CHECK(sigaddset(&sigset, SIGCHLD) == 0);
    CHECK(sigprocmask(SIG_BLOCK, &sigset, NULL) == 0);
    pid_t pid = fork();
    if(!pid) {
        kill(getppid(), SIGUSR1);
        fwritef(STDOUT_FILENO, "child: exit\n");
        exit(0);
    } else {
        sleep(100);
    }
    return 0;
}
```

收到一个非常正常的信号
和system的关联是，，system也是这么实现的？？

