#!/bin/sh
# 
# CONFIG NETWORK FISRT!!!
# vi /etc/config/network
# vi /etc/config/wireless

install_opkg_ipks(){
  echo "install require ipks"
  local mods="kmod-usb-audio alsa-lib zlib"
  opkg update
  for m in ${mods}; do 
    opkg install $m
  done
}

create_ddsuite_conf(){
  echo "create default ddsuite conf"
  local CONF="/etc/ddsuite/ddsuite.conf"
  mkdir -p "/etc/ddsuite"
  echo "online help: http://m.jdodo.cn/help.html"
  printf "Enter DEV_UUID:"
  read DEV_UUID
cat <<END>${CONF}
STA_ENC=off
STA_SSID=unknown-ssid
STA_KEY=unknown-ssid-key
DEV_UUID=${DEV_UUID}
DEV_PIN=null
END
}

add_firmware_rule(){
  echo "add ddsuite firewall rule"
  local CONF="/etc/config/firewall"
  if [ -e ${CONF} ]; then
cat <<END>>${CONF}
# Allow ddsuite port 3000
config rule
        option name     Allow-ddsuite-service
        option src      wan
        option proto    tcp
        option dest_port        3000
        option target   ACCEPT
        option family   ipv4
END
  /etc/init.d/firewall restart
  fi
}

install_ddmusic_service(){
  echo "create boot launch bash"
  local SH="/etc/init.d/ddmusic"
cat <<END>${SH}
#!/bin/sh /etc/rc.common
######################################
# this is ddmusic service bash
######################################
START=60
TING=/tmp/music-box/ting

download_ddmusic(){
  local URL=\$1
  local PWD=\`pwd\`
  if ! [ -x \$TING ]; then
    cd /tmp/
    wget "\$URL" -O - | tar -zx
    cd \$PWD
  fi
}

start(){
  local BOARD=\`cat /proc/cmdline|awk '{print \$1}'\`
  if test x\$BOARD = x; then
    BOARD=\`dmesg |grep Kernel|awk '{print \$6}'\`
  fi
  if test x\$BOARD = x; then
    echo "UNKNOWN BOARD"
    exit 1
  fi
  local VERSION="2.0.0"
  local QUERY="http://m.jdodo.cn/api/package?\$BOARD&version=\${VERSION}"
  # echo \$QUERY
  local SRC_URL=\`wget -q -O- \$QUERY\`
  if ! test x\$SRC_URL = x; then
    echo \$SRC_URL
    if test \$SRC_URL = "N/A"; then
      echo "NOT support this board!"
      exit 1
    fi
    download_ddmusic \$SRC_URL
    if [ -x \$TING ]; then
      \$TING start
    fi
  fi
}

stop(){
  if [ -x \$TING ]; then
    \$TING stop
  fi
}
END
  chmod +x ${SH}
  /etc/init.d/ddmusic enable
  echo "enable ddmusic service"
  echo "please reboot device."
}

install_opkg_ipks
create_ddsuite_conf
add_firmware_rule
install_ddmusic_service


