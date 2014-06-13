==
ddsuite is simple openwrt web-config-ui

usage:
 git apply openwrt_1209.patch
 cp config_musicbox_wr703n to path_openwrt
 cp the project to openwrt/packages/
 make menucofig add ddsuite
 make

# install ddmusic with openwrt-frimware
obtain dev_uuid from http://m.jdodo.cn/obtain_dev_uuid.html
telnet/ssh the router wr703n
cd /tmp/
wget "http://downloads.openwrt.org/attitude_adjustment/12.09/ar71xx/generic/openwrt-ar71xx-generic-tl-wr703n-v1-squashfs-factory.bin"
mtd -r write openwrt-ar71xx-generic-tl-wr703n-v1-squashfs-factory.bin firmware
cd /tmp/
wget "http://res.jdodo.cn/release/install.sh"
chmod +x install.sh
/tmp/install.sh
reboot

