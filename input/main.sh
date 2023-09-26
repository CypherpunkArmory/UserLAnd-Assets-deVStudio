#!/bin/bash

echo "127.0.0.1 localhost" > /etc/hosts
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

echo "#!/bin/sh" > /etc/profile.d/userland.sh
echo "unset LD_PRELOAD" >> /etc/profile.d/userland.sh
echo "unset LD_LIBRARY_PATH" >> /etc/profile.d/userland.sh
echo "export LIBGL_ALWAYS_SOFTWARE=1" >> /etc/profile.d/userland.sh
chmod +x /etc/profile.d/userland.sh

#update our repos so we can install some packages
apt-get update

#install some packages with need for UserLAnd
apt-get install -y --no-install-recommends sudo dropbear libgl1-mesa-glx tightvncserver xterm xfonts-base twm openbox expect
apt-get install -y wget gpg
archi=$(dpkg --print-architecture)
case "$archi" in
  arm64) wget --no-check-certificate -O vscode.deb 'http://code.visualstudio.com/sha/download?build=stable&os=linux-deb-arm64'
    ;;
  armhf) wget --no-check-certificate -O vscode.deb 'http://code.visualstudio.com/sha/download?build=stable&os=linux-deb-armhf'
    ;;
  amd64) wget --no-check-certificate -O vscode.deb 'http://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
    ;;
  *) echo "unsupported arch"
    exit
    ;;
esac
apt install -y ./vscode.deb
rm -f ./vscode.deb

apt-get install -y firefox-esr
apt-get install -y git

apt-get install -y curl apt-transport-https software-properties-common
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt-get install nodejs

apt-get install -y build-essential pkg-config python3 npm gdb
npm config set python python3
npm install --global code-server --unsafe-perm

#clean up after ourselves
apt-get clean

#tar up what we have before we grow it
tar -czvf /output/rootfs.tar.gz --exclude sys --exclude dev --exclude proc --exclude mnt --exclude etc/mtab --exclude output --exclude input --exclude .dockerenv /

#build disableselinux to go with this release
apt-get update
apt-get -y install build-essential
gcc -shared -fpic /input/disableselinux.c -o /output/libdisableselinux.so

#grab a static version of busybox that we can use to set things up later
apt-get -y install busybox-static
cp /bin/busybox output/busybox
