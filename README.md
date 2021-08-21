### 前言

网上的内网穿透，大都不合我的心意，所以我想自己写一个，最初的动机是自己需要用，顺便带大家用一用，结果还是为了省事，借用了 ngrok 的逻辑，按照我的需要进行优化。我会基于之前的使用经验，不断优化改造。

### 特别说明

1、本次开放主要是帮助大家本地的开发，不是为了收费。所以没有任何收费逻辑，但后期可能会考虑改成数据库存储隧道。  
2、不支持 443 端口（即 https），如果确实需要 https 的支持，就等我确实闲了，来更新。

3、感谢 ngrok 给我的帮助。

这是 go module 版本的。

一条命令生成客户端和服务端：

`make all`

### 关于部署

我建议大家多看看 `Makefile` 里面的命令。比如用以上命令生成了双端，服务端的启动方式：

```Bash
-httpAddr=:80 -domain="*.你的域名" -log="./bin/log.txt"
```

这样就开启了服务端。如何保证服务端持续运行，建议使用 `supervisor` 或 `systemd` 。客户端的启动方式：

```Bash
./roll -config=./config.yml start web ssh
```

对应的配置文件如下：

`config.yml`

```Yaml
server_addr: "zach-rock.com:4443"

tunnels:
  web:
    subdomain: "client"
    proto:
      http: 127.0.0.1:80
  ssh:
    proto:
      tcp: 22
    remote_port: 50018

```

### Windows 版

```
服务端 x86：GOOS=windows GOARCH=386 make server
客户端 x86：GOOS=windows GOARCH=386 make client
服务端 x64：GOOS=windows GOARCH=amd64 make server
客户端 x64：GOOS=windows GOARCH=amd64 make client
```

### Linux 版

```
服务端 x86：GOOS=linux GOARCH=386 make server
客户端 x86：GOOS=linux GOARCH=386 make client
服务端 x64：GOOS=linux GOARCH=amd64 make server
客户端 x64：GOOS=linux GOARCH=amd64 make client
```

### MacOS 版

```
服务端 x86：GOOS=darwin GOARCH=386 make server
客户端 x86：GOOS=darwin GOARCH=386 make client
服务端 x64：GOOS=darwin GOARCH=amd64 make server
客户端 x64：GOOS=darwin GOARCH=amd64 make client
```

### 其他版本的，自行搜索 go 交叉编译。

![image](https://user-images.githubusercontent.com/62736001/130325475-5c0482c6-3c11-4c92-af97-e418e0f2d19e.png)

# 最后：Let's rock! 开源万岁！

Author: Zach.Lu  
Email: 1049655193@qq.com
