---
title: cha40.登录记账
date: 2023-8-24 12:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 40-1 40-4

- 实现getlogin0。在40.5节中曾提到过当进程运行在一些软件终端模拟器下时getlogin0可能无法正确工作，在那种情况下就在虚拟控制台中进行测试。

- 实现一个简单的who(1)。

```c
//
// Created by root on 8/23/23.
//
#define _GNU_SOURCE
#include <stdio.h>
#include <unistd.h>
#include <utmpx.h>
#include <string.h>
#include <time.h>

char *__getlogin() {
    static char login[__UT_NAMESIZE];
    char *tty = ttyname(0);
    if(tty) tty++;
    tty=strchr(tty, '/');
    if(tty) tty++;
    printf("tty=%s\n", tty);
    size_t ttylen = strlen(tty);
    struct utmpx *ut;
    setutxent();
    while((ut = getutxent()) != NULL) {
        printf("type:\t%s\nline:\t%s\nuser:\t%s\nhost:\t%s\ntime:\t%s\n\n",
            ut->ut_type == EMPTY         ? "EMPTY"         :
            ut->ut_type == RUN_LVL       ? "RUN_LVL"       :
            ut->ut_type == BOOT_TIME     ? "BOOT_TIME"     :
            ut->ut_type == NEW_TIME      ? "NEW_TIME"      :
            ut->ut_type == OLD_TIME      ? "OLD_TIME"      :
            ut->ut_type == INIT_PROCESS  ? "INIT_PROCESS"  :
            ut->ut_type == USER_PROCESS  ? "USER_PROCESS"  :
            ut->ut_type == DEAD_PROCESS  ? "DEAD_PROCESS"  :
            ut->ut_type == LOGIN_PROCESS ? "LOGIN_PROCESS" : "unknown",
            ut->ut_line, ut->ut_user, ut->ut_host, ctime((time_t *)&ut->ut_tv.tv_sec)
        );
        if(!strncmp(tty, ut->ut_line, ttylen) &&
            (ut->ut_type == INIT_PROCESS ||
            ut->ut_type == USER_PROCESS ||
            ut->ut_type == LOGIN_PROCESS)) {
            strcpy(login, ut->ut_user);
        }
    }
    endutxent();
    return login;
}

int main() {
    printf("getlogin=%s\n", getlogin());
    printf("getlogin=%s\n", __getlogin());
}
```

## 40-2 40-3
- 修改程序清单40-3中的程序(utmpx loginc)使它除了更新utmp和wtmp文件之外还更新lastlog文件。
- 阅读login(3)、logout(3)以及logwtmp(3)的手册。实现这些函数

