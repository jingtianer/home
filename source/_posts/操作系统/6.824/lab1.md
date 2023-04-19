---
title: 6.824-lab1-Mapreduce
date: 2022-10-28 18:00:36
tags: '6.824'
categories: OS
toc: true
language: zh-CN
---

## Intro

### 实验目的
- 实现一个MapReduce调度器(Coordinator)

## 准备工作

1. 下载源码

```sh
git clone git://g.csail.mit.edu/6.824-golabs-2021 6.824
```

2. 串行运行 word-count
```sh
cd ./6.824
cd src/main
go build -race -buildmode=plugin ../mrapps/wc.go
rm mr-out*
go run -race mrsequential.go wc.so pg*.txt
more mr-out-0
```

## 我的任务
修改`mr/coordinator.go`,` mr/worker.go`, `mr/rpc.go`，实现coordinator和worker

### 运行方式
- 编译并运行coordinator
```sh
go build -race -buildmode=plugin ../mrapps/wc.go 
rm mr-out*
go run -race mrcoordinator.go pg-*.txt
```
- 多开几个窗口跑worker
```sh
go run -race mrworker.go wc.so
```

- 测试
```sh
bash test-mr.sh
```
## 测试
### early exit 
```sh
rm -f mr-*

echo '***' Starting early exit test.

timeout -k 2s 180s ../mrcoordinator ../pg*txt &

## give the coordinator time to create the sockets.
sleep 1

## start multiple workers.
timeout -k 2s 180s ../mrworker ../../mrapps/early_exit.so &
timeout -k 2s 180s ../mrworker ../../mrapps/early_exit.so &
timeout -k 2s 180s ../mrworker ../../mrapps/early_exit.so &

## wait for any of the coord or workers to exit
## `jobs` ensures that any completed old processes from other tests
## are not waited upon
jobs &> /dev/null
wait -n
## 关键是这一行
## a process has exited. this means that the output should be finalized
## otherwise, either a worker or the coordinator exited early
sort mr-out* | grep . > mr-wc-all-initial

## wait for remaining workers and coordinator to exit.
wait
```
- 这一行的作用是当上面任何一个线程中，第一个线程结束，则停止wait继续下面的脚本
- 也就是说，大家要一起退出，不能因为执行完任务了，也没有新任务了，就让worker结束
```sh
wait -n
## 关键是这一行
```
> 一种可行的方法是当所有reduce任务结束后，直接退出，socket连接关闭，后面的worker心跳直接连接关闭的socket导致panic退出


但这样太不优雅

> 每个worker请求task时发送自己已经完成的reduce数
> 如果coordinator收到了所有的reduce complete消息，维护一个变量reduce，此时每收到一个RequestTask消息reduce+=该客户端的reduce数，并发送finish消息，worker收到后立刻finish
> Coordinator的Done实现为，该reduce大于等于NReduce时，结束运行


### job count test
- 检查某个job运行的次数是否正确
- 这个检测最初没有通过，就去看了测试脚本和源码

```sh
echo '***' Starting job count test.

rm -f mr-*

timeout -k 2s 180s ../mrcoordinator ../pg*txt &
sleep 1

timeout -k 2s 180s ../mrworker ../../mrapps/jobcount.so &
timeout -k 2s 180s ../mrworker ../../mrapps/jobcount.so
timeout -k 2s 180s ../mrworker ../../mrapps/jobcount.so &
timeout -k 2s 180s ../mrworker ../../mrapps/jobcount.so

NT=`cat mr-out* | awk '{print $2}'`
if [ "$NT" -ne "8" ]
then
  echo '---' map jobs ran incorrect number of times "($NT != 8)"
  echo '---' job count test: FAIL
  failed_any=1
else
  echo '---' job count test: PASS
fi

wait
```

> 简单分析可知，加载jobcount中的特殊map，reduce函数，使输出文件输出的是map的个数
> 通过cat输出mr-out*的所有文件，在使用awk输出mr-out*的第二个参数(`awk 'print $2'`)

{% codeblock mrapps/crash.go lang:go %}
var count int

func Map(filename string, contents string) []mr.KeyValue {
	me := os.Getpid()
	f := fmt.Sprintf("mr-worker-jobcount-%d-%d", me, count)
	count++
	err := ioutil.WriteFile(f, []byte("x"), 0666)
	if err != nil {
		panic(err)
	}
	time.Sleep(time.Duration(2000+rand.Intn(3000)) * time.Millisecond)
	return []mr.KeyValue{mr.KeyValue{"a", "x"}}
}

func Reduce(key string, values []string) string {
	files, err := ioutil.ReadDir(".")
	if err != nil {
		panic(err)
	}
	invocations := 0
	for _, f := range files {
		// println("test, f =", f.Name(), strings.HasPrefix(f.Name(), "mr-worker-jobcount"))
		if strings.HasPrefix(f.Name(), "mr-worker-jobcount") {
			invocations++
		}
	}
	return strconv.Itoa(invocations)
}
{% endcodeblock %}

> 分析这里的代码可知，每调用依次map，全局变量count就会++，并创建该worker的第count个文件
> 在reduce中数当前目录下前缀为mr-worker-jobcount的文件个数就是map的个数

调试了自己的代码，map只调用了8次，reduce只调用了一次

> 注意到jobcount中使用了go已经弃用的`ioutils`包，改为os，问题解决

### crash test

```sh
## mimic rpc.go's coordinatorSock()
SOCKNAME=/var/tmp/824-mr-`id -u`
```

测试脚本要模仿Coordinator的Sock