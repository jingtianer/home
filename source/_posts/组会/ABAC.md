---
title: ABAC 调研
date: 2022-11-22 12:15:37
tags: 
    - abac
    - 组会 
categories: 组会
toc: true
language: zh-CN
---

## 什么是ABAC、RBAC

### RBAC -- role based access control

基于角色的访问控制，系统根据用户的角色判断用户是否具有权限

- 分类
  - Flat RBAC：每个员工至少被分配一个角色，但有些人可以拥有多个角色。如果有人想要访问新文件/资源​​/服务器，他们需要先获得一个新角色。
  - 分层 RBAC：角色是根据资历级别定义的。除了自己的特权外，高级员工还拥有下属的特权。
  - 受约束的 RBAC：该模型引入了职责分离 (SOD)。SOD 将执行任务的权限分散到多个用户，从而降低欺诈和/或风险活动的风险。例如，如果开发人员想要停用服务器，他们不仅需要直接经理的批准，还需要基础设施负责人的批准。这让基础设施负责人做出改变，拒绝有风险和/或不必要的请求。
  - 对称 RBAC：定期审查所有组织角色。作为这些审查的结果，可能会分配或撤销特权，可能会添加或删除角色。


### ABAC -- attribute based access control

基于属性的访问控制，系统根据用户的属性判断权限，属性可能与用户、访问的资源、行为和环境等因素相关

## 优缺点

### RBAC
- 优点
  - 简易：定义角色比分配角色更容易
  - 层级：更容易定义层次结构，上级拥有下级的权限
  - 成本：角色较少时，实施成本低
- 缺点
  - 角色爆炸：容易角色爆炸，导致要添加更多角色满足需求。在角色爆炸的情况下，将用户需求转换为角色可能是一项复杂的任务

### ABAC
- 优点
  - 细粒度：可以定义更加精细的控制策略，从大量的属性中进行选择
  - 可扩展性：无需修改现有规则以适应新用户。管理员需要做的就是为新加入者分配相关属性。
  - 易于维护：通过修改属性而不是定义新角色修改用户权限
- 缺点
  - 资源：比RBAC更耗时，更多资源，经济成本更高

## 适用范围

### ABAC

- 大型组织，支持可扩展性
- 需要根据环境，如地理位置，时间等因素判断权限
- 想要尽可能精细和灵活的访问控制策略
- 有时间、资源和预算来正确实施 ABAC

### RBAC

- 在中小型组织中
- 在您的组织内拥有定义明确的群体，并且应用广泛的、基于角色的策略是有意义的
- 实施访问控制策略的时间、资源和/或预算有限
- 不要有太多的外部贡献者，也不需要加入很多新人

## fabric中对abac的支持
- [地址](https://hyperledger-fabric-ca.readthedocs.io/en/latest/users-guide.html#attribute-based-access-control)
- [abac api](https://github.com/hyperledger/fabric-chaincode-go/blob/main/pkg/cid/README.md)

## fabric数据增删改查

### 删除

```go
func (s *SmartContract) DeleteAsset(ctx contractapi.TransactionContextInterface, id string) error {

	asset, err := s.ReadAsset(ctx, id)
	if err != nil {
		return err
	}

	clientID, err := s.GetSubmittingClientIdentity(ctx)
	if err != nil {
		return err
	}

	if clientID != asset.Owner {
		return fmt.Errorf("submitting client not authorized to update asset, does not own asset")
	}

	return ctx.GetStub().DelState(id)
}
```