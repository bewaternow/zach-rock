### 一、前言

网上的内网穿透，大都不合我的心意，所以我想自己维护一个，最初的动机是自己需要用，顺便带大家用一用，结果还是为了省事。我会基于之前的使用经验，不断优化改造。  
大家的部署发布的时候，记得开端口号，重要的如：4443 端口。

### 二、特别说明

1、本次开放主要是帮助大家本地的开发，不是为了收费。所以没有任何收费逻辑，但后期可能会考虑改成数据库存储隧道。  
2、不支持 443 端口（即 https），如果确实需要 https 的支持，就等我确实闲了，来更新。

3、感谢 ngrok 给我的帮助。

这是 go module 版本的。

一条命令生成客户端和服务端：

`make all`

### 三、关于部署

#### 1、配置和启动

我建议大家多看看 `Makefile` 里面的命令。比如用以上命令生成了双端，服务端的启动方式：

```Bash
./rock -httpAddr=:80 -domain="*.你的域名" -tunnelAddr=zach-rock.com:4443 -log="./bin/log.txt"
```

记得把通信的端口开起来，如果你用的是默认的 4443 端口，那你就记得开启 4443 端口，这样就开启了服务端。
如何保证服务端持续运行，建议使用 `supervisor` 或 `systemd` 。客户端的启动方式：

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

### 2、如何让服务端在后台守护进程

#### 2.1 可以尝试 systemd

参考链接 [https://www.cnblogs.com/zhangyy3/p/14759993.html]
友情提醒：确保这里面的执行命令是全局可用的。

#### 2.2 supervisor

示例：

```Bash
/opt/rock -httpAddr=:80 -domain="zach-rock.com" -log="/opt/log.txt"
```

```Vim
[program:zach-rock]
command = sh ./start.sh
directory   = /opt

autostart=true
autorestart=true
redirect_stderr         = true
stdout_logfile_maxbytes = 50MB
stdout_logfile_backups  = 10
stdout_logfile          = /var/log/supervisor-zach-rock.log

stderr_logfile_maxbytes = 50MB
stderr_logfile_backups  = 10
stderr_logfile          = /var/log/supervisor-zach-rock.log
```

#### 2.3 简单的命令（感觉不是很稳定，但我就是用的这个，省事 😂）

```Bash
nohup /opt/start.sh &
```

### 3、生成服务端和客户端

#### Windows 版

```
服务端 x86：GOOS=windows GOARCH=386 make server
客户端 x86：GOOS=windows GOARCH=386 make client
服务端 x64：GOOS=windows GOARCH=amd64 make server
客户端 x64：GOOS=windows GOARCH=amd64 make client
```

#### Linux 版

```
服务端 x86：GOOS=linux GOARCH=386 make server
客户端 x86：GOOS=linux GOARCH=386 make client
服务端 x64：GOOS=linux GOARCH=amd64 make server
客户端 x64：GOOS=linux GOARCH=amd64 make client
```

#### MacOS 版

```
服务端 x86：GOOS=darwin GOARCH=386 make server
客户端 x86：GOOS=darwin GOARCH=386 make client
服务端 x64：GOOS=darwin GOARCH=amd64 make server
客户端 x64：GOOS=darwin GOARCH=amd64 make client
```

#### 添加了 docker 部署的方式

见 Makefile 文件。

#### 其他版本的，自行搜索 go 交叉编译。

![image](https://user-images.githubusercontent.com/62736001/130351228-13d44aac-f3c0-4f8d-a93b-067c9610b6af.png)

# 最后：Let's rock! 开源万岁！

QQ 群: 1️⃣ 597337923  
Author: Zach.Lu  
Email: 1049655193@qq.com

# 常见问题

## 1、bash: /usr/local/bin/docker-compose: Permission denied

```
sudo chmod +x /usr/local/bin/docker-compose;
```
