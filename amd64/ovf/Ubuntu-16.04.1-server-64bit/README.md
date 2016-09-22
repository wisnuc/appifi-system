# appifi-system for amd64 platform
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
  - OS: Ubuntu 16.04.1 64bit Server
  - Essential Softwares: **Docker** **Nodejs** 

### Procedure
+ Use VMware to install Ubuntu 16.04.1
+ HostName: wisnuc UserName: wisnuc Password: wisnuc (Remember to install openssh-server)
+ Enter shell after install Ubuntu 16.04.1 success
+ chroot /target
+ export PATH=$PATH:/usr/local/bin
+ echo $PATH
+ install-appifi.sh<p>
  `wget https://raw.githubusercontent.com/JiangWeiGitHub/appifi-system/master/amd64/ovf/Ubuntu-16.04.1-server-64bit/install-appifi.sh`<p>
+ run install-appifi.sh<p>
  `chmod 755 ./install-appifi.sh`<p>
  `./install-appifi.sh`<p>
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
  - Clean apt packages & tmp folder
+ type 'exit' in shell
+ type 'poweroff' in shell
+ Use VMware "export as ovf" on Window 7
+ Copy files you need (*.mf file maybe make virtual box import failed)
+ Done
