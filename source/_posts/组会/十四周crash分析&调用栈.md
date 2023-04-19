---
title: crash分析&调用栈
date: 2023-4-11 12:15:37
tags: 
    - 组会 
categories: 组会
toc: true
language: zh-CN
---

## 挖掘情况

|版本|软件|
|-|-|
|bind9_15_0|named|

## dns_rdata_fromwire_text的crash分析
- 这个是fuzz文件夹下挖出的crash，没什么参考价值，先用这个摸索一下分析方法


|版本|软件|
|-|-|
|bind9_16_0|dns_rdata_fromwire_text|


### main.c的代码结构

main.c中包含三个函数
- test_all_from，传入一个目录，读取目录下所有文件作为测试用例，每读取一个，调用`LLVMFuzzerTestOneInput`进行测试
- main(没有启用AFL时)，将目录初始化为`fuzz`文件夹的绝对路径，调用`test_all_from`
- main(启用AFL时)，从`stdin`中读取一个测试用例，每读取一个，调用`LLVMFuzzerTestOneInput`进行测试

> 这里使用启用AFL时的main函数，猜测crashwalk也会将测试用例放到标准输入中


#### 编译参数
- 不使用AFL，加`-g`和`address`，检测内存问题的sanitizer
```shell
export CC=clang
export CXX=clang++

export CFLAGS="-g -fsanitize=address -fno-omit-frame-pointer -O1"
export CXXFLAGS="-g -fsanitize=address -fno-omit-frame-pointer -O1"

# build for gdb
pushd $SUBJECT
  make clean
  ./configure --enable-fuzz=afl
  make
  pushd fuzz
    make
  popd
popd
```

- 由于crashwalk本质上也是gdb，crashwalk会模仿afl的输入输出方式，所以这里编译时依旧添加afl选项，将`AFL_LOOP`编译至代码中

### 直接运行
```shell
for dir in `ls ../out`; do
    if [ -d "../out/$dir/crashes" ]; then
        ls ../out/$dir/crashes
        for file in `ls ../out/$dir/crashes`; do
            echo Input = $PWD/../out/$dir/crashes/$file
            $SUBJECT/fuzz/dns_rdata_fromwire_text < $PWD/../out/$dir/crashes/$file
        done
    else
        echo omit, $dir is not a directory or no crashes under $dir
    fi
done

(./gdb.sh 2>&1 1>/dev/null) | grep Aborted -B 1 | sort | uniq # 读取标准错误流中的Abort，排序去重
```

```shell
dns_rdata_fromwire_text: dns_rdata_fromwire_text.c:138: int LLVMFuzzerTestOneInput(const uint8_t *, size_t): Assertion `result == ISC_R_SUCCESS' failed.
dns_rdata_fromwire_text: dns_rdata_fromwire_text.c:150: int LLVMFuzzerTestOneInput(const uint8_t *, size_t): Assertion `result == ISC_R_SUCCESS' failed.
dns_rdata_fromwire_text: dns_rdata_fromwire_text.c:151: int LLVMFuzzerTestOneInput(const uint8_t *, size_t): Assertion `rdata2.length == size' failed.
dns_rdata_fromwire_text: dns_rdata_fromwire_text.c:161: int LLVMFuzzerTestOneInput(const uint8_t *, size_t): Assertion `result == ISC_R_SUCCESS' failed.
```

由于bind9报错的同时会答打印出出错的位置，经过排序去重，共有四处位置发送错误。这里因为是fuzz文件夹下的东西，没什么意义

### crashwalk
- 使用crashwalk，先将所有crash读一遍
```shell
for dir in `ls ../out`; do
    if [ -d "../out/"$dir"/crashes" ]; then
        echo Crashwalk, reading crashes in $dir
        cwtriage -root $AFL_CRASHES -afl > $dir.crashwalk
    else
        echo omit, $dir is not a directory or no crashes under $dir
    fi
done
```

- 提取其中的Stack Head

