---
title: 05-Retrofit
date: 2023-9-27 21:15:36
tags: Android 高级开发瓶颈突破系列课
categories: Android
toc: true
language: zh-CN
---

## HOST验证

在上节https的ca证书验证时，如果某个恶意网站直接获取整个ca证书，发给其他用户骗取信任怎么办。这个时候就需要host验证，即证书的host主机与发送证书的主机host是否是同一个域名。

### fiddler如何抓包

fiddler是一个中间人，通过系统代理，浏览器/应用将请求发送至fiddler，fiddler自签一个证书与浏览器/应用使用，且需要用户向操作系统安装根证书。fiddler拿到数据包后再与服务器交互。

## retrofit源码阅读
### retrofit的使用
- 注解: 通过注解对Interface中的方法和参数进行标注。如`@GET` `@POST` `@PUT`定义`HTTP`的方法类型
- Converter: 对请求和响应的转换，如把一个Java的`File`与http的`Multipart`互相转化
- CallAdapter: 适配器，接口的返回值可能为一个`Call<R>`对象，也可能是`RxJava`的`Single`,`Observale`对象。适配器的作用即是将响应类型和返回类型做适配

### Retrofit.create(Class\<T\>)
`T`即为声明的接口，crate中使用反射创建了T类型的对象。
- 首先判断是否是Object的方法，如果是，直接调用
- 其次判断是否为java8的`Default Method`（即接口实现的方法），如果是，直接调用
- 如果不是，说明是接口，生成/从缓存中获取`ServiceMethod<?>
`，并调用。

### 方法的生成
retrofit为每个method生成了一个`ServiceMethod<?>`，存储在一个concurrentMap中，调用时根据调用方法寻找对象，并调用对象的invoke方法。
方法生成的东西很多，主要是：
- 分析注解：根据注解进行合法性检查
- 根据注解构造RequestFactory。用于OKHttp生成OKhttp的Call
- 构造CallAdaptor，把Body变成返回值
- 构造ResponseConverter，把响应转化为响应body
`ServiceMethod<?>`的invoke方法构造了`OkHttpCall<>`，他实现了OKhttp请求的构造，并通过okhttp发送请求，最后调用adapt方法将OKHTTP的响应做转换。
adapt方法是抽象函数，由三个子类实现：
- SuspendForBody: 返回值不是response类型，直接返回body
- SuspendForResponse: 返回值是response
- CallAdapted: 不是kotlin的suspend方法
他们三个都实现了adapt方法，使用CallAdapter进行转换

### 动态代理

retrofit中，ExecutorCallbackCall对Call进行了代理，负责把后台任务拉回到前台。根据不同的平台，在android中使用handler。

### Adaptor

适配器，做转接

`retrofit`中，不同的`CallAdaptor`实现不同的转接方式

### Factory

根据不同的条件生产不同的对象

在retrofit中`RequestFactory.Builder`可以根据接口的注释，分析出请求的url，header，要不要body等信息，并根据该信息创建`RequestFactory`。`Request Factory`可以生产`Okhttp.Request`。

### Builder

有些对象很重，先构造再修改其中的值回很耗时，builder可以提前将值设置好，根据值做检查后构造对象

除了`RequestFactory`，`Retrofit`的本身也有buidler，配置不同的`Converter、Adapter`

### Abstract Factory

就是有父类的工厂呗，子类工厂负责生产某一种类的产品
`Retrofit`的各种`Converter`就是抽象工厂的具体实现