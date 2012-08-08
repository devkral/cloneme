#! /bin/bash

intern_help()
{
  echo "usage: umountscript.sh <mode> <mountpoint/mounteddevice>"
  echo "modes:"
  echo "rm: remove mountdir after unmount"
  echo "n: just umount; if loop or blockdevice umount all depending mounts (and detach loop)"
  echo "uma: unmount underlying blockdevice/loop/mountpoint from other mountpoints"
}

#intern dependencies: -



mode="$1"
mountpointt="$(realpath "$2")"
#important for security
if [ ! -e "$mountpointt" ] && [[ $(echo "$mountpointt" | wc -l) = 1 ]]; then
  echo "umountscript: error: $mountpointt doesn't exist"
  exit 1
fi
staticmounts="$(cat /proc/mounts)"




#un_mount because umount is reserved
#usage: un_mount <mountpoint>
un_mount()
{
  umountpoint="${1}"
  if [ -d "${umountpoint}" ]; then
    if mountpoint "${umountpoint}" > /dev/null; then
      if ! umount "${umountpoint}"; then
        echo "umountscript: cannot unmount the mount directory"
        echo "could mean that an other service depending on this directory is still running"
        echo "abort!"
        exit 1
      fi
  
      mountpointold="$(echo "$staticmounts" | grep "${umountpoint}" | sed "s/^\([^ ]\+\) .*/\1/")"
      if losetup -a | grep "$(echo "${mountpointold}")"  > /dev/null;then
        #echo "$(echo "${mountpointold}" | sed 's/p[0-9]\+$//')"
        losetup -d "$(losetup -a | grep "${mountpointold}" | sed 's/:.\+//')";
      fi
    fi
  elif [ -f "${umountpoint}" ]; then
    local umountloop="$(losetup -a | grep "${umountpoint}" | sed 's/:.\+//')"
    local pathtoumount="$(grep "$umountloop" /proc/mounts | sed -e "s/^[^ ]\+ \([^ ]\+\) .*/\1/g")"
    if [ "$pathtoumount" != "" ]; then
      for itemtoumount in $pathtoumount
      do
        #echo "mount_blockdevice: un_mount $itemtoumount"
        un_mount "$(echo "$itemtoumount" | sed -e 's/\\040/\ /g')"
      done
    fi
    if losetup -a | grep "$(echo "${umountpoint}")"  > /dev/null;then
      #echo "$(echo "${umountpoint}" | sed 's/p[0-9]\+$//')"
      losetup -d "$umountloop";
    fi
  elif [ -b "${umountpoint}" ]; then
    local pathtoumount="$(grep "$umountpoint" /proc/mounts | sed -e "s/^[^ ]\+ \([^ ]\+\) .*/\1/g")"
    if [ "$pathtoumount" != "" ]; then
      for itemtoumount in $pathtoumount
      do
        #echo "mount_blockdevice: un_mount $itemtoumount"
        un_mount "$(echo "$itemtoumount" | sed -e 's/\\040/\ /g')"
      done
    fi
  fi
}

#umount_all <blockdevice>
umount_all()
{
  if [ -b "$mountpointt" ];then
    local umountdevice="$mountpointt"
  elif [ -f "$mountpointt" ];then
    local umountdevice="$mountpointt"
  elif [ -d "$mountpointt" ];then
    local umountdevice="$(grep "$mountpointt " /proc/mounts | grep "^/" | sed -e "s/^\([^ ]\+\) [^ ]\+ .*/\1/g")"
    if [ "$umountdevice" = "" ]; then
      echo "$mountpointt is no mountpoint"
      exit 1
    fi
  fi
  un_mount "$umountdevice"
}



case "$mode" in
  "n")un_mount "$mountpointt";;
  "rm")un_mount "$mountpointt"; rmdir "$mountpointt";;
  "uma")umount_all;;
  *)intern_help  ;;
esac

exit 0
