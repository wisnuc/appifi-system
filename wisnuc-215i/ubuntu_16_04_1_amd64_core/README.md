# appifi-system for wisnuc-215i

### Goal
  1. Create a new rootfs.tar.gz for wisnuc-215i from ubuntu 16.04.1 64bit rootfs.tar.gz
  2. You can copy this rootfs.tar.gz to your U disk which can boot 215i, then U disk can write this rootfs.tar.gz to 215i emmc

### Prerequisite
  + Windows 7 Ultimate 64bit
  + VMware 12
  + Ubuntu 16.04.1 64bit rootfs.tar.gz
  + wisnuc-215i kernel package (like linux-image-4.3.3.001+_001_amd64.deb)

### Caution
  1. Assume origin rootfs package just like rootfs.tar.gz already exits under host's /home/ folder
  2. Assume kernel package just like linux-image-4.3.3.001+_001_amd64.deb already exits under host's /home/ folder

### Procedure
  1. Only need to run '**deploy-rootfs-outside-chroot.sh**', but you have to modify this file and '**deploy-rootfs-inside-chroot.sh**' if some names have changed like '*rootfs.tar.gz*' or '*linux-image-4.3.3.001+_001_amd64.deb*'

### Tips
  + How to create Ubuntu 16.04.1 64bit rootfs.tar.gz?
    - Use VMware to install Ubuntu 16.04.1 64bit
      1. You have to create two virtual disks, and separately install Ubuntu into both of them
      2. When first disk installation is succeed, **DO NOT** reboot you system, You need to store a clean environment, so poweroff system directly, then install second disk, when that is done, reboot system and boot system with second disk, finally mount first disk as removeable disk into second Ubuntu system, **COPY** them, done!
    - Use PC to install Ubuntu 16.04.1 64bit
      1. When installation is done, **DO NOT** reboot system, poweroff and use rescue U disk to reboot system instead, then **MOUNT** & **COPY** system disk, done