```sh
cat *.crashwalk | grep 'Stack Head' -A 6 | tee tmp.crashwalk # -A 输出 grep 后6行
Stack Head (6 entries):
   __GI_raise                @ 0x00007ffff6887438: in (BL)
   __GI_abort                @ 0x00007ffff688903a: in (BL)
   __assert_fail_base        @ 0x00007ffff687fbe7: in (BL)
   __GI___assert_fail        @ 0x00007ffff687fc92: in (BL)
   LLVMFuzzerTestOneInput    @ 0x00000000005163f9: in /home/ubuntu/dnsenv/aflgo-workdir/bind9-16-39/bind9/fuzz/dns_rdata_fromwire_text
   main                      @ 0x00000000005167fe: in /home/ubuntu/dnsenv/aflgo-workdir/bind9-16-39/bind9/fuzz/dns_rdata_fromwire_text
```
- 提取其中分类
```sh
cat *.crashwalk | grep 'Classification' | tee classification.crashwalk # -A 输出 grep 后6行
```
> 这里输出全是Unknown

### gdb
- 这里asan和gdb会冲突，编译时不要用asan(后面named加asan调试没问题)

#### 直接运行

查看其函数调用栈，发现其输出与crashwalk相同，有更详细的具体代码文件，行号
```gdb
#0  0x00007ffff6887438 in __GI_raise (sig=sig@entry=6) at ../sysdeps/unix/sysv/linux/raise.c:54
#1  0x00007ffff688903a in __GI_abort () at abort.c:89
#2  0x00007ffff687fbe7 in __assert_fail_base (fmt=<optimized out>, assertion=assertion@entry=0x90b360 <.str> "result == ISC_R_SUCCESS", file=file@entry=0x90b2c0 <.str> "dns_rdata_fromwire_text.c", 
    line=line@entry=138, function=function@entry=0x90b300 <__PRETTY_FUNCTION__.LLVMFuzzerTestOneInput> "int LLVMFuzzerTestOneInput(const uint8_t *, size_t)") at assert.c:92
#3  0x00007ffff687fc92 in __GI___assert_fail (assertion=0x90b360 <.str> "result == ISC_R_SUCCESS", file=0x90b2c0 <.str> "dns_rdata_fromwire_text.c", line=138, 
    function=0x90b300 <__PRETTY_FUNCTION__.LLVMFuzzerTestOneInput> "int LLVMFuzzerTestOneInput(const uint8_t *, size_t)") at assert.c:101
#4  0x00000000005163f9 in LLVMFuzzerTestOneInput (
    data=0x618000000082 "art_time        : 1681477147\nlast_update       : 1681477267\nfuzzer_pid        : 7592\ncycles_done       : 0\nexecs_done        : 7074\nexecs_per_sec     : 58.58\npaths_total       : 100\npaths_favored     "..., size=887) at dns_rdata_fromwire_text.c:138
#5  0x0000000000516c53 in test_all_from (dirname=0x7fffffffca80 "/home/ubuntu/dnsenv/aflgo-workdir/bind9-16-39/out") at main.c:69
#6  0x00000000005167fe in main (argc=<optimized out>, argv=<optimized out>) at main.c:109
```

#### 查看所有调用栈
使用非交互式执行gdb脚本，进入函数`dns_rdata_tofmttext`中查看调用栈



```sh
for dir in `ls ../out`; do
    cat /dev/null > $dir.gdb
    if [ -d "../out/$dir/crashes" ]; then
        for file in `ls ../out/$dir/crashes`; do
          GDBSEQ="break 138;r < ../out/$dir/crashes/$file;bt;q"
          echo $GDBSEQ | awk '{len=split($0,a,";");for(i=1;i<=len;i++)print ""a[i] ;}' | tee script.gdb
          gdb -q --batch -x script.gdb $SUBJECT/fuzz/dns_rdata_fromwire_text >> $dir.gdb
        done
    else
        echo omit, $dir is not a directory or no crashes under $dir
    fi
done
```

- 直接运行，在return0前打一个断点，循环读取所有crash，通过gdb脚本输入到程序中，运行，如果出错，会在出错的位置打印bt，否则不输出只有一个`main`


