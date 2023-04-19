---
title: aflchurn的使用
date: 2023-3-15 12:15:37
tags: 
    - 组会 
    - afl
categories: 组会
toc: true
language: zh-CN
---

## 尝试对knot dns进行测试
> 尝试对knot dns进行测试，和之前皓辰的结果一样，程序找不到新路径

> knot dns在运行时会产生Segment fault，不知道是什么原因，程序`_exit`值为139。在github中查找了该退出代码，并没有找到相应文件

```sh
tt@ubuntu:~/Desktop/dnsenv/aflgo-knot$ export SUBJECT=$PWD/knot-dns
tt@ubuntu:~/Desktop/dnsenv/aflgo-knot$ $SUBJECT/tests-fuzz/knotd_stdio -c $SUBJECT/tests-fuzz/knotd_wrap/knot_stdio.conf
2023-03-19T20:17:55-0700 info: Knot DNS 3.3.dev.1678845372.e31fee4 starting
2023-03-19T20:17:55-0700 info: loaded configuration file '/home/tt/Desktop/dnsenv/aflgo-knot/knot-dns/tests-fuzz/knotd_wrap/knot_stdio.conf', mapsize 500 MiB
2023-03-19T20:17:55-0700 warning: no network interface configured
2023-03-19T20:17:55-0700 info: AFL, UDP handler listening on stdin
2023-03-19T20:17:55-0700 warning: removing stale PID file '/tmp/knotd-fuzz/rundir/knot.pid'
2023-03-19T20:17:55-0700 info: loading 0 zones
2023-03-19T20:17:55-0700 warning: no zones loaded
2023-03-19T20:17:55-0700 info: starting server
2023-03-19T20:17:55-0700 info: server started in the foreground, PID 128184
2023-03-19T20:17:55-0700 info: control, binding to '/tmp/knotd-fuzz/rundir/knot.sock'
2023-03-19T20:17:55-0700 info: AFL, empty TCP handler
Segmentation fault
tt@ubuntu:~/Desktop/dnsenv/aflgo-knot$ echo $?
139
```

## aflchurn简介

- [aflchurn主页](https://github.com/aflchurn/aflchurn)

作者通过观察`oss-fuzz`中的bugs发现，新出现的bug往往与最新添加、修改的代码有关，在fuzz时给予最新修改过的bb块更高的权重，其他bb块更低的权重

### aflchurn(/tʃɜːn/)安装
```shell
git clone https://github.com/aflchurn/aflchurn.git
cd aflchurn
export AFLCHURN=$PWD
make clean all
cd llvm_mode
make clean all
```

> 比较简单，直接下载编译即可

### 利用aflchurn插装
```shell
CC=$AFLCHURN/afl-clang-fast CXX=$AFLCHURN/afl-clang-fast++ ./configure [...options...]
make
```

> 与afl相同

### 测试bind


> 问题1：插装时，发现大量文件产生错误`fatal: unknown date format unix`，不能正确读取文件的修改时间信息
>

```sh
                  aflchurn 2.57b (dns_message_parse)

┌─ process timing ─────────────────────────────────────┬─ overall results ─────┐
│        run time : 0 days, 0 hrs, 12 min, 25 sec      │  cycles done : 0      │
│   last new path : 0 days, 0 hrs, 0 min, 1 sec        │  total paths : 1203   │
│ last uniq crash : none seen yet                      │ uniq crashes : 0      │
│  last uniq hang : none seen yet                      │   uniq hangs : 0      │
├─ cycle progress ────────────────────┬─ map coverage ─┴───────────────────────┤
│  now processing : 268 (22.28%)      │    map density : 2.15% / 8.51%         │
│ paths timed out : 0 (0.00%)         │ count coverage : 3.64 bits/tuple       │
├─ stage progress ────────────────────┼─ findings in depth ────────────────────┤
│  now trying : arith 8/8             │ favored paths : 353 (29.34%)           │
│ stage execs : 2166/9256 (23.40%)    │  new edges on : 452 (37.57%)           │
│ total execs : 1.70M                 │ total crashes : 0 (0 unique)           │
│  exec speed : 1930/sec              │aflchurn factor: 2.136                  │
├─ fuzzing strategy yields ───────────┴───────────────┬─ path geometry ────────┤
│   bit flips : 265/66.5k, 59/66.4k, 32/66.3k         │    levels : 2          │
│  byte flips : 3/8312, 7/6476, 5/6420                │   pending : 1147       │
│ arithmetics : 233/356k, 8/196k, 1/84.5k             │  pend fav : 343        │
│  known ints : 12/26.2k, 26/136k, 32/251k            │ own finds : 903        │
│  dictionary : 0/0, 0/0, 14/96.4k                    │  imported : n/a        │
│       havoc : 206/312k, 0/0                         │ stability : 75.52%     │
│        trim : 0.00%/3397, 21.26%                    ├────────────────────────┘
└─────────────────────────────────────────────────────┘          [cpu002:127%]
```

> aflchurm和aflgo一直都在跑，最后跑出了一个oom

```sh
[-] PROGRAM ABORT : Unable to request new process from fork server (OOM?)
         Location : run_target(), afl-fuzz.c:2882
```

> 应该是运行时设置了参数`-m 12800`，每次测试程序之允许分配12800MB的内存，导致程序内存不足

### 增大内存分配

- 将内存参数设置为`-m none`，不限制内存的使用
- 将in文件夹改为`-`，表示继续之间的模糊测试进度

```sh
LD_LIBRARY_PATH=$SUBJECT/lib/isc/.libs:$SUBJECT/lib/dns/.libs $AFLGO/afl-fuzz -m none  -i - -o out $SUBJECT/fuzz/.libs/dns_message_parse
```