ISO安装

ISO安装采用Ubuntu Server amd64版本为基础；

安装过程在Ubuntu Server安装后的首次启动系统时，而非安装过程中，主要考虑在安装过程中不方便向用户显示。

该服务的unit file

```bash
# /lib/systemd/system/wisnuc-installer.service
[Unit]
Description=Wisnuc Installer
Before=getty@tty1.service
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/wisnuc-installer
StandardInput=tty
StandardOutput=inherit
StandardError=inherit

[Install]
WantedBy=multi-user.target
```



wisnuc-installer脚本

```bash
#!/bin/bash

URL=https://raw.githubusercontent.com/wisnuc/appifi-system/master/install-scripts/ubuntu-16-04-02-amd64/install-appifi.sh
BS=
SHA1=

if [ -f $BS ] || [ -f $SHA1 ]; then exit 0; fi

mkdir -p /wisnuc
curl -s $URL | bash - 2>&1 | tee /wisnuc/install.log

if [ $? -ne 0 ]; then
  echo "----------------------------------"
  echo "wisnuc installation failed"
  echo "see /wisnuc/install.log for detail"
  echo "----------------------------------"
  sleep 10
else
  systemctl disable wisnuc-installer.service
  echo "----------------------------------"
  echo "wisnuc system successfully installed"
  echo "----------------------------------"
fi
```



