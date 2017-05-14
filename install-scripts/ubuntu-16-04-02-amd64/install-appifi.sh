#!/bin/bash

#
# Platform: Ubuntu 16.04.2 amd64 server
#

set -e

DASH="------------------------------------------------------------"

banner()
{
	echo ""
	echo $DASH
	echo "$1"
	echo $DASH
	echo ""
}

banner "apt update"
apt-get update

#
# update apt sourcelist first
#
# banner "Update apt"
# echo "deb http://ubuntu.uestc.edu.cn/ubuntu/ xenial main restricted universe multiverse" > /etc/apt/sources.list
# echo "deb http://ubuntu.uestc.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list
# echo "deb http://ubuntu.uestc.edu.cn/ubuntu/ xenial-proposed main restricted universe multiverse" >> /etc/apt/sources.list
# echo "deb http://ubuntu.uestc.edu.cn/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list
# echo "deb http://ubuntu.uestc.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list

#
# install avahi packages
#
banner "install nodejs"
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt install -y nodejs

banner "install docker"
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update && sudo apt install -y docker-ce

banner "install dependencies"
sudo apt-get install -y avahi-daemon avahi-utils build-essential python-minimal openssh-server btrfs-tools imagemagick ffmpeg samba udisks2

#
# Related deployment with appifi bootstrap
#
banner "Pull bootstrap files"
mkdir -p /wisnuc/bootstrap
wget https://raw.githubusercontent.com/wisnuc/appifi-bootstrap-update/release/appifi-bootstrap-update.packed.js /wisnuc/bootstrap
wget https://raw.githubusercontent.com/wisnuc/appifi-bootstrap/release/appifi-bootstrap.js.sha1 /wisnuc/bootstrap

#
# appifi-bootstrap service file
#
banner "install appifi-bootstrap service file"
cat > /lib/systemd/system/appifi-bootstrap.service <<EOF
[Unit]
Description=Appifi Bootstrap Server
After=network.target

[Service]
Type=idle
ExecStartPre=/bin/cp /wisnuc/bootstrap/appifi-bootstrap.js.sha1 /wisnuc/bootstrap/appifi-bootstrap.js
ExecStart=/usr/local/bin/node /wisnuc/bootstrap/appifi-bootstrap.js
TimeoutStartSec=3
Restart=always

[Install]
WantedBy=multi-user.target
EOF

#
# Appifi Bootstrap Update Service
#
banner "install appifi-bootstrap-update service file"
cat > /lib/systemd/system/appifi-bootstrap-update.service <<EOF
[Unit]
Description=Appifi Bootstrap Update

[Service]
Type=simple
ExecStart=/usr/bin/node /wisnuc/bootstrap/appifi-bootstrap-update.packed.js
EOF

#
# Appifi Bootstrap Update Service Timer
#
banner "install appifi-bootstrap-update timer file"
cat > /lib/systemd/system/appifi-bootstrap-update.timer <<EOF
[Unit]
Description=Runs Appifi Bootstrap Update every 4 hour

[Timer]
OnBootSec=5min
OnUnitActiveSec=4h
Unit=appifi-bootstrap-update.service

[Install]
WantedBy=multi-user.target
EOF

# Create soft link
# ln -s /lib/systemd/system/appifi-bootstrap* /etc/systemd/system/multi-user.target.wants/
# configure network
# echo "[Match]"                       > /etc/systemd/network/wired.network
# echo "Name=en*"                     >> /etc/systemd/network/wired.network
# echo "[Network]"                    >> /etc/systemd/network/wired.network
# echo "DHCP=ipv4"                    >> /etc/systemd/network/wired.network

banner "system daemon reload"
systemctl daemon-reload

banner "stop and disable smb/nmb service"
systemctl stop smbd nmbd
systemctl disable smbd nmbd

banner "enable networkd, resolved, avahi"
systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable avahi-daemon

banner "enable appifi-bootstrap, appifi-bootstrap-update"
systemctl enable appifi-bootstrap
systemctl enable appifi-bootstrap-update.timer

