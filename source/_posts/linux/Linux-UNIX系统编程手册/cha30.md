---
title: cha30.线程：线程同步
date: 2023-6-29 18:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 

## 30.2

实现一组线程安全的函数，以更新和搜索一个不平衡二叉树。此函数库应该包含如
下形式的函数（目的明显):
```c
initialize(tree);
add(tree,char *key,void *value);
delete(tree,char *key)
Boolean lookup(char *key,void**value)
```
上述函数原型中，tree是一个指向根节点的结构（为此需要足义一个合P的绐构)。例的每个节点保存有一个键-值对。还需为树中每个节点定义一数据结构，其中应包含互斥量，以
确保同时仅有一个线程可以访问该节点。initialize()、add()和 lookup()函数的实现相对简单。delete()的实现需要较为深入的考虑。

### 实现
```c
//
// Created by root on 6/28/23.
//

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <pthread.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>

#define CHECK(x, exitline, ...)  do { if(!(x)) { \
                                    fprintf(stderr, "CHECK: ");       \
                                    fprintf(stderr, __VA_ARGS__);        \
                                    fprintf(stderr, "\n");       \
                                    exitline;        \
                                }                                          \
                            } while(0)

#define CHECKERR(x, exitline)  CHECK(x, exitline, "Error: %s\n", strerror(errno))
typedef int K;
typedef int V;
typedef struct ConcurrentTreeStruct{
    pthread_mutex_t mutex;
    K *key;
    V *value;
    struct ConcurrentTreeStruct *left;
    struct ConcurrentTreeStruct *right;
} *ConcurrentTreeNode;



typedef struct ConcurrentTree{
    ConcurrentTreeNode dummy;
    int (*compare)(K *key1, K *key2);
    void (*destroyKey)(K *key);
    void (*destroyValue)(V *value);
} *ConcurrentTree;



ConcurrentTreeNode initCTreeNode(K *key, V *value, ConcurrentTreeNode left, ConcurrentTreeNode right) {
    ConcurrentTreeNode tree = (ConcurrentTreeNode)malloc(sizeof(struct ConcurrentTreeStruct));
    CHECKERR(tree, return NULL);
    tree->left = left;
    tree->right = right;
    tree->key = key;
    tree->value = value;
    CHECKERR(pthread_mutex_init(&tree->mutex, NULL) == 0, do {free(tree); return NULL; } while(0));
    return tree;
}
ConcurrentTree initCTree(
    int (*compare)(K *key1, K *key2),
    void (*destroyKey)(K *key),
    void (*destroyValue)(V *value)
) {
    ConcurrentTree tree = (ConcurrentTree)malloc(sizeof(struct ConcurrentTree));
    CHECKERR(tree, return NULL);
    tree->dummy = initCTreeNode(NULL, NULL, NULL, NULL);
    CHECK(tree->dummy, do { free(tree); return NULL; } while(0), "");
    tree->compare = compare;
    tree->destroyKey = destroyKey;
    tree->destroyValue = destroyValue;
    return tree;
}
int add(ConcurrentTree tree, K *key, V *value) {
    CHECK(tree, return -1, "");
    CHECKERR(pthread_mutex_lock(&tree->dummy->mutex) == 0, return -1);
    pthread_mutex_t *old = &tree->dummy->mutex;
    ConcurrentTreeNode *treeNode = &tree->dummy->left;
    while(*treeNode){
        pthread_mutex_t *lock = &(*treeNode)->mutex;
        CHECKERR(pthread_mutex_lock(&(*treeNode)->mutex) == 0, exit(5));
        int cmp = tree->compare(key, (*treeNode)->key);
        if (cmp < 0) { // key小于根
            treeNode = &(*treeNode)->left;
        } else {
            treeNode = &(*treeNode)->right;
        }
        CHECKERR(pthread_mutex_unlock(old) == 0, exit(5));
        old = lock;
    }
    *treeNode = initCTreeNode(key, value, NULL, NULL);
    CHECKERR(pthread_mutex_unlock(old) == 0, exit(5));
    return 0;
}

void delCTreeNode(ConcurrentTreeNode tree, void (*destroyKey)(K *key), void (*destroyValue)(V *value)) {
    if(!tree) return;
    destroyKey(tree->key);
    destroyValue(tree->value);
    pthread_mutex_destroy(&tree->mutex);
    tree->key = NULL;
    tree->value = NULL;
}

int del(ConcurrentTree tree, K *key) {
    CHECK(tree, return -1, "");
    if(!tree->dummy->left) return -1;
    CHECKERR(pthread_mutex_lock(&tree->dummy->mutex) == 0, return -1);
    CHECKERR(pthread_mutex_lock(&tree->dummy->left->mutex) == 0, do { pthread_mutex_unlock(&tree->dummy->mutex); return -1;} while(0));
    pthread_mutex_t *parent_lock = &tree->dummy->mutex;
    pthread_mutex_t *child_lock =&tree->dummy->left->mutex;
    ConcurrentTreeNode *parentNode = &tree->dummy->left;
    ConcurrentTreeNode treeNode = tree->dummy->left;

    while(treeNode) {
//        printf("cmp %d, %d\n", *key, *treeNode->key);
        int cmp = tree->compare(key, treeNode->key);
        if(cmp == 0) {
            if(treeNode->left) CHECKERR(pthread_mutex_lock(&treeNode->left->mutex) == 0, exit(5));
            if(treeNode->right) CHECKERR(pthread_mutex_lock(&treeNode->right->mutex) == 0, exit(5));
            ConcurrentTreeNode left = treeNode->left;
            ConcurrentTreeNode right = treeNode->right;
            if(!left && !right) {
                *parentNode = NULL;
            } else if(!left) {
                *parentNode = right;
            } else if(!right) {
                *parentNode = left;
            } else {
                *parentNode = left;
            }
            CHECKERR(pthread_mutex_unlock(parent_lock) == 0, exit(5));
            if(left && right) {
                while (left->right) {
                    ConcurrentTreeNode old = left;
                    left = left->right;
                    if(left) CHECKERR(pthread_mutex_lock(&left->mutex) == 0, exit(5));
                    CHECKERR(pthread_mutex_unlock(&old->mutex) == 0, exit(5));
                }
                left->right = right;
            }
            if(left)CHECKERR(pthread_mutex_unlock(&left->mutex) == 0, exit(5));
            if(right)CHECKERR(pthread_mutex_unlock(&right->mutex) == 0, exit(5));

            CHECKERR(pthread_mutex_unlock(child_lock) == 0, exit(5));
            delCTreeNode(treeNode, tree->destroyKey, tree->destroyValue);
            free(treeNode);
            return 0;
        } else if(cmp < 0) {
            CHECKERR(pthread_mutex_unlock(parent_lock) == 0, exit(5));
            if(treeNode->left) CHECKERR(pthread_mutex_lock(&treeNode->left->mutex) == 0, exit(5));
            parent_lock = &treeNode->mutex;
            parentNode = &treeNode->left;
            treeNode = treeNode->left;
            child_lock = treeNode ? &treeNode->mutex : NULL;
        } else {
            CHECKERR(pthread_mutex_unlock(parent_lock) == 0, exit(5));
            if(treeNode->right) CHECKERR(pthread_mutex_lock(&treeNode->right->mutex) == 0, exit(5));
            parent_lock = &treeNode->mutex;
            parentNode = &treeNode->right;
            treeNode = treeNode->right;
            child_lock = treeNode ? &treeNode->mutex : NULL;
        }
    }
    CHECKERR(pthread_mutex_unlock(parent_lock) == 0, exit(5));
    if(child_lock) CHECKERR(pthread_mutex_unlock(child_lock) == 0, exit(5));
    return -1;
}

int lookup(ConcurrentTree tree, K *key, V **value) {
    CHECK(tree, return -1, "tree cannot be null");
    CHECK(key, return -1, "key cannot be null");
    CHECK(value, return -1, "value cannot be null");
    CHECKERR(pthread_mutex_lock(&tree->dummy->mutex) == 0, return -1);
    if(tree->dummy->left)CHECKERR(pthread_mutex_lock(&tree->dummy->left->mutex) == 0, do { pthread_mutex_unlock(&tree->dummy->mutex); return -1;} while(0));
    ConcurrentTreeNode treeNode = tree->dummy->left;
    CHECKERR(pthread_mutex_unlock(&tree->dummy->mutex) == 0, exit(5));
    while(treeNode) {
        int cmp = tree->compare(key, treeNode->key);
        if(cmp == 0) {
            *value = treeNode->value;
            CHECKERR(pthread_mutex_unlock(&treeNode->mutex) == 0, exit(5));
            return 0;
        } else if(cmp < 0) {
            ConcurrentTreeNode old = treeNode;
            treeNode = treeNode->left;
            if(treeNode) CHECKERR(pthread_mutex_lock(&treeNode->mutex) == 0, do { pthread_mutex_unlock(&old->mutex); return -1;} while(0)); //先获取新锁，再放弃旧锁
            CHECKERR(pthread_mutex_unlock(&old->mutex) == 0, exit(5));
        } else {
            ConcurrentTreeNode old = treeNode;
            treeNode = treeNode->right;
            if(treeNode) CHECKERR(pthread_mutex_lock(&treeNode->mutex) == 0, do { pthread_mutex_unlock(&old->mutex); return -1;} while(0));
            CHECKERR(pthread_mutex_unlock(&old->mutex) == 0, exit(5));
        }
    }
    return -1;
}

void destroyCTreeNode(ConcurrentTreeNode tree, void (*destroyKey)(K *key), void (*destroyValue)(V *value)) {
    if(!tree) return;
    destroyCTreeNode(tree->left, destroyKey, destroyValue);
    destroyCTreeNode(tree->right, destroyKey, destroyValue);
    delCTreeNode(tree, destroyKey, destroyValue);
    free(tree);
}

void destroyCTree(ConcurrentTree tree) {
    CHECK(tree, return, "tree cannot be null\n");
    destroyCTreeNode(tree->dummy->left, tree->destroyKey, tree->destroyValue);
    free(tree->dummy);
    tree->dummy = NULL;
}
struct ThreadRet {
    int read;
    int add;
    int del;
};
struct ThreadArg {
    ConcurrentTree tree;
    int threadID;
};
int cmpInt(int *a, int *b) {
    if(*a == *b) {
        return 0;
    } else if(*a > *b) {
        return 1;
    } else {
        return -1;
    }
}
void destroyInt(int *a) {
    if(a) {
        free(a);
    }
}
int maxKey = 0;
pthread_mutex_t mutex_mk;
void *threadfn(void *args) {
    ConcurrentTree tree = ((struct ThreadArg *)args)->tree;
    int tid = ((struct ThreadArg *)args)->threadID;
    CHECKERR(tree, return NULL);
    struct ThreadRet *ret = malloc(sizeof(struct ThreadRet));
    CHECKERR(ret, return NULL);
    ret->read = ret->add = ret->del = 0;
    int opNum = 1000 + rand() % 1001;
    int *key = (int *)malloc(sizeof(int));
    while (opNum--) {
        int *val;
        CHECKERR(key, return ret);
        switch (rand()%3) {
            case 0:
                printf("Thread-%d, try add\n", tid);
                val = (int *)malloc(sizeof(int));
                CHECKERR(val, return ret);
                *val = rand()%200000;

                CHECKERR(pthread_mutex_lock(&mutex_mk) == 0,return ret);
                maxKey++;
                *key = maxKey;
                CHECKERR(pthread_mutex_unlock(&mutex_mk) == 0,return ret);

                add(tree, key, val);
                ret->add++;
                printf("Thread-%d, add (%d, %d)\n", tid, *key, *val);
                key = (int *)malloc(sizeof(int));
                break;
            case 1:
                printf("Thread-%d, try read\n", tid);
                CHECKERR(pthread_mutex_lock(&mutex_mk) == 0,return ret);
                if(maxKey > 0)*key = rand()%maxKey + 1;
                else *key = -1;
                CHECKERR(pthread_mutex_unlock(&mutex_mk) == 0,return ret);
//                printf("Thread-%d, try read %d\n", tid, *key);
                if(lookup(tree, key, &val) == 0) printf("Thread-%d, read (%d, %d)\n", tid, *key, *val);
                else printf("Thread-%d, fail to read (%d)\n", tid, *key);
                ret->read++;
                break;
            case 2:
                printf("Thread-%d, try del\n", tid);
                CHECKERR(pthread_mutex_lock(&mutex_mk) == 0,return ret);
                if(maxKey > 0) {
                    *key = maxKey;
                }
                else *key = -1;
                CHECKERR(pthread_mutex_unlock(&mutex_mk) == 0,return ret);
//                printf("Thread-%d, try del %d\n", tid, *key);
                if(del(tree, key) == 0) {
                    printf("Thread-%d, del (%d)\n", tid, *key);
                    CHECKERR(pthread_mutex_lock(&mutex_mk) == 0,return ret);
                    maxKey--;
                    CHECKERR(pthread_mutex_unlock(&mutex_mk) == 0, return ret);
                }
                else printf("Thread-%d, fail to del (%d)\n", tid, *key);
                ret->del++;
                break;
        }
    }
    free(key);
    free(args);
    return ret;
}

int main(int argc, char *argv[]) {
    CHECK(argc > 1, return 1, "Usage: %s threadCnt", argv[0]);
    int threadCnt = atoi(argv[1]);
    pthread_t *thread = malloc(threadCnt * sizeof(pthread_t));
    CHECKERR(thread, return 2);
    CHECKERR(pthread_mutex_init(&mutex_mk, NULL) == 0,return 3);
    ConcurrentTree tree = initCTree(cmpInt, destroyInt, destroyInt);
    for(int i = 0; i < threadCnt; i++) {
        struct ThreadArg *args = malloc(sizeof(struct ThreadArg));
        args->threadID = i+1;
        args->tree = tree;
        CHECKERR(pthread_create(&thread[i], NULL, threadfn, args) == 0,return 1);
    }
    for(int i = 0; i < threadCnt; i++) {
        struct ThreadRet *ret;
        CHECKERR(pthread_join(thread[i], (void **)&ret) == 0,return 1);
        if(!ret) {
            printf("Summary: Thread-%d occured error, returned NULL\n", i+1);
        } else {
            printf("Summary: Thread-%d add=%d, read=%d, del=%d\n", i+1, ret->add, ret->read, ret->del);
            free(ret);
        }
    }
    CHECKERR(pthread_mutex_destroy(&mutex_mk) == 0,return 3);
    destroyCTree(tree);
    free(tree);
    free(thread);
    return 0;
}
```

> 用四个线程跑了几次，反正都没有死锁过。还没有仔细看过正确性

### valgrind
valgrind跑了很多次，正常情况下全部内存都被free了，没有泄漏

### asan
asan跑了几次，每次都有错误。用gdb也看不到调用栈，后来clion很给力，打印出了调用栈

![](./images/concurrent_tree_asan.png)

不是实现有问题，是在输出log的时候出错了，原理如下
> A线程给树里加入一个节点，然后A打印他的值。但在这之前B又把他删除，他的key，value都被free了，这个时候就不对了。
