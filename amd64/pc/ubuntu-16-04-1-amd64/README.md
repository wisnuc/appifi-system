### Goal
  1. users only need to copy some files & run a shell script inside `Ubuntu 16.04.1 amd64` operating system on their own PC, and `Appifi System` will be running after reboot.

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
  - OS: Ubuntu 16.04.1 amd64 Desktop

### Procedure
+ Run Ubuntu 16.04.1
+ Open shell
+ Download install-appifi.sh<p>
  `wget https://raw.githubusercontent.com/JiangWeiGitHub/appifi-system/master/amd64/pc/ubuntu-16-04-1-amd64/install-appifi.sh`<p>
+ Copy `node-v6.9.2-linux-x64.tar.xz` & `docker-1.12.4.tgz` & `appifi-bootstrap-update.packed.js` & `appifi-bootstrap.js.sha1` under the same level directory with `install-appifi.sh`
  - `node-v6.9.2-linux-x64.tar.xz` [*download path*](https://nodejs.org/dist/v6.9.2/node-v6.9.2-linux-x64.tar.xz)<p>
  - `docker-1.12.4.tgz` [*download path*](https://get.docker.com/builds/Linux/x86_64/docker-1.12.4.tgz)<p>
  - `appifi-bootstrap-update.packed.js` [*download path*](https://raw.githubusercontent.com/wisnuc/appifi-bootstrap-update/release/appifi-bootstrap-update.packed.js)<p>
  - `appifi-bootstrap.js.sha1` [*download path*](https://raw.githubusercontent.com/wisnuc/appifi-bootstrap/release/appifi-bootstrap.js.sha1)<p>
+ Run install-appifi.sh<p>
  `chmod 755 ./install-appifi.sh`<p>
  `./install-appifi.sh`<p>
  - Install avahi with apt-get
  - Install Nodejs with local binary lib
  - Install docker with local binary lib
  - Create some folders under 'wisnuc'
  - Get 'appifi-bootstrap-update.packed.js' with local file
  - Get 'appifi-bootstrap.js.sha1' with local file
  - Create appifi bootstrap service
  - Create appifi bootstrap update Service & timer
  - Enable & Disable some service with systemctl
  - Clean apt packages & tmp folder
+ Reboot system
+ Done
