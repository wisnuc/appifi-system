#!/bin/bash

set -e

# generated iso file name
IMAGE=ubuntu-16.04.2-server-amd64-wisnuc.iso
# original iso mount point
ISO=iso
# working directory
BUILD=cd-image

# check path argument
if [ ! -f "$1" ]; then
  echo "please provide iso image file path"
  exit 1
fi

# clean
sudo rm -rf $ISO
sudo rm -rf $BUILD

# mount iso
mkdir -p $ISO
sudo mount -o loop $1 $ISO

# cp all iso files into build folder
mkdir -p $BUILD
cp -rT $ISO $BUILD
sudo umount $ISO

# fix permission
chmod a+w $BUILD/preseed/ubuntu-server.seed

cat <<'EOF' >> $BUILD/preseed/ubuntu-server.seed
# Install wisnuc installer
d-i preseed/late_command string \
in-target wget -O /tmp/preseed-install https://raw.githubusercontent.com/wisnuc/appifi-system/master/install-scripts/ubuntu-16-04-2-amd64/preseed-install; \
in-target bash -c "bash -x /tmp/preseed-install > /.preseed-install.log 2>&1"
EOF

chmod a+w $BUILD/isolinux/isolinux.bin
mkisofs -r -V "ubuntu-server 16.04.2 wisnuc" \
  -cache-inodes \
  -J -l -b isolinux/isolinux.bin \
  -c isolinux/boot.cat -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -o $IMAGE $BUILD

rm -rf $ISO
sudo rm -rf $BUILD

