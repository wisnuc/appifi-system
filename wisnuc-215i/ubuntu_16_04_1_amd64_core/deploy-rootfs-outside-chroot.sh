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

banner "In deploy-rootfs-outside-chroot file"

#
# define all pathnames
#
# version
# nodejs: 6.2.2
#
tarball="rootfs.tar.gz"
untar_tmp_folder="appifi-rootfs"
kernel_package="linux-image-4.3.3.001+_001_amd64.deb"
deploy_rootfs_inside_chroot_path="https://raw.githubusercontent.com/JiangWeiGitHub/appifi-system/master/wisnuc-215i/ubuntu_16_04_1_amd64_core/deploy-rootfs-inside-chroot.sh"
deploy_rootfs_inside_chroot_name="deploy-rootfs-inside-chroot.sh"

new_tarball_name="wisnuc-appifi-rootfs.tar.gz"

#
# download deploy_rootfs_inside_chroot file
#
banner "Download deploy_rootfs_inside_chroot file"
wget $deploy_rootfs_inside_chroot_path
if [ $? != 0 ]
then
   echo "Download deploy_rootfs_inside_chroot file failed!"
   exit 110
fi
chmod 755 $deploy_rootfs_inside_chroot_name

#
# create a tmp folder
#
banner "Create tmp folder & copy tarball"
mkdir tmp
cd tmp
cp /home/$tarball ./

#
# untar tarball
#
banner "Untar tarball"
mkdir $untar_tmp_folder
cd $untar_tmp_folder
tar -zxf ../$tarball
if [ $? != 0 ]
then
   echo "Untar tarball failed!"
   exit 110
fi
cd ..

#
# copy kernel package into this untar folder
#
banner "Copy kernel package into this untar folder"
cp /home/$kernel_package ./$untar_tmp_folder/home/

#
# copy deploy_rootfs_inside_chroot file into this untar folder
#
banner "Copy deploy_rootfs_inside_chroot file into this untar folder"
cp /home/$deploy_rootfs_inside_chroot_name ./$untar_tmp_folder/home/

#
# mount essential folders
#
banner "Mount essential folders"
mount -t devtmpfs dev ./$untar_tmp_folder/dev
mount -t proc proc ./$untar_tmp_folder/proc
mount -t sysfs none ./$untar_tmp_folder/sys
mount -t devpts devpts ./$untar_tmp_folder/dev/pts
mount -t tmpfs -o size=8m tmpfs ./$untar_tmp_folder/tmp

#
# chroot into this fs
#
banner "chroot & run deploy_rootfs_inside_chroot file"
chroot ./$untar_tmp_folder/  /bin/bash -c "/home/$deploy_rootfs_inside_chroot_name"

#
# quit from chroot
#
banner "Exit chroot"
# exit

#
# unmount
#
banner "umount every path"
umount ./$untar_tmp_folder/tmp
umount ./$untar_tmp_folder/dev/pts
umount ./$untar_tmp_folder/sys
umount ./$untar_tmp_folder/proc
umount ./$untar_tmp_folder/dev

#
# make new tarball
#
banner "Make new tarball"
cd ./$untar_tmp_folder/
tar -zcf /home/$new_tarball_name ./*
cd /home
