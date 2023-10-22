---
title: 06-OKHTTP
date: 2023-10-10 21:15:36
tags: Android 高级开发瓶颈突破系列课
categories: Android
toc: true
language: zh-CN
---

## websocket

[wikipedia](https://en.wikipedia.org/wiki/WebSocket): 
- 利用tcp提供全双工通信 WebSocket is a computer communications protocol, providing full-duplex communication channels over a single TCP connection.
- 运行在80/443端口上 WebSocket is designed to work over HTTP ports 443 and 80 as well as to support HTTP proxies and intermediaries

## Dispatcher - 线程控制

## AsyncCall - 异步请求

## ConnectionSpec - 连接配置

## CertificatePinner - 自签名验证

## Authenticator - 登录

## connectionPool
## DNS
## followxxxredirect
## pingInterval - websocket的心跳间隔
- 一方发ping and 一方发pong

## interceptor 
interceptor获得chain，就是整个interceptor的链条，chain的request获取请求，对请求处理后，调用proceed，将请求处理给下一个interceptor，并返回response，在对响应处理后，将response返回。每个interceptor对象配合一个RealInterceptorChain工作。
RealInterceptorChain是一个chain，（也就是interceptor的参数），RealInterceptorChain保存上一级的request

interceptor通过调用RealInterceptorChain的proceed函数传递自己处理的request，proceed函数创建下一个interceptor的RealInterceptorChain，并调用interceptor的intercept，这样下一个intercept又会调用request获取request，然后调用proceed传递处理后的请求，得到response。
每个interceptor调用proceed获得响应并处理后，将自己处理后的请求返回给上一级的RealInterceptorChain.proceed，上一级的RealInterceptorChain.proceed又将其返回给上一级的intercept函数