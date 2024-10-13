#!/bin/bash
ROOTDIR=$(pwd)
echo $ROOTDIR
if [ ! -e "$ROOTDIR/build" ]; then
    echo "Please run from root / no build dir"
    exit 1
fi

OPENWRT_BRANCH=22.03
CUSTOMIZATIONS_DIR="$ROOTDIR/openwrt-$OPENWRT_BRANCH/user_customizations/"

cd "$ROOTDIR/build/openwrt"



# Execute user customizations script
CUSTOMIZATIONS_SCRIPT="$CUSTOMIZATIONS_DIR/user_customizations.sh"
echo -e "\n\nRunning user customizations script $CUSTOMIZATIONS_SCRIPT..."

if [ -f "$CUSTOMIZATIONS_SCRIPT" ]; then
  # Source the script
  source "$CUSTOMIZATIONS_SCRIPT"
else
  # Print an error message
  echo "\Error: User customization script does not exist... not executing" >&2
fi

# Load `CUSTOMIZATIONS_DELETE_PATHES`
source "$PATCHDIR/patch_settings.sh"

# Delete directories in the openwrt code (to replace them with brand new versions)
echo -e "\n\nDeleting directories..."
for path in "${CUSTOMIZATIONS_DELETE_PATHES[@]}"; do
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

# Update & install feeds
echo -e "\n\nUpdating and installing feeds..."
./scripts/feeds update -i && ./scripts/feeds install -a


rm -rf .config
