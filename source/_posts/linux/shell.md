---
title: shell的使用
date: 2022-10-27 18:05:00
tags: shell
categories: linux
toc: true
language: zh-CN
---

## shell fuction
### 函数定义
- 定义1
{% codeblock xxx.sh lang:sh %}
function funcName() {
    # do sth
}
{% endcodeblock %}
- 定义2
{% codeblock xxx.sh lang:sh %}
f2() {
    value=$(($1+$2+1))
    echo $1 "+" $2 "=" $value
}
{% endcodeblock %}

### 传参
{% codeblock xxx.sh lang:sh %}
function funcName() {
    echo $1 # 打印第一个参数
    echo $2 # 打印第二个参数
}
{% endcodeblock %}

### 调用
- 直接在脚本中调用

{% codeblock xxx.sh lang:sh %}
function funcName() {
    echo $1 # 打印第一个参数
    echo $2 # 打印第二个参数
}
funcName 刘喵喵 大帅哥
{% endcodeblock %}

- 在shell中调用


{% codeblock shell lang:sh %}
. xxx.sh # import导入其中的函数
funcName 刘喵喵 大帅哥
{% endcodeblock %}

> 如果function写在`/etc/profile`、`~/.bashrc`下，则可以直接调用

### 应用
- 有了以上方法，在bashrc中将自己常用但容易遗忘的命令写成函数，就可以方便的调用了
- 如果函数忘了，，那就可以去`~/.bashrc`下看看😅x1
- 如果忘记去哪里看了，，，那就来看看这篇文章😅x2
- 如果忘记这篇文章，，，那我直接😅x3

{% codeblock ~/.bashrc lang:sh %}
function setgitproxy() {
    git config --global http.proxy 'socks5h://localhost:7890'
    git config --global https.proxy 'socks5h://localhost:7890'
}
function unsetgitproxy() {
    git config --global --unset http.proxy
    git config --global --unset https.proxy
}
{% endcodeblock %}

## ubuntu中创建unit

### systemctl
systemctl 提供了一组子命令来管理单个的 unit，其命令格式为：
```sh
systemctl [command] [unit]
```

### 创建unit

- 编写`.service`文件
```sh
sudo vim /etc/systemd/system/xxx.service
```

{% codeblock xxx.service lang:sh %}
[Unit]
Description=clash daemon

[Service]
Type=simple
User=root
ExecStart=/opt/xxx/xxx -d /etc/xxx/ #start时执行的命令
Restart=on-failure

[Install]
WantedBy=multi-user.target
{% endcodeblock %}

- 重新加载systemctl daemon
```sh
sudo systemctl daemon-reload
```

- 启动service

```sh
sudo systemctl start xxx.service
```

- 设置为开机启动

```sh
sudo systemctl enable xxx.service
```