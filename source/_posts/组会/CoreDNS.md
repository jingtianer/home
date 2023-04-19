---
title: CoreDNS安装使用
date: 2023-1-1 12:15:37
tags: 
    - CoreDNS
    - 组会 
categories: 组会
toc: true
language: zh-CN
---

## CoreDNS简介
- 是一个DNS服务器
- 支持插件
- 使用Go编写的

## 安装
- 预编译的可执行文件[下载地址](https://github.com/coredns/coredns/releases/tag/v1.10.0)
- Docker [DockerHub-CoreDNS](https://hub.docker.com/r/coredns/coredns/)
- 源代码编译

> 安装很简单，下载解压可以得到一个`coredns`可执行文件

## 测试
### 启动服务
```sh
./coredns -dns.port=1053
```

### 测试服务
```sh
dig @localhost -p 1053 a whoami.example.org
```

> 以上命令均未报错，且coredns打印出了服务日志

## 插件
[官方插件教程](https://coredns.io/2017/03/01/how-to-add-plugins-to-coredns/)

可以通过实现以下go语言接口，使插件获取dns服务器的请求，进行处理并返回处理结果

```go
func (wh Whoami) ServeDNS(ctx context.Context, w dns.ResponseWriter, r *dns.Msg) (int, error)
```


## 补充知识
### dig命令
dig(domain information group)是常用的域名查询工具，该工具可以从指定DNS服务器查询主机信息

```sh
; <<>> DiG 9.18.1-1ubuntu1.2-Ubuntu <<>> @localhost -p 1053 a whoami.example.org
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 32883
;; flags: qr aa rd; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 3
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: 83bd45262339483b (echoed)
;; QUESTION SECTION:
;whoami.example.org.            IN      A

;; ADDITIONAL SECTION:
whoami.example.org.     0       IN      A       127.0.0.1
_udp.whoami.example.org. 0      IN      SRV     0 0 41003 .
```
- dig 的查询时间
```sh
;; Query time: 0 msec
;; SERVER: 127.0.0.1#1053(localhost) (UDP)
;; WHEN: Sun Jan 01 10:49:45 CST 2023
;; MSG SIZE  rcvd: 135
```

#### dig的参数

- 指定DNS查询记录
```sh
dig www.baidu.com A     # 查询A记录，如果域名后面不加任何参数，默认查询A记录
dig www.baidu.com MX    # 查询MX记录
dig www.baidu.com CNAME # 查询CNAME记录
dig www.baidu.com NS    # 查询NS记录
dig www.baidu.com ANY   # 查询上面所有的记录

dig www.baidu.com A +short      # 查询A记录并显示简要的返回的结果
dig www.baidu.com A +multiline  # 查询A记录并显示详细的返回结果
```

- 指定dns服务器

```sh
dig @DNS_SERVER_IP -p port www.baidu.com
```
- 只打印answer部分
```sh
dig -p 1053 @localhost +noall +answer <name> <type>
```

[其他信息](https://blog.csdn.net/qq_41982020/article/details/121231166)
### DNS记录类型

DNS记录类型包含：A记录、AAAA记录、CNAME记录、MX记录、NS记录、TXT记录、SRV记录、URL转发。对这些类型的记录解释如下：

- A记录
将域名指向一个IPv4地址（例如：100.100.100.100），需要增加A记录

- AAAA记录
将域名指向一个IPv6地址（例如：ff03:0:0:0:0:0:0:c1），需要添加AAAA记录

- CNAME记录
将域名指向一个域名，实现与被指向域名相同的访问效果，需要增加CNAME记录。这个域名一般是主机服务商提供的一个域名

- MX记录
将域名指向一个邮件服务器地址，需要设置MX记录。建立邮箱时，一般会根据邮箱服务商提供的MX记录填写此记录

- NS记录
记录是域名服务器记录，用来指定该域名由哪个DNS服务器来进行解析。

- PTR记录
PTR记录是A记录的逆向记录，又称做IP反查记录或指针记录，负责将IP反向解析为域名

- SRV记录
Service Record，用于指定服务器提供服务的位置（如主机名和端口）数据


## 在windows下访问dns服务器

在windows中使用dig命令进行试验，如果windows可以正常输出，且dns服务器可以打印相应的日志即可

### Bind9 的安装
dig命令属于bind工具，官方提供了[ftp](ftp://ftp.isc.org/isc/bind9/9.9.9rc1/)服务器用于下载

### 使用dig命令
我使用的是wsl，首先在wsl中使用ifconfig找到wsl的ip地址，并使用下面的命令进行测试
```sh
dig @172.23.208.1 -p 1053 www.baidu.com
```

> 观察到命令可以正常返回，dns服务器也打印出了相应的日志