```sh
Program received signal SIGABRT, Aborted.
0x00007ffff6fae438 in __GI_raise (sig=sig@entry=6) at ../sysdeps/unix/sysv/linux/raise.c:54
#0  0x00007ffff6fae438 in __GI_raise (sig=sig@entry=6) at ../sysdeps/unix/sysv/linux/raise.c:54
#1  0x00007ffff6fb003a in __GI_abort () at abort.c:89
#2  0x00007ffff6fa6be7 in __assert_fail_base (fmt=<optimized out>, assertion=assertion@entry=0x8392f7 "result == ISC_R_SUCCESS", file=file@entry=0x8392a9 "dns_rdata_fromwire_text.c", line=line@entry=138, function=function@entry=0x8392c3 "int LLVMFuzzerTestOneInput(const uint8_t *, size_t)") at assert.c:92
#3  0x00007ffff6fa6c92 in __GI___assert_fail (assertion=0x8392f7 "result == ISC_R_SUCCESS", file=0x8392a9 "dns_rdata_fromwire_text.c", line=138, function=0x8392c3 "int LLVMFuzzerTestOneInput(const uint8_t *, size_t)") at assert.c:101
#4  0x0000000000423524 in LLVMFuzzerTestOneInput (data=0x7ffffffedce2 "", data@entry=0x7ffffffedce0 "(", size=970, size@entry=972) at dns_rdata_fromwire_text.c:138
#5  0x0000000000423a20 in main (argc=<optimized out>, argv=<optimized out>) at main.c:136
A debugging session is active.
```

## named crash分析


|版本|软件|
|-|-|
|bind9_15_0|named|

### crashwalk

首先通过crashwalk，发现其三个crash分类均为可利用的`Classification: EXPLOITABLE`，调用栈都相同

```sh
Extra Data:
   Description: Possible stack corruption
   Short description: PossibleStackCorruption (7/22)
   Explanation: GDB generated an error while unwinding the stack and/or the stack contained return addresses that were not mapped in the inferior's process address space and/or the stack pointer is pointing to a location outside the default stack region. These conditions likely indicate stack corruption, which is generally considered exploitable.
```

通过crashwalk分析，三个crash均会导致栈损坏，其调用栈如下
```sh
Stack Head (16 entries):
   __GI_raise                @ 0x00007ffff43a0438: in (BL)
   __GI_abort                @ 0x00007ffff43a203a: in (BL)
   __sanitizer::Abort        @ 0x00000000004f32eb: in /home/ubuntu/dnsenv/aflgo-workdir/bind9-16-39-named/bind9/bin/named/.libs/named
   __asan::ReserveShadowMemo @ 0x00000000004d5dd2: in /home/ubuntu/dnsenv/aflgo-workdir/bind9-16-39-named/bind9/bin/named/.libs/named
   __asan::InitializeShadowM @ 0x00000000004d6115: in /home/ubuntu/dnsenv/aflgo-workdir/bind9-16-39-named/bind9/bin/named/.libs/named
   __asan::AsanInitInternal  @ 0x00000000004d588f: in /home/ubuntu/dnsenv/aflgo-workdir/bind9-16-39-named/bind9/bin/named/.libs/named
   _dl_init                  @ 0x00007ffff7de7862: in /lib/x86_64-linux-gnu/ld-2.23.so
   _dl_start_user            @ 0x00007ffff7dd7c6a: in /lib/x86_64-linux-gnu/ld-2.23.so
   None                      @ 0x0000000000000006: in ?
   None                      @ 0x00007fffffffdf7c: in [stack]
   None                      @ 0x00007fffffffdfcc: in [stack]
   None                      @ 0x00007fffffffdfcf: in [stack]
   None                      @ 0x00007fffffffdfe5: in [stack]
   None                      @ 0x00007fffffffdfe8: in [stack]
   None                      @ 0x00007fffffffdfeb: in [stack]
   None                      @ 0x0000000000000000: in ?
```

这里调用栈的有效信息只有函数名，需要手动gdb调试一下。

### gdb结果