```c
//
// Created by root on 8/24/23.
//
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <stdlib.h>
#include <utmpx.h>
#include <stdarg.h>
#include <time.h>
#include <paths.h>
#include <wait.h>
#include <lastlog.h>
#include <pwd.h>
#include <fcntl.h>
#include <pwd.h>
#include <crypt.h>
#include <shadow.h>

void error(const char *file, int line,const char *str, ...) {
    va_list fmt;
    va_start(fmt, str);
    fprintf(stderr, "error:%s %s:%d\n", strerror(errno), file, line);
    vfprintf(stderr, str, fmt);
    fprintf(stderr, "\n");
    va_end(fmt);
}

#define ERROR(...) do { error(__FILE__, __LINE__, __VA_ARGS__); exit(1); } while(0)
#define FAIL(...) do { error(__FILE__, __LINE__, __VA_ARGS__); return -1; } while(0)

char *alloc_sprintf(const char * __format, ...) {
    va_list fmt;
    va_start(fmt, __format);
    int len = vsnprintf(NULL, 0, __format, fmt);
    va_end(fmt);
    char *str = malloc(len+1);
    if(str == NULL) ERROR("");
    va_start(fmt, __format);
    vsnprintf(str, 0, __format, fmt);
    va_end(fmt);
    return str;
}

int tmpxlog(struct utmpx *ut, const char *user, const char *ttyName) {
    memset(ut, 0, sizeof(struct utmpx));
    ut->ut_type = USER_PROCESS;
    strncpy(ut->ut_user, user, sizeof(ut->ut_user));
    if(time((time_t *)&ut->ut_tv.tv_sec) == -1) {
        ERROR("");
    }
    ut->ut_pid = getpid();
    strcpy(ut->ut_line, ttyName + 5);
    strcpy(ut->ut_id, ttyName + 8);
    strcpy(ut->ut_host, "meow-bash");
    setutxent();
    if(pututxline(ut) == NULL) ERROR("");
    updwtmpx(_PATH_WTMP, ut);
    return 0;
}

int lastlog(uid_t uid, const char *ttyName) {
    struct lastlog lastlog = {
            .ll_host="meow-bash"
    };
    strcpy(lastlog.ll_line, ttyName + 5);
    if(time((time_t *)&lastlog.ll_time) == -1) {
        ERROR("");
    }
    int lstlogfd = open(_PATH_LASTLOG, O_RDWR);
    if(lseek(lstlogfd, uid * sizeof(struct lastlog), SEEK_SET) == -1) ERROR("");
    if(write(lstlogfd, &lastlog, sizeof(struct lastlog)) != sizeof(struct lastlog)) ERROR("");
    close(lstlogfd);
    return 0;
}

int tmpxlogout(struct utmpx *ut) {
    ut->ut_type = DEAD_PROCESS;
    if(time((time_t *)&ut->ut_tv.tv_sec) == -1) {
        ERROR("");
    }
    strncpy(ut->ut_user, "", sizeof(ut->ut_user));
    setutxent();
    if(pututxline(ut) == NULL) ERROR("");
    updwtmpx(_PATH_WTMP, ut);
    endutxent();
    return 0;
}

int checkpwd(const char *username) {
    char *shadow = NULL;
    struct passwd *usrpwd;
    if((usrpwd = getpwnam(username)) == NULL) FAIL("username:%s not found", username);
    shadow = usrpwd->pw_passwd;
    char *pass = getpass("Password: ");
    if(!strcmp(shadow, "x")) {
        struct spwd *shadowpwd;
        if((shadowpwd = getspnam(username)) == NULL) FAIL("shadowpwd not found");
        shadow = shadowpwd->sp_pwdp;
        pass = crypt(pass, shadow);
    }
    if(strcmp(shadow, pass) == 0) FAIL("password not match!");
    return 0;
}

char *user = NULL;

int init_check(int argc, char *argv[]) {
    if(argc < 2) {
        user = malloc(2048);
        char hostname[2048];
        gethostname(hostname, 2048);
        printf("%s login: ", hostname);
        scanf("%s", user);
    } else {
        user = strdup(argv[1]);
    }
    if(getuid() != 0) {
        ERROR("uid must be 0\n");
    }
}

int main(int argc, char *argv[]) {
    struct utmpx ut;
    char *homedir = NULL;
    uid_t uid;
    struct passwd *passwd = NULL;
    char *ttyName = ttyname(0);
    if(ttyName == NULL) {
        ERROR("");
    }

    init_check(argc, argv);

    if(checkpwd(user) == -1) ERROR("");

    passwd = getpwnam(user);
    uid = passwd->pw_uid;
    homedir = alloc_sprintf("%s/.bashrc", passwd->pw_dir);

    tmpxlog(&ut, user, ttyName);
    lastlog(uid, ttyName);
    printf("meow-meow-bash login\n");

    fflush(NULL);
    switch (fork()) {
        case -1:
            ERROR("");
            break;
        case 0:
            setuid(uid);
            if(execlp("/bin/bash", "/bin/bash", "--init-file", homedir, NULL) == -1) {
                ERROR("");
            }
            break;
        default:
            wait(NULL);
            break;
    }
    tmpxlogout(&ut);
    printf("meow-meow-bash logout\n");
    free(homedir);
    free(user);
}
```