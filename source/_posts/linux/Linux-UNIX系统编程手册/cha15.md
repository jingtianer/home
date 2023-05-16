---
title: cha15.文件元数据
date: 2023-5-16 18:05:00
tags: 
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 15.1

## 15.2

## 15.3

## 15.4

## 15.5

## 15.6

### chmod
chmod的大写`X`表示:
> execute/search only if the file is a directory or already has execute permission for some user (X)

也就是若某些用户已经有了执行权限时，为其赋予执行/搜索权限

```c
#include <stdio.h>
#include <sys/stat.h>
#include <string.h>
#include <stdbool.h>
#include <errno.h>
#include <unistd.h>

mode_t MODE = 0;
mode_t UMASK = 0;
int operation = 0; // bits from high to low represents, -/+/= ugo
bool flag_X = false;

void step41(char *arg) {
    if(arg == NULL || *arg == 0) return;
    if(*arg == 'r') {
        if(operation&01) {
            MODE |= 04;
        }
        if(operation&02) {
            MODE |= 040;
        }
        if(operation&04) {
            MODE |= 0400;
        }
        step41(arg+1);
    } else if(*arg == 'w') {
        if(operation&01) {
            MODE |= 02;
        }
        if(operation&02) {
            MODE |= 020;
        }
        if(operation&04) {
            MODE |= 0200;
        }
        step41(arg+1);
    } else if(*arg == 'x') {
        if(operation&01) {
            MODE |= 01;
        }
        if(operation&02) {
            MODE |= 010;
        }
        if(operation&04) {
            MODE |= 0100;
        }
        step41(arg+1);
    } else if(*arg == 'X') {
        flag_X = true;
        step41(arg+1);
    } else if(*arg == 's') {
        // u+s, g+s
        if(operation&02) {
            MODE |= 02000;
        }
        if(operation&04) {
            MODE |= 04000;
        }
        step41(arg+1);
    } else if(*arg == 't') {
        MODE |= 01000;
        step41(arg+1);
    } else {
        // undefined behavior
    }
}

void step42(char *arg) {
    if(arg == NULL || *arg == 0) return;
    int flag = *arg - '0';
    if(operation&01) {
        MODE |= flag;
    }
    if(operation&02) {
        MODE |= flag<<3;
    }
    if(operation&04) {
        MODE |= flag<<6;
    }
    step42(arg+1);
}


// parse: [rwxXst]+|[0-7]+
void step3(char * arg) {
    if(arg == NULL || *arg == 0) return;
    if(*arg == 'r' || *arg == 'w' || *arg == 'x' || *arg == 'X' || *arg == 's' || *arg == 't') {
        step41(arg);
    } else if(*arg >= '0' && *arg <= '7') {
        step42(arg);
    } else {
        // undefined behavior
    }
}

// parse: [-+=]([rwxXst]+|[0-7]+)
void step2(char * arg) {
    if(arg == NULL || *arg == 0) return;
    if(*arg == '-') {
        operation |= 010;
        step3(arg+1);
    } else if(*arg == '+') {
        operation |= 020;
        step3(arg+1);
    } else if(*arg == '=') {
        operation |= 030;
        step3(arg+1);
    } else {
        // undefined behavior
    }
}

// 原本的表达式是: [ugoa]*([-+=]([rwxXst]*|[ugo]))+|[-+=][0-7]+，简化为
// parse: [ugoa]*[-+=]([rwxXst]+|[0-7]+)
void step1(char * arg) {
    if(arg == NULL || *arg == 0) return;
    if(*arg == 'u') {
        operation = 4;
        step1(arg+1);
    } else if(*arg == 'g') {
        operation = 2;
        step1(arg+1);
    } else if(*arg == 'o') {
        operation = 1;
        step1(arg+1);
    } else if(*arg == 'a') {
        operation = 7;
        step1(arg+1);
    } else {
        if(operation == 0) {
            operation = 7;

        }
        step2(arg);
    }

}

mode_t apply_mod(mode_t mode) {
    fprintf(stderr, "MODE = %o\n", MODE);
    mode_t mask = ((operation&07) == 0) ? UMASK : 0;
    fprintf(stderr, "op = %o\n", operation);
    MODE = MODE & (~mask);
    //00 0
    //01 0
    //10 1
    //11 0
    //
    //( a & ~b ) 逻辑减法
    if((operation&00070) == 010) {
        // -
        mode = mode & (~MODE);
        if(flag_X && (mode&0111)) {
            mode = (~(0111) & mode); // 三个xxx全都变成0，其余不变
        }
    } else if ((operation&00070) == 020) {
        // +
        mode = mode | MODE;

        if(flag_X && (mode&0111)) {
            if(operation&01) {
                mode |= 01;
            }
            if(operation&02) {
                mode |= 010;
            }
            if(operation&04) {
                mode |= 0100;
            }
        }
    } else if ((operation&00070) == 030) {
        // =
        fprintf(stderr, "flagX = %d, mode = %o\n", flag_X, mode);
        if(flag_X && (mode&0111)) {
            if(operation&01) {
                MODE |= 01;
            }
            if(operation&02) {
                MODE |= 010;
            }
            if(operation&04) {
                MODE |= 0100; //这里的大MODE，防止一会mode被MODE覆盖
            }
        } // incase: chmod =X
        if(operation&01) {
            mode = (07&MODE) | ((~07)&mode);
        }
        if(operation&02) {
            mode = (070&MODE) | ((~070)&mode);
        }
        if(operation&04) {
            mode = (0700&MODE) | ((~0700)&mode);
        }
        mode = (07000&MODE) | ((~07000)&mode);
        //000 0
        //010 0
        //100 1
        //110 0
        //001 0
        //011 1
        //101 1
        //111 1
        //
        //( b & c )|( ~b & a ) // 根据掩码b置位

        if(flag_X && (mode&0111)) {
            if(operation&01) {
                mode |= 01;
            }
            if(operation&02) {
                mode |= 010;
            }
            if(operation&04) {
                mode |= 0100;
            }
        }
    } else {

    }
    operation = 0;
    MODE = 0;
    flag_X = false;
    return mode;
}

// parse_mod: split by ','
mode_t parse_mod(char * arg, mode_t mode) {
    fprintf(stderr, "old Mode = %o\n", mode);
    char *end = NULL;
    while((end = strchr(arg, ',')) != NULL) {
        *end = 0;
        step1(arg);
        mode = apply_mod(mode);
        fprintf(stderr, "new Mode = %o\n", mode);
        arg = end+1;
    }
    step1(arg);
    mode = apply_mod(mode);
    fprintf(stderr, "new Mode = %o\n", mode);
    return mode;
}

mode_t current_umask() {
    mode_t old = umask(0);
    umask(old);
    return old;
}

int main(int argc, char **argv) {
#ifndef DEBUG
    freopen("/dev/null", "w", stderr);
#endif
    int i = 1;
    UMASK = current_umask();
    char *mode = NULL;
    for(; i < argc-1; i++) {
        if(argv[i][0] == '-' && argv[i][1] == '-') {
            // argument or --reference
            fprintf(stderr, "unsupported argument: %s\n", argv[i]);
        } else if(argv[i][0] >= '0' && argv[i][0] <= '9') {
            // octal-mode
            while (*argv[i] != NULL) {
                MODE *= 8;
                MODE += *argv[i] - '0';
                argv[i]++;
            }
            i++;
            break;
        } else {
            // mod
            mode = argv[i];
//            parse_mod(argv[i]);
            i++;
            break;
        }
    }
    fprintf(stderr, "argv[i] = %s\n", argv[i]);
    fprintf(stderr, "mode = %s\n", mode);
    // chmod
    if(mode == NULL) {
        for(; i < argc; i++) {
            chmod(argv[i], MODE);
        }
    } else {
        for(; i < argc; i++) {
            struct stat filestat;
            if (stat(argv[i], &filestat) == -1) {
                fprintf(stderr, "stat, error: %s\n", strerror(errno));
            }
            mode_t newMode = parse_mod(mode, filestat.st_mode);
            if (chmod(argv[i], newMode) == -1) {
                fprintf(stderr, "chmod, error: %s\n", strerror(errno));
            }
        }
    }
    return 0;
}

// chmod u=s,g=s tmp.c的行为与chmod不同(仅为=s时不同，其他含有多个等号时相同)
```

## 15.7
