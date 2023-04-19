---
title: cha7.内存分配
date: 2023-4-9 18:05:00
tags: 
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 7.1
> 修改程序清单7-1中的程序(free_and_sbrk.c)，在每次执行malloc后打印出 program break的当前值。指定一个较小的内存分配尺寸来运行该程序。这将证明malloc不会在每次被调用时都调用sbrk()来调整program break 的位置，而是周期性地分配大块内存，并从中将小片内存返回给调用者。

```c
// 与代码7.2main相同
```

## 7.2
> (高级)实现 malloc()和 free()。


```c
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#define CHECK(x, code, message, ...) if(!(x)) {fprintf(stderr, "%s:%d, error: %s\t----\t", __FILE__, __LINE__, strerror(errno)); fprintf(stderr, (const char*)message, ##__VA_ARGS__); exit(code); }
#define ERR(code, format, ...) fprintf(stderr, (const char*)format, ##__VA_ARGS__); exit(code)

#define UNUSED 0
#define USED 1

#define EXIT_SBRK_FAIL 1
#define UNKNOWN_FAIL 2
#define UNKNOWN_MEM_ERROR 3
#define FREE_TWICE 4

#define MAXALLOC 100000

void *freeMem = NULL;

unsigned long getBlockSize(void *mem) {
    return *((unsigned long *)mem - 1);
}

void setBlockSize(void *mem, size_t size) {
    *((unsigned long *)mem - 1) = size;
}

void *getNextFreeBlock(void *__free) {
    return (unsigned long*) *((unsigned long *)__free + 1);
}

void setNextFreeBlock(void *__free, void *__ptr) {
    *((unsigned long *)__free + 1) = (unsigned long)__ptr;
}

void *getPrevFreeBlock(void *__free) {
    return (unsigned long*) *(unsigned long *)__free;
}

void setPrevFreeBlock(void *__free, void *__ptr) {
    *(unsigned long *)__free = (unsigned long)__ptr;
}

char getUsed(void *__ptr) {
    return *((char *)__ptr - 1 - sizeof(void *));
}

void setUsed(void *__ptr, char used) {
    *((char *)__ptr - 1 - sizeof(void *)) = used;
}

void memInit(char used, void *__ptr, void *prev, void *next, size_t size) {
    setUsed(__ptr, used);
    setBlockSize(__ptr, size);
    setPrevFreeBlock(__ptr, prev);
    setNextFreeBlock(__ptr, next);
}

void *firstFit(size_t size) {
    void *move = freeMem;
    void *next = getNextFreeBlock(freeMem);
    while(next != NULL) {
        if(getBlockSize(next) >= size) {
            break;
        }
        move = next;
        next = getNextFreeBlock(next);
    }
    return move;
}

void *__malloc(size_t size) {
    if(freeMem == NULL) {
        freeMem = sbrk(sizeof(void *) * 3 + 1);
        CHECK(freeMem != (void*)-1, EXIT_SBRK_FAIL, "sbrk fail\n");
        freeMem += sizeof(void *) + 1;
        memInit(UNUSED, freeMem, NULL, NULL, sizeof(void *) * 2);
    }
    void *__free = firstFit(size);
    void *newMem = NULL;
    CHECK(__free != NULL, UNKNOWN_FAIL, "unknown error\n");
    if(getNextFreeBlock(__free) == NULL) {
        size = size > 2 * sizeof(void *) ? size : 2 * sizeof(void *);
        newMem = sbrk(1 + sizeof(void *) + size);
        CHECK(newMem != (void*)-1, EXIT_SBRK_FAIL, "sbrk fail\n");
        newMem += 1 + sizeof(void *);
        memInit(USED, newMem, NULL, NULL, size);
    } else {
        newMem = getNextFreeBlock(__free);
        setUsed(newMem, USED);
        setNextFreeBlock(__free, getNextFreeBlock(newMem));
    }
    return newMem;
}

void __free(void * __ptr) {
    CHECK(freeMem != NULL, UNKNOWN_MEM_ERROR,"memory: %p is not allocated by __mallo\n", __ptr);
    CHECK(getUsed(__ptr) == USED, FREE_TWICE, "trying to free memory %p twice\n", __ptr);
    setUsed(__ptr, UNUSED);
    void *move = freeMem;
    void *next = getNextFreeBlock(freeMem);
    void *front = (char *)__ptr - 1 - sizeof(void *), *back = (char *)__ptr + getBlockSize(__ptr);
    while(next != NULL) {
        if((char *)next - 1 - sizeof(void *) >= (char *)back) {
            break;
        }
        move = next;
        next = getNextFreeBlock(next);
    }
    if(front == (char *)move + getBlockSize(move)) {
        setBlockSize(move, (char *)back - (char *)move);
        __ptr = move;
    } else {
        setNextFreeBlock(__ptr, getNextFreeBlock(move));
        setNextFreeBlock(move, __ptr);
        setPrevFreeBlock(__ptr, move);
    }
    if(next == NULL) return;
    if(back == (char *)next - 1 - sizeof(void *)) {
        setBlockSize(__ptr, (char *)next + getBlockSize(next) - (char *)__ptr);
    } else {
        setPrevFreeBlock(next, __ptr);
    }
    return;
}

void __printMemblock(void* ptr) {
    printf("------------Memory Block %p---------------\n", ptr);
    printf("front = %p, back = %p\n", (char *)ptr - 1 - sizeof(void *), (char *)ptr + getBlockSize(ptr));
    int used = *((char *)ptr - 1 - sizeof(unsigned long));
    printf("used\t\t=\t%d\n", used);
    printf("blocksize\t=\t%lu\n", *((unsigned long *)ptr - 1));
    if(!used) {
        printf("last free block\t=\t%p\n", (unsigned long*) *(unsigned long *)ptr);
        printf("next free block\t=\t%p\n", (unsigned long*) *((unsigned long *)ptr + 1));
    }
    printf("Current brk = %p\n", sbrk(0));
}

void __showFreeBlocks() {
    printf("show free blocks\n");
    void *move = freeMem;
    while(move) {
        __printMemblock(move);
        move = getNextFreeBlock(move);
    }
}

int main(int argc, char *argv[]) {
    if(argc < 3) {
        ERR(1, "Usage: %s numalloc blocksize [freestep] [freemin] [freemax]\n", argv[0]);
    }
    int numalloc = atoi(argv[1]);
    size_t blocksize = atoi(argv[2]);
    int freestep = argc > 3 ? atoi(argv[3]) : 1;
    int freemin = argc > 4 ? atoi(argv[4]) : 1;
    int freemax = argc > 5 ? atoi(argv[5]) : numalloc;

    void *ptr[MAXALLOC];

    if(numalloc > MAXALLOC) {
        ERR(2, "constraint: numalloc <= %d\n", MAXALLOC);
    }

    printf("sizeof(void *) = %lu\n", sizeof(void *));
    printf("Start to allocate mem, Current program break: %p\n", sbrk(0));

    for(int i = 0; i < numalloc; i++) {
        ptr[i] = __malloc(blocksize);
        if(ptr[i] == NULL) {
            ERR(3, "fail to __malloc loc: %d\n", i);
        }
        printf("Current program break: %p\n", sbrk(0));
        __printMemblock(ptr[i]);
    }

    for(int i = 0; i < numalloc; i++) {
        __printMemblock(ptr[i]);
    }
    __showFreeBlocks();
    printf("Allocation finished, Current program break: %p\n", sbrk(0));

    for(int i = freemin-1; i < freemax; i += freestep) {
        __free(ptr[i]);
        printf("Current program break: %p\n", sbrk(0));
        __printMemblock(ptr[i]);
    }
    
    printf("Mem __free finished, Current program break: %p\n", sbrk(0));

    for(int i = freemin-1; i < freemax; i += freestep) {
        __printMemblock(ptr[i]);
    }
    __showFreeBlocks();
    return 0;
}
```

