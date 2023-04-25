---
title: cha12.系统和进程信息
date: 2023-4-24 18:05:00
tags: 
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 12.1
编写一个程序，以用户名作为命令行参数，列表显示该用户下所有正在运行的进程ID和命令名。（程序清单8-1中的userldFromName()函数对本题程序的编写可能会有所帮助。）通过分析系统中/proc/PID/status文件的 Name:和 Uid:各行信息，可以实现此功能。遍历系统的所有/proc/PID目录需要使用readdir(3)函数，18.8节对其进行了描述。程序必须能够正确处理如下可能性:在确定目录存在与程序尝试打开相应/proc/PID/status文件之间，/proc/PID目录消失了。

```c
#include <unistd.h>
#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <pwd.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/types.h>   
#include <unistd.h>
#include <limits.h>

uid_t getUid(const char * user) {
    errno = 0;
    struct passwd *ret = getpwnam(user);
    if(ret == NULL) {
        fprintf(stderr, "ERROR: fail to get uid of user '%s'\n", user);
        exit(1);
    }
    return ret->pw_uid;
}

int get_pid_max() {
    FILE *pid_max = fopen("/proc/sys/kernel/pid_max", "r");
    int ret = -1;
    fscanf(pid_max, "%d", &ret);
    fclose(pid_max);
    if(ret == -1) {
        fprintf(stderr, "Error: fail to read /proc/sys/kernel/pid_max\n");
        exit(3);
    }
    return ret;
}

int main(int argc, char **argv) {
    if(argc < 2 || strcmp(argv[1], "-help") == 0) {
        fprintf(stderr, "Usage: user list [-help]\n");
        exit(0);
    }
    pid_t pid_max = get_pid_max();
    uid_t *uidlist = (uid_t *)alloca(argc * sizeof(uid_t));
    pid_t **uid2pids = (pid_t **)alloca(argc * sizeof(pid_t*));
    for(int i = 1; i < argc; i++) {
        uidlist[i] = getUid(argv[i]);
        uid2pids[i] = (pid_t *)alloca((pid_max + 1) * sizeof(pid_t));
        uid2pids[i][0] = 0;
    }
    DIR *proc = opendir("/proc");
    if(proc == NULL) {
        fprintf(stderr, "ERROR: fail to read /proc: %s\n", strerror(errno));
        exit(1);
    }
    struct dirent *proc_rent = NULL;
    while((proc_rent = readdir(proc)) != NULL) {
        const char *spid = proc_rent->d_name;
        char *end;
        errno = 0;
        pid_t pid = strtol(spid, &end, 10);
        if(end == spid || *end != '\0' || errno != 0) {
            fprintf(stderr, "INFO: %s/%s is not a pid\n", "/proc", spid);
            continue;
        }
        char filename[128] = {0};
        sprintf(filename, "/proc/%s/status", spid);
        FILE *status = fopen(filename, "r");
        if(status == NULL) {
            fprintf(stderr, "ERROR: fail to open %s\n", filename);
            exit(4);
        }
        uid_t realUid = -1;
        char buffer[1024] = {0};
        fscanf(status, "%*[^\n]\n");
        fscanf(status, "%*[^\n]\n"); 
        fscanf(status, "%*[^\n]\n"); 
        fscanf(status, "%*[^\n]\n"); 
        fscanf(status, "%*[^\n]\n"); 
        fscanf(status, "%*[^\n]\n"); 
        fscanf(status, "%*[^\n]\n"); 
        fscanf(status, "%*[^\n]\n"); 
        fscanf(status, "%*s %u", &realUid); //忽略前8行
        if(realUid == -1) {
            fprintf(stderr, "ERROR: fail to read Uid in %s/%s/status\n", "/proc", spid);
            exit(2);
        }
        for(int i = 1; i < argc; i++) {
            if(realUid == uidlist[i]) {
                uid2pids[i][++uid2pids[i][0]] = pid;
                break;
            }
        }
        fclose(status);
    }
    for(int i = 1; i < argc; i++) {
        printf("---------------Process of User: %s, uid = %u---------------\n", argv[i], uidlist[i]);
        for(int j = 1; j < uid2pids[i][0]; j++) {
            printf("\t├ %d\n", uid2pids[i][j]);
        }
        if(uid2pids[i][0] == 0) {
            printf("\t(nil)\n");
        } else {
            printf("\t└ %d\n", uid2pids[i][uid2pids[i][0]]);
        }
    }
    closedir(proc);
}
```

### `/proc/PID`目录消失

我觉得不要去读`/proc/PID`目录就好了，直接读`/proc/PID/status`，不存在就返回`NULL`， 然后读取下一个pid

## 12.2
实现一个pstree


