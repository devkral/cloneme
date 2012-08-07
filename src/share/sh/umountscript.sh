#! /bin/sh

#usage: umountscript.sh <mode> <mountpoint> 
#modes:
#rm: remove mountdir after unmount
#n: just unmount
#uad: unmount underlying blockdevice from other mountpoints (can also be just the device)

#intern dependencies: -

mode="$1"
mountpointt="$(realpath "$2")"
#important for security
if [ ! -e "$mountpointt" ] && [[ $(echo "$mountpointt" | wc -l) = 1 ]]; then
  echo "error: $mountpointt doesn\'t exist"
  exit 1
fi
staticmounts="$(cat /proc/mounts)"

if [ -b "$mountpointt" ];then
  blockdevice="$mountpointt"
else
  blockdevice="$(grep "$mountpointt " /proc/mounts | grep "^/" | sed -e "s/^\([^ ]\+\) [^ ]\+ .*/\1/g")"
  if [ "$blockdevice" = "" ]; then
    echo "$mountpointt is no mountpoint"
    exit 1
  fi
fi



#un_mount because umount is reserved
#usage: un_mount <mountpoint>
un_mount()
{
umountpoint="${1}"
if [ -d "${umountpoint}" ]; then
  if ! umount "${umountpoint}"; then
    echo "cannot unmount the mount directory"
    echo "an other service depending on this directory is still running"
    echo "abort!"
    exit 1
  fi
  
  mountpointold="$(echo "$staticmounts" | grep "${umountpoint}" | sed "s/^\([^ ]\+\) .*/\1/")"
  if losetup -a | grep "$(echo "${mountpointold} " | sed "s/p[0-9]\+$//")"  > /dev/null;then
    losetup -d "$(echo "$mountpointold" | sed "s/p[0-9]\+$//")";
  fi
fi
}

umount_all()
{
  local pathtoumount="$(grep "$blockdevice" /proc/mounts | sed -e "s/^[^ ]\+ \([^ ]\+\) .*/\1/g")"
  if [ "$pathtoumount" != "" ]; then
    for itemtoumount in $pathtoumount
    do
      #echo "mount_blockdevice: un_mount $itemtoumount"
      un_mount "$(echo "$itemtoumount" | sed -e 's/\\040/\ /g')"
    done
  fi
}


case "$mode" in
  "n")un_mount "$mountpointt";;
  "rm")un_mount "$mountpointt";rmdir "$mountpointt";;
  "uad")umount_all;;
  *)echo "usage: umountscript.sh <mode> <mountpoint>";;
esac

exit 0
