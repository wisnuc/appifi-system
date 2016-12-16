### Goal
  1. users only need to run a shell script inside `Ubuntu 16.04.1 amd64` operation system on their own PC, and `Appifi System` will run after reboot

### Configuration
+ **Host PC Related**
  - Architecture: X86
  - OS: Windows 7 ultimate 64bit
  - CPU: Intel(R) Core(TM) i3-4160 CPU @ 3.60GHz
  - Memory: 8.00GB
  - VMware: VMware Workstation 12 Pro
+ **Default Parameters in VMware** (develop environment)
  - CPU: 1 CPU 4 Core
  - Memory: 2G
  - Network: Bridge
  - Hard disk: 80G
  - Others: Default
+ **appifi-system Related**
  - OS: Ubuntu 16.04.1 AMD64 Desktop

### Procedure
+ Run Ubuntu 16.04.1
+ Open shell
+ Check APT sourclist (`/etc/apt/sources.list`)
+ Download install-appifi.sh<p>
  `wget https://raw.githubusercontent.com/JiangWeiGitHub/appifi-system/master/amd64/pc/ubuntu-16.04.1-server-amd64/install-appifi.sh`<p>
+ Copy `node-v6.9.2-linux-x64.tar.xz` & `docker-1.12.4.tgz` & `appifi-bootstrap-update.packed.js` & `appifi-bootstrap.js.sha1` under the same level directory with `install-appifi.sh`
+ Run install-appifi.sh<p>
  `chmod 755 ./install-appifi.sh`<p>
  `./install-appifi.sh`<p>
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
+ Reboot system
+ Done
