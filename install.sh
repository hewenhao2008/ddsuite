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
  printf "Enter DEV_UUID:(tg22321)"
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

create_boot_launch_sh(){
  echo "create boot launch bash"
  local SH="/root/ddsuite"
cat <<END>${SH}
#!/bin/sh
# this is boot run bash for ddsuite
download_and_run(){
  APP=music-box
  URL=\$1
  PWD=`pwd`

  cd /tmp/
  wget "\$URL" -O \${APP}.tar.gz
  tar -zxf \${APP}.tar.gz
  APP_BIN=/tmp/\${APP}/ting
  \$APP_BIN
  rm -f \${APP}.tar.gz
  cd \$PWD
}

action_rsync(){
  BOARD=`cat /proc/cmdline|awk '{print \$1}'`
  if test x\$BOARD = x; then
    BOARD=`dmesg |grep Kernel|awk '{print \$6}'`
  fi
  if test x\$BOARD = x; then
    echo "UNKNOWN BOARD"
    exit 1
  fi
  VERSION="2.0.0"
  QUERY="http://music.fadai8.cn/api/package?\$BOARD&version=\${VERSION}"
  # echo \$QUERY
  SRC_URL=\`wget -q -O- \$QUERY\`
  if ! test x\$SRC_URL = x; then
    echo \$SRC_URL
    if test \$SRC_URL = "N/A"; then
      echo "NOT support this board!"
      exit 1
    fi
    download_and_run \$SRC_URL
  fi
}

case \$1 in
  *)
    action_rsync
    ;;
esac
END
  chmod +x ${SH}
  echo "LAST thing!add '/root/ddsuite' to /etc/rc.local"
}

install_opkg_ipks
create_ddsuite_conf
add_firmware_rule
create_boot_launch_sh