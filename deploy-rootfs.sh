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

#
# define all pathnames
#
# version
# nodejs: 6.2.2
#
install_appifi_download_path="https://raw.githubusercontent.com/JiangWeiGitHub/appifi-system/master/install-appifi.sh"
tarball="tmp.tar.gz"
untar_tmp_folder="appifi-rootfs"

kernel_package="linux-image-4.3.3.001+_001_amd64.deb"
kernel_bzimage_name="vmlinuz-4.3.3.001+"
kernel_initrd_name="initrd.img-4.3.3.001+"

#
# create a tmp folder
#
mkdir tmp
cd tmp
cp /home/$tarball ./

#
# untar tarball
#
mkdir $untar_tmp_folder
cd $untar_tmp_folder
tar -zxvf ../$tarball
if [ $? != 0 ]
then
   echo "Untar tarball failed!"
   exit 110
fi
cd ..

#
# copy kernel package into this untar folder
#
cp /home/$kernel_package ./$untar_tmp_folder/home/

#
# mount essential folders
#
mount -t devtmpfs dev ./$untar_tmp_folder/dev
mount -t proc proc ./$untar_tmp_folder/proc
mount -t sysfs none ./$untar_tmp_folder/sys
mount -t devpts devpts ./$untar_tmp_folder/dev/pts
mount -t tmpfs -o size=8m tmpfs ./$untar_tmp_folder/tmp

#
# chroot into this fs
#
chroot ./$untar_tmp_folder/

#
# install appifi
#
cd home
wget $install_appifi_download_path
if [ $? != 0 ]
then
   echo "Download install appifi script failed!"
   exit 110
fi

/bin/sh install-appifi.sh

#
# change fstab
#
echo "/dev/mmcblk0p1 /               ext4    errors=remount-ro 0       1" > etc/fstab

#
# install our own kernel
#
dpkg -i $kernel_package
cd /boot
ln -s $kernel_bzimage_name bzImage
ln -s $kernel_initrd_name ramdisk
echo "console=tty0 console=ttyS0,115200 root=/dev/mmcblk0p1 rootwait" > /boot/cmdline
cd /home

#
# clean up
#
rm -rf ./*

#
# quit from chroot
#
exit

#
# unmount
#
umount ./$untar_tmp_folder/dev
umount ./$untar_tmp_folder/proc
umount ./$untar_tmp_folder/sys
umount ./$untar_tmp_folder/dev/pts
umount ./$untar_tmp_folder/tmp
