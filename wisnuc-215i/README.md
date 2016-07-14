# appifi-system for wisnuc-215i

### Goal
`Create a new rootfs.tar.gz for wisnuc-215i from ubuntu 16.04 64bit rootfs.tar.gz`<p>

### Prerequisite
  + Ubuntu 16.04 64bit rootfs.tar.gz
  + wisnuc-215i kernel package (like ?.deb)

### Caution
  1. Assume origin rootfs package just like tmp.tar.gz already exits under host's /home/ folder
  2. Assume kernel package just like kernel.deb already exits under host's /home/ folder
  3. Only need to run '**deploy-rootfs-outside-chroot.sh**', but you have to modify this file and '**deploy-rootfs-inside-chroot.sh**' if some names have changed like '*tmp.tar.gz*' or '*kernel.deb*'
