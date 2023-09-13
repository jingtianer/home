---
title: cha46.System V 消息队列
date: 2023-9-2 19:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 46.2
改造44.8节中的序号客户端-服务器应用程序使之使用System V消息队列。使用单个消息队列来传输客户端到服务器以及服务器到客户端之间的消息。使用 46.8节中介绍的消息类型规范。


```c
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>
#include <sys/msg.h>
#include <sys/ipc.h>
#include <stdbool.h>
#include <stddef.h>
#include <syslog.h>
#include <wait.h>

//#define DEBUG_LEVEL LOG_DEBUG

#ifndef DEBUG_LEVEL
#define DEBUG_LEVEL LOG_INFO
#endif

FILE *logfile = NULL;

void logger(int level, const char *msg, ...) {
    if(level <= DEBUG_LEVEL) {
        va_list fmt;
        va_start(fmt, msg);
        vfprintf(logfile, msg, fmt);
        va_end(fmt);
        fprintf(logfile, "\n");
    }
}
#define COND_RET(x, ret, msg...) \
        do {                     \
            errno = 0;\
            if(!(x)) { \
                if(errno == 0)logger(LOG_ERR, "%s:%d\nunmet condition:\"%s\"\n", __FILE__, __LINE__, #x); \
                else logger(LOG_ERR, "%s:%d\nerror: %s\nunmet condition:\"%s\"\n", __FILE__, __LINE__,strerror(errno), #x); \
                logger(LOG_ERR, msg);                                                                                  \
                logger(LOG_ERR, "\n");                                                                    \
                ret \
            }    \
        } while(0)

#define CHECK(x, msg...) COND_RET(x, return -1;, msg)
#define CHECK_EXIT(x, msg...) COND_RET(x, exit(1);, msg)
#define CHECK_LOG(x, msg...) COND_RET(x, ;, msg)

#define safe_free(ptr) do { if(ptr) { free(ptr); ptr = NULL;} } while(0)

char *alloc_sprintf(const char * __format, ...) {
    va_list fmt;
    va_start(fmt, __format);
    int len = vsnprintf(NULL, 0, __format, fmt);
    va_end(fmt);
    char *str = malloc(len+1);
    COND_RET(str != NULL, return NULL;, "");
    va_start(fmt, __format);
    vsnprintf(str, len+1, __format, fmt);
    va_end(fmt);
    return str;
}


char *MSQ_KEY_FILE = NULL;
#define BUFFER_SIZE 4096
static pid_t SELF_PID = -1;
static int MSG_ID = -1;
#define SERVER_MSG_TYPE 1
#define CLIENT_MSG_TYPE SELF_PID

#define REQ_TOUCH   1
#define REQ_RM      2
#define REQ_CAT     3
#define REQ_LS      4
#define REQ_RDLK    5

#define RET_MORE    0x0001
#define RET_SUCCESS 0x0010

struct ServerReturnType {
    long mtype;
    int msgType;
    char mcontent[BUFFER_SIZE];
};
struct ClientRequestType {
    long mtype;
    int msgType;
    pid_t pid;
    char mcontent[BUFFER_SIZE];
};
#define REQ_SIZE (offsetof(struct ClientRequestType, mcontent) - offsetof(struct ClientRequestType, msgType) + BUFFER_SIZE)
#define RET_SIZE (offsetof(struct ServerReturnType, mcontent) - offsetof(struct ServerReturnType, msgType) + BUFFER_SIZE)
void atexitCloseLogfile(void) {
    logger(LOG_DEBUG, "SERVER: atexitCloseLogfile");
    CHECK_LOG(fclose(logfile) != -1, "");
}

void atexitFreeKeyfile(void) {
    logger(LOG_DEBUG, "SERVER: atexitFreeKeyfile");
    safe_free(MSQ_KEY_FILE);
}

void atexitRMID(void) {
    logger(LOG_DEBUG, "SERVER: atexitRMID");
    CHECK_LOG(msgctl(MSG_ID, IPC_RMID, NULL) != -1, "");
}


void client(const char *filename, int msgType) {
    struct ServerReturnType ret;
    struct ClientRequestType req;

    req.mtype = SERVER_MSG_TYPE;
    req.msgType = msgType;
    req.pid = SELF_PID;
    strcpy(req.mcontent, filename);

    ssize_t send = msgsnd(MSG_ID, &req, REQ_SIZE, 0);
    CHECK_EXIT(send != -1, "");
    do {
        ssize_t recv = msgrcv(MSG_ID, &ret, RET_SIZE, CLIENT_MSG_TYPE, 0);
        CHECK_EXIT(recv != -1, "");
        if(ret.msgType & RET_SUCCESS) {
            printf("oJBk: ");
        } else {
            printf("fail: ");
        }
        printf("%s", ret.mcontent);
    } while (ret.msgType & RET_MORE);
    printf("\n");
}

void waitChild(int sig, siginfo_t *info, void *buf) {
    logger(LOG_DEBUG, "SERVER: received sig:%d(%s)", sig, strsignal(sig));
    if(sig == SIGCHLD)CHECK_LOG(waitpid(info->si_pid, NULL, 0) != -1, "");
}
char *execute(char *cmd, bool *success) {
    *success = false;
    FILE *f = popen(cmd, "r");
    if(!f) {
        logger(LOG_DEBUG, "SERVER: execute, f is NULL");
        free(cmd);
        return NULL;
    }
    char content[BUFFER_SIZE] = {0};
    char *ret = strdup("");
    while (fgets(content, BUFFER_SIZE-1, f) != NULL) {
        char *concat = alloc_sprintf("%s%s", ret, content);
        free(ret);
        ret = concat;
    }
    free(cmd);
    int status = pclose(f);
    *success = WIFEXITED(status) && (WEXITSTATUS(status) == 0);
    logger(LOG_DEBUG, "SERVER: execute success=%d, ret = %s", *success, ret);
    return ret;
}

char *touch(char *filename, bool *success) {
    char *cmd = alloc_sprintf("touch %s 2>&1", filename);
    return execute(cmd, success);
}

char *rm(char *filename, bool *success) {
    char *cmd = alloc_sprintf("rm -rf %s 2>&1", filename);
    return execute(cmd, success);
}

char *ls(char *filename, bool *success) {
    char *cmd = alloc_sprintf("ls %s 2>&1", filename);
    return execute(cmd, success);

}

char *rdlk(char *filename, bool *success) {
    char *cmd = alloc_sprintf("readlink %s 2>&1", filename);
    return execute(cmd, success);

}

char *cat(char *filename, bool *success) {
    char *cmd = alloc_sprintf("cat %s 2>&1", filename);
    return execute(cmd, success);
}

void server_exit(int sig) {
    exit(0);
}

char *splitby(char *mcontent, const char *sep) {
    while (*sep) {
        char *ptr = strchr(mcontent, *sep);
        if(ptr) *ptr = '\0';
        sep++;
    }
    return mcontent;
}

void server() {
    struct sigaction action;
    struct ClientRequestType req;
    action.sa_flags = SA_RESTART;
    CHECK_EXIT(sigemptyset(&action.sa_mask) != -1, "");
    action.sa_sigaction = waitChild;
    CHECK_EXIT(sigaction(SIGCHLD, &action, NULL) != -1, "");
    CHECK_EXIT(atexit(atexitRMID) != -1, "");
    CHECK_EXIT(signal(SIGHUP, server_exit) != SIG_ERR, "");
    CHECK_EXIT(signal(SIGINT, server_exit) != SIG_ERR, "");
    ssize_t msg_len;
    for(;;) {
        memset(&req, 0, sizeof(struct ClientRequestType));
        msg_len = msgrcv(MSG_ID, &req, REQ_SIZE, SERVER_MSG_TYPE,  0);
        if(msg_len == -1) {
            if(errno == EINTR) continue;
            CHECK_EXIT(true, "");
        }
        logger(LOG_DEBUG, "read msg");
        struct ServerReturnType ret;
        sigset_t sigset;
        sigemptyset(&sigset);
        sigaddset(&sigset, SIGCHLD);
        switch (fork()) {
            case -1:
                CHECK_EXIT(false, "");
                break;
            case 0:
                sigprocmask(SIG_SETMASK, &sigset, NULL); // 防止pclose删除消息队列
                memset(&ret, 0, sizeof(struct ServerReturnType));
                ret.mtype = req.pid;
                char *mcontent;
                bool success;
                splitby(req.mcontent, "; |>&");
                switch (req.msgType) {
                    case REQ_TOUCH:
                        mcontent = touch(req.mcontent, &success);
                        break;
                    case REQ_RM:
                        mcontent = rm(req.mcontent, &success);
                        break;
                    case REQ_CAT:
                        mcontent = cat(req.mcontent, &success);
                        break;
                    case REQ_LS:
                        mcontent = ls(req.mcontent, &success);
                        break;
                    case REQ_RDLK:
                        mcontent = rdlk(req.mcontent, &success);
                        break;
                    default:
                        mcontent = alloc_sprintf("unsupported msgType:%d", req.msgType);
                        success = false;
                        break;
                }
                if(success) {
                    ret.msgType = RET_SUCCESS;
                    logger(LOG_DEBUG, "SERVER: success");
                } else {
                    ret.msgType = 0;
                    logger(LOG_DEBUG, "SERVER: fail");
                }
                size_t len = strlen(mcontent);
                char *tcontent = mcontent;
                ret.msgType |= RET_MORE;
                for(int i = 0; i < len/BUFFER_SIZE; i++) {
                    memcpy(ret.mcontent, mcontent, BUFFER_SIZE);
                    CHECK_LOG(msgsnd(MSG_ID, &ret, RET_SIZE, 0) != -1, "");
                    mcontent += BUFFER_SIZE;
                }
                memcpy(ret.mcontent, mcontent, len%BUFFER_SIZE);
                ret.msgType &= ~RET_MORE;
                CHECK_LOG(msgsnd(MSG_ID, &ret, RET_SIZE, 0) != -1, "");
                safe_free(tcontent);
                fflush(NULL);
                _exit(0); // 不要执行atxite注册的函数
                break;
            default:
                break;
        }
    }
}


int main(int argc, char **argv) { //处理参数
    logfile = stderr;
    CHECK(argc > 1, "Usage: %s [server|client] argv...", argv[0]);
    MSQ_KEY_FILE = realpath(strdup(argv[0]), NULL);
    CHECK(atexit(atexitFreeKeyfile) != -1, "");

    SELF_PID = getpid();
    CHECK(SELF_PID != -1, "");

    static key_t __MSG_KEY = -1;
    __MSG_KEY = ftok(MSQ_KEY_FILE, 't');
    CHECK(__MSG_KEY != -1, "");
    MSG_ID = msgget(__MSG_KEY, IPC_CREAT | 0666);
    CHECK(MSG_ID != -1, "");

    if(!strcmp("client", argv[1])) {
        CHECK(argc > 3, "Usage: %s client filename cmd", argv[0]);
        int cmd;
        if(!strcmp(argv[3], "touch")) {
            cmd = REQ_TOUCH;
        } else if(!strcmp(argv[3], "ls")) {
            cmd = REQ_LS;
        } else if(!strcmp(argv[3], "cat")) {
            cmd = REQ_CAT;
        } else if(!strcmp(argv[3], "readlink")) {
            cmd = REQ_RDLK;
        } else if(!strcmp(argv[3], "rm")) {
            cmd = REQ_RM;
        } else {
            cmd = -1;
        }
        client(argv[2], cmd);
    } else if(!strcmp("server", argv[1])) {
        CHECK(true, "Usage: %s server [--daemon=] [--logfile=]", argv[0]);
        bool deamonlize = false;
        char *logfilename = NULL;
        for(int i = 2; i < argc; i++) {
            if(!strncmp("--daemon=", argv[i], 9)) {
                if(!strcmp(argv[i] + 9, "true")) {
                    logger(LOG_DEBUG,"SERVER: daemon");
                    deamonlize = true;
                } else {
                    logger(LOG_DEBUG,"SERVER: non-daemon");
                }
            } else if(!strncmp("--logfile=", argv[i], 10)) {
                logfilename = argv[i] + 10;
                logger(LOG_DEBUG,"SERVER: logfile: %s", logfilename);
            } else {
                logger(LOG_DEBUG, "Unknown argv: %s", argv[i]);
            }
        }
        if(deamonlize) {
            CHECK(daemon(0,0) != -1, "");
        }
        if(logfilename == NULL) {
            logfile = stderr;
        } else {
            int logfileFd;
            CHECK((logfileFd = open(logfilename, O_WRONLY | O_CREAT, 0600)) != -1, "");
            logfile = fdopen(logfileFd, "w");
            CHECK(logfile != NULL, "");
            CHECK(dup2(logfileFd, STDERR_FILENO) != -1, "");
            CHECK(dup2(logfileFd, STDOUT_FILENO) != -1, "");
            CHECK(atexit(atexitCloseLogfile) != -1, "");
        }
        server();
    } else {
        CHECK(false, "Usage: %s [server|client] argv...", argv[0]);
    }
}
```

