---
title: cha19.监控文件事件
date: 2023-5-22 18:05:00
tags: 
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 19.1

监控某个目录及其所有子目录的，创建，删除改名

```c
//
// Created by root on 5/22/23.
//
#define _XOPEN_SOURCE 600
#include <stdio.h>
#include <unistd.h>
#include <limits.h>
#include <sys/inotify.h>
#include <stddef.h>
#include <sys/stat.h>
#include <ftw.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <alloca.h>
#include <stdbool.h>
// 对root及其子目录下所有文件的创建、删除改名操作监控，并支持监控新建的子目录

struct listNode {
    int wd;
    char *name;
    struct listNode *next;
} *head;

int len() {
    int l = 0;
    struct listNode *next = head->next;
    while (next) {
        l++;
        next = next->next;
    }
    return l;
}

struct listNode *newListNode(int wd, const char *name, struct listNode *next) {
    struct listNode *node = malloc(sizeof(struct listNode));
    node->wd = wd;
    node->name = strdup(name);
    node->next = next;
    return node;
}
struct listNode *searchWD(const char *name) {
    struct listNode *next = head->next;
    while (next) {
        if(strcmp(next->name, name) == 0) {
            return next;
        }
        next = next->next;
    }
    return NULL;
}
struct listNode *search(int wd) {
    struct listNode *next = head->next;
    while (next) {
        if(next->wd == wd) {
            return next;
        }
        next = next->next;
    }
    return NULL;
}

bool delete(int wd) {
    struct listNode *next = head;
    while (next->next) {
        if(next->next->wd == wd) {
            struct list *del = next->next;
            next->next = next->next->next;
            free(del);
            return true;
        }
        next = next->next;
    }
    return false;
}

const uint32_t watch_mask = IN_CREATE|IN_DELETE|IN_DELETE_SELF|IN_MOVED_TO|IN_MOVED_FROM;
int fd = -1;
size_t read_event(void *ievent) {
    size_t numRead = read(fd, ievent, 10 * (sizeof(struct inotify_event) + NAME_MAX + 1));
    if(numRead == -1) {
        fprintf(stderr, "read1: %s\n", strerror(errno));
        return -1;
    }
    printf("readNum = %lu\n", numRead);
    return numRead;
}

int addwatch(const char *path) {
    int wd;
    if((wd = inotify_add_watch(fd, path, watch_mask)) != -1) {
        struct listNode *e = NULL;
        if((e = search(wd)) == NULL) {
            head->next = newListNode(wd, path, head->next);
        } else {
            free(e->name);
            e->name = strdup(path);
        }
        fprintf(stderr, "watching: %s\n", path);
        return 0;
    } else {
        fprintf(stderr, "fail to watch: %s, %s\n", path, strerror(errno));
        return -1;
    }
}

int nftw_read(const char *path, const struct stat *sbuf, int type, struct FTW *ftwb) {
    switch (sbuf->st_mode & S_IFMT) {
        case S_IFDIR:
            break;
        default:
            return 0;
    }
    addwatch(path);
    return 0;
}

void update_monitor(struct inotify_event *ievent) {

    struct listNode *node = search(ievent->wd);
    char *new_path = malloc(strlen(node->name) + strlen(ievent->name) + 1 +  1);
    sprintf(new_path, "%s/%s", node->name, ievent->name);
    struct stat stat1;
    if(stat(new_path, &stat1) != -1) {
        if((stat1.st_mode & S_IFMT) == S_IFDIR) {
//            addwatch(new_path);
            if(nftw(new_path, nftw_read, 10, FTW_PHYS) == -1) {
                fprintf(stderr, "fail to traverse: %s, %s", new_path, strerror(errno));
            }
        }
    }
    free(new_path);
}
int nftw_del(const char *path, const struct stat *sbuf, int type, struct FTW *ftwb) {
    switch (sbuf->st_mode & S_IFMT) {
        case S_IFDIR:
            break;
        default:
            return 0;
    }
    addwatch(path);

    inotify_rm_watch(fd, searchWD(path)->wd);
    delete(searchWD(path)->wd);
    return 0;
}
void rm_monitor(struct inotify_event *ievent) {
    struct listNode *node = search(ievent->wd);
    char *new_path = malloc(strlen(node->name) + strlen(ievent->name) + 1 +  1);
    sprintf(new_path, "%s/%s", node->name, ievent->name);
    if(nftw(new_path, nftw_del, 10, FTW_PHYS) == -1) {
        fprintf(stderr, "fail to traverse: %s, %s", new_path, strerror(errno));
    }
    free(new_path);
}

void process_event(struct inotify_event *ievent) {
//    IN_CREATE|IN_DELETE|IN_DELETE_SELF|IN_MOVE

    printf("mask = %x\n", ievent->mask);
    if(ievent->mask & IN_CREATE) {
        printf("Monitor: File Creation: %s/%s\n", search(ievent->wd)->name, ievent->name);
        update_monitor(ievent);
    }
    if(ievent->mask & IN_DELETE) {
        printf("Monitor: File Deletion: %s, wd = %s\n", ievent->name, search(ievent->wd)->name);
    }
    if(ievent->mask & IN_DELETE_SELF) {
        printf("Monitor: File Deletion: %s, stop monitoring, wd = %s\n", search(ievent->wd)->name, search(ievent->wd)->name);
        rm_monitor(ievent);
    }
    if(ievent->mask & IN_MOVED_FROM) {
        printf("Monitor: File Move in, from: %s/%s\n", search(ievent->wd)->name, ievent->name);
        rm_monitor(ievent);

    }
    if(ievent->mask & IN_MOVED_TO) {
        printf("Monitor: File Move out, to: %s/%s\n", search(ievent->wd)->name, ievent->name);
        update_monitor(ievent);
    }
}

int main(int argc, char *argv[]) {
    char *monitor_root = (argc > 1) ? argv[1] : ".";
    fd = inotify_init();
    if(fd == -1) {
        fprintf(stderr, "fail to init inotify: %s\n", strerror(errno));
        return 1;
    }

    head = newListNode(0, "", NULL);
    if(head == NULL) {
        fprintf(stderr, "fail to malloc head, %s", strerror(errno));
        return 2;
    }

    if(nftw(monitor_root, nftw_read, 10, FTW_PHYS) == -1) {
        fprintf(stderr, "fail to traverse: %s, %s", monitor_root, strerror(errno));
    }

    void *ievent = malloc(10 * (sizeof(struct inotify_event) + NAME_MAX + 1));
    for(;len()>0;) {
        size_t numread = -1;
        if((numread = read_event(ievent)) == -1) {
            fprintf(stderr, "read fail, sleep\n");
            usleep(500000);
            continue;
        }
        for(void *p = ievent; p < ievent + numread;) {
            struct inotify_event* e = (struct inotify_event *)p;
            p += e->len + sizeof(struct inotify_event);
            process_event(e);
        }
    }
    free(ievent);
}
```

### todo:
如果read了半个event怎么办