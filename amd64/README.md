# appifi-system for amd64 platfor
system installation for appifi and it's dependencies

### Goal
  1. Create ovf format files

### Preface
  1. We use VMware software to install the whole appifi-system under host PC with Windows 7 ultimate 64bit.

### Configuration
+ **Host PC Related**
  - Architecture: X86
  - OS: Windows 7 ultimate 64bit
  - CPU: Intel(R) Core(TM) i3-4160 CPU @ 3.60GHz
  - Memory: 8.00GB
  - VMware: VMware Workstation 12 Pro
+ **Default Parameters in VMware**
  - CPU: 1 CPU 4 Core
  - Memory: 2G
  - Network: Bridge
  - Hard disk: 80G
  - Others: Default
+ **appifi-system Related**
  - OS: Ubuntu 16.04 64bit Server
  - Essential Softwares: **Docker** **Nodejs** 

### Procedure
+ Use VMware to install Ubuntu 16.04
+ HostName: wisnuc UserName: wisnuc Password: wisnuc (Remember to install openssh-server)
+ Enter shell after install Ubuntu 16.04 success
+ chroot /target
+ wget install-appifi.sh from https://raw.githubusercontent.com/JiangWeiGitHub/appifi-system/master/amd64/install-appifi.sh
+ run install-appifi.sh
  - Edit & update APT sourcelist
  - Install avahi with apt-get
  - Install Nodejs with binary lib
  - Install docker with apt-get
  - Create some folders under 'wisnuc'
  - Get 'appifi-bootstrap-update.packed.js' with wget
  - Get 'appifi-bootstrap.js.sha1' with wget
  - Create appifi bootstrap service
  - Create appifi bootstrap update Service & timer
  - Enable & Disable some service with systemctl
+ type 'exit' in shell
+ type 'poweroff' in shell
+ Use VMware "export as ovf" on Window 7
+ Copy files you need (*.mf file maybe make virtual box import failed)
+ Done
