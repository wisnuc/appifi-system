### Goal
Create a bootable U Stick for X86 platform

### Reference
[Reference](http://www.richud.com/wiki/Ubuntu_Create_Hard_Drive_Image)

### Prerequisite
  1. rootfs.tar.gz which includes Ubuntu 16.04.1 & latest appifi application
  2. Make sure that rootfs.tar.gz under /home folder

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

  5. Install the bootloader - **syslinux**<p>
  `syslinux -i /dev/sdb1`<p>

  6. Configure the bootloader<p>
  ```
  PROMPT 0
  TIMEOUT 1
  DEFAULT wisnuc
  LABEL wisnuc
  LINUX vmlinuz-???
  APPEND root=UUID=??? rw
  INITRD initrd.img-???  
  ```
  
  7. Clone the U Stick<p>
  `dd if=/dev/sdb of=ustick.img bs=512 count=7733248 conv=noerror,notrunc`<p>  
  
  8. Burn this image to other real U Sticks

### Appendix
  + Compress image for space saving
    1. zerofree /dev/sdb2<p>
    ps: zerofree only can deal with 'ext4' family<p>
  
    2. Tar the image<p>
    `gzip -9 ustick.img`<p>
    
  + Using loop device to create image
    1. **deploy.sh** uses loop device to create u stick image
    2. When the script finishes, it will create a ustick.img under /home/tmp folder
    3. Burn this image to a real U Stick
    4. Ubuntu 16.04 does not get on well with syslinux & loop, so you have to reinstall them on this U Stick again
