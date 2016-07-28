#!/bin/bash

vmlinuz="vmlinuz-4.4.0-31-generic"
initrd="initrd.img-4.4.0-31-generic"
rootfs_uuid=`blkid | grep /dev/loop2 | awk '{print $2}' | cut -b 7-42`

cd /home
mkdir tmp
cd tmp
rm -rf *

dd if=/dev/zero of=ustick.img bs=512 count=7733248 conv=noerror,notrunc
losetup /dev/loop0 ustick.img
dd bs=440 count=1 if=/usr/lib/syslinux/mbr/mbr.bin of=/dev/loop0 conv=noerror,notrunc

(echo n; echo ; echo ; echo ; echo +200M; echo a; echo n; echo ; echo ; echo ; echo ; echo t; echo 1; echo c; echo w) | fdisk /dev/loop0

losetup -d /dev/loop0

losetup -o 1048576 --sizelimit 210763264 /dev/loop1 ustick.img
losetup -o 210763776 --sizelimit 3959422464 /dev/loop2 ustick.img

mkfs.vfat /dev/loop1
mkfs.ext4 /dev/loop2

mkdir /mnt/boot
mkdir /mnt/root

mount /dev/loop1 /mnt/boot
mount /dev/loop2 /mnt/root

cd /mnt/root
tar zxf /home/rootfs.tar.gz

cd /mnt/boot
cp ../root/boot/$vmlinuz .
cp ../root/boot/$initrd .

syslinux -i /dev/loop1

echo "PROMPT 0" > syslinux.cfg
echo "TIMEOUT 1" >> syslinux.cfg
echo "DEFAULT wisnuc" >> syslinux.cfg
echo "LABEL wisnuc" >> syslinux.cfg
echo "LINUX $vmlinuz" >> syslinux.cfg
echo "APPEND root=UUID=$rootfs_uuid rw" >> syslinux.cfg
echo "INITRD $initrd" >> syslinux.cfg

cd /home/tmp

umount /dev/loop1
umount /dev/loop2

losetup -d /dev/loop1
losetup -d /dev/loop2
