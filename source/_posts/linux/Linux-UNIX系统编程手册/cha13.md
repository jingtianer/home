---
title: cha13.文件I/O缓冲
date: 2023-4-26 18:05:00
tags: 
    - Linux/UNIX系统编程手册
categories: linux
toc: true
language: zh-CN
---

## 13.1
使用shell内嵌的time命令，测算程序清单4-1(copy.c)在当前环境下的用时。
a）使用不同的文件和缓冲区大小进行试验。编译应用程序时使用
-DBUF_SIZE=nbytes选项可设置缓冲区大小。
b) 对open()的系统调用加入O_SYNC标识，针对不同大小的缓冲区，速度存在多
大差异?
c) 在一系列文件系统（比如，ext3、XFS、Btrfs和 JFS）中执行这些计时测试。结果相似吗?当缓冲区大小从小变大时，用时趋势相同吗?


```c
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

#ifndef BUF_SIZE
#define BUF_SIZE 1024
#endif

#define ERR(code, format, ...) do { \
    if(!(code)) { \
        fprintf(stderr, (char*)format, ##__VA_ARGS__); \
        exit(code); \
    } \
} while(0)

int main(int argc, char *argv[]) {
    char buf[BUF_SIZE];
    ssize_t readsize = 0;
    int openflag = O_RDONLY;
#ifdef SYNC
    openflag |= O_SYNC;
#endif
    int inputfd = open(argv[1], openflag);
    ERR(inputfd != -1, "fail to open %s, err:%s\n", argv[1], strerror(errno));

    int outputfd = open(argv[2], 
        O_CREAT | O_WRONLY | O_TRUNC, 
        S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
    ERR(outputfd != -1, "fail to open %s, err:%s\n", argv[2], strerror(errno));
    
    while((readsize = read(inputfd, buf, BUF_SIZE)) > 0) {
        ERR(write(outputfd, buf, readsize) == readsize, "could not write whole buffer, err:%s\n", strerror(errno));
    }
    ERR(readsize != -1, "read fail, err:%s", strerror(errno));
    ERR(close(inputfd) != -1, "fail to close input, err:%s\n", strerror(errno));
    ERR(close(outputfd) != -1, "fail to close output, err:%s\n", strerror(errno));
    return 0;
}
```
## 测试时间
```sh
BUFSIZE=1
cat /dev/null > log13.1.log
for i in `seq 15`; do
    echo round $i, BUFSIZE=$BUFSIZE >> log13.1.log
    gcc practice13_1.c -DBUF_SIZE=$BUFSIZE -o practice13_1
    /usr/bin/time -f "real = %e\nuser = %U\nsystem = %S" -o log13.1.log -a ./practice13_1 big big.copy
    BUFSIZE=`expr $BUFSIZE \* 2`
done

BUFSIZE=1
cat /dev/null > log13.1_sync.log
for i in `seq 15`; do
    echo round $i, BUFSIZE=$BUFSIZE >> log13.1_sync.log
    gcc practice13_1.c -DBUF_SIZE=$BUFSIZE -DSYNC -o practice13_1
    /usr/bin/time -f "real = %e\nuser = %U\nsystem = %S" -o log13.1_sync.log -a ./practice13_1 big big.copy
    BUFSIZE=`expr $BUFSIZE \* 2`
done
```

### 生成md
```sh
file=$1
tee awk_script.awk  2>&1 > /dev/null <<-'EOF'
{
    print "|round|bufsize|real|user|system|";
    print "|-|-|-|-|-|";len=split($0, a, "\n")-1;
    for(i = 0; i < len/4; i++) {
        split(a[i*4+1], line1, ",");
        split(line1[1], line11, " ");
        round=line11[2];split(line1[2], line12, "=");
        bufsize=line12[2];
        printf("|%s|%s|", round, bufsize);
        for(j = 2; j <= 4; j++) {
            split(a[i*4+j], linej, " ");
            printf("%s|", linej[3]); 
        }
        printf("\n");
    }
}
EOF
cat $file | awk -v RS='EOF' -f awk_script.awk
```

### 测试结果
> 测试于ext4，搭建其他文件系统太耗时了，就不弄了

- 没有O_SYNC

|round|bufsize|real|user|system|
|-|-|-|-|-|
|1|1|322.64|86.14|236.38|
|2|2|160.22|43.23|116.92|
|3|4|80.88|21.85|58.97|
|4|8|40.21|10.77|29.41|
|5|16|19.97|5.23|14.73|
|6|32|10.13|2.72|7.37|
|7|64|5.06|1.42|3.63|
|8|128|2.52|0.57|1.94|
|9|256|1.27|0.26|1.00|
|10|512|0.71|0.14|0.56|
|11|1024|0.37|0.11|0.26|
|12|2048|0.21|0.03|0.17|
|13|4096|0.14|0.03|0.10|
|14|8192|0.10|0.02|0.07|
|15|16384|0.10|0.00|0.09|

- 有O_SYNC

|round|bufsize|real|user|system|
|-|-|-|-|-|
|1|1|370.43|99.46|270.89|
|2|2|202.32|53.13|149.09|
|3|4|95.62|25.74|69.80|
|4|8|49.08|12.88|36.17|
|5|16|23.94|6.48|17.45|
|6|32|11.96|3.65|8.31|
|7|64|6.05|1.55|4.49|
|8|128|3.26|0.82|2.43|
|9|256|1.61|0.38|1.22|
|10|512|0.78|0.23|0.55|
|11|1024|0.45|0.06|0.39|
|12|2048|0.31|0.08|0.16|
|13|4096|0.24|0.04|0.14|
|14|8192|0.19|0.00|0.12|
|15|16384|0.19|0.02|0.12|

## 13.2
懒得搞

## 13.3
如下语句的执行效果是什么?
```c
fflush(fp);
fsync(fileno(fp));
```
> 先将文件指针`fp`的stdio库的缓存调用write系统调用，再获取`fd`的文件描述符，将该文件描述符的系统IO缓冲区的数据以及文件元数据强制写入存储设备

## 13.4

试解释取决于将标准输出重定向到终端还是磁盘文件,为什么如下代码的输出结果不同。
```c
printf("If I had more time,\n");
write(STDOUT_FILENO, "I would have written you a shorter letter.\n",43);
```

### 代码
```c
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>

int main() {
    printf("If I had more time,\n");
    write(STDOUT_FILENO, "I would have written you a shorter letter.\n",43);

    FILE* file = freopen("tmp13.4", "w", stdout);
    if(file == NULL) {
        return 1;
    }
    printf("If I had more time,\n");
    write(STDOUT_FILENO, "I would have written you a shorter letter.\n",43);
    fclose(file);
    return 0;
}
```
### 结果
- 终端
  - 由于终端的缓存mod默认为_IOLBUF，行缓冲io，也就是当遇到一行结束或缓存满时，就写入终端，所以会按照代码的顺序输出
- 文件
  - 普通磁盘文件的缓存mod为_IOFBUF，全缓冲io，printf会先写入stdio库的缓冲区，write直接写入系统IO缓冲区，一般情况下，write会先于stdio进入系统缓冲区，导致最终写入文件的顺序与代码中的顺序相反

## 13.5
