### Goal
Create a bootable U Stick for X86 platform

### Prerequisite
Make sure that rootfs.tar.gz under /home folder

### Procedure
  1. Create two filesystems on the U Stick<p>
    a. The first one is for boot with  'W95 FAT32 (LBA)' format and used 200M space<p>
      ps: You **MUST** mark this filesystem as bootable<p>
    b. The second one is for root with  'EXT4' format and used almost 3.5G space<p>
    
    ```
    Device     Boot  Start     End Sectors  Size Id Type
    /dev/sdb1  *      2048  411647  409600  200M  c W95 FAT32 (LBA)
    /dev/sdb2       411648 7733247 7321600  3.5G 83 Linux
    ```
    `(echo n; echo ; echo ; echo ; echo +200M; echo a; echo n; echo ; echo ; echo ; echo 7733247; echo t; echo 1; echo c; echo w) | fdisk /dev/sdb`<p>
    ```
    ...
    mkfs.vfat /dev/sdb1
    mkfs.ext4 /dev/sdb2
    ...
    ```

  2. Mount filesystems
  ```
  mount /dev/sdb1 /mnt/boot
  mount /dev/sdb2 /mnt/root
  ```
  
  3. Untar rootfs.tar.gz into /mnt/root
  4. Copy /mnt/root/boot/vmlinuz-4.4.0-31-generic & /mnt/root/boot/initrd.img-4.4.0-31-generic into /mnt/boot folder
  5. Install the bootloader -syslinux
  `syslinux -i /dev/sdb1`<p>
