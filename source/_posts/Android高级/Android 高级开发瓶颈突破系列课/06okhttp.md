---
title: 06-OKHTTP
date: 2023-10-10 21:15:36
tags: Android 高级开发瓶颈突破系列课
categories: Android
toc: true
language: zh-CN
---

```java
final Dispatcher dispatcher; // 线程控制
final @Nullable Proxy proxy; // 代理服务器，java.net
final List<Protocol> protocols;
final List<ConnectionSpec> connectionSpecs;
final List<Interceptor> interceptors;
final List<Interceptor> networkInterceptors;
final EventListener.Factory eventListenerFactory;
final ProxySelector proxySelector;
final CookieJar cookieJar;
final @Nullable Cache cache;
final @Nullable InternalCache internalCache;
final SocketFactory socketFactory;
final SSLSocketFactory sslSocketFactory;
final CertificateChainCleaner certificateChainCleaner;
final HostnameVerifier hostnameVerifier;
final CertificatePinner certificatePinner;
final Authenticator proxyAuthenticator;
final Authenticator authenticator;
final ConnectionPool connectionPool;
final Dns dns;
final boolean followSslRedirects;
final boolean followRedirects;
final boolean retryOnConnectionFailure;
final int callTimeout;
final int connectTimeout;
final int readTimeout;
final int writeTimeout;
final int pingInterval;

```

## websocket