```sh
#1  0x00007ffff43a003a in __GI_abort () at abort.c:89

#2  0x000000000053baf1 in assertion_failed (file=<optimized out>, line=<optimized out>, type=<optimized out>, cond=<optimized out>) at main.c:234

#3  0x00007ffff750a547 in isc_assertion_failed (file=0x4e57 <error: Cannot access memory at address 0x4e57>, line=20061, line@entry=692, type=6, type@entry=isc_assertiontype_ensure, cond=0x7ffff439e438 <__GI_raise+56> "H=") at assertions.c:48
#3  0x00007ffff750a547 in isc_assertion_failed (file=0x4e69 <error: Cannot access memory at address 0x4e69>, line=20082, line@entry=692, type=6, type@entry=isc_assertiontype_ensure, cond=0x7ffff439e438 <__GI_raise+56> "H=") at assertions.c:48
#3  0x00007ffff750a547 in isc_assertion_failed (file=0x4e7a <error: Cannot access memory at address 0x4e7a>, line=20110, line@entry=692, type=6, type@entry=isc_assertiontype_ensure, cond=0x7ffff439e438 <__GI_raise+56> "H=") at assertions.c:48

#4  0x00007ffff6c8dd7c in dns_name_countlabels (name=<optimized out>) at name.c:692

#5  0x00007ffff671921f in query_getdb (client=0x61f00000fc80, name=0x616000020180, qtype=1, options=0, zonep=0x7fffec6e2b20, dbp=0x7fffec6e2ad0, versionp=0x7fffec6e2ad8, is_zonep=0x7fffec6e2689) at query.c:1372
#5  0x00007ffff671921f in query_getdb (client=0x61f00000fc80, name=0x616000020180, qtype=1, options=0, zonep=0x7fffed6e4b20, dbp=0x7fffed6e4ad0, versionp=0x7fffed6e4ad8, is_zonep=0x7fffed6e4689) at query.c:1372
#5  0x00007ffff671921f in query_getdb (client=0x61f000010a80, name=0x616000020180, qtype=1, options=0, zonep=0x7fffeeee7b20, dbp=0x7fffeeee7ad0, versionp=0x7fffeeee7ad8, is_zonep=0x7fffeeee7689) at query.c:1372

#6  0x00007ffff671646d in ns__query_start (qctx=0x7fffec6e2650) at query.c:5680
#6  0x00007ffff671646d in ns__query_start (qctx=0x7fffed6e4650) at query.c:5680
#6  0x00007ffff671646d in ns__query_start (qctx=0x7fffeeee7650) at query.c:5680

#7  0x00007ffff6729cf4 in query_setup (client=0x61f00000fc80, qtype=1) at query.c:5528
#7  0x00007ffff6729cf4 in query_setup (client=0x61f000010a80, qtype=1) at query.c:5528

#8  0x00007ffff6728639 in ns_query_start (client=0x61f00000fc80, handle=0x614000010040) at query.c:12094
#8  0x00007ffff6728639 in ns_query_start (client=0x61f000010a80, handle=0x614000010240) at query.c:12094

#9  0x00007ffff66f16bb in ns__client_request (handle=0x614000010040, eresult=ISC_R_SUCCESS, region=0x7fffec6e3e20, arg=0x613000001fc0) at client.c:2236
#9  0x00007ffff66f16bb in ns__client_request (handle=0x614000010040, eresult=ISC_R_SUCCESS, region=0x7fffed6e5e20, arg=0x613000001fc0) at client.c:2236
#9  0x00007ffff66f16bb in ns__client_request (handle=0x614000010240, eresult=ISC_R_SUCCESS, region=0x7fffeeee8e20, arg=0x613000001fc0) at client.c:2236

#10 0x00007ffff74c55c0 in isc__nm_readcb_job (arg=0x61c000000080) at netmgr/netmgr.c:1883

#11 isc__nm_readcb (sock=0x7fffec6e3de0, uvreq=<optimized out>, eresult=<optimized out>, async=<optimized out>) at netmgr/netmgr.c:1897
#11 isc__nm_readcb (sock=0x7fffed6e5de0, uvreq=<optimized out>, eresult=<optimized out>, async=<optimized out>) at netmgr/netmgr.c:1897
#11 isc__nm_readcb (sock=0x7fffeeee8de0, uvreq=<optimized out>, eresult=<optimized out>, async=<optimized out>) at netmgr/netmgr.c:1897

#12 0x00007ffff750449c in isc__nm_udp_read_cb (handle=<optimized out>, nrecv=<optimized out>, buf=<optimized out>, addr=<optimized out>, flags=<optimized out>) at netmgr/udp.c:592

#13 0x00007ffff56d4ff3 in uv__udp_recvmmsg (handle=handle@entry=0x629000006910, buf=buf@entry=0x7fffeeee99a0) at src/unix/udp.c:231
#13 0x00007ffff56d4ff3 in uv__udp_recvmmsg (handle=handle@entry=0x6290000082a8, buf=buf@entry=0x7fffed6e69a0) at src/unix/udp.c:231
#13 0x00007ffff56d4ff3 in uv__udp_recvmmsg (handle=handle@entry=0x6290000093b8, buf=buf@entry=0x7fffec6e49a0) at src/unix/udp.c:231

#14 0x00007ffff56d5f4b in uv__udp_recvmsg (handle=0x629000006910) at src/unix/udp.c:273
#14 0x00007ffff56d5f4b in uv__udp_recvmsg (handle=0x6290000082a8) at src/unix/udp.c:273
#14 0x00007ffff56d5f4b in uv__udp_recvmsg (handle=0x6290000093b8) at src/unix/udp.c:273

#15 uv__udp_io (loop=<optimized out>, w=0x629000006990, revents=1) at src/unix/udp.c:178
#15 uv__udp_io (loop=<optimized out>, w=0x629000008328, revents=1) at src/unix/udp.c:178
#15 uv__udp_io (loop=<optimized out>, w=0x629000009438, revents=1) at src/unix/udp.c:178

#16 0x00007ffff56d9a0c in uv__io_poll (loop=loop@entry=0x627000000e80, timeout=<optimized out>) at src/unix/epoll.c:374
#16 0x00007ffff56d9a0c in uv__io_poll (loop=loop@entry=0x627000002290, timeout=<optimized out>) at src/unix/epoll.c:374
#16 0x00007ffff56d9a0c in uv__io_poll (loop=loop@entry=0x627000002ff0, timeout=<optimized out>) at src/unix/epoll.c:374

#17 0x00007ffff56c6bd0 in uv_run (loop=loop@entry=0x627000000e80, mode=mode@entry=UV_RUN_DEFAULT) at src/unix/core.c:406
#17 0x00007ffff56c6bd0 in uv_run (loop=loop@entry=0x627000002290, mode=mode@entry=UV_RUN_DEFAULT) at src/unix/core.c:406
#17 0x00007ffff56c6bd0 in uv_run (loop=loop@entry=0x627000002ff0, mode=mode@entry=UV_RUN_DEFAULT) at src/unix/core.c:406

#18 0x00007ffff7563287 in loop_run (loop=0x627000000e60) at loop.c:273
#18 0x00007ffff7563287 in loop_run (loop=0x627000002270) at loop.c:273
#18 0x00007ffff7563287 in loop_run (loop=0x627000002fd0) at loop.c:273

#19 loop_thread (arg=<optimized out>) at loop.c:299
```


- 找到调用栈中造成断言的位置`name.c:692`

```c
unsigned int
dns_name_countlabels(const dns_name_t *name) {
	/*
	 * How many labels does 'name' have?
	 */

	REQUIRE(VALID_NAME(name));

	ENSURE(name->labels <= DNS_NAME_MAXLABELS); 

	return (name->labels);
}
```

> 出问题的位置在`ENSURE`，name的个数应该小于最大限制，gdb将该位置设置为断点并运行查看该变量的值

- 源码中最大label为127，但是运行时打印*name的结果为4
```c
#define DNS_NAME_MAXLABELS 127
````

> 暂时调试到这里，想不通这里为什么会abort，后续了解一下gdb和栈损坏相关的知识