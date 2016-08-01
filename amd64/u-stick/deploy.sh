#!/bin/bash

vmlinuz="vmlinuz-4.4.0-31-generic"
initrd="initrd.img-4.4.0-31-generic"

echo "###################  create & enter into tmp folder  ###################"
cd /home
mkdir tmp
cd tmp
rm -rf *

echo "###################  dd a empty image  ###################"
dd if=/dev/zero of=ustick.img bs=512 count=7733248 conv=noerror,notrunc

echo "###################  set up a new loop device - loop0  ###################"
losetup /dev/loop0 ustick.img

echo "###################  write MBR to loop0  ###################"
dd bs=440 count=1 if=/usr/lib/syslinux/mbr/mbr.bin of=/dev/loop0 conv=noerror,notrunc

echo "###################  fdisk for loop0  ###################"
(echo n; echo ; echo ; echo ; echo +200M; echo a; echo n; echo ; echo ; echo ; echo ; echo t; echo 1; echo c; echo w) | fdisk /dev/loop0

echo "###################  delete loop0  ###################"
losetup -d /dev/loop0

echo "###################  set up loop1 & loop2 for image partitions  ###################"
losetup -o 1048576 --sizelimit 210763264 /dev/loop1 ustick.img
losetup -o 210763776 --sizelimit 3959422464 /dev/loop2 ustick.img

echo "###################  mkfs for loop1 & loop2  ###################"
mkfs.vfat /dev/loop1
mkfs.ext4 /dev/loop2

echo "###################  create /mnt/boot & /mnt/root  ###################"
mkdir /mnt/boot
mkdir /mnt/root

echo "###################  mount loop1 & loop2  ###################"
mount /dev/loop1 /mnt/boot
mount /dev/loop2 /mnt/root

echo "###################  enter into loop2 (/mnt/root) & untar rootfs.tar.gz ###################"
cd /mnt/root
tar zxf /home/rootfs.tar.gz

echo "###################  enter into loop1 (/mnt/boot) & copy vmlinuz and initrd  ###################"
cd /mnt/boot
cp ../root/boot/$vmlinuz .
cp ../root/boot/$initrd .

echo "###################  install syslinux on loop1  ###################"
syslinux -i /dev/loop1

echo "###################  get loop2's uuid  ###################"
rootfs_uuid=`blkid | grep /dev/loop2 | awk '{print $2}' | cut -b 7-42`

echo "###################  create syslinux.cfg  ###################"
echo "PROMPT 0" > syslinux.cfg
echo "TIMEOUT 1" >> syslinux.cfg
echo "DEFAULT wisnuc" >> syslinux.cfg
echo "LABEL wisnuc" >> syslinux.cfg
echo "LINUX $vmlinuz" >> syslinux.cfg
echo "APPEND root=UUID=$rootfs_uuid rw" >> syslinux.cfg
echo "INITRD $initrd" >> syslinux.cfg

echo "###################  clean up  ###################"
cd /home/tmp

umount /dev/loop1
umount /dev/loop2

losetup -d /dev/loop1
losetup -d /dev/loop2
