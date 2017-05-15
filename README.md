# appifi-system

此项目用于提供在各种目标系统上安装wisnuc系统的安装方式，以及为开发者和高级用户提供wisnuc系统部署和启动逻辑的基础文档。

项目当前支持一般用户在64bit x86系统（以下使用amd64）上自行安装wisnuc系统，提供三种安装方式：

1. 用户首先在64位x86系统上，包括物理设备和虚拟机，自行安装ubuntu server，然后使用此项目提供的安装脚本安装wisnuc系统；
2. 使用预安装的u盘镜像制作启动u盘，直接运行；该方式以u盘作为系统盘，不支持从u盘再次安装系统到物理硬盘；
3. 使用预安装的虚机镜像，该方式主要用于测试和功能体验，不应用于实际使用；

Wisnuc w215i产品已经预装wisnuc系统，用户不需要使用此项目提供的安装脚本重新安装，这有可能导致用户数据丢失。

## 使用方式


### 第一步：安装Ubuntu 16.04.2 amd64 server版

wisnuc系统不支持LVM，其他无特殊要求；

在选择安装软件时，不要去除缺省选中的standard system utilities，选中OpenSSH server；Samba file server会在安装脚本中自动安装，此处选不选均可；

root密码需要足够强度，否则局域网内的攻击者获取root密码后可窃取和删除所有文件。

### 第二步：安装winsuc系统

登录后执行下面的命令即可。

```bash
curl -s https://raw.githubusercontent.com/wisnuc/appifi-system/master/install-scripts/ubuntu-16-04-02-amd64/install-appifi.sh | sudo -E bash -
```

安装后可以通过执行下述命令启动wisnuc的系统服务，或者重启操作系统后wisnuc系统服务会自动启动。

```bash
sudo systemctl start appifi-bootstrap
```

打开浏览器访问3001端口。


## 组件与安装过程说明

本节内容面向开发者和高级用户。

wisnuc系统基于ubuntu server的amd64版本，目前最新版本为16.04.2；在ubuntu发布更新的版本后，此项目在经过充分测试后支持新版本，并不再对老版本提供维护服务。

wisnuc系统安装主要提供以下组成部分：

1. node.js
2. docker
3. wisnuc系统依赖的第三方程序，均已apt install方式安装
4. wisnuc提供的应用

### Node.js

Node.js使用6.x LTS版本，暂无升级到7.x计划，代码不承诺兼容7.x版本；

Nodejs使用Node官方提供的平台包管理器方式安装：

https://nodejs.org/en/download/package-manager/

```bash
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt install -y nodejs
```

该方式安装之后用户可以用`apt update && apt upgrade`升级到最新版本；

安装之后`node`的路径是`/usr/bin/node`；

### Docker

Docker没有使用Ubuntu软件池中的docker.io包，而是使用docker官方提供的软件池方式安装。

安装方式来自Docker官方文档，假定系统内没有预先安装docker，如果尝试手动安装和维护，请参阅官方文档卸载旧版本安装新版本。

https://docs.docker.com/engine/installation/linux/ubuntu/

对于amd64系统，docker安装过程如下：

```bash
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update && sudo apt install -y docker-ce
```

### wisnuc系统依赖

以下列出wisnuc系统依赖的其他第三方组件，全部来自ubuntu官方软件池，其中用户依赖是用户使用wisnuc系统需要安装的依赖，开发者依赖仅开发者需要安装；

#### 用户依赖

1. openssh-server, btrfs-tools (should be installed when installing Ubuntu)
2. avahi-daemon, avahi-utils
3. imagemagick, 图片工具
4. ffmpeg, 视频工具
5. samba, smb文件服务
6. udisk2, U盘工具
7. xz-utils, 不确定，可能tar需要

#### 开发者依赖

1. build-essential, npm编译需要
2. python-minimal, npm编译需要
3. xattr ???

### wisnuc系统

以下文件和服务为wisnuc系统预装的文件

## wisnuc系统服务说明

