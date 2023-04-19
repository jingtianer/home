---
title: geth搭建私链
date: 2023-1-10 11:28:00
tags: 
    - geth
    - blockchain
    - linux
categories: misc
toc: true
language: zh-CN
---

## 主要工作
参考`go-ethereum`官网的[Private Networks](https://geth.ethereum.org/docs/fundamentals/private-network)文档搭建了一个私有链，并总结出几个脚本，可以半自动化地实现geth网络的搭建，脚本已上传至github仓库[DLCCB](https://github.com/jingtianer/DLCCB)

## setup.sh

- 这一步使用了以下几个工具
  - `geth`命令，用于生成初始两个节点的账户，使用创世块配置文件对两个账户进行初始化
  - `puppeth` 用于生成创世块的配置文件，这个命令是交互式的，编写了一个`puppeth.txt`作为其输入，默认生成一个基于pow的区块链
  - `bootnode` 用于生成启动bootnode
- 这一步使用了以下几个linux命令
  - `sed` 非交互式的文本编辑器，用于读取生成的账户的区块链地址，写入`puppeth.txt`中，使得`puppeth`工具能为初始的两个节点分配一定的以太币
  - `awk`，用于对文本的处理

{% codeblock setup.sh lang:sh %}
mkdir node1 node2
geth --datadir node1 account new < password.txt
geth --datadir node2 account new < password.txt

sed -i "5i$(cat node1/keystore/UTC--* | awk '{split($0, arr, "\""); print arr[4]}')" puppeth.txt 
sed -i "5i$(cat node2/keystore/UTC--* | awk '{split($0, arr, "\""); print arr[4]}')" puppeth.txt 
puppeth < puppeth.txt
sed -i "5d" puppeth.txt
sed -i "5d" puppeth.txt

geth init --datadir node1 tianer.json
geth init --datadir node2 tianer.json

cat password.txt | head -n 1 | tee node1/password.txt
cat password.txt | head -n 1 | tee node2/password.txt

bootnode -genkey boot.key
bootnode -nodekey boot.key -addr :30305
{% endcodeblock %}

### 两个输入文件的内容
{% codeblock password.txt lang:plain %}
1234567890
1234567890
{% endcodeblock %}

> 这里两个节点的密码是相同的，也可以单独为每个节点写一个密码文件，但是密码文件必须两行相同，因为创建账户时需要输入两次密码

{% codeblock puppeth.txt lang:plain %}
tianer
2
1
1

yes
12345
2
2

2
3
{% endcodeblock %}

> 从上到下依次对配置创世块的配置文件进行创建，导出保存，删除。
> 会使用sed命令在第五行临时插入刚刚生成的账户文件的区块链地址，这样`puppeth`命令就知道要给哪些地址分配初始的以太币
>

### sed命令

sed 命令是一个面向行处理的工具，它以“行”为处理单位，针对每一行进行处理，处理后的结果会输出到标准输出（STDOUT）。你会发现 sed 命令是很懂礼貌的一个命令，它不会对读取的文件做任何贸然的修改，而是将内容都输出到标准输出中。

- 基本用法
```sh
sed [选项] "指令" 文件
```
- 选项，如果希望sed命令对文件直接进行更改，需要添加`-i`参数， 以下是几个查那个用的参数
  - `-e` 　　--它告诉sed将下一个参数解释为一个sed指令，只有当命令行上给出多个sed指令时使用
  - `-f` 　　--后跟保存了sed指令的文件
  - `-i` 　　--直接对内容进行修改，不加 i 时默认只是预览，不会对文件进行实际修改
  - `-n` 　　--取消默认输出，sed默认会输出所有文本内容，使用 -n 参数后只显示处理过的行

- 指令，类似vim，sed也有编辑命令
  - `a` 　　  --追加，向匹配行后插入内容
  - `c` 　    --更改，更改匹配行的内容
  - `i` 　    --插入，向匹配行前插入内容
  - `d`   　　--删除，删除匹配的内容
  - `s`   　　--替换，替换匹配到的内容
  - `p` 　    --打印，打印匹配到的内容，通常与 -n 和用
  - `=` 　　  --用来打印被匹配到的行的行号
  - `n`　　   --读取下一行，遇到n时会自动跳入下一行
  - `r,w` 　　--读和写，r用于将内容读入文件，w用于将匹配内容写入到文件

> 其中`s`命令后跟正则串和目标串，可以起到文本的匹配替换
> `sed`的指令使用`/`作为定界符，转义符为`\`

例子：
```sh
sed -i 's/book/books/' file
sed -i 's/book/books/g' file # 后缀g对每行的所有匹配进行替换
sed -i '2d' file #删除指定行
sed -i '5ixxxxx' file #在指定行插入xxxxx
```
- 具体可以参考[这里](https://blog.csdn.net/L1259863243/article/details/79364094)
### awk命令

AWK 是一种处理文本文件的语言，是一个强大的文本分析工具。
之所以叫 AWK 是因为其取了三位创始人 Alfred Aho，Peter Weinberger, 和 Brian Kernighan 的 Family Name 的首字符
linux中有三剑客之称：
三剑客之首就是 AWK
三剑客功能:
grep ： 过滤文本
sed  :  修改文本
awk  :  处理文本

- 语法格式

```sh
awk [参数] [处理内容] [操作对象]
```

- 具体可以参考[这里](http://c.biancheng.net/view/4082.html)

## mine.sh

用于启动创建的两个节点

{% codeblock mine.sh lang:sh %}
NODE=$2
ENODE=$1
AUTHRPCPORT=$(($2+8554))
PORT=$(($2+30308))

echo geth --datadir node$NODE --port $PORT --bootnodes $ENODE --networkid 12345 --unlock 0x$(cat node$NODE/keystore/UTC--* | awk '{split($0, arr, "\""); print arr[4]}') --password node1/password.txt --authrpc.port $AUTHRPCPORT

geth --datadir node$NODE --port $PORT --bootnodes $ENODE --networkid 12345 --unlock 0x$(cat node$NODE/keystore/UTC--* | awk '{split($0, arr, "\""); print arr[4]}') --password node1/password.txt --authrpc.port $AUTHRPCPORT --mine
{% endcodeblock %}

> 前一个脚本执行后，会输出enode， 将其复制下来，打开两个新的terminal窗口，enode作为这个脚本的第一个参数，第二个参数是希望启动的节点的编号

## attach.sh

用于让两个节点开始挖矿，使用`geth attach`打开js交互界面，`miner.txt`作为输入文件，执行命令`miner.start(1)`开始挖矿

{% codeblock attach.sh lang:sh %}
NODE=$1
echo geth attach node$NODE/geth.ipc
geth attach node$NODE/geth.ipc  < miner.txt
{% endcodeblock %}

> 参数为希望开始挖矿的节点编号，也需要打开新的terminal执行

{% codeblock miner.txt lang:js %}
net.peerCount
eth.getBalance(eth.accounts[0])
miner.start(1)
{% endcodeblock %}

## sk.js

用于获取节点的私钥，在开发时私钥很重要

{% codeblock sk.js lang:js %}
var keythereum = require("keythereum");
var datadir = "/home/tt/eth/net/node2/";
var address= "e43b98ac32beb344c94b15b9af5b46674d6c3e6d";//要小写
const password = "1234567890";
var keyObject = keythereum.importFromFile(address, datadir);
var privateKey = keythereum.recover(password, keyObject);
console.log(privateKey.toString('hex'));
{% endcodeblock %}

> 需要节点的`datadir`和节点的`address`