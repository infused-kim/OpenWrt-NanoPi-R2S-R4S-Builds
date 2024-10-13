#!/bin/bash
ROOTDIR=$(pwd)
echo $ROOTDIR
if [ ! -e "$ROOTDIR/build" ]; then
    echo "Please run from root / no build dir"
    exit 1
fi

OPENWRT_BRANCH=22.03
BUILDDIR="$ROOTDIR/build"
PATCHDIR="$ROOTDIR/openwrt-$OPENWRT_BRANCH/patches/"
SNAPSHOTDIR="$BUILDDIR/openwrt-fresh-$OPENWRT_BRANCH/"

cd "$BUILDDIR/openwrt"

# Replace target/linux/rockchip with SNAPSHOT version
echo -e "Replacing target/linux/rockchip with SNAPSHOT version..."
rm -rf target/linux/rockchip
cp -R $SNAPSHOTDIR/target/linux/rockchip target/linux/

# Replace target/linux/generic/config-5.10 with SNAPSHOT version
echo -e "\n\nReplacing target/linux/generic/config-5.10 with SNAPSHOT version..."
cp $SNAPSHOTDIR/target/linux/generic/config-5.10 target/linux/generic/config-5.10

# Update feeds
echo -e "\n\nUpdating feeds..."
./scripts/feeds update -a

# Update feeds
echo -e "\n\nUpdating feeds..."
./scripts/feeds update -a

# Load `DELETE_PATHES` and `CLEAN_TARGETS` config variables
source "$PATCHDIR/patch_settings.sh"

# Delete directories in the openwrt code (to replace them with brand new versions)
echo -e "\n\nDeleting directories..."
for path in "${DELETE_PATHES[@]}"; do
   full_path="$(realpath "./$path")"
   echo -e "\t- $full_path"
   rm -rf "$full_path"
done

# Sync file_replacement directory into openwrt code directory.
#  - New files are added
#  - Existing files are overwritten
#  - Entire directories (such as a package) can be replaced by adding the path
#    to the `DELETE PATHES` variable above
echo -e "\n\nRsyncing file_replacements to $(realpath "./")..."
rsync -avz $PATCHDIR/file_replacements/ .

# enable motorcomm for R2C
echo -e "\n\nEnabling CONFIG_MOTORCOMM_PHY"
echo "CONFIG_MOTORCOMM_PHY=y" >> target/linux/rockchip/armv8/config-5.10

# add caiaq usb sound module for shairport with old soundcard
echo -e "\n\nAdding caiaq usb sound module..."
ADDON_PATH='snd-usb-caiaq.makefileaddon'
ADDON_DEST='package/kernel/linux/modules/usb.mk'
if ! grep -q " --- $ADDON_PATH" $ADDON_DEST; then
   echo "Adding $ADDON_PATH to $ADDON_DEST"
   echo "# --- $ADDON_PATH" >> $ADDON_DEST
   cat $PATCHDIR/addons/$ADDON_PATH >> $ADDON_DEST
else
   echo "Already added $ADDON_PATH to $ADDON_DEST"
fi

#cleanup
if [ -e .config ]; then
   for target in "${CLEAN_TARGETS[@]}"; do
      echo -e "\n\nCleaning up target $target..."
      make $target
   done
fi

# Time stamp with $Build_Date=$(date +%Y.%m.%d)
MANUAL_DATE="$(date +%Y.%m.%d) (manual build)"
BUILD_STRING=${BUILD_STRING:-$MANUAL_DATE}
echo "Write build date in openwrt : $BUILD_DATE"
echo -e '\nAO Build@'${BUILD_STRING}'\n'  >> package/base-files/files/etc/banner
#sed -i '/DISTRIB_REVISION/d' package/base-files/files/etc/openwrt_release
#echo "DISTRIB_REVISION='${BUILD_STRING}'" >> package/base-files/files/etc/openwrt_release
sed -i '/DISTRIB_DESCRIPTION/d' package/base-files/files/etc/openwrt_release
echo "DISTRIB_DESCRIPTION='AO Build@${BUILD_STRING}'" >> package/base-files/files/etc/openwrt_release
sed -i '/luciversion/d' feeds/luci/modules/luci-base/luasrc/version.lua
