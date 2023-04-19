---
title: 使用afl对bind进行测试
date: 2023-1-11 12:15:37
tags: 
    - QSYM
    - afl
    - MOPT
    - bind
    - 组会 
categories: 组会
toc: true
language: zh-CN
---

## 使用afl对bind进行编译

- 希望使用afl对bind进行编译
- 通过`./configure -help`知道，需要配置下面几个环境变量，达到替换编译器的目的

```sh
export CC='afl-gcc'
export CXX='afl-g++'
```

- 对bind进行编译

```sh
./configure
sudo make
sudo make install
```

## 使用qsym进行测试（结合MOPT-FAST）

- 使用正常的`gcc`编译`bind`，将生成的`named`复制到`test/uninstrumented`下 （运行qsym需要）
- 使用`afl-gcc`编译`bind`，将生成的`named`复制到`test/instrumented`下 （运行afl-fuzz的master和slave需要）
- 选取`MOPT-FAST`中的一个测试用例，复制到`test/testcase_dir`
- 按照qsym文档的顺序依次启动master，slave和qsym，命令如下


```sh
afl-fuzz -m 4096 -M afl-master -i testcase_dir/ -o finding_dir/ -- ./instrumented/named
afl-fuzz -m 4096 -S afl-slave -i testcase_dir/ -o finding_dir/ -- ./instrumented/named

# 打开qsym环境
source ../qsym/venv/bin/activate
../qsym/bin/run_qsym_afl.py -a afl-slave -o finding_dir/ -n qsym -- ./uninstrumented/named
```

### 问题1
- 报错 Pipe at the beginning of 'core_pattern'

```sh
echo core | sudo tee /proc/sys/kernel/core_pattern
```

> 之前我们创建了一个virtualenv，这次运行第三个命令时，也要先进入这个环境中

### master输出
```sh

                     american fuzzy lop 2.57b (afl-master)

┌─ process timing ─────────────────────────────────────┬─ overall results ─────┐
│        run time : 0 days, 0 hrs, 0 min, 59 sec       │  cycles done : 0      │
│   last new path : 0 days, 0 hrs, 0 min, 2 sec        │  total paths : 15     │
│ last uniq crash : none seen yet                      │ uniq crashes : 0      │
│  last uniq hang : none seen yet                      │   uniq hangs : 0      │
├─ cycle progress ────────────────────┬─ map coverage ─┴───────────────────────┤
│  now processing : 0 (0.00%)         │    map density : 7.53% / 7.59%         │
│ paths timed out : 0 (0.00%)         │ count coverage : 1.01 bits/tuple       │
├─ stage progress ────────────────────┼─ findings in depth ────────────────────┤
│  now trying : havoc                 │ favored paths : 1 (6.67%)              │
│ stage execs : 2533/16.4k (15.46%)   │  new edges on : 13 (86.67%)            │
│ total execs : 3608                  │ total crashes : 0 (0 unique)           │
│  exec speed : 50.36/sec (slow!)     │  total tmouts : 4 (4 unique)           │
├─ fuzzing strategy yields ───────────┴───────────────┬─ path geometry ────────┤
│   bit flips : 1/32, 0/31, 0/29                      │    levels : 2          │
│  byte flips : 0/4, 0/3, 0/1                         │   pending : 15         │
│ arithmetics : 1/224, 0/25, 0/0                      │  pend fav : 1          │
│  known ints : 0/25, 0/84, 0/44                      │ own finds : 14         │
│  dictionary : 0/0, 0/0, 0/0                         │  imported : 0          │
│       havoc : 0/0, 0/0                              │ stability : 97.85%     │
│        trim : n/a, 0.00%                            ├────────────────────────┘
└─────────────────────────────────────────────────────┘          [cpu000:168%]

```

### slave 输出
```sh
   american fuzzy lop 2.57b (afl-slave)

┌─ process timing ─────────────────────────────────────┬─ overall results ─────┐
│        run time : 0 days, 0 hrs, 0 min, 33 sec       │  cycles done : 0      │
│   last new path : 0 days, 0 hrs, 0 min, 4 sec        │  total paths : 14     │
│ last uniq crash : none seen yet                      │ uniq crashes : 0      │
│  last uniq hang : none seen yet                      │   uniq hangs : 0      │
├─ cycle progress ────────────────────┬─ map coverage ─┴───────────────────────┤
│  now processing : 0 (0.00%)         │    map density : 7.53% / 7.58%         │
│ paths timed out : 0 (0.00%)         │ count coverage : 1.49 bits/tuple       │
├─ stage progress ────────────────────┼─ findings in depth ────────────────────┤
│  now trying : havoc                 │ favored paths : 1 (7.14%)              │
│ stage execs : 1163/4096 (28.39%)    │  new edges on : 11 (78.57%)            │
│ total execs : 1700                  │ total crashes : 0 (0 unique)           │
│  exec speed : 50.70/sec (slow!)     │  total tmouts : 12 (8 unique)          │
├─ fuzzing strategy yields ───────────┴───────────────┬─ path geometry ────────┤
│   bit flips : n/a, n/a, n/a                         │    levels : 2          │
│  byte flips : n/a, n/a, n/a                         │   pending : 14         │
│ arithmetics : n/a, n/a, n/a                         │  pend fav : 1          │
│  known ints : n/a, n/a, n/a                         │ own finds : 13         │
│  dictionary : n/a, n/a, n/a                         │  imported : 0          │
│       havoc : 0/0, 0/0                              │ stability : 53.47%     │
│        trim : n/a, n/a                              ├────────────────────────┘
└─────────────────────────────────────────────────────┘          [cpu001:166%]
```

