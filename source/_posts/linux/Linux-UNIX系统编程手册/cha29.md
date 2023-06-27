---
title: cha29.线程：介绍
date: 2023-6-27 18:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 29.1
若一线程执行了如下代码,可能会产生什么结果?
pthread_join(pthread_self()，NULL);
在 Linux上编写一个程序，观察一下实际会发生什么情况。假设代码中有一变量 tid,其中包含了某个线程ID，在自身发起pthread_join(tid, NULL)调用时，要避免造成与上述语句相同的后果，该线程应采取何种措施?


```c
#define CHECK(x) do { \
                        if(!(x)) { \
                            fwritef(STDERR_FILENO, "error: %s\n", strerror(errno));     \
                            pthread_exit(NULL); \
                        }      \
                    } while(0)
void *thread1_fun(void * args) {
    sleep(1);
    return NULL;
}

void *thread_fun(void * args) {
    void *ret;
    printf("thread: before,join-pthread_self()\n");
    CHECK(pthread_join(pthread_self(), &ret) == 0);
    printf("thread: after,join-pthread_self()\n");
    return NULL;
}

int main() {
    pthread_t thread;
    CHECK(pthread_create(&thread, NULL, thread_fun, NULL) == 0);
    CHECK(pthread_detach(thread) == 0);
    printf("main: pthread_created.\n");
    sleep(10);
    return 0;
}
```

### 结果

pthread_join返回值非0，出现错误，errno表示SUCCESS

为啥是success呢，errno不是一个线程一份吗，还是这个函数不算系统调用？？可能是他调用了waitpid，但是出错位置不在waitpid

### 措施

检查一下tid与pthread_self()呗，使用pthread_equal

## 29.2


除了缺少错误检查，以及对各种变量和结构的声明外，下列程序还有什么问题?
```c
static void*
threadFunc(void *arg){
    struct someStruct *pbuf = (struct someStruct *) arg;/* Do some work with structure pointed to by 'pbuf'*/
}
int
main(int argc,char *argv[]){
    struct someStruct buf;
    pthread_create(&thr，NULL,threadFunc，(void *) &buf);
    pthread_exit(NULL);
}
```

### 回答

thread函数里面最后没有return（这里感谢Clion的提示

这里居然不会因为main的退出而导致线程的退出，因为在主线程调用这个函数，其他线程会继续运行

