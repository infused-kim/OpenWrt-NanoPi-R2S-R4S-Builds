
#!/bin/bash

# WARNING:
# The script 03_patch_openwrt deletes the pathes below by executing
# `rm -rf XXX` on each of them.
#
# After that it rsyncs the files in `file_replacements/` into the openwrt code
# directory. New files are added and existing files are overwritten.
#
# The rsync without deletion let's you replace or add files. And by adding a
# path to the `delete_paths` below, you can replace an entire directory tree.
#
# This can be useful to completely replace packages, for example.

CUSTOMIZATIONS_DELETE_PATHES=(
  "feeds/packages/net/acme*"
  "feeds/packages/net/haproxy"
  "feeds/packages/net/adguardhome"
)