## 46.3

在46.8节中的客户端-服务器应用程序中客户端为何在消息体(在clientId 字段中)中传递其消息队列的标识符，而不是在消息类型(mtype)中传递?

- clientid有可能为0，mtype不能为0


## 46.4 46.5
对46.8节中的客户端-服务器应用程序做出下列变更。
- 使用IPC_PRIVATE创建，将标识符写入文件中，客户端读取这个文件
- 将错误输出到syslog
- daemon
- 使用信号`SIGTERM`和`SIGINT`创建干净的退出
- 处理客户端过早退出的情况（timer超时）
- 客户端考虑服务端可能出现的错误（如：消息队列满）

```c
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <signal.h>
#include <sys/msg.h>
#include <sys/ipc.h>
#include <stdbool.h>
#include <stddef.h>
#include <syslog.h>
#include <wait.h>


#define DEBUG_LEVEL LOG_DEBUG

#ifndef DEBUG_LEVEL
#define DEBUG_LEVEL LOG_INFO
#endif
FILE *logfile = NULL;
bool syslog_enable = false;

#define alloc_sprintf(__alloc_sprintf_str, __format...) do { \
    int __alloc_sprintf_len = snprintf(NULL, 0, __format); \
    (__alloc_sprintf_str) = malloc(__alloc_sprintf_len+1);                     \
    if(__alloc_sprintf_str != NULL) \
        snprintf(__alloc_sprintf_str, __alloc_sprintf_len+1, __format); \
} while(0)

#define logger(level, msg...) do { \
    if(level <= DEBUG_LEVEL) {     \
        fprintf(logfile, msg); \
        fprintf(logfile, "\n"); \
    } \
    if(syslog_enable) { \
        char *data; \
        alloc_sprintf(data, msg); \
        syslog(level, "%s", data); \
        safe_free(data); \
    } \
} while(0)

#define COND_RET(x, ret, msg...) \
        do {                     \
            if(!(x)) { \
                if(errno == 0)logger(LOG_ERR, "%s:%d\nunmet condition:\"%s\"\n", __FILE__, __LINE__, #x); \
                else logger(LOG_ERR, "%s:%d\nerror: %s\nunmet condition:\"%s\"\n", __FILE__, __LINE__,strerror(errno), #x); \
                logger(LOG_ERR, msg);                                                                                  \
                logger(LOG_ERR, "\n");                                                                    \
                ret \
            }    \
        } while(0)

#define CHECK(x, msg...) COND_RET(x, return -1;, msg)
#define CHECK_EXIT(x, msg...) COND_RET(x, exit(EXIT_FAILURE);, msg)
#define CHECK_LOG(x, msg...) COND_RET(x, ;, msg)

#define safe_free(__safe_free_ptr) do { if(__safe_free_ptr) { free(__safe_free_ptr); (__safe_free_ptr) = NULL;} } while(0)


#define BUFFER_SIZE 4096
static pid_t SELF_PID = -1;
static int MSG_ID = -1;
#define SERVER_MSG_TYPE 1
#define CLIENT_MSG_TYPE SELF_PID

#define REQ_TOUCH   1
#define REQ_RM      2
#define REQ_CAT     3
#define REQ_LS      4
#define REQ_RDLK    5

#define RET_MORE    0x0001
#define RET_SUCCESS 0x0010

#define SERVER_MSG_FILE "SERVER_MSG_FILE-Meow"

struct ServerReturnType {
    long mtype;
    int msgtype;
    char mcontent[BUFFER_SIZE];
};
struct ClientRequestType {
    long mtype;
    int msqid;
    char mcontent[BUFFER_SIZE];
};
#define REQ_SIZE (offsetof(struct ClientRequestType, mcontent) - offsetof(struct ClientRequestType, msqid) + BUFFER_SIZE)
#define RET_SIZE (offsetof(struct ServerReturnType, mcontent) - offsetof(struct ServerReturnType, msgtype) + BUFFER_SIZE)

void atexitWorker(int status, void *arg) {
    if(WIFEXITED(status) && (WEXITSTATUS(status) == EXIT_SUCCESS)) return;
    struct ClientRequestType *req = arg;
    logger(DEBUG_LEVEL, "worker atexitWorker");
    CHECK_LOG(msgctl(req->msqid, IPC_RMID, NULL) != -1, "");
}

void atexitCloseLogfile(int status, void *arg) {
    if(!*(bool *)arg) return;
    logger(LOG_DEBUG, "SERVER: atexitCloseLogfile");
    CHECK_LOG(fclose(logfile) != -1, "");
    logfile = stderr;
}
void atexitCloseLog(int status, void *arg) {
    if(!*(bool *)arg) return;
    logger(LOG_DEBUG, "SERVER: atexitCloseLog");
    closelog();
}
void atexitRMID(int status, void *arg) {
    if(!*(bool *)arg) return;
    logger(LOG_DEBUG, "SERVER: atexitRMID");
    CHECK_LOG(unlink(SERVER_MSG_FILE) != -1, "");
    CHECK_LOG(msgctl(MSG_ID, IPC_RMID, NULL) != -1, "");
}

void clientAtexitRMID(int status, void *arg) {
    logger(LOG_DEBUG, "CLIENT: atexitRMID");
    CHECK_LOG(msgctl(MSG_ID, IPC_RMID, NULL) != -1, "");
}

void client(const char *filename, int msgType) {
    on_exit(clientAtexitRMID, NULL);
    int SERVER_MSG_ID = -1;
    int server_msg_id = open(SERVER_MSG_FILE, O_EXCL | O_RDONLY);
    CHECK_EXIT(server_msg_id != -1, "");
    CHECK_EXIT(read(server_msg_id, &SERVER_MSG_ID, sizeof(int)) == sizeof(int), "");
    close(server_msg_id);
    struct ServerReturnType ret;
    struct ClientRequestType req;

    req.mtype = msgType;
    req.msqid = MSG_ID;
    strcpy(req.mcontent, filename);

    ssize_t send = msgsnd(SERVER_MSG_ID, &req, REQ_SIZE, IPC_NOWAIT);
    CHECK_EXIT(send != -1, "");
    do {
        ssize_t recv = msgrcv(MSG_ID, &ret, RET_SIZE, 0, 0);
        CHECK_EXIT(recv != -1, "");
        if(ret.msgtype & RET_SUCCESS) {
            printf("oJBk: ");
        } else {
            printf("fail: ");
        }
        printf("%s", ret.mcontent);
    } while (ret.msgtype & RET_MORE);
    printf("\n");
}

void waitChild(int sig, siginfo_t *info, void *buf) {
    logger(LOG_DEBUG, "SERVER: received sig:%d(%s)", sig, strsignal(sig));
    int savedErrno = errno;
    if(sig == SIGCHLD)CHECK_LOG(waitpid(-1, NULL, WNOHANG) != -1, ""); // 等所有吧
    errno = savedErrno;
}
char *execute(char *cmd, bool *success) {
    *success = false;
    FILE *f = popen(cmd, "r");
    if(!f) {
        logger(LOG_DEBUG, "SERVER: execute, f is NULL");
        free(cmd);
        return NULL;
    }
    char content[BUFFER_SIZE] = {0};
    char *ret = strdup("");
    while (fgets(content, BUFFER_SIZE-1, f) != NULL) {
        char *concat;
        alloc_sprintf(concat, "%s%s", ret, content);
        free(ret);
        ret = concat;
    }
    free(cmd);
    int status = pclose(f);
    *success = WIFEXITED(status) && (WEXITSTATUS(status) == 0);
    logger(LOG_DEBUG, "SERVER: execute success=%d, ret = %s", *success, ret);
    return ret;
}

char *touch(char *filename, bool *success) {
    char *cmd;
    alloc_sprintf(cmd, "touch %s 2>&1", filename);
    return execute(cmd, success);
}

char *rm(char *filename, bool *success) {
    char *cmd;
    alloc_sprintf(cmd, "rm -rf %s 2>&1", filename);
    return execute(cmd, success);
}

char *ls(char *filename, bool *success) {
    char *cmd;
    alloc_sprintf(cmd, "ls %s 2>&1", filename);
    return execute(cmd, success);

}

char *rdlk(char *filename, bool *success) {
    char *cmd;
    alloc_sprintf(cmd, "readlink %s 2>&1", filename);
    return execute(cmd, success);

}

char *cat(char *filename, bool *success) {
    char *cmd;
    alloc_sprintf(cmd, "cat %s 2>&1", filename);
    return execute(cmd, success);
}

void server_exit(int sig) {
    exit(0);
}

char *splitby(char *mcontent, const char *sep) {
    while (*sep) {
        char *ptr = strchr(mcontent, *sep);
        if(ptr) *ptr = '\0';
        sep++;
    }
    return mcontent;
}

bool is_server = false;
int task_timeout = 20;
void workerTimeout(int sig) {
    logger(LOG_DEBUG, "WORKER: received sig:%d(%s), work timeout!", sig, strsignal(sig));
    fflush(NULL);
    exit(EXIT_FAILURE);
}
void server() {
    is_server = true;
    int server_msg_id = open(SERVER_MSG_FILE, O_CREAT | O_EXCL | O_RDONLY | O_FSYNC | O_WRONLY, 0666);
    CHECK_EXIT(server_msg_id != -1, "");
    CHECK_EXIT(write(server_msg_id, &MSG_ID, sizeof(int)) == sizeof(int), "");
    close(server_msg_id);

    struct sigaction action;
    struct ClientRequestType req;
    action.sa_flags = SA_RESTART;
    CHECK_EXIT(sigemptyset(&action.sa_mask) != -1, "");
    action.sa_sigaction = waitChild;
    CHECK_EXIT(sigaction(SIGCHLD, &action, NULL) != -1, "");
    CHECK_EXIT(on_exit(atexitRMID, &is_server) != -1, "");
    CHECK_EXIT(signal(SIGHUP, server_exit) != SIG_ERR, "");
    CHECK_EXIT(signal(SIGINT, server_exit) != SIG_ERR, "");
    CHECK_EXIT(signal(SIGTERM, server_exit) != SIG_ERR, "");
    ssize_t msg_len;
    for(;;) {
        memset(&req, 0, sizeof(struct ClientRequestType));
        msg_len = msgrcv(MSG_ID, &req, REQ_SIZE, 0,  0);
        if(msg_len == -1) {
            if(errno == EINTR) continue;
            CHECK_EXIT(false, "");
        }
        logger(LOG_DEBUG, "read msg");
        struct ServerReturnType ret;
        sigset_t sigset;
        sigemptyset(&sigset);
        sigaddset(&sigset, SIGCHLD);
        switch (fork()) {
            case -1:
                CHECK_EXIT(false, "");
                break;
            case 0:
                is_server = false;
                sigprocmask(SIG_SETMASK, &sigset, NULL); // 防止pclose删除消息队列
                memset(&ret, 0, sizeof(struct ServerReturnType));
                ret.mtype = 1;
                char *mcontent;
                bool success;
                splitby(req.mcontent, "; |>&");
                on_exit(atexitWorker, &req);
                CHECK_EXIT(signal(SIGALRM, workerTimeout) != SIG_ERR, "");
                CHECK_EXIT(alarm(task_timeout) != -1, "");
                switch (req.mtype) {
                    case REQ_TOUCH:
                        mcontent = touch(req.mcontent, &success);
                        break;
                    case REQ_RM:
                        mcontent = rm(req.mcontent, &success);
                        break;
                    case REQ_CAT:
                        mcontent = cat(req.mcontent, &success);
                        break;
                    case REQ_LS:
                        mcontent = ls(req.mcontent, &success);
                        break;
                    case REQ_RDLK:
                        mcontent = rdlk(req.mcontent, &success);
                        break;
                    default:
                        alloc_sprintf(mcontent, "unsupported msgType:%ld", req.mtype);
                        success = false;
                        break;
                }
                if(success) {
                    ret.msgtype = RET_SUCCESS;
                    logger(LOG_DEBUG, "SERVER: success");
                } else {
                    ret.msgtype = 0;
                    logger(LOG_DEBUG, "SERVER: fail");
                }
                size_t len = strlen(mcontent);
                char *tcontent = mcontent;
                ret.msgtype |= RET_MORE;
                for(int i = 0; i < len/BUFFER_SIZE; i++) {
                    memcpy(ret.mcontent, mcontent, BUFFER_SIZE);
                    CHECK_LOG(msgsnd(req.msqid, &ret, RET_SIZE, 0) != -1, "");
                    mcontent += BUFFER_SIZE;
                }
                memcpy(ret.mcontent, mcontent, len%BUFFER_SIZE);
                ret.msgtype &= ~RET_MORE;
                CHECK_LOG(msgsnd(req.msqid, &ret, RET_SIZE, 0) != -1, "");

                CHECK_EXIT(alarm(0) != -1, ""); //cancel
                safe_free(tcontent);
                fflush(NULL);
                exit(EXIT_SUCCESS);
                break;
            default:
                break;
        }
    }
}


int main(int argc, char **argv) { //处理参数
    logfile = stderr;
    CHECK(argc > 1, "Usage: %s [server|client] argv...", argv[0]);

    SELF_PID = getpid();
    CHECK(SELF_PID != -1, "");

    MSG_ID = msgget(IPC_PRIVATE, 0666);
    CHECK(MSG_ID != -1, "");

    if(!strcmp("client", argv[1])) {
        CHECK(argc > 3, "Usage: %s client filename cmd", argv[0]);
        int cmd;
        if(!strcmp(argv[3], "touch")) {
            cmd = REQ_TOUCH;
        } else if(!strcmp(argv[3], "ls")) {
            cmd = REQ_LS;
        } else if(!strcmp(argv[3], "cat")) {
            cmd = REQ_CAT;
        } else if(!strcmp(argv[3], "readlink")) {
            cmd = REQ_RDLK;
        } else if(!strcmp(argv[3], "rm")) {
            cmd = REQ_RM;
        } else {
            cmd = -1;
        }
        client(argv[2], cmd);
    } else if(!strcmp("server", argv[1])) {
        CHECK(true, "Usage: %s server [--daemon=true|false] [--logfile=] [--syslog=true|false] [--timeout=number]", argv[0]);
        bool deamonlize = false;
        char *logfilename = NULL;
        for(int i = 2; i < argc; i++) {
            if(!strncmp("--daemon=", argv[i], 9)) {
                if(!strcmp(argv[i] + 9, "true")) {
                    logger(LOG_DEBUG,"SERVER: daemon");
                    deamonlize = true;
                } else {
                    logger(LOG_DEBUG,"SERVER: non-daemon");
                }
            } else if(!strncmp("--logfile=", argv[i], 10)) {
                logfilename = argv[i] + 10;
                logger(LOG_DEBUG,"SERVER: logfile: %s", logfilename);
            } else if(!strncmp("--syslog=", argv[i], 9)) {
                if(!strcmp(argv[i] + 9, "true")) {
                    syslog_enable = true;
                    openlog(argv[0], LOG_CONS|LOG_PID, LOG_USER);
                    on_exit(atexitCloseLog, &is_server);
                    logger(LOG_DEBUG,"SERVER: enable-syslog");
                } else {
                    logger(LOG_DEBUG,"SERVER: disable-syslog");
                }
            } else if(!strncmp("--timeout=", argv[i], 10)) {
                logger(LOG_DEBUG, "timeout: %s", argv[i]);
                task_timeout = atoi(argv[i] + 10);
            } else {
                logger(LOG_DEBUG, "Unknown argv: %s", argv[i]);
            }
        }
        if(deamonlize) {
            CHECK(daemon(1,0) != -1, "");
        }
        if(logfilename != NULL) {
            int logfileFd;
            if(access(logfilename, F_OK)) {
                unlink(logfilename);
            }
            CHECK((logfileFd = open(logfilename, O_WRONLY | O_CREAT | O_APPEND, 0600)) != -1, "");
            logfile = fdopen(logfileFd, "w");
            setlinebuf(logfile);
            CHECK(logfile != NULL, "");
            CHECK(dup2(logfileFd, STDERR_FILENO) != -1, "");
            CHECK(dup2(logfileFd, STDOUT_FILENO) != -1, "");
            CHECK(on_exit(atexitCloseLogfile, &is_server) != -1, "");
        }
        server();
    } else {
        CHECK(false, "Usage: %s [server|client] argv...", argv[0]);
    }
}
```