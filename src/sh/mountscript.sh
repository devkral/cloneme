#! /bin/bash

if [ ! -e "/bin/mount" ] && [ ! -e "/usr/bin/mount" ]; then
  echo "error command: mount not found"
  exit 1
fi

if [ ! -e "/bin/mountpoint" ] && [ ! -e "/usr/bin/mountpoint" ]; then
  echo "error command: mountpoint not found"
  exit 1
fi



#mount_blockdevice <"device"> <"mountpoint">
#mount blockdevices
mount_blockdevice()
{
  local device="$1"
  local mountpath="$2"
#safeguard for not killing innocent mounts
  if [ ! -b "$device" ];then
    echo "mount_blockdevice error: $device is no block device"
    exit 1
  fi

#sorry other mountpoints but we must be sure that this is the only mountpoint
#/proc/mounts of the real running system is used
  local pathtoumount="$(cat /proc/mounts | grep "$device" | sed -e "s/^[^ ]\+ \([^ ]\+\) .*/\1/g")"
  if [ "$pathtoumount" != "" ]; then
    for itemtoumount in $pathtoumount
    do
      echo "mount_blockdevice: umount $itemtoumount"
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
    else
      echo "mount_blockdevice success: unmount ${mountpath}"
    fi
  fi
  
  if ! mount "${device}" "${mountpath}"; then
    # error message by mount itself
    echo "mount_blockdevice hint: have you restarted the kernel after last update?"
    exit 1
  fi
  return 0
}

#mount
##don't run this when a subprocess of itself
echo "$1"
if [ "$choosemode" != "---special-mode---" ] && [ "$choosemode" != "---special-mode-graphic---" ]; then
  if [ -d "${clonesource}" ];then
    clonesourcedir="${clonesource}"
  elif [ -b "${clonesource}" ];then
    mkdir -p "${syncdir}/src" 2> /dev/null
    mount_blockdevice "${clonesource}" "${syncdir}/src"
    clonesourcedir="${syncdir}/src"
  elif [ -f "${clonesource}" ];then
    mkdir -p "${syncdir}"/src 2> /dev/null
    if ! losetup -a | grep "${clonesource}" > /dev/null;then
      if ! losetup -f -P "${clonesource}";then
        echo "Hint: have you restarted the kernel after last update?"
        exit 1
      fi
    else
      echo "raw file already loop mounted but this is no issue"
    fi
    clonesourceloop="$(losetup -a | grep "${clonesource}" | sed -e "s/:.*//" -e 's/^ \+//' -e 's/ \+$//')"
    echo "Please enter the partition number (beginning with p)"
    read parts
    mount_blockdevice "${clonesourceloop}$parts" "${syncdir}/src"
    clonesourcedir="${syncdir}/src"
  else
    echo "source not recognized"
    exit 1
  fi

  if [ -d "${clonetargetdevice}" ];then
    clonetargetdir="${clonetargetdevice}"
  elif [ -b "${clonetargetdevice}" ];then
    mkdir -p "${syncdir}/dest" 2> /dev/null
    mount_blockdevice "${clonetargetdevice}" "${syncdir}/dest"
    clonetargetdir="${syncdir}/dest"
  elif [ -f "${clonetargetdevice}" ];then
    mkdir -p "${syncdir}/dest" 2> /dev/null
    if ! losetup -a | grep "${clonetargetdevice}" > /dev/null;then
      if ! losetup -f -P "${clonetargetdevice}";then 
        echo "Hint: have you restarted the kernel after last update?"
        exit 1
      fi
    fi
    clonetargetloop="$(losetup -a | grep "${clonetargetdevice}" | sed -e "s/:.*//")"
    echo "Please enter the partition number (beginning with p)"
    read partd
    mount_blockdevice "${clonetargetloop}$partd" "${syncdir}/dest"
    clonetargetdir="${syncdir}/dest"
  else
    echo "target not recognized"
    exit 1
  fi
#check clonesourcedir; it has to end with /"
  tempp="$(echo "$clonesourcedir" | sed "s/\/$//")"
  clonesourcedir="$tempp/"
else
  clonetargetdir="$2"
fi

