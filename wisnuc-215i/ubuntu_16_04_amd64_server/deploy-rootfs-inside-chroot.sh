#!/bin/bash

#
# important: only use for intel 215i platform
#

#
# prerequisite:
# 1. mount that disk partition which to be package as rootfs.tar.gz to this running system
# 2. assume the mount path is /home/tmp/
# 3. tar the whole folder with tar -zcvf /home/tmp.tar.gz /home/tmp/*
# 4. umount that disk partition
#

#
# procedure:
# 1. assume origin rootfs package just like tmp.tar.gz already exits under /home/ folder
# 2. assume kernel package just like kernel.deb already exits under /home/ folder
# 3. untar tmp.tar.gz
# 4. copy kernel.deb into untar folder
# 5. mount dev proc sys pts tmp
# ...
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

banner "In deploy-rootfs-inside-chroot file"

#
# define all pathnames
#
# version
# nodejs: 6.2.2
#
install_appifi_download_path="https://raw.githubusercontent.com/JiangWeiGitHub/appifi-system/master/wisnuc-215i/ubuntu_16_04_amd64_server/install-appifi.sh"
install_appifi_name="install-appifi.sh"

kernel_package="linux-image-4.3.3.001+_001_amd64.deb"
kernel_bzimage_name="vmlinuz-4.3.3.001+"
kernel_initrd_name="initrd.img-4.3.3.001+"

#
# close auto-update
#
echo "APT::Periodic::Update-Package-Lists "0";" > /etc/apt/apt.conf.d/10periodic
echo "APT::Periodic::Download-Upgradeable-Packages "0";" >> /etc/apt/apt.conf.d/10periodic
echo "APT::Periodic::AutocleanInterval "0";" >> /etc/apt/apt.conf.d/10periodic

#
# install appifi
#
banner "Download install-appifi.sh"
cd home
wget $install_appifi_download_path
if [ $? != 0 ]
then
   echo "Download install appifi script failed!"
   exit 110
fi

banner "Run install-appifi.sh"
/bin/sh $install_appifi_name

#
# change fstab
#
banner "Edit fstab"
echo "/dev/mmcblk0p1 /               ext4    errors=remount-ro 0       1" > /etc/fstab

#
# install our own kernel
#
banner "Install our own kernel"
dpkg -i $kernel_package
cd /boot
ln -s $kernel_bzimage_name bzImage
ln -s $kernel_initrd_name ramdisk
echo "console=tty0 console=ttyS0,115200 root=/dev/mmcblk0p1 rootwait" > /boot/cmdline
cd /home

#
# clean up
#
banner "Clean up"
apt-get -y autoremove --purge linux-headers-generic linux-generic
apt-get -y autoremove --purge linux-headers-4.4.0-21 linux-headers-4.4.0-21-generic linux-image-extra-4.4.0-21-generic linux-image-4.4.0-21-generic
apt-get clean
rm -rf ./*
