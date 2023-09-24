---
title: 02-http
date: 2023-9-23 21:15:36
tags: Android 高级开发瓶颈突破系列课
categories: Android
toc: true
language: zh-CN
---

## 格式

- 报文格式(Request)
  - 请求行 eg: `GET /users?id=xxxx HTTP/1.1`
    - method
    - path(包括参数部分)
    - Http version
  - headers (Host在这里)
  - body
- 报文格式(Response)
  - 状态行 eg: `HTTP/1.1 200 OK`
    - Http Version
    - status code
    - status message
  - headers
  - body

## Request

### method

- GET
  - 获取资源
  - 没有body
- POST
  - 增加/修改资源
  - 有body
- PUT
  - 修改资源
  - 有body
- DELETE
  - 删除资源
  - 没有body
- HEAD
  - 获取资源
  - 没有body
  - 响应无body
  - 用于下载时，确定文件大小，有无断点续传等信息

幂等性：指重复的请求多次向服务器传送，对服务器的没有影响。如`GET`和`PUT`,`DELETE`。

## Response

### status code

为了方便开发人员定位错误

- 1xx: 临时性消息
  - 100 当客户端传送数据过大时，将其分段发送，在最后一个请求之前，服务器每收到一个请求，返回`100`表示收到，客户端再发送下一个。
  - 101 表示支持`http2`，浏览并尝试使用`http2`时，会先发送一个试探性的请求，如果返回`200`，说明服务器不支持`http2`，返回`101`则表示支持
- 2xx: 成功
- 3xx: 重定向
  - 301 如，浏览器访问http时返回301，自动改用https访问
  - 304 内容未改变
- 4xx: 客户端错误
  - 400 请求有问题
  - 401 未登录
  - 404 没找到
- 5xx: 服务器出错

## Header

请求的数据的元数据

- Host: 服务器主机(作用是区分多个域名对应同一个ip的情况，在发送之前已经解析出ip了)
- Content-Length: 内容长度，作用是当传送二进制数据时，确定结束位置
- Content-type: 内容类型
  - text/html: 是html页面
  - application/x-www-form-urlencoded: 普通表单(html里面那个)，encoded URL格式
    - body中的内容和path中的参数一样，都是使用urlencoded编码的纯文本信息
  - multipart/form-data: 多部份，带文件的表单，二进制内容
    - 每个part通过boundary指定 分隔
  - application/json
  - image/jpeg, application/zip 传送单个文件
- Chunked Transfer Encoding: 分块传输，若响应量非常大，服务器相应非常耗时时，想要每查出一部分数据后就立即返回给客户端。
  - body格式
```sh
<len1>
<content1>
<len2>
<content1>
<len3>
<content1>
...more
<len_n>
<content1>
0 #结束
```
- Location: 重定向的目标URL
- User-Agent: 标识用户使用的客户端
- Range / Accept-Range: 指定接收body的范围，断点续传时使用，多线程下载
- Cookie / set-Cookie: Cookie
- Authorization: 授权信息
- [more](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers)

### Cache-Control

- cache和buffer的区别
  - Cache:  缓存，如cpu的Cache，Android的LRUCache。已经使用过的内存，未来可能还要用，暂时存起来
  - Buffer: 缓冲，未来一定会用，来不及使用/预读提升速度。如视频缓冲

- no-cache: 可以缓存，再次访问该页面时，重新请求
- no-store: 不要缓存
- max-age: 请求结果具有生效时间
- private/private: 消息链路上的其他路由节点是否可以缓存这个消息
### Last-Modified

资源最近一次更新的时间，若更新于请求之后，则资源失效

### Etag
类似hash值，若不一样则资源失效

### REST
- [REST](https://en.wikipedia.org/wiki/REST)