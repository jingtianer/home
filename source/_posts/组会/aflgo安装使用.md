---
title: aflgo的安装与使用
date: 2023-3-2 12:15:37
tags: 
    - 组会 
    - aflgo
categories: 组会
toc: true
language: zh-CN
---

## aflgo的安装与测试

### 安装依赖

#### 执行一键安装脚本
先克隆aflgo[仓库](https://github.com/aflgo/aflgo.git)，脚本位于`./scripts/build`下的`aflgo-build.sh`

使用一键安装脚本安装有几个问题

- 编译时报错`error: ‘numeric_limits’ is not a member of ‘std’`，这是因为llvm源文件少引用了一个头文件，编辑文件`/root/build/llvm_tools/llvm-11.0.0.src/utils/benchmark/src/benchmark_register.h`，加入以下头文件
```sh
#include<limits>
```
- 或在脚本解压操作完成后，执行一次以下命令
```sh
sed -i '5i#include<limits>' ~/build/llvm_tools/llvm-11.0.0.src/utils/benchmark/src/benchmark_register.h
```

- apt找不到部分包
```sh
E: Package 'python-dev' has no installation candidate
E: Unable to locate package python-bs4
```
- 在脚本`# install some packages`下修改为以下内容
```sh
apt install -y python2-dev python3 python3-dev python3-pip autoconf automake libtool-bin python3-bs4 libboost-all-dev # libclang-11.0-dev
```
- apt/apt-get前没有`sudo`，需要加上，最好不要sudo整个脚本，否则会将文件编译到`/root/build`下

- 对于`ubuntu 16.04`版本，将脚本中判断系统版本的地方修改成以下内容，他想判断系统是否大于`1604`，但在16.04版本中获取的版本号是带引号的

```sh
if [[ "$UBUNTU_YEAR" > '"16' || "$UBUNTU_MONTH" > '04"' ]]
then
    sudo apt-get install -y python3-distutils
fi
```

### 确定SUBJECT环境变量
`$SUBJECT`就是需要被fuzz的源码目录，这里我们先对`libxml2`进行测试，那么`$SUBJECT`定义如下
```sh
# Clone subject repository
git clone https://gitlab.gnome.org/GNOME/libxml2
export SUBJECT=$PWD/libxml2
```

### 生成BBTarget
```sh
export SUBJECT=$PWD/libxml2
# Setup directory containing all temporary files
mkdir temp
export TMP_DIR=$PWD/temp
# Download commit-analysis tool
wget https://raw.githubusercontent.com/jay/showlinenum/develop/showlinenum.awk
chmod +x showlinenum.awk
mv showlinenum.awk $TMP_DIR

# Generate BBtargets from commit ef709ce2
pushd $SUBJECT
  git checkout ef709ce2
  git diff -U0 HEAD^ HEAD > $TMP_DIR/commit.diff
popd
cat $TMP_DIR/commit.diff |  $TMP_DIR/showlinenum.awk show_header=0 path=1 | grep -e "\.[ch]:[0-9]*:+" -e "\.cpp:[0-9]*:+" -e "\.cc:[0-9]*:+" | cut -d+ -f1 | rev | cut -c2- | rev > $TMP_DIR/BBtargets.txt

# Print extracted targets. 
echo "Targets:"
cat $TMP_DIR/BBtargets.txt
```

> 根据git commit提交记录中的代码差异文件`*.diff`，生成`BBtargets.txt`，其文件格式为`文件名:行号`

### 生成distance

- 根据上一步的`BBtargets.txt`，使用gold插件，生成CFG(控制流程图)和CG(调用图)

```sh
# Set aflgo-instrumenter
export AFLGO=~/build/llvm_tools/build-llvm/msan/aflgo
export CC=$AFLGO/afl-clang-fast
export CXX=$AFLGO/afl-clang-fast++
export SUBJECT=$PWD/libxml2
export TMP_DIR=$PWD/temp
# Set aflgo-instrumentation flags
export COPY_CFLAGS=$CFLAGS
export COPY_CXXFLAGS=$CXXFLAGS
export ADDITIONAL="-targets=$TMP_DIR/BBtargets.txt -outdir=$TMP_DIR -flto -fuse-ld=gold -Wl,-plugin-opt=save-temps"
export CFLAGS="$CFLAGS $ADDITIONAL"
export CXXFLAGS="$CXXFLAGS $ADDITIONAL"

# Build libxml2 (in order to generate CG and CFGs).
# Meanwhile go have a coffee ☕️
export LDFLAGS=-lpthread
pushd $SUBJECT
  ./autogen.sh
  ./configure --disable-shared
  make clean
  make xmllint
popd
```

- 计算distance，将会在`$TMP_DIR`下生成fuzz所需的`distance.cfg.txt`

```sh
$AFLGO/scripts/gen_distance_fast.py $SUBJECT $TMP_DIR xmllint
```


### 插桩

使用第一步中编译出的`aflgo`工具，以及上一步生成的`distance`再次编译`libxml2`，进行插桩
```sh
export AFLGO=~/build/llvm_tools/build-llvm/msan/aflgo
export CC=$AFLGO/afl-clang-fast
export CXX=$AFLGO/afl-clang-fast++
export SUBJECT=$PWD/libxml2
export TMP_DIR=$PWD/temp
# Set aflgo-instrumentation flags
export COPY_CFLAGS=$CFLAGS
export COPY_CXXFLAGS=$CXXFLAGS
export CFLAGS="$COPY_CFLAGS -distance=$TMP_DIR/distance.cfg.txt"
export CXXFLAGS="$COPY_CXXFLAGS -distance=$TMP_DIR/distance.cfg.txt"

# Clean and build subject with distance instrumentation ☕️
pushd $SUBJECT
  make clean
  ./configure --disable-shared
  make xmllint
popd
```

### 进行fuzz
```sh
export AFLGO=~/build/llvm_tools/build-llvm/msan/aflgo
export SUBJECT=$PWD/libxml2
# Construct seed corpus
mkdir in
cp -r $SUBJECT/test/dtd* in
cp $SUBJECT/test/dtds/* in

# echo core | sudo tee /proc/sys/kernel/core_pattern

$AFLGO/afl-fuzz -S ef709ce2 -z exp -c 45m -i in -o out $SUBJECT/xmllint --valid --recover @@
```

### fuzz结果(libxml2)
```sh

                      american fuzzy lop 2.52b (ef709ce2)

┌─ process timing ─────────────────────────────────────┬─ overall results ─────┐
│        run time : 0 days, 1 hrs, 1 min, 7 sec        │  cycles done : 6      │
│   last new path : 0 days, 0 hrs, 1 min, 54 sec       │  total paths : 2839   │
│ last uniq crash : 0 days, 0 hrs, 51 min, 32 sec      │ uniq crashes : 14     │
│  last uniq hang : 0 days, 0 hrs, 2 min, 24 sec       │   uniq hangs : 10     │
├─ cycle progress ────────────────────┬─ map coverage ─┴───────────────────────┤
│  now processing : 2828 (99.61%)     │    map density : 4.94% / 18.43%        │
│ paths timed out : 0 (0.00%)         │ count coverage : 3.24 bits/tuple       │
├─ stage progress ────────────────────┼─ findings in depth ────────────────────┤
│  now trying : trim 32/32            │ favored paths : 462 (16.27%)           │
│ stage execs : 17/60 (28.33%)        │  new edges on : 787 (27.72%)           │
│ total execs : 730k                  │ total crashes : 23 (14 unique)         │
│  exec speed : 6.90/sec (zzzz...)    │  total tmouts : 20 (13 unique)         │
├─ fuzzing strategy yields ───────────┴───────────────┬─ path geometry ────────┤
│   bit flips : n/a, n/a, n/a                         │    levels : 22         │
│  byte flips : n/a, n/a, n/a                         │   pending : 1930       │
│ arithmetics : n/a, n/a, n/a                         │  pend fav : 3          │
│  known ints : n/a, n/a, n/a                         │ own finds : 2825       │
│  dictionary : n/a, n/a, n/a                         │  imported : 0          │
│       havoc : 1342/241k, 1497/369k                  │ stability : 99.49%     │
│        trim : 41.17%/97.2k, n/a                     ├────────────────────────┘
└─────────────────────────────────────────────────────┘          [cpu000: 90%]
```

## 对bind进行fuzz

### 生成BBTarget
```sh
git clone https://github.com/isc-projects/bind9.git
export SUBJECT=$PWD/bind9
mkdir aflgo-bind9-tmp
export TMP_DIR=$PWD/aflgo-bind9-tmp

python3 BBtarget.py $SUBJECT $TMP_DIR

echo "Targets:"
cat $TMP_DIR/BBtargets.txt
```

> 其中`BBtarget.py`是我写的一个脚本，用来读取之前`gcc-python-plugin`找出的`recv`,`send`,`vulnerable`和`blocking`

### 生成distance
```sh
# Set aflgo-instrumenter
export AFLGO=~/build/llvm_tools/build-llvm/msan/aflgo
export CC=$AFLGO/afl-clang-fast
export CXX=$AFLGO/afl-clang-fast++
export SUBJECT=$PWD/bind9
export TMP_DIR=$PWD/aflgo-bind9-tmp
# Set aflgo-instrumentation flags
export COPY_CFLAGS=$CFLAGS
export COPY_CXXFLAGS=$CXXFLAGS
export ADDITIONAL="-targets=$TMP_DIR/BBtargets.txt -outdir=$TMP_DIR -flto -fuse-ld=gold -Wl,-plugin-opt=save-temps"
export CFLAGS="$CFLAGS $ADDITIONAL"
export CXXFLAGS="$CXXFLAGS $ADDITIONAL"

# Build bind9 (in order to generate CG and CFGs).
# Meanwhile go have a coffee ☕️
# export LDFLAGS=-lpthread
pushd $SUBJECT
  autoreconf -fi
  ./configure  --enable-fuzzing=afl
  make clean
  make -j
popd
$SUBJECT/bin/named --valid --recover $SUBJECT/test/dtd3
ls $TMP_DIR/dot-files
echo "Function targets"
cat $TMP_DIR/Ftargets.txt

# Clean up
cat $TMP_DIR/BBnames.txt | grep -v "^$"| rev | cut -d: -f2- | rev | sort | uniq > $TMP_DIR/BBnames2.txt && mv $TMP_DIR/BBnames2.txt $TMP_DIR/BBnames.txt
cat $TMP_DIR/BBcalls.txt | grep -Ev "^[^,]*$|^([^,]*,){2,}[^,]*$"| sort | uniq > $TMP_DIR/BBcalls2.txt && mv $TMP_DIR/BBcalls2.txt $TMP_DIR/BBcalls.txt

# Generate distance ☕️
# $AFLGO/scripts/genDistance.sh is the original, but significantly slower, version
$AFLGO/scripts/gen_distance_fast.py $SUBJECT/bin/named/.libs $TMP_DIR named

# Check distance file
echo "Distance values:"
head -n5 $TMP_DIR/distance.cfg.txt
echo "..."
tail -n5 $TMP_DIR/distance.cfg.txt
```

### 插桩

```sh
export AFLGO=~/build/llvm_tools/build-llvm/msan/aflgo
export CC=$AFLGO/afl-clang-fast
export CXX=$AFLGO/afl-clang-fast++
export SUBJECT=$PWD/bind9
export TMP_DIR=$PWD/aflgo-bind9-tmp
# Set aflgo-instrumentation flags
export COPY_CFLAGS=$CFLAGS
export COPY_CXXFLAGS=$CXXFLAGS
export CFLAGS="$COPY_CFLAGS -distance=$TMP_DIR/distance.cfg.txt"
export CXXFLAGS="$COPY_CXXFLAGS -distance=$TMP_DIR/distance.cfg.txt"

# Clean and build subject with distance instrumentation ☕️
pushd $SUBJECT
  make clean
  ./configure --enable-fuzzing=afl
  make -j
popd
```

参考[isc bind9仓库](https://github.com/isc-projects/bind9/blob/main/fuzz/FUZZING.md)中的描述，configure的时候要加上这个参数`--enable-fuzzing=afl`

### fuzz

```sh
export AFLGO=~/build/llvm_tools/build-llvm/msan/aflgo
export SUBJECT=$PWD/bind9
# Construct seed corpus
rmdir in
mkdir in
cp -r $SUBJECT/fuzz/* ./in

# echo core | sudo tee /proc/sys/kernel/core_pattern

# 根据自己cpu占用情况并行fuzz
$AFLGO/afl-fuzz -m 8192 -M bind9_0 -z exp -c 45m -i in -o out $SUBJECT/bin/named/.libs/named -c @@ -g
$AFLGO/afl-fuzz -m 8192 -S bind9_1 -z exp -c 45m -i in -o out $SUBJECT/bin/named/.libs/named -c @@ -g
$AFLGO/afl-fuzz -m 8192 -S bind9_2 -z exp -c 45m -i in -o out $SUBJECT/bin/named/.libs/named -c @@ -g
$AFLGO/afl-fuzz -m 8192 -S bind9_3 -z exp -c 45m -i in -o out $SUBJECT/bin/named/.libs/named -c @@ -g
```

最后一行的参数`-c -g`参考了`hongfuzz`对`bind`测试的[example](https://github.com/google/honggfuzz/tree/master/examples/bind)

测试用例使用的是`bind9/fuzz`下自带的

[Re: Fuzzing Bind](https://www.mail-archive.com/bind-users@lists.isc.org/msg30792.html)官方如何对named进行fuzz的一个回答，这里提到了如何使用pkt文件作为种子进行模糊测试

[dns-fuzzing仓库](https://github.com/CZ-NIC/dns-fuzzing)提供了用于测试的种子

> 到此就可以使用`aflgo`对`named`进行测试了

