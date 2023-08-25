---
title: cha42.共享库高级特性
date: 2023-8-25 12:05:00
tags:
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 42.1 42.2
- 编写一个程序来验证当使用dlclose0关闭一个库时如果其中的符号还在被其他库使用的话将不会卸载这个库。
- 在程序清单42-1中的程序(dynload.c)中添加一个dladdr0调用以获取与dlsym返回的地址有关的信息。打印出返回的 DI inf 结构中各个字段的值并验证这些值是否与预期的值一样。

{% codeblock practice42.1.a.c lang:c %}
//
// Created by root on 8/25/23.
//
#include <stdio.h>

int foo(int a, int b) {
    printf("foo\n");
    return a+b;
}

int bar(int a, int b) {
    printf("bar\n");
    return a*b;
}

void __attribute__ ((constructor)) init() {
    printf("constructing\n");
}

void __attribute__ ((destructor())) dest() {
    printf("destructing\n");
}

{% endcodeblock %}


{% codeblock practice42.1.b.c lang:c %}
//
// Created by root on 8/25/23.
//
#define _GNU_SOURCE
#include <stdio.h>
#include <dlfcn.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>

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

int main(int argc, char **argv) {
    if(argc < 1) {
        ERROR("Usage: %s shared-object", argv[0]);
    }
    void *libhandler = dlopen(argv[1], RTLD_NOW);
    if(libhandler == NULL) {
        ERROR(dlerror());
    }
    void *libhandler1 = dlopen(argv[1], RTLD_NOW);
    if(libhandler1 == NULL) {
        ERROR(dlerror());
    }
    int (*f)(int, int) = dlsym(libhandler, "foo");
    if(f == NULL) {
        ERROR(dlerror());
    }
    int (*f1)(int, int) = dlsym(libhandler1, "bar");
    if(f1 == NULL) {
        ERROR(dlerror());
    }
    Dl_info info;
    memset(&info, 0, sizeof(Dl_info));
    if(dladdr(f, &info) == 0) {
        ERROR(dlerror());
    }
    printf("addr=%p\n\tfname=%s\n\tfbase=%p\n\tsname=%s\n\tsaddr=%p\n", f, info.dli_fname, info.dli_fbase, info.dli_sname, info.dli_saddr);
    memset(&info, 0, sizeof(Dl_info));
    if(dladdr(f1, &info) == 0) {
        ERROR(dlerror());
    }
    printf("addr=%p\n\tfname=%s\n\tfbase=%p\n\tsname=%s\n\tsaddr=%p\n", f1, info.dli_fname, info.dli_fbase, info.dli_sname, info.dli_saddr);
    printf("%d, %d\n", f(1,2), f1(2,3));
    printf("dlclose libhandler\n");
    dlclose(libhandler);
    printf("dlclose libhandler1\n");
    dlclose(libhandler1);
}
{% endcodeblock %}