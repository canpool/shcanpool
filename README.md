|Branch|Status|
|:--|:--|
|master|[![Build Status](https://www.travis-ci.org/canpool/shcanpool.svg?branch=master)](https://www.travis-ci.org/canpool/shcanpool)|
|develop|[![Build Status](https://www.travis-ci.org/canpool/shcanpool.svg?branch=develop)](https://www.travis-ci.org/canpool/shcanpool)|

------
<!-- TOC -->

- [1. 简介](#1-简介)
- [2. 仓库](#2-仓库)
- [3. 目录](#3-目录)
- [4. 使用](#4-使用)
    - [4.1. 开发](#41-开发)
    - [4.2. 执行](#42-执行)
    - [4.3. 环境](#43-环境)
    - [4.4. 配置](#44-配置)
- [5. 案例](#5-案例)
- [6. 结语](#6-结语)

<!-- /TOC -->

# 1. 简介
shcanpool是一个精选的shell脚本框架，采用面向过程的编程思想，可用于开发命令行管理工具。

# 2. 仓库
- [github](https://github.com/canpool/shcanpool)
- [gitee](https://gitee.com/icanpool/shcanpool)

# 3. 目录

|一级目录|二级目录|说明|
|:---|:---|:---|
|config||配置模板|
|projects||工程|
||demo|样例工程|
|src|apps|应用（命令）脚本|
||base|基础脚本|
||libs|基础库脚本，基于标准命令实现|
||plugins|特定的库脚本|
||utils|通用脚本，框架的核心|
|test||测试脚本|

备注：utils和libs中的脚本都是通用的，可以广泛的用在别的项目中。

# 4. 使用

以projects/demo工程为例进行讲解，用户可以参考demo工程开发个人命令工具。

|一级目录|说明|
|:---|:---|
|demo.sh|命令入口|
|apps|应用（命令）脚本|

## 4.1. 开发

如何开发一个功能？以helloworld.sh为例，如下：
```shell
method_def helloworld

usage_helloworld() {
printf "helloworld (hello): Hello to the world

usage:
    ${PROG} hello

"
}

alias_def helloworld hello
do_helloworld() {
    echo "hello world"
}
```

1. 一个功能必须定义两个函数：do_helloworld，usage_helloworld

    备注：
    * do_xxx和usage_xxx后面的名字必须一致
    * usage_xxx第一行是功能的简述，通过':'分割

2. 一个功能通过method定义后才生效：method_def helloworld

    备注：
    * method定义的方法，最终以子命令的形式存在

3. 一个功能别名通过alias定义：alias_def helloworld hello

    备注：
    * alias定义的别名，最终也以子命令的形式存在
    * ailas可以定义多个别名，比如：alias_def helloworld hello hw

## 4.2. 执行

通过执行 ```demo.sh``` 脚本来执行不同的功能。

1. 查看所有帮助信息
```
bash demo.sh [-h|--help]
```

2. 查看命令帮助信息
```
bash demo.sh h helloworld
bash demo.sh h hello
```

3. 执行命令
```
bash demo.sh helloworld
bash demo.sh hello
```

## 4.3. 环境

功能中会使用一些非系统内嵌的命令，这些命令可能需要单独进行安装，通过下面命令可以检测当前系统中是否存在用到的相关命令：
```
bash demo.sh checkenv
bash demo.sh ce
```

## 4.4. 配置

有些命令需要先配置信息，配置模板文件在config/template.conf中，通过变量CONFIG_FILE指定配置文件。

提供了两个命令用来管理配置文件：init，set

```
bash demo.sh init
bash demo.sh set
```
init：初始化配置文件

set：设置/编辑配置文件

# 5. 案例
- [ola](https://gitee.com/maminjie/ola)：一款为openEuler写的shell命令工具

# 6. 结语
更多功能请自行解锁！
