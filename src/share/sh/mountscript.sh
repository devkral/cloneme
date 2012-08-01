#! /bin/sh

#usage: mountscript <mode> <device> [partition] <mountpoint> 
#modes:
#needpart
#mount
#debug



case "$#" in
4)
  mode="$1"
  thingtomount="$(realpath "$2")"
  partition="$3"
  mountpath="$(realpath "$4")"
  ;;
3)
  mode="$1"
  thingtomount="$(realpath "$2")"
  mountpath="$(realpath "$3")"
  ;;
2)
  mode="$1"
  thingtomount="$(realpath "$2")"
  mountpath="" #for needpart only!!!!
  ;;
esac


#new:  "$mountpath" <dest>
mount_blockdevice()
{
  local device="$1"
#safeguard for not killing innocent mounts
  if [ ! -b "$device" ];then
    echo "mount_blockdevice error: $device is no block device" 1>&2 
    exit 1
  fi

#sorry other mountpoints but we must be sure that this is the only mountpoint
#/proc/mounts of the real running system is used
  local pathtoumount="$(cat /proc/mounts | grep "$device" | sed -e "s/^[^ ]\+ \([^ ]\+\) .*/\1/g")"
  if [ "$pathtoumount" != "" ]; then
    for itemtoumount in $pathtoumount
    do
      #echo "mount_blockdevice: umount $itemtoumount"
      umount "$(echo "$itemtoumount" | sed -e 's/\\040/\ /g')"
    done
  fi

  if mountpoint "${mountpath}" &> /dev/null; then
#sorry predecessor but we must be sure that is mounted as ROOT
    if ! umount "${mountpath}"; then
      echo "mount_blockdevice error: cannot unmount the mount directory"
      echo "an other service depending on this directory is still running"
      echo "abort!"
      exit 1
    fi
  fi
  
  if ! mount "${device}" "${mountpath}"; then
    # error message by mount itself
    echo "mount_blockdevice hint: have you restarted the kernel after last update?"
    exit 1
  fi
}

if [ "$mode" = "needpart" ]; then
  if [ -f "${thingtomount}" ]; then
    exit 0
  else
    exit 1
  fi
fi

if [ "$mode" = "mount" ]; then
  if [ -d "${thingtomount}" ];then
    mountdir="${thingtomount}"
  elif [ -b "${thingtomount}" ];then
    mkdir -p "${mountpath}" 2> /dev/null
    mount_blockdevice "${thingtomount}"
    mountdir="${mountpath}"
  elif [ -f "${thingtomount}" ];then
    mkdir -p "${mountpath}" 2> /dev/null
    if ! losetup -a | grep "${thingtomount}" > /dev/null;then
      if ! losetup -f -P "${thingtomount}";then
        echo "Hint: have you restarted the kernel after last update?"
        exit 1
      fi
    #else
    #  echo "raw file already loop mounted but this is no issue" 1>&2 
    fi
    loopmount="$(losetup -a | grep "${thingtomount}" | sed -e "s/:.*//" -e 's/^ \+//' -e 's/ \+$//')"

    mount_blockdevice "${loopmount}${partition}"
    mountdir="${mountpath}"
  else
    echo "source not recognized"
    exit 1
  fi
  echo "$mountdir"
  exit 0
fi

