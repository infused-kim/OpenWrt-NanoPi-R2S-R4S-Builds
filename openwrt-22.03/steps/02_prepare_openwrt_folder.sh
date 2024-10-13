#!/bin/bash

TARGET=rockchip
VERSION=22.03.2

ROOTDIR=$(pwd)
echo $ROOTDIR
if [ ! -e "$ROOTDIR/build" ]; then
    echo "Please run from root / no build dir"
    exit 1
fi

cd "$ROOTDIR/build"

# Backup previous openwrt build folders
if [ -d "openwrt" ]; then
  i=1
  while true; do
    if [ ! -d "openwrt-prev-$i" ]; then
      mv openwrt openwrt-prev-$i
      break
    fi
    i=$((i+1))
  done
fi

# Create fresh build dir
cp -R openwrt-fresh-22.03 openwrt
cd openwrt

echo "Preparing build directory for OpenWRT v${VERSION} with target ${TARGET}..."
git checkout v${VERSION}
git checkout -b build-v${VERSION}

echo "Current OpenWRT commit"
git log -1
git describe

# Download build config of official build
echo "Getting official build config..."
wget "https://downloads.openwrt.org/releases/${VERSION}/targets/${TARGET}/armv8/config.buildinfo" -O config-official.buildinfo

# Generate full build config of official build
cp config-official.buildinfo .config
make defconfig
mv .config config-official-full.buildinfo

# Install feeds
echo "Updating and installing feeds..."
wget https://downloads.openwrt.org/releases/22.03.2/targets/rockchip/armv8/feeds.buildinfo -O feeds-official.buildinfo
cp feeds-official.buildinfo feeds.conf

echo "Updating Feeds..."
./scripts/feeds update -a && ./scripts/feeds install -a

