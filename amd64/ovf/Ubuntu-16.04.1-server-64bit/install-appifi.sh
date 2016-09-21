#!/bin/bash

#
# Platform: Ubuntu 16.04.1 server 64bit
#

#
# Operation Path: chroot /target
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

banner "In install-appifi.sh file"

#
# update apt sourcelist first
#
banner "Update apt"
echo "deb http://ubuntu.uestc.edu.cn/ubuntu/ xenial main restricted universe multiverse" > /etc/apt/sources.list
echo "deb http://ubuntu.uestc.edu.cn/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ubuntu.uestc.edu.cn/ubuntu/ xenial-proposed main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ubuntu.uestc.edu.cn/ubuntu/ xenial-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb http://ubuntu.uestc.edu.cn/ubuntu/ xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list

apt-get update

#
# define all pathnames
#
# version
# nodejs: 6.2.2
#
node_download_path="https://nodejs.org/dist/v6.6.0/node-v6.6.0-linux-x64.tar.xz"
node_package_name="node-v6.6.0-linux-x64.tar.xz"
node_home_path="node-v6.6.0-linux-x64"

system_run_path="/usr/local"

#
# install avahi packages
#
banner "Install avahi"
apt-get -y install avahi-daemon avahi-utils

#
# create a new empty folder
#
mkdir -p /home/tmp
cd /home/tmp

#
# install some essential packages for whole system
#
banner "Install essential packages for whole system"
apt-get -y install build-essential python-minimal openssh-server imagemagick libudev-dev

#
# install nodejs
#
banner "Install nodejs"
wget $node_download_path
if [ $? != 0 ]
then
   echo "Download nodejs package failed!"
   exit 110
fi

tar Jxf $node_package_name
\cp -rf ./$node_home_path/* $system_run_path

#
# install nodejs's global bianry packages
#
/usr/local/bin/npm --registry https://registry.npm.taobao.org install -g xxhash fs-xattr udev

#
# install some essential packages for docker
#
banner "Install essential packages for docker"
apt-get -y install xz-utils git aufs-tools

#
# install docker
#
banner "Install docker"
apt-get update
apt-get -y install apt-transport-https ca-certificates
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 F76221572C52609D
# echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list
echo "deb https://mirrors.ustc.edu.cn/apt.dockerproject.org/repo/ ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get -y install linux-image-extra-$(uname -r) apparmor
apt-get -y install docker-engine

#
# Related deployment with appifi bootstrap
#
banner "deploy our own service"

# Get files
mkdir -p /wisnuc/appifi /wisnuc/appifi-tarballs /wisnuc/appifi-tmp /wisnuc/bootstrap
wget https://raw.githubusercontent.com/wisnuc/appifi-bootstrap-update/master/appifi-bootstrap-update.packed.js
mv appifi-bootstrap-update.packed.js /wisnuc/bootstrap
wget https://raw.githubusercontent.com/wisnuc/appifi-bootstrap/master/appifi-bootstrap.js.sha1
mv appifi-bootstrap.js.sha1 /wisnuc/bootstrap

# Appifi Bootstrap Service
echo "[Unit]" > /lib/systemd/system/appifi-bootstrap.service
echo "Description=Appifi Bootstrap Server" >> /lib/systemd/system/appifi-bootstrap.service
echo "After=network.target" >> /lib/systemd/system/appifi-bootstrap.service
echo "" >> /lib/systemd/system/appifi-bootstrap.service

echo "[Service]" >> /lib/systemd/system/appifi-bootstrap.service
echo "Type=idle" >> /lib/systemd/system/appifi-bootstrap.service
echo "ExecStartPre=/bin/cp /wisnuc/bootstrap/appifi-bootstrap.js.sha1 /wisnuc/bootstrap/appifi-bootstrap.js" >> /lib/systemd/system/appifi-bootstrap.service
echo "ExecStart=/usr/local/bin/node /wisnuc/bootstrap/appifi-bootstrap.js" >> /lib/systemd/system/appifi-bootstrap.service
echo "TimeoutStartSec=3" >> /lib/systemd/system/appifi-bootstrap.service
echo "Restart=always" >> /lib/systemd/system/appifi-bootstrap.service
echo "" >> /lib/systemd/system/appifi-bootstrap.service

echo "[Install]" >> /lib/systemd/system/appifi-bootstrap.service
echo "WantedBy=multi-user.target" >> /lib/systemd/system/appifi-bootstrap.service

# Appifi Bootstrap Update Service
echo "[Unit]" > /lib/systemd/system/appifi-bootstrap-update.service
echo "Description=Appifi Bootstrap Update" >> /lib/systemd/system/appifi-bootstrap-update.service
echo "" >> /lib/systemd/system/appifi-bootstrap-update.service
echo "[Service]" >> /lib/systemd/system/appifi-bootstrap-update.service
echo "Type=simple" >> /lib/systemd/system/appifi-bootstrap-update.service
echo "ExecStart=/usr/local/bin/node /wisnuc/bootstrap/appifi-bootstrap-update.packed.js" >> /lib/systemd/system/appifi-bootstrap-update.service

# Appifi Bootstrap Update Service Timer
echo "[Unit]" > /lib/systemd/system/appifi-bootstrap-update.timer
echo "Description=Runs Appifi Bootstrap Update every 4 hour" >> /lib/systemd/system/appifi-bootstrap-update.timer
echo "" >> /lib/systemd/system/appifi-bootstrap-update.timer
echo "[Timer]" >> /lib/systemd/system/appifi-bootstrap-update.timer
echo "OnBootSec=1min" >> /lib/systemd/system/appifi-bootstrap-update.timer
echo "OnUnitActiveSec=4h" >> /lib/systemd/system/appifi-bootstrap-update.timer
echo "Unit=appifi-bootstrap-update.service" >> /lib/systemd/system/appifi-bootstrap-update.timer
echo "" >> /lib/systemd/system/appifi-bootstrap-update.timer
echo "[Install]" >> /lib/systemd/system/appifi-bootstrap-update.timer
echo "WantedBy=multi-user.target" >> /lib/systemd/system/appifi-bootstrap-update.timer

# Create soft link
ln -s /lib/systemd/system/appifi-bootstrap* /etc/systemd/system/multi-user.target.wants/

# configure network
echo "[Match]"                       > /etc/systemd/network/wired.network
echo "Name=en*"                     >> /etc/systemd/network/wired.network
echo "[Network]"                    >> /etc/systemd/network/wired.network
echo "DHCP=ipv4"                    >> /etc/systemd/network/wired.network

# Set some softwares' initial value
systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable avahi-daemon
systemctl disable docker
systemctl enable appifi-bootstrap
systemctl enable appifi-bootstrap-update.timer

#
# cleanup
#
cd ..
rm -rf tmp
