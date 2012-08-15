#! /usr/bin/env bash

#usage: rsyncci.sh <mode> <src> <dest>
#intern dependencies: -

if [ ! -e /usr/bin/realpath ]; then
  realpath="readlink -f"
fi

mode="$1"
src="$(realpath "$2")"
dest="$(realpath "$3")"

#src end slash less
srcsl="$(echo "$src" | sed "s|/$||")"

if [ "$mode" = "install" ];then
  
  if ! rsync -a -A --progress --delete --exclude "${srcsl}/run/*" --exclude "${srcsl}/"boot/grub/grub.cfg --exclude "${srcsl}/"boot/grub/device.map --exclude "${dest}" --exclude "${srcsl}/home/*" --exclude "${srcsl}/sys/*" --exclude "${srcsl}/dev/*" --exclude "${srcsl}/proc/*" --exclude "${srcsl}/var/log/*" --exclude "${srcsl}/tmp/*" --exclude "${srcsl}/run/*" --exclude "${srcsl}/var/run/*" --exclude "${srcsl}/var/tmp/*" "${srcsl}"/* "${dest}" ;then
    echo "error: rsync could not sync"
    exit 1
  fi
  
fi

if [ "$mode" = "update" ];then
  if ! rsync -a -A --progress --delete --exclude "${srcsl}/run/*" --exclude "${srcsl}/"boot/grub/grub.cfg --exclude "${srcsl}"/boot/grub/device.map --exclude "${srcsl}"/etc/fstab --exclude "${dest}" --exclude "${srcsl}/home/*" --exclude "${srcsl}/sys/*" --exclude "${srcsl}/dev/*" --exclude "${srcsl}/proc/*" --exclude "${srcsl}/var/log/*" --exclude "${srcsl}/tmp/*" --exclude "${srcsl}/run/*" --exclude "${srcsl}/var/run/*" --exclude "${srcsl}/var/tmp/*" "${srcsl}"/* "${dest}" ; then
    echo "error: rsync could not sync"
    exit 1
  fi

fi

exit 0