wisnuc使用Ubuntu 16.04版本的systemd管理所有系统服务和启动项。

### appifi-bootstrap服务

该服务用于提供3001端口的appifi系统安装和启动服务；

```bash
# /lib/systemd/system/appifi-bootstrap.service
[Unit]
Description=Appifi Bootstrap Server
After=network.target

[Service]
Type=idle
ExecStartPre=/bin/cp /wisnuc/bootstrap/appifi-bootstrap.js.sha1 /wisnuc/bootstrap/appifi-bootstrap.js
ExecStart=/usr/bin/node /wisnuc/bootstrap/appifi-bootstrap.js
TimeoutStartSec=3
Restart=always

[Install]
WantedBy=multi-user.target
```

appifi-bootstrap是整个wisnuc系统的主进程；所有日志均从该服务输出，查看、启动和停止服务可以使用`systemctl`命令，查看日志使用`journalctl`命令，例如：

```bash
sudo systemctl status appifi-bootstrap.service      # 查看服务状态
sudo systemctl start appifi-bootstrap.service       # 启动服务
sudo systemctl stop appifi-bootstrap.service        # 停止服务
sudo journalctl -u appifi-bootstrap.service         # 查看服务日志
sudo journalctl -u appifi-bootstrap.service -f      # 以follow方式查看服务日志
```

如果修改了服务文件，应该让`systemd`重新载入服务文件：

```bash
sudo systemctl daemon-reload
```

### appifi-bootstrap-update服务

这是一个cron job，按照`systemd`的使用方式，该服务分为两个文件，其中服务文件执行任务，timer文件用于实现定期检查；

```bash
# /lib/systemd/system/appifi-bootstrap-update.service
[Unit]
Description=Appifi Bootstrap Update

[Service]
Type=simple
ExecStart=/usr/bin/node /wisnuc/bootstrap/appifi-bootstrap-update.packed.js

# /lib/systemd/system/appifi-bootstrap-update.timer
[Unit]
Description=Runs Appifi Bootstrap Update every 4 hour

[Timer]
OnBootSec=5min
OnUnitActiveSec=4h
Unit=appifi-bootstrap-update.service

[Install]
WantedBy=multi-user.target
```

### 安装目录与启动逻辑

wisnuc主要使用`/wisnuc`目录用于持久化文件存储，`/run/wisnuc`用于每次启动的临时文件系统和磁盘挂载点；

```
wisnuc
├── appifi                                      # appifi程序目录
├── appifi-tarballs                             # appifi-bootstrap下载的各个版本程序的tarball目录
├── appifi-tmp                                  # appifi-bootstrap程序使用的临时目录
└── bootstrap                                   # appifi-bootstrap程序存储目录
    ├── appifi-bootstrap.js                     # 当前执行的appifi-bootstrap.js程序文件（可执行文件）
    ├── appifi-bootstrap.js.sha1                # 最新下载的appifi-bootstrap.js程序文件
    └── appifi-bootstrap-update.packed.js       # appifi-bootstrap-update程序文件（可执行文件）
```

所有目录和目录内的文件均由wisnuc系统维护，用户不该自行修改，否则系统可能工作异常。

`appifi-bootstrap-update`服务仅下载最新版本的`appifi-bootstrap`程序文件，保存为`appifi-bootstrap.js.sha1`；`appifi-bootstrap`服务每次启动时会先复制`appifi-bootstrap.js.sha1`文件为`appifi-bootstrap`程序文件，然后启动后者，以避免出现竞争；所以最新版本的`appifi-bootstrap`在下载之后需要用户重启设备方可完成升级。

`appifi-bootstrap-update`目前的时间设定是：系统启动后5分钟进行第一次新版本检查，之后每4小时执行一次检查任务。









### Caution

1. It can runs on X86 platform & 215i which is a product of Wisnuc
2. We offer ovf file for X86 user; U disk image for 215i user
3. You can find the procedure of making ovf or rootfs.tar.gz in related folder
