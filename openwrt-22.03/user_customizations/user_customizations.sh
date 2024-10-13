#!/bin/bash

# This script is executed from `04-parepare_package.sh`. It  allows you to make additional customizations that are more complicated than just deleting or replacing files.
#
# When this script is executed, the working directory is the openwrt code directory

# clone stangri repo
rm -rf ../stangri_repo
git clone https://github.com/stangri/source.openwrt.melmac.net ../stangri_repo

# replace vpn routing packages
rm -rf feeds/packages/net/vpn-policy-routing/
cp -R ../stangri_repo/vpn-policy-routing feeds/packages/net/
rm -rf feeds/luci/applications/luci-app-vpn-policy-routing
cp -R ../stangri_repo/luci-app-vpn-policy-routing feeds/luci/applications/

# add pbr
cp -R ../stangri_repo/pbr feeds/packages/net/
cp -R ../stangri_repo/luci-app-pbr feeds/luci/applications/
