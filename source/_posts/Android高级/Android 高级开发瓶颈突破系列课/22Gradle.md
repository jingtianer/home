---
title: 22-Gradle
date: 2024-04-23 21:15:36
tags: 
  - Android
  - gradle
categories: 
  - Android
  - gradle
toc: true
language: zh-CN
---

## 核心概念

- 项目
  - Gradle项目是一个可以构建的软件，例如应用程序或库。
  - 包括一个`根项目`和任意数量的`子项目`。
- 构建脚本
  - 构建脚本向 Gradle 详细介绍了构建项目所需采取的步骤。
  - 每个项目可以包含一个或多个构建脚本。
- 依赖管理
  - 依赖管理是一种用于声明和解析项目所需的外部资源的自动化技术。
  - 每个项目通常都包含许多外部依赖项，Gradle 将在构建过程中解决这些依赖项。
- 任务
  - 任务是基本的工作单元，例如编译代码或运行测试。
  - 每个项目都包含在构建脚本或插件中定义的一个或多个任务。
- 插件
  - 插件用于扩展 Gradle 的功能，并可选择向项目贡献任务。

## Gradle 项目结构

|文件/目录名称|作用|
|-|-|
|gradlew/gradlew.bat|Gradle 包装脚本|
|build.gradle(.kts)|项目的 Gradle 构建脚本|
|settings.gradle(.kts)|Gradle 设置文件用于定义根项目名称和子项目|
|src|项目/子项目的源码、资源|

## 使用gradle/gradlew编译

- 编译
```sh
./gradlew build
```

- 编译单个任务
```sh
./gradlew :taskname
./gradlew taskname
```
> 编译单个任务以及全部依赖

- 编译多项目工程中的任务
```sh
./gradlew :subproject:taskName
./gradlew subproject:taskName
```
> `:`相当于分隔符，第一个冒号可以省略
- 清理产物
```sh
./gradlew clean
```

- 执行多个任务
```sh
./gradlew clean build
```

## settings.gradle

- 单工程: optional
- 多工程: mandatory
  - 要声明所有子工程

```groovy
rootProject.name = 'root-project'   
// 定义工程名
include('sub-project-a')            
include('sub-project-b')
include('sub-project-c')
// 声明子工程
```

### Settings对象

#### Settings对象的属性

- buildCache: 编译缓存配置
- plugins: 应用该设置的插件
- rootDir: 编译的根目录, 根项目的目录
- rootProject: 根项目
- settings: 当前Settings对象

#### Settings对象的方法
- include(): 定义自项目
- includeBuild(): 看不懂