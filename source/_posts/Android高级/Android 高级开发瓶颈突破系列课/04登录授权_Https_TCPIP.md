---
title: 04-登录授权 Https TCP/IP
date: 2023-9-26 21:15:36
tags: Android 高级开发瓶颈突破系列课
categories: Android
toc: true
language: zh-CN
---


## 登录授权

### Basic
在header中
Authorization: Basic `username:password(Base64ed, encrypted)`
### Bearer
在header中
Authorization: Bearer `bearer_token`

这里的bearer_token就类似于github的`Personal access tokens`，在请求中持有token的请求，可以根据token的权限对第三方账号中的数据进行获取、修改

![](./images/githubTokenGen.png)

可以配置token的失效时间，权限大小

客户端使用Basic方式登录后获取token，之后的请求都使用该token，不必记录用户的用户名密码。

#### OAuth2流程

在`Bearer`方式的授权方式中，第三方网站的`token`直接存储在用户端设备上是不安全的(直接将token返回给用户端设备不安全）。在OAuth2中，返回`access code`，用户端向自家服务器提供`access code`，自家服务器使用`access code`以安全的https信道向第三方服务器获取token，储存在服务器中，之后的对第三方账号的操作全部由服务器代劳。

## HTTPS
http over ssl
加密后，从传输层看，无法判断其是否是http消息。
### 建立过程

1. Client Hello
2. Server Hello
3. 服务器器证书 信任建⽴立
4. Pre-master Secret
5. 客户端通知：将使⽤用加密通信
6. 客户端发送：Finished
7. 服务器器通知：将使⽤用加密通信
8. 服务器器发送：Finished

### 信任建立
#### 证书
为了让客户端相信`我是我`，需要使用数字签名，但是在不知道对方公钥的情况下，如何证明`我是我`呢？需要一个权威机构向其证明。
证明的方式是：
![](./images/CA.png)

使用我的公钥可以证明`我是我`，但是为了防止其他人生成密钥欺骗我，我在消息里添加我的证书颁布放的公钥即相关信息。使用颁布放的公钥可以验证`我的证书颁布方是我的证书颁布方`。但是我依然可以生成一个颁布放的密钥，颁布方的信息中需要放入根证书。每台机器上都由所有根证书的列表和根证书的公钥，使用该公钥即可验证`我的颁布方的颁布方是我的颁布方的颁布方`。所以只要系统中有根证书，我就是可信任的。

证书是由证书的颁布机构所签名的
#### 流程

![](./images/CertArchitecture.png)

#### HMAC

HMAC = Hash-based Message Authenticate Code

就是一种不容易被破解的Hash，加盐，且是只有收发两方知道的盐

