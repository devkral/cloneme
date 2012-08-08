#! /bin/bash

#usage: mountscript <mode> <device> [partition] <mountpoint> 
#device can be a raw file (with use of partition!) or a blockdevice or something mount can mount
#modes:
#needpart: return 0 if partition doesn't need to be specified (needs just device)
#mount: mount the device and partition
#debug: return debug infos (but mounts real)
#quiet: mount; don't ask in case of unclear partition

#intern dependencies: umountscript.sh


sharedir="$(dirname "$(dirname "$(realpath "$0")")")"

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

if [ "$mode" = "mount" ] || [ "$mode" = "debug" ] || [ "$mode" = "quiet" ]; then

  if [ ! -d "${thingtomount}" ];then
    #sorry other mountpoints but we must be sure that this is the only mountpoint;
    #/proc/mounts of the real running system is used
    "$sharedir"/sh/umountscript.sh n "$thingtomount"
  fi
  
  if mountpoint "${mountpath}" &> /dev/null; then
  #sorry predecessor but we must be sure that is mounted as ROOT
    if ! "$sharedir"/sh/umountscript.sh n "${mountpath}"; then
      exit 1
    fi
  fi
  
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
    elif [ "${mode}" = "debug" ];then
      echo "raw file already loop mounted but this is no issue" 1>&2 
    fi
    loopmount="$(losetup -a | grep "${thingtomount}" | sed -e "s/:.*//" -e 's/^ \+//' -e 's/ \+$//')"
    if [ "${partition}" = "" ] && [ "$mode" != "quiet" ]; then
      echo "Please enter the partition number (beginning with p)"
      read partition
    fi
    mount_blockdevice "${loopmount}${partition}"
    mountdir="${mountpath}"
  else
    echo "source not recognized"
    exit 1
  fi
  echo "$mountdir"
  exit 0
fi

