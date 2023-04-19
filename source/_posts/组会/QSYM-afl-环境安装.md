---
title: QSYM-afl-环境安装
date: 2023-1-7 12:15:37
tags: 
    - QSYM
    - afl
    - 组会 
categories: 组会
toc: true
language: zh-CN
---

## afl的安装
- 安装`build-essentials`和`cmake`
- github下载源码并解压
- `make`
- `make install`

`usr/local/bin`下有了编译好的afl工具
```sh
root@tt-HP:~/dns_env# find /usr/local/bin/afl*
/usr/local/bin/afl-analyze
/usr/local/bin/afl-clang
/usr/local/bin/afl-clang++
/usr/local/bin/afl-cmin
/usr/local/bin/afl-fuzz
/usr/local/bin/afl-g++
/usr/local/bin/afl-gcc
/usr/local/bin/afl-gotcpu
/usr/local/bin/afl-plot
/usr/local/bin/afl-showmap
/usr/local/bin/afl-tmin
/usr/local/bin/afl-whatsup
```

## qsym的安装

- 以下是安装方法
```sh
# disable ptrace_scope for PIN
$ echo 0|sudo tee /proc/sys/kernel/yama/ptrace_scope

# install z3 and system deps
$ ./setup.sh

# install using virtual env
$ virtualenv venv
$ source venv/bin/activate
$ pip install .
```
> 不用wsl用vm就不会有很多问题
### ptrace置0

可能是由于内核版本问题，`/proc/sys/kernel/yama/ptrace_scope`文件不存在，查到可以修改另一个文件 `/etc/sysctl.d/10-ptrace.conf`，添加或修改以下内容

```sh
kernel.yama.ptrace_scope = 0
```

在`setup.sh`中会对这个`/proc/sys/kernel/yama/ptrace_scope`文件中的值是否为0进行判断，由于我没有，将脚本中这几行删掉
```sh
if ! grep -qF "0" /proc/sys/kernel/yama/ptrace_scope; then
  echo "Please run 'echo 0|sudo tee /proc/sys/kernel/yama/ptrace_scope'"
  exit -1
fi
```

### 子模块下载问题

安装过程中发现`git submodule`下载不下来，使用递归的方式重新clone

```sh
git clone https://github.com/sslab-gatech/qsym.git --recursive
```

在`setup.sh`把git submodule 去掉
```sh
git submodule init
git submodule update
```

### 配置PYTHON环境变量

观察到setup.sh中，get-pip时需要使用python2环境，提示需要`PYTHON环境变量`

```sh
echo export PYTHON=$(echo $(whereis python2) | awk '{split($0, arr, " "); print arr[2]}') | tee -a ~/.bashrc 
source ~/.bashrc
```

### 找不到`bits/*.h`
- 安装multilib
```sh
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install -y g++-multilib
```

### 安装virtualenv

```sh
sudo apt-get install virtualenv
# or
pip install virtualenv
```

### 安装lsb

- 进行`pip install .`时可能报错`make: lsb_release: Command not found`，安装lsb既可

```sh
sudo apt install lsb-core
```


> 最终在vm的ubuntu 16.04下成功进行了安装，python环境是python3.7.9（ubuntu 16.04需要下载python3.7源码编译安装）（python2环境也成功了，其实不应该安装python3，整个项目都应该运行在python2环境下）
>

### 运行测试
```sh
cd tests
python build.py
python -m pytest -n $(nproc)
```

- requirements
  - `pip install python-afl`

- 运行结果
```sh
(venv) tt@ubuntu:~/Desktop/dns/qsym/tests$ python -m pytest -n $(nproc)
============================= test session starts ==============================
platform linux2 -- Python 2.7.12, pytest-4.6.11, py-1.11.0, pluggy-0.13.1
rootdir: /home/tt/Desktop/dns/qsym
plugins: forked-1.3.0, xdist-1.34.0
gw0 [250] / gw1 [250] / gw2 [250] / gw3 [250]
........................................................................ [ 28%]
........................................................................ [ 57%]
........................................................................ [ 86%]
..................................                                                                                                                                                                   [100%]
======================================================================================= 250 passed in 565.71 seconds =======================================================================================
```


## 使用docker安装qsym

```sh
# disable ptrace_scope for PIN
$ echo 0|sudo tee /proc/sys/kernel/yama/ptrace_scope

# build docker image
$ docker build -t qsym ./

# run docker image
$ docker run --cap-add=SYS_PTRACE -it qsym /bin/bash
```

### 错误1
- ERROR [internal] load metadata for docker.io/library/ubuntu:16.04

在docker中的`daemon.json`中修改buildkit为false
```json
"features": { "buildkit": false }
```

### ptrace置0

- 使用docker时，build时的ubuntu镜像也没有这个`/proc/sys/kernel/yama/ptrace_scope`文件。setup.sh中将脚本中这几行删掉
```sh
if ! grep -qF "0" /proc/sys/kernel/yama/ptrace_scope; then
  echo "Please run 'echo 0|sudo tee /proc/sys/kernel/yama/ptrace_scope'"
  exit -1
fi
```

### 最终的dockerfile
```dockerfile
FROM ubuntu:16.04

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak
RUN echo deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse >>/etc/apt/sources.list
RUN echo deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse >>/etc/apt/sources.list
RUN echo deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse >>/etc/apt/sources.list
RUN echo deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse >>/etc/apt/sources.list
RUN echo deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse >>/etc/apt/sources.list

# jingtianer: 国内源

RUN apt-get update
RUN apt-get install -y git build-essential sudo python

RUN mkdir -p /workdir/qsym

WORKDIR /workdir/qsym

RUN apt-get install -y lsb-core
RUN apt-get install -y libc6 libstdc++6 linux-libc-dev gcc-multilib g++-multilib \
  llvm-dev g++ g++-multilib python \
  lsb-release
RUN apt-get install -y gcc make python-pip


COPY . /workdir/qsym
RUN ./setup.sh

RUN python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple --upgrade pip
RUN pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
# jingtianer: pip清华源

# RUN echo kernel.yama.ptrace_scope = 0 | sudo tee /etc/sysctl.d/10-ptrace.conf
# jingtianer: ptrace置为0
RUN pip install .

RUN pip install python-afl
# jingtianer: test需要的依赖包
```

> docker 方式在ubuntu22.04中配置安装，但是不能成功运行测试代码


> 两种方法都无法在wsl中使用，缺少文件夹`/proc/sys/kernel/yama`
> 两种方法在编译时都存在warnings