### qsym 输出

```sh
(venv) tt@ubuntu:~/Desktop/dns/test$ ../qsym/bin/run_qsym_afl.py -a afl-slave -o finding_dir/ -n qsym -- ./uninstrumented/named
DEBUG:qsym.afl:Temp directory=/tmp/tmpvbo369
DEBUG:qsym.afl:Run qsym: input=finding_dir/afl-slave/queue/id:000037,src:000005,op:havoc,rep:2,+cov
DEBUG:qsym.Executor:Executing timeout -k 5 90 /home/tt/Desktop/dns/qsym/venv/lib/python2.7/site-packages/qsym/../../../../third_party/pin-2.14-71313-gcc.4.4.7-linux/pin.sh -ifeellucky -t /home/tt/Desktop/dns/qsym/venv/lib/python2.7/site-packages/qsym/pintool/obj-intel64/libqsym.so -logfile /tmp/tmpvbo369/qsym-out-0/pin.log -i /home/tt/Desktop/dns/test/finding_dir/qsym/.cur_input -s 1 -o /tmp/tmpvbo369/qsym-out-0 -l 1 -b finding_dir/qsym/bitmap -- ./uninstrumented/named
DEBUG:qsym.afl:Total=13 s, Emulation=13 s, Solver=0 s, Return=-4
DEBUG:qsym.afl:Generate 0 testcases
DEBUG:qsym.afl:0 testcases are new
DEBUG:qsym.afl:Run qsym: input=finding_dir/afl-slave/queue/id:000032,src:000005,op:havoc,rep:16,+cov
DEBUG:qsym.Executor:Executing timeout -k 5 90 /home/tt/Desktop/dns/qsym/venv/lib/python2.7/site-packages/qsym/../../../../third_party/pin-2.14-71313-gcc.4.4.7-linux/pin.sh -ifeellucky -t /home/tt/Desktop/dns/qsym/venv/lib/python2.7/site-packages/qsym/pintool/obj-intel64/libqsym.so -logfile /tmp/tmpvbo369/qsym-out-1/pin.log -i /home/tt/Desktop/dns/test/finding_dir/qsym/.cur_input -s 1 -o /tmp/tmpvbo369/qsym-out-1 -l 1 -b finding_dir/qsym/bitmap -- ./uninstrumented/named
DEBUG:qsym.afl:Total=9 s, Emulation=9 s, Solver=0 s, Return=-4
DEBUG:qsym.afl:Generate 0 testcases
DEBUG:qsym.afl:0 testcases are new
DEBUG:qsym.afl:Run qsym: input=finding_dir/afl-slave/queue/id:000024,src:000005,op:havoc,rep:128,+cov
DEBUG:qsym.Executor:Executing timeout -k 5 90 /home/tt/Desktop/dns/qsym/venv/lib/python2.7/site-packages/qsym/../../../../third_party/pin-2.14-71313-gcc.4.4.7-linux/pin.sh -ifeellucky -t /home/tt/Desktop/dns/qsym/venv/lib/python2.7/site-packages/qsym/pintool/obj-intel64/libqsym.so -logfile /tmp/tmpvbo369/qsym-out-2/pin.log -i /home/tt/Desktop/dns/test/finding_dir/qsym/.cur_input -s 1 -o /tmp/tmpvbo369/qsym-out-2 -l 1 -b finding_dir/qsym/bitmap -- ./uninstrumented/named
```

## 总结

- `qsym`结合`mopt`对`bind`的`dns`服务器进行了测试，`afl`总共跑了`1 days, 11 hrs, 53 min, 22 sec`, 并没有生成任何testcase

- 每次输出总伴随这个这个timeout，不知道是什么问题
```sh
DEBUG:qsym.Executor:Executing timeout -k 5 90 /home/tt/Desktop/dns/qsym/venv/lib/python2.7/site-packages/qsym/../../../../third_party/pin-2.14-71313-gcc.4.4.7-linux/pin.sh -ifeellucky -t /home/tt/Desktop/dns/qsym/venv/lib/python2.7/site-packages/qsym/pintool/obj-intel64/libqsym.so -logfile /tmp/tmphuJKne/qsym-out-262/pin.log -i /home/tt/Desktop/dns/test/finding_dir/qsym/.cur_input -s 1 -o /tmp/tmphuJKne/qsym-out-262 -l 1 -b finding_dir/qsym/bitmap -- ./uninstrumented/named
```

> 查看了很多`issue`，发现上传的日志中大家也都有timeout