```c
#include <unistd.h>
#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/types.h>   
#include <unistd.h>
#include <limits.h>

int get_pid_max() {
    FILE *pid_max = fopen("/proc/sys/kernel/pid_max", "r");
    int ret = -1;
    fscanf(pid_max, "%d", &ret);
    fclose(pid_max);
    if(ret == -1) {
        fprintf(stderr, "Error: fail to read /proc/sys/kernel/pid_max\n");
        exit(1);
    }
    return ret;
}

struct process {
    char *name;
    char *cmd;
    pid_t parent;
    pid_t pid;
    struct process *children;
    struct process *sibling;
};

char *append(char * str, const char *cat) {
    int len = strlen(str) + strlen(cat) + 1;
    char *ret = malloc(len*sizeof(char));
    ret[0] = 0;
    strcat(ret, str);
    strcat(ret, cat);
    return ret;
}

int max(int a, int b) {
    return a>b?a:b;
}

void prettyPrint(struct process *root, char *preffix, int last) {
    const char * tab = last ? "└" : "├";
    printf("%s│•Name=%s\n", preffix, root->name);
    printf("%s│ pid=%d\n", preffix, root->pid);
    printf("%s│ cmd=%s\n", preffix, root->cmd);
    printf("%s│ ppid=%d\n", preffix, root->parent);
    printf("%s%s", preffix, tab);
    struct process *move = root->children;
    if(move != NULL) {
        printf("┬");
    } else {
        printf("─");
    }
    int suff = max(max(strlen(root->name)+5, strlen(root->cmd)+4), 10);
    while(suff) {printf("─"); suff--;}
    printf("\n");
    
    preffix = append(preffix, (!last ? "│" : " "));
    while(move != NULL && move->sibling != NULL) {
        prettyPrint(move, preffix, 0);
        move = move->sibling;
    }

    if(move != NULL) prettyPrint(move, preffix, 1);
}

int main(int argc, char **argv) {
#ifndef DEBUG
    freopen("/dev/null", "w", stderr);
#endif
    long lim_filename = pathconf("/proc",_PC_NAME_MAX);
    long lim_argmax = sysconf(_SC_ARG_MAX);

    int pid_max = get_pid_max();
    struct process **pidlist = (struct process **)malloc(pid_max * sizeof(struct process *));
    pid_t *pids = (pid_t *)malloc(pid_max * sizeof(pid_t));
    int pidscount = 0;
    pids[pidscount++] = 0;
    memset(pidlist, 0, pid_max * sizeof(struct process *));
    pidlist[0] = malloc(sizeof(struct process));
    memcpy(pidlist[0], &(struct process) {
        .name=NULL, //filename ?
        .cmd=NULL,
        .parent=-1,
        .pid=0,
        .children=NULL,
        .sibling=NULL
    }, sizeof(struct process));

    char *filename = malloc((14 + lim_filename+1)*sizeof(char));
    DIR *proc = opendir("/proc");
    struct dirent *proc_rent = NULL;
    while((proc_rent = readdir(proc)) != NULL) {
        const char *spid = proc_rent->d_name;
        char *end;
        errno = 0;
        pid_t pid = strtol(spid, &end, 10);
        if(end == spid || *end != '\0' || errno != 0) {
            fprintf(stderr, "INFO: %s/%s is not a pid\n", "/proc", spid);
            continue;
        }
        // if(pid == selfpid || pid == selfppid) continue;
        fprintf(stderr, "INFO: current pid = %d\n", pid);
        pidlist[pid] = malloc(sizeof(struct process));
        memcpy(pidlist[pid], &(struct process) {
            .name=malloc((lim_filename+1)*sizeof(char)), //filename ?
            .cmd=malloc((lim_argmax+1)*sizeof(char)),
            .parent=-1,
            .pid=pid,
            .children=NULL,
            .sibling=NULL
        }, sizeof(struct process));
        pidlist[pid]->name[0] = 0;
        pidlist[pid]->cmd[0] = 0;
        sprintf(filename, "/proc/%s/status", spid);
        FILE *status = fopen(filename, "r");
        if(status == NULL) {
            fprintf(stderr, "ERROR: fail to open %s\n", filename);
            exit(4);
        }
        uid_t realUid = -1;
        char buffer[1024] = {0};
        fscanf(status, "%*s %s\n", pidlist[pid]->name);
        fscanf(status, "%*[^\n]\n"); 
        fscanf(status, "%*[^\n]\n"); 
        fscanf(status, "%*[^\n]\n"); 
        fscanf(status, "%*[^\n]\n"); 
        fscanf(status, "%*[^\n]\n"); 
        fscanf(status, "%*s %d\n", &pidlist[pid]->parent);
        if(strcmp(pidlist[pid]->name, "") == 0 || pidlist[pid]->parent == -1) {
            fprintf(stderr, "ERROR: fail to read name or ppid in %s/%s/status\n", "/proc", spid);
            exit(2);
        }
        // printf("read /proc/%s/status, name = %s, ppid = %d\n", spid,pidlist[pid]->name, pidlist[pid]->parent);
        sprintf(filename, "/proc/%s/cmdline", spid);
        FILE *cmdline = fopen(filename, "r");
        if(cmdline == NULL) {
            fprintf(stderr, "ERROR: fail to open %s\n", filename);
            exit(4);
        }
        fscanf(cmdline, "%s", pidlist[pid]->cmd);
        // printf("read cmdline = %s\n", pidlist[pid]->cmd);
        fclose(cmdline); 
        fclose(status);
        pids[pidscount++] = pid;

        // pid_t ppid = pidlist[pid]->parent;
        // pidlist[pid]->sibling = pidlist[ppid]->children;
        // pidlist[ppid]->children = pidlist[pid];
        // 不能在这里找父节点，父节点可能还没读出来。
    }
    for(int i = 1; i < pidscount; i++) {
        pid_t pid = pids[i];
        pid_t ppid = pidlist[pid]->parent;
        pidlist[pid]->sibling = pidlist[ppid]->children;
        pidlist[ppid]->children = pidlist[pid];
    }
    
    closedir(proc);
    prettyPrint(pidlist[1], memset(malloc(sizeof(char)), 0, sizeof(char)), 1);

    for(int i = 0; i < pidscount; i++) {
        free(pidlist[pids[i]]->name);
        free(pidlist[pids[i]]->cmd);
        free(pidlist[pids[i]]);
    }
    free(filename);
    free(pids);
    free(pidlist);
    return 0;
}

```
## 12.3
编写一个程序，列表展示打开同一特定路径名文件的所有进程。可以通过分析所有/proc/PID/fd/*符号链接的内容来实现此功能。这需要利用readdir(3)函数来嵌套循环，扫描所有/proc/PID目录以及每个/proc/PID目录下所有/proc/PID/fd的条目内容。读取/proc/PID/fd/n符号链接的内容，需要使用readlink(),
18.5节对其进行了描述。



```c
#include <unistd.h>
#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/types.h>   
#include <unistd.h>
#include <limits.h>

int get_pid_max() {
    FILE *pid_max = fopen("/proc/sys/kernel/pid_max", "r");
    int ret = -1;
    fscanf(pid_max, "%d", &ret);
    fclose(pid_max);
    if(ret == -1) {
        fprintf(stderr, "Error: fail to read /proc/sys/kernel/pid_max\n");
        exit(1);
    }
    return ret;
}

int main(int argc, char **argv) {
    if(argc != 2) {
        fprintf(stderr, "Usage: %s filename\n", argv[0]);
        exit(0);
    }
#ifndef DEBUG
    freopen("/dev/null", "w", stderr);
#endif

    int pid_max = get_pid_max();
    long lim_argmax = sysconf(_SC_ARG_MAX);
    long lim_pathmax = pathconf("/proc",_PC_PATH_MAX);

    pid_t *pids = malloc(pid_max * sizeof(pid_t));
    int pidscount = 0;

    DIR *proc = opendir("/proc");
    if(proc == NULL) {
        fprintf(stderr, "ERROR: fail to read /proc: %s\n", strerror(errno));
        exit(1);
    }
    struct dirent *proc_rent = NULL;
    char *fdname = alloca((lim_pathmax+1) * sizeof(char));
    char *fdlink = alloca((lim_pathmax+1) * sizeof(char));
    char *fdbuf = alloca((BUFSIZ + 1) * sizeof(char));
    while((proc_rent = readdir(proc)) != NULL) {
        const char *spid = proc_rent->d_name;
        char *end;
        errno = 0;
        pid_t pid = strtol(spid, &end, 10);
        if(end == spid || *end != '\0' || errno != 0) {
            fprintf(stderr, "INFO: %s/%s is not a pid\n", "/proc", spid);
            continue;
        }
        sprintf(fdname, "/proc/%s/fd", spid);
        DIR *fd = opendir(fdname);
        struct dirent *fd_rent = NULL;
        while((fd_rent = readdir(fd)) != NULL) {
            
            errno = 0;
            int filedes = strtol(fd_rent->d_name, &end, 10);
            if(end == fd_rent->d_name || *end != '\0' || errno != 0) {
                fprintf(stderr, "INFO: %s/%s is not a fd\n", fdname, fd_rent->d_name);
                continue;
            }
            sprintf(fdlink, "%s/%s", fdname, fd_rent->d_name);
            ssize_t readsize = readlink(fdlink, fdbuf, BUFSIZ);
            if(readsize == -1) {
                fprintf(stderr, "ERROR: fail to read link: %s, %s\n", fdlink, strerror(errno));
            }
            fdbuf[readsize] = 0;
#ifdef DEBUG
            fprintf(stderr, "fdbuf = %s\n", fdbuf);
#endif
            if(strcmp(fdbuf, argv[1]) == 0) {
                pids[pidscount++] = pid;
#ifndef DEBUG
                break;
#endif
            }
        }
        closedir(fd);
    }
    closedir(proc);
    if(pidscount > 0) {
        char *command = alloca((lim_argmax+1) * sizeof(char));
        strcpy(command, "ps -f -p");
        for(int i = 0; i < pidscount; i++) {
            sprintf(command, "%s %d", command, pids[i]);
        }

    #ifdef DEBUG
        fprintf(stderr, "command = %s\n", command);
    #endif
        system(command);
    } else {
        char *command = alloca((lim_argmax+1) * sizeof(char));
        sprintf(command, "ps -f -p %d", pid_max);

    #ifdef DEBUG
        fprintf(stderr, "command = %s\n", command);
    #endif
        system(command);
        
    }

    return 0;
}
```