#! /bin/bash

clonesource="$1"
syncdir="$2"


  rsync -a -A --progress --delete --exclude "${clonesource}"/boot/grub/grub.cfg --exclude "${clonesource}"/boot/grub/device.map  --exclude "${syncdir}" --exclude "${clonesource}/home/*" --exclude "${clonesource}/sys/*" --exclude "${clonesource}/dev/*" --exclude "${clonesource}/proc/*" --exclude "${clonesource}/var/log/*" --exclude "${clonesource}/tmp/*" --exclude "${clonesource}/run/*" --exclude "${clonesource}/var/run/*" --exclude "${clonesource}/var/tmp/*" "${clonesource}"/* "${syncdir}"
  if [ -e "${syncdir}"/boot/grub/device.map ];then
    sed -i -e "s/\((hd0)\)/# \1/" "${syncdir}"/boot/grub/device.map
  fi
  echo "(hd0) $(grub-probe -t device -d "${clonetargetdevice}" | sed -e "s|[0-9]*$||") #--special-cloneme--" >> "${syncdir}"/boot/grub/device.map
  sed -i -e "s/.\+\( \/ .\+\)/UUID=$(grub-probe -t fs_uuid -d ${clonetargetdevice})\1/" "${syncdir}"/etc/fstab
  echo "root in fstab updated"
