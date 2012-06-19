#! /bin/bash

device="$1"
mountpoint="$2"
if [ ! -d ${device} ];then
  if mountpoint "${device}" &> /dev/null; then
    echo "Debug: ${device} is already mounted."
  else
    if ! mount "${clonetargetdevice}" "${mountpoint}"; then
      # error message by mount itself
      echo "Hint: have you restarted the kernel after last update?"
      exit 1
    fi
  fi
fi




if [ -d "${syncdir}"/src ]; then
  if [ "$(grub-probe -t device -d ${clonesource})" != "$(grub-probe -t device "${syncdir}")" ] && [ "$(grub-probe -t fs_uuid -d ${clonetargetdevice})" != "$(grub-probe -t fs_uuid "${syncdir}")" ]; then
  echo "error: mounted device is not target device"
  exit 1;
fi

exit 0