[wikipedia](https://en.wikipedia.org/wiki/WebSocket): 
- 利用tcp提供全双工通信 WebSocket is a computer communications protocol, providing full-duplex communication channels over a single TCP connection.
- 运行在80/443端口上 WebSocket is designed to work over HTTP ports 443 and 80 as well as to support HTTP proxies and intermediaries

## Dispatcher - 线程控制
使用Deque控制任务
```java
private int maxRequests = 64; // 最大请求数
private int maxRequestsPerHost = 5; // 每个host最大请求数
private @Nullable Runnable idleCallback;

/** Executes calls. Created lazily. */
private @Nullable ExecutorService executorService;

/** Ready async calls in the order they'll be run. */
private final Deque<AsyncCall> readyAsyncCalls = new ArrayDeque<>();

/** Running asynchronous calls. Includes canceled calls that haven't finished yet. */
private final Deque<AsyncCall> runningAsyncCalls = new ArrayDeque<>();

/** Running synchronous calls. Includes canceled calls that haven't finished yet. */
private final Deque<RealCall> runningSyncCalls = new ArrayDeque<>();
```
```java
void enqueue(AsyncCall call) {
    synchronized (this) {
        readyAsyncCalls.add(call);

        // Mutate the AsyncCall so that it shares the AtomicInteger of an existing running call to
        // the same host.
        if (!call.get().forWebSocket) {
            AsyncCall existingCall = findExistingCallWithHost(call.host());
            // 先从runningAsyncCall中找host，没找到再从ready中找
            if (existingCall != null) call.reuseCallsPerHostFrom(existingCall);
            // 相同host使用同一个计数器
        }
    }
    promoteAndExecute();
}
```
```java
  private boolean promoteAndExecute() {
    assert (!Thread.holdsLock(this)); // 当前线程没有持有this的锁

    List<AsyncCall> executableCalls = new ArrayList<>();
    boolean isRunning;
    synchronized (this) {
      for (Iterator<AsyncCall> i = readyAsyncCalls.iterator(); i.hasNext(); ) {
        AsyncCall asyncCall = i.next();

        if (runningAsyncCalls.size() >= maxRequests) break; // Max capacity.
        if (asyncCall.callsPerHost().get() >= maxRequestsPerHost) continue; // Host max capacity.

        i.remove();
        asyncCall.callsPerHost().incrementAndGet();
        executableCalls.add(asyncCall);
        runningAsyncCalls.add(asyncCall);
      }
      isRunning = runningCallsCount() > 0;
    } // 把ready的请求提升为executable，条件是host没到capacity，总数没到capacity

    for (int i = 0, size = executableCalls.size(); i < size; i++) {
      AsyncCall asyncCall = executableCalls.get(i);
      asyncCall.executeOn(executorService()); // 使用ExecutorService执行
    }

    return isRunning;
  }
```
```java
  public synchronized ExecutorService executorService() { // 单例，获取线程池
    if (executorService == null) {
      executorService = new ThreadPoolExecutor(0, Integer.MAX_VALUE, 60, TimeUnit.SECONDS,
          new SynchronousQueue<>(), Util.threadFactory("OkHttp Dispatcher", false));
    }
    return executorService;
  }
```
## AsyncCall - 异步请求
```java
  final class AsyncCall extends NamedRunnable {
    private final Callback responseCallback; //回调
    private volatile AtomicInteger callsPerHost = new AtomicInteger(0); //host计数
  }
```
承接上文的executeOn，使用线程池执行
```java
    void executeOn(ExecutorService executorService) {
      assert (!Thread.holdsLock(client.dispatcher()));
      boolean success = false;
      try {
        executorService.execute(this);
        success = true;
      } catch (RejectedExecutionException e) {
        InterruptedIOException ioException = new InterruptedIOException("executor rejected");
        ioException.initCause(e);
        transmitter.noMoreExchanges(ioException);
        responseCallback.onFailure(RealCall.this, ioException);
      } finally {
        if (!success) {
          client.dispatcher().finished(this); // This call is no longer running!
        }
      }
    }
```
线程池拿到runnable，调用run，NamedRunnable调用execute
```java
    @Override protected void execute() {
      boolean signalledCallback = false;
      transmitter.timeoutEnter();
      try {
        Response response = getResponseWithInterceptorChain(); // 核心！调用interceptor，逐层执行，获得响应
        signalledCallback = true;
        responseCallback.onResponse(RealCall.this, response); // 回调
      } catch (IOException e) {
        if (signalledCallback) {
          // Do not signal the callback twice!
          Platform.get().log(INFO, "Callback failure for " + toLoggableString(), e);
        } else {
          responseCallback.onFailure(RealCall.this, e); //回调
        }
      } catch (Throwable t) {
        cancel();
        if (!signalledCallback) {
          IOException canceledException = new IOException("canceled due to " + t);
          canceledException.addSuppressed(t);
          responseCallback.onFailure(RealCall.this, canceledException);
        }
        throw t;
      } finally {
        client.dispatcher().finished(this); 
        // 通知dispatcher结束，对两个capacity decrement
        // 从相应的队列中删除任务
        // 再次调用promoteAndExecute，为线程池添加任务
      }
    }
```
创建拦截器，并开始一层层执行
```java
  Response getResponseWithInterceptorChain() throws IOException {
    // Build a full stack of interceptors.
    List<Interceptor> interceptors = new ArrayList<>();
    interceptors.addAll(client.interceptors());
    interceptors.add(new RetryAndFollowUpInterceptor(client));
    interceptors.add(new BridgeInterceptor(client.cookieJar()));
    interceptors.add(new CacheInterceptor(client.internalCache()));
    interceptors.add(new ConnectInterceptor(client));
    if (!forWebSocket) {
      interceptors.addAll(client.networkInterceptors());
    }
    interceptors.add(new CallServerInterceptor(forWebSocket));

    Interceptor.Chain chain = new RealInterceptorChain(interceptors, transmitter, null, 0,
        originalRequest, this, client.connectTimeoutMillis(),
        client.readTimeoutMillis(), client.writeTimeoutMillis());

    boolean calledNoMoreExchanges = false;
    try {
      Response response = chain.proceed(originalRequest);
      if (transmitter.isCanceled()) {
        closeQuietly(response);
        throw new IOException("Canceled");
      }
      return response;
    } catch (IOException e) {
      calledNoMoreExchanges = true;
      throw transmitter.noMoreExchanges(e);
    } finally {
      if (!calledNoMoreExchanges) {
        transmitter.noMoreExchanges(null);
      }
    }
  }
```


## interceptor - 拦截器
### RealInterceptorChain
```java
  @Override public Response proceed(Request request) throws IOException {
    return proceed(request, transmitter, exchange);
  }
  public Response proceed(Request request, Transmitter transmitter, @Nullable Exchange exchange)
      throws IOException {
    /*
        检查proceed只被调用一次
    */
    // Call the next interceptor in the chain.
    RealInterceptorChain next = new RealInterceptorChain(interceptors, transmitter, exchange,
        index + 1, request, call, connectTimeout, readTimeout, writeTimeout);
    Interceptor interceptor = interceptors.get(index);
    Response response = interceptor.intercept(next);
    /*
        检查proceed只被调用一次
    */
    /*
        检查response，body不为空
    */
    return response;
  }
```
## XXXInterceptor - 对于一般的Interceptor实现
```java
  @Override public Response intercept(Chain chain) throws IOException {
    /* do task0 */
    Request request = chain.request();
    /* do your task1 */
    Response response = chain.proceed(request);
    /* do your task2 */
    return response;
  }
```
interceptor获得chain，就是整个interceptor的链条，chain的request获取请求，对请求处理后，调用proceed，将请求处理给下一个interceptor，并返回response，在对响应处理后，将response返回。每个interceptor对象配合一个RealInterceptorChain工作。
RealInterceptorChain是一个chain，（也就是interceptor的参数），RealInterceptorChain保存上一级的request

interceptor通过调用RealInterceptorChain的proceed函数传递自己处理的request，proceed函数创建下一个interceptor的RealInterceptorChain，并调用interceptor的intercept，这样下一个intercept又会调用request获取request，然后调用proceed传递处理后的请求，得到response。
每个interceptor调用proceed获得响应并处理后，将自己处理后的请求返回给上一级的RealInterceptorChain.proceed，上一级的RealInterceptorChain.proceed又将其返回给上一级的intercept函数

## ConnectionSpec - 连接配置

## CertificatePinner - 自签名验证

## Authenticator - 登录

## connectionPool
## DNS
## followxxxredirect
## pingInterval - websocket的心跳间隔
- 一方发ping and 一方发pong
