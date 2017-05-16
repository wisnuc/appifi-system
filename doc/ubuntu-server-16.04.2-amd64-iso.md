ISO安装

ISO安装采用Ubuntu Server amd64版本为基础；

安装过程在Ubuntu Server安装后的首次启动系统时，而非安装过程中，主要考虑在安装过程中不方便向用户显示。

该服务的unit file

```bash
# /lib/systemd/system/wisnuc-installer.service
[Unit]
Description=Wisnuc Installer
Before=getty@tty1.service
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/wisnuc-installer
StandardInput=tty
StandardOutput=inherit
StandardError=inherit

[Install]
WantedBy=multi-user.target
```



wisnuc-installer脚本

```bash
#!/bin/bash

URL=https://raw.githubusercontent.com/wisnuc/appifi-system/master/install-scripts/ubuntu-16-04-02-amd64/install-appifi.sh
SHA1=/wisnuc/bootstrap/appifi-bootstrap.js.sha1
UPDATE=/wisnuc/bootstrap/appifi-bootstrap-update.packed.js

if [ -f $SHA1 ] || [ -f $UPDATE ]; then exit 0; fi

systemctl is-active appifi-bootstrap.service
if [ $? -eq 0 ]; then systemctl stop appifi-bootstrap.service; fi

systemctl is-active appifi-bootstrap-update.service
if [ $? -eq 0 ]; then systemctl stop appifi-bootstrap-update.service; fi

mkdir -p /wisnuc
curl -s $URL | bash - 2>&1 | tee /wisnuc/install.log

if [ $? -ne 0 ]; then
  echo "----------------------------------"
  echo "wisnuc installation failed"
  echo "see /wisnuc/install.log for detail"
  echo "----------------------------------"
  sleep 10
else
  systemctl disable wisnuc-installer.service
  echo "----------------------------------"
  echo "wisnuc system successfully installed"
  echo "----------------------------------"
  sleep 10
fi
```



```bash
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
rm -rf $ISO
rm -rf $BUILD

# mount iso
mkdir -p $ISO
mount -o loop $ISO $1

# cp all iso files into build folder
mkdir -p $BUILD
cp -rT $ISO $BUILD

mkdir -p $BUILD/wisnuc
cat > $BUILD/wisnuc/wisnuc-installer.service <<'EOF'
[Unit]
Description=Wisnuc Installer
Before=getty@tty1.service
After=multi-user.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/wisnuc-installer
StandardInput=tty
StandardOutput=inherit
StandardError=inherit

[Install]
WantedBy=multi-user.target
EOF

cat > /lib/systemd/system/appifi-bootstrap.service <<EOF
EOF

cat <<'EOF' >> $BUILD/preseed/ubuntu-server.seed

# Add wisnuc installer
d-i preseed/late_command string cp /cdrom/wisnuc/wisnuc-installer.service /target/lib/systemd/system/wisnuc-installer.service
d-i preseed/late_command string cp /cdrom/wisnuc/wisnuc-installer /target/usr/bin/wisnuc-installer
d-i preseed/late_command string chroot /target systemctl enable wisnuc-installer.service
EOF

mkisofs -r -V "Ubuntu-Server 16.04.2 LTS amd4 with WISNUC" \
            -cache-inodes \
            -J -l -b isolinux/isolinux.bin \
            -c isolinux/boot.cat -no-emul-boot \
            -boot-load-size 4 -boot-info-table \
            -o $IMAGE $BUILD
```

