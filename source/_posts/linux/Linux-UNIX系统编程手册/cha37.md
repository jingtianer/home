---
title: cha37.DAEMON
date: 2023-8-1 12:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 37.1

编写一个使用syslog(3)的程序(与logger(1)类似)来将任意的消息写入到系统日志
文件中。程序应该接收包含如记录到日志中的消息的命令行参数，同时应该允许指
定消息的level。

```c
//
// Created by root on 7/24/23.
//

#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <sys/stat.h>
#include <limits.h>
#include <sys/resource.h>
#include <syslog.h>

volatile int init = 0;

void restart(int sig) {
    if(init) {
        closelog();
        printf("restart\n");
    }
    openlog("meow", LOG_CONS|LOG_NDELAY|LOG_PID, LOG_USER);
    init = 1;
}

#define min(x, y) ((x) < (y) ? (x) : (y))

#define CHECK_WITH_RET(x, ret, format, ...) \
        do {     \
            if(!(x)) { \
                fprintf(stderr, format, __VA_ARGS__); \
                ret         \
            }    \
        } while(0)

#define CHECK(x)        CHECK_WITH_RET(x, return -1;, "%s:%d\nerror: %s\nunmet condition:\"%s\"\n", __FILE__, __LINE__,strerror(errno), #x)
#define CONDITION(x)    CHECK_WITH_RET(x, exit(2);, "%s:%d\nunmet condition:\"%s\"\n", __FILE__, __LINE__, #x)
#define CHECKMAIN(x)    CHECK_WITH_RET(x, exit(1);, "%s:%d\nerror: %s\nunmet condition:\"%s\"\n", __FILE__, __LINE__,strerror(errno), #x)

int makeDaemon() {
    pid_t pid;
    switch ((pid = fork())) {
        case -1:
            CHECK(0);
        case 0:
            break;
        default:
            printf("pid:%ld\n", (long)pid);
            _exit(0);
    }
    CHECK(setsid() != -1);
    CHECK(umask(0) != -1);
    CHECK(chroot("/") != -1);
    int nullfd = open("/dev/null", O_RDWR);
    CHECK(nullfd != -1);
    CHECK(dup2(nullfd, STDIN_FILENO) != -1);
    CHECK(dup2(nullfd, STDOUT_FILENO) != -1);
    CHECK(dup2(nullfd, STDERR_FILENO) != -1);
    CHECK(close(nullfd) != -1);
    long fdmax = sysconf(_SC_OPEN_MAX);
    struct rlimit rlimit;
    CHECK(getrlimit(RLIMIT_NOFILE, &rlimit) != -1);
    for(int fdi = 0; fdi < min(fdmax, rlimit.rlim_cur); fdi++) {
        close(fdi);
    }
    CHECK(signal(SIGHUP, restart) != SIG_ERR);
    return 0;
}

struct logmesg {
    int level;
    char *str;
};

int main(int argc, char **argv) {
    printf("pid:%ld\n", (long)getpid());
    CHECKMAIN(makeDaemon() != -1);
    printf("pid:%ld\n", (long)getpid());
    restart(SIGHUP);
    CHECKMAIN(signal(SIGHUP, restart) != SIG_ERR);
    CONDITION(argc >= 3);
    struct logmesg *data = malloc(sizeof(struct logmesg));
    data->level = atoi(argv[1]);
    CONDITION(data->level >= 0 && data->level <= 7);
    int strlen = 0;
    for(char **argvi = &argv[2]; *argvi; argvi++) {
        strlen += snprintf(NULL, 0, "%s %s", (char *)NULL, *argvi);
    }
    char *str  = malloc(strlen + 1);

    for(char **argvi = &argv[2]; *argvi; argvi++) {
        strlen += sprintf(str, "%s %s",str, *argvi);
    }
    data->str = str+1;
    syslog(data->level, "%s", data->str);
    printf("syslog: %s\n", data->str);
    closelog();
}
```

不及丢为什么，syslog.conf中配置的东西打印不出来