- `size_t`和`unsigned long`以及`void *`类型转换之间还在报warning
- 没有字节对齐
- malloc找不到合适的块时，每次都会sbrk抬升program break
- 只实现了first fit

### bug fix

- freeMem为空时先抬升program break，作为链表头节点，但是对这块内存的分配，`memInit(UNUSED, freeMem, NULL, NULL, 0);`，最后一个参数不应该是0，而应该是 `2 * sizeof(void *)`。

### 一次性分配大块内存
```c
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#define CHECK(x, code, message, ...) if(!(x)) {fprintf(stderr, "%s:%d, error: %s\t----\t", __FILE__, __LINE__, strerror(errno)); fprintf(stderr, (const char*)message, ##__VA_ARGS__); exit(code); }
#define ERR(code, format, ...) fprintf(stderr, (const char*)format, ##__VA_ARGS__); exit(code)

#define UNUSED 0
#define USED 1

#define EXIT_SBRK_FAIL 1
#define UNKNOWN_FAIL 2
#define UNKNOWN_MEM_ERROR 3
#define FREE_TWICE 4

#define MAXALLOC 100000
#define PAGE 0x010000

void *freeMem = NULL;

unsigned long getBlockSize(void *mem) {
    return *((unsigned long *)mem - 1);
}

void setBlockSize(void *mem, size_t size) {
    *((unsigned long *)mem - 1) = size;
}

void *getNextFreeBlock(void *__free) {
    return (unsigned long*) *((unsigned long *)__free + 1);
}

void setNextFreeBlock(void *__free, void *__ptr) {
    *((unsigned long *)__free + 1) = (unsigned long)__ptr;
}

void *getPrevFreeBlock(void *__free) {
    return (unsigned long*) *(unsigned long *)__free;
}

void setPrevFreeBlock(void *__free, void *__ptr) {
    *(unsigned long *)__free = (unsigned long)__ptr;
}

char getUsed(void *__ptr) {
    return *((char *)__ptr - 1 - sizeof(void *));
}

void setUsed(void *__ptr, char used) {
    *((char *)__ptr - 1 - sizeof(void *)) = used;
}

void memInit(char used, void *__ptr, void *prev, void *next, size_t size) {
    setUsed(__ptr, used);
    setBlockSize(__ptr, size);
    setPrevFreeBlock(__ptr, prev);
    setNextFreeBlock(__ptr, next);
}

void *firstFit(size_t size) {
    void *move = freeMem;
    void *next = getNextFreeBlock(freeMem);
    while(next != NULL) {
        if(getBlockSize(next) >= size) {
            break;
        }
        move = next;
        next = getNextFreeBlock(next);
    }
    return move;
}

void *__malloc(size_t size) {
    if(freeMem == NULL) {
        freeMem = sbrk(PAGE);
        CHECK(freeMem != (void*)-1, EXIT_SBRK_FAIL, "sbrk fail\n");
        freeMem += sizeof(void *) + 1;
        memInit(UNUSED, freeMem, NULL, freeMem + sizeof(void *) * 3 + 1, sizeof(void *) * 2);
        memInit(UNUSED, freeMem + sizeof(void *) * 3 + 1, freeMem, NULL, PAGE - (1 + sizeof(void *) + 1 + 3*sizeof(void *)));
    }
    void *__free = firstFit(size);
    void *newMem = NULL;
    CHECK(__free != NULL, UNKNOWN_FAIL, "unknown error\n");
    if(getNextFreeBlock(__free) == NULL) {
        size = size > 2 * sizeof(void *) ? size : 2 * sizeof(void *);
        size_t newSize = PAGE * (size / PAGE + 1) + 1 + sizeof(void *) + 1 + 3 * sizeof(void *);
        newMem = sbrk(newSize); // 按页分配，再加一个链表头，一个完整链表头
        CHECK(newMem != (void*)-1, EXIT_SBRK_FAIL, "sbrk fail\n");
        newMem += 1 + sizeof(void *);
        memInit(USED, newMem, NULL, NULL, size);
        void *next_free = (char *)newMem + size + 1 + sizeof(void *);
        setNextFreeBlock(__free, next_free);
        memInit(UNUSED, next_free, __free, NULL, newSize - (size + 1 + sizeof(void *) + 1 + sizeof(void *)));
    } else {
        newMem = getNextFreeBlock(__free);
        setUsed(newMem, USED);
        setNextFreeBlock(__free, getNextFreeBlock(newMem));
        if(getBlockSize(newMem) >= size + 1 + 3 * sizeof(void *)) {
            memInit(UNUSED, newMem + size + 1 + sizeof(void *), __free, getNextFreeBlock(__free), getBlockSize(newMem) - size - 1 - sizeof(void *));
            setNextFreeBlock(__free, newMem + size + 1 + sizeof(void *));
            if(getNextFreeBlock(newMem)) setPrevFreeBlock(getNextFreeBlock(newMem),  newMem + size + 1 + sizeof(void *));
            setBlockSize(newMem, size);
        } // 当前块的大小大于本次分配需要的大小，且剩余部分仍能放的的下一个完整的链表头，则将该部分再次初始化一个空闲节点，插入原双向链表中
    }
    return newMem;
}

void __free(void * __ptr) {
    CHECK(freeMem != NULL, UNKNOWN_MEM_ERROR,"memory: %p is not allocated by __mallo\n", __ptr);
    CHECK(getUsed(__ptr) == USED, FREE_TWICE, "trying to free memory %p twice\n", __ptr);
    setUsed(__ptr, UNUSED);
    void *move = freeMem;
    void *next = getNextFreeBlock(freeMem);
    void *front = (char *)__ptr - 1 - sizeof(void *), *back = (char *)__ptr + getBlockSize(__ptr);
    while(next != NULL) {
        if((char *)next - 1 - sizeof(void *) >= (char *)back) {
            break;
        }
        move = next;
        next = getNextFreeBlock(next);
    }
    if(front == (char *)move + getBlockSize(move) && move != freeMem) { // move不是头节点，头节点不参与到内存分配中，不与后面的空闲内存合并
        setBlockSize(move, (char *)back - (char *)move);
        __ptr = move;
    } else {
        setNextFreeBlock(__ptr, getNextFreeBlock(move));
        setNextFreeBlock(move, __ptr);
        setPrevFreeBlock(__ptr, move);
    }
    if(next == NULL) return;
    if(back == (char *)next - 1 - sizeof(void *)) {
        setBlockSize(__ptr, (char *)next + getBlockSize(next) - (char *)__ptr);
        setNextFreeBlock(__ptr, getNextFreeBlock(next));
        if(getNextFreeBlock(next)) setPrevFreeBlock(getNextFreeBlock(next), __ptr);
    } else {
        setPrevFreeBlock(next, __ptr);
        setNextFreeBlock(__ptr, next);
    }
    return;
}

void __printMemblock(void* ptr) {
    printf("------------Memory Block %p---------------\n", ptr);
    printf("front = %p, back = %p\n", (char *)ptr - 1 - sizeof(void *), (char *)ptr + getBlockSize(ptr));
    int used = *((char *)ptr - 1 - sizeof(unsigned long));
    printf("used\t\t=\t%d\n", used);
    printf("blocksize\t=\t%lu\n", *((unsigned long *)ptr - 1));
    if(!used) {
        printf("last free block\t=\t%p\n", (unsigned long*) *(unsigned long *)ptr);
        printf("next free block\t=\t%p\n", (unsigned long*) *((unsigned long *)ptr + 1));
    }
    printf("Current brk = %p\n", sbrk(0));
}

void __showFreeBlocks() {
    printf("show free blocks\n");
    void *move = freeMem;
    while(move) {
        __printMemblock(move);
        move = getNextFreeBlock(move);
    }
}

int main(int argc, char *argv[]) {
    if(argc < 3) {
        ERR(1, "Usage: %s numalloc blocksize [freestep] [freemin] [freemax]\n", argv[0]);
    }
    int numalloc = atoi(argv[1]);
    size_t blocksize = atoi(argv[2]);
    int freestep = argc > 3 ? atoi(argv[3]) : 1;
    int freemin = argc > 4 ? atoi(argv[4]) : 1;
    int freemax = argc > 5 ? atoi(argv[5]) : numalloc;

    void *ptr[MAXALLOC];

    if(numalloc > MAXALLOC) {
        ERR(2, "constraint: numalloc <= %d\n", MAXALLOC);
    }

    printf("sizeof(void *) = %lu\n", sizeof(void *));
    printf("Start to allocate mem, Current program break: %p\n", sbrk(0));

    for(int i = 0; i < numalloc; i++) {
        ptr[i] = __malloc(blocksize);
        if(ptr[i] == NULL) {
            ERR(3, "fail to __malloc loc: %d\n", i);
        }
        printf("Current program break: %p\n", sbrk(0));
        __printMemblock(ptr[i]);
        __showFreeBlocks();
    }

    for(int i = 0; i < numalloc; i++) {
        __printMemblock(ptr[i]);
    }
    __showFreeBlocks();
    printf("Allocation finished, Current program break: %p\n", sbrk(0));

    for(int i = freemin-1; i < freemax; i += freestep) {
        __free(ptr[i]);
        printf("Current program break: %p\n", sbrk(0));
        __printMemblock(ptr[i]);
        __showFreeBlocks();
    }
    
    
    printf("Mem __free finished, Current program break: %p\n", sbrk(0));

    for(int i = freemin-1; i < freemax; i += freestep) {
        __printMemblock(ptr[i]);
    }
    __showFreeBlocks();
    return 0;
}
```

- free时如果内存块的front和前一个块的back相同，先判断move是否为头节点，不是头节点再合并，头节点不参与内存分配
- 头节点为空/找不到合适的块时，抬升`program break`，一次性分配多个page，把剩余部分作为新的空闲内存节点，加入到双向链表中
- 应该还有很多地方没考虑到，比如判断一个内存块是否是__malloc分配的
- 当freeStep为1时，最后剩余内存链表只剩两个节点，一个长度为16的头节点，和一个完整的内存块，且该内存块的back与当前`program break`相同。