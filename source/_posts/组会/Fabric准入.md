---
title: fabric 准入调研
date: 2022-11-22 12:15:37
tags: 
    - fabric
    - 组会 
categories: 组会
toc: true
language: zh-CN
---

## fabric ca

- [官方教程](https://hyperledger-fabric-ca.readthedocs.io/en/latest/deployguide/cadeploy.html)

- fabric ca提供以下几个功能
  - 注册, registration of identities, or connects to LDAP as the user registry
  - 签发注册证书, issuance of Enrollment Certificates (ECerts)
  - 证书续订和吊销, certificate renewal and revocation

![](https://hyperledger-fabric-ca.readthedocs.io/en/latest/_images/fabric-ca.png)

### 负载平衡
Hyperledger Fabric CA 客户端或 SDK 可以连接到 Hyperledger Fabric CA 服务器集群中的服务器。这在图表的右上角进行了说明。客户端路由到 HA 代理端点，该端点将流量负载平衡到其中一个结构服务器集群成员。

## user注册

### 使用fabric gateway

```
读取公钥私钥文件
创建Identity
与ca/peer建立grpc连接，获取fabric网络和contract
```


### 不使用fabric gateway

```
读取connection-*.json的位置，（提前生成的ccp对象）
获取ca，检查用户名是否已经注册
获取adminIdentity
注册，enroll
```


- 用户只需要提供自己的ID`appUser`，就可以生成访问区块链的身份
- 如果使用fabric gateway，需要peer的msp公钥私钥和证书
- 如果不使用fabric gateway，则需要用户端知道ca的访问账户和密码`admin:adminpw`
- 通过ca可以获得对contract的使用权，但是如果有其它业务，如果不用合约实现，可能需要传统的注册方式，并于ca的身份绑定

