# 
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ddsuite
PKG_RELEASE:=1
PKG_VERSION:=1.0.1

include $(INCLUDE_DIR)/package.mk

define Package/ddsuite
  CATEGORY:=Base system
  TITLE:=ddsuite for basic functional
endef

define Package/ddsuite/description
  custom suite for openwrt
endef

define Build/Compile/Default

endef
Build/Compile = $(Build/Compile/Default)

define Package/ddsuite/install
	$(INSTALL_DIR) $(1)/bin/
	$(INSTALL_BIN) ./files/ddsuite $(1)/bin/ddsuite
	$(INSTALL_DIR) $(1)/etc/ddsuite/
	$(INSTALL_CONF) ./files/conf.tmpl $(1)/etc/ddsuite/conf.tmpl
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ddsuite.init $(1)/etc/init.d/ddsuite
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/ddsuite.config $(1)/etc/config/ddsuite
	$(CP) -r ./files/www $(1)/
endef

define Package/ddsuite/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
  /etc/init.d/ddsuite enable
fi
exit 0
endef

define Package/ddsuite/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
  /etc/init.d/ddsuite disable
fi
exit 0
endef

$(eval $(call BuildPackage,ddsuite))
