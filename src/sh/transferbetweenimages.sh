#! /bin/bash

#License: Do what you want with this script. But no warranty.
#be careful; this is a very hard topic. I won't use much safeguarding
transferscript="/sbin/cloneme.sh update"
dir_for_sync="/syncdir2"

if [ "$1" = "--help" ] || [ "$1" = "help" ];then
  echo "Usage:"
  echo "$0 [<path to transferscript> args… (src) (dest)]"
  echo "Important: run as root"
  exit 0
else
  transferscript="$*"
fi

#check if runs with root permission
if [ ! "$UID" = "0" ]; then
  echo "error: needs root permissions"
  exit 1;
fi
mkdir -p "$dir_for_sync"
mkdir "$dir_for_sync"/src
mkdir "$dir_for_sync"/dest

echo "enter path to source image or DISK"
read imagesource
if [ -b "$imagesource" ];then
  mounttemps="$imagesource"
else
  losetup -f -P "$imagesource"
  sleep 1;
  temps=$(losetup -a | grep "$imagesource")
  mounttemps=$(echo $temps | sed -e "s/:.*//")
fi

  
if mountpoint "$dir_for_sync"/src &> /dev/null; then
  echo "Abort: $dir_for_sync/src is already mounted"
  exit 1
fi

echo "enter partitionnumber"
read partsource
if [ -b "$imagesource" ];then
  if ! mount ${mounttemps}${partsource} "$dir_for_sync"/src; then
    # error message by mount itself
    echo "Hint: have you restart the kernel after last update?"
    exit 1
  fi
else
  if ! mount ${mounttemps}p${partsource} "$dir_for_sync"/src; then
    # error message by mount itself
    echo "Hint: have you restart the kernel after last update?"
    exit 1
  fi
fi

echo "enter path to target image or DISK!"
read imagedest
if [ -b "$imagedest" ];then
  mounttempd="$imagedest"
else
  losetup -f -P "$imagedest"
  sleep 1;
  tempd=$(losetup -a | grep "$imagedest")
  mounttempd=$(echo $tempd | sed -e "s/:.*//")

fi

if mountpoint "$dir_for_sync"/dest &> /dev/null; then
  echo "Abort: $dir_for_sync/dest is already mounted"
  exit 1
fi

echo "enter partitionnumber"
read partdest
if [ -b "$imagedest" ];then
  if ! mount ${mounttempd}${partsource} "$dir_for_sync"/dest; then
  # error message by mount itself
    echo "Hint: have you restart the kernel after last update?"
    exit 1
  fi
else
  if ! mount ${mounttempd}p${partsource} "$dir_for_sync"/dest; then
  # error message by mount itself
    echo "Hint: have you restart the kernel after last update?"
    exit 1
  fi
fi

$transferscript "$dir_for_sync"/src "$dir_for_sync"/dest


umount "$dir_for_sync"/src
if [ ! -b "$imagesource" ];then
  losetup --detach ${mounttemps}
fi
rmdir "$dir_for_sync"/src

umount "$dir_for_sync"/dest
if [ ! -b "$imagedest" ];then
  losetup --detach ${mounttempd}
fi
rmdir "$dir_for_sync"/dest

rmdir "$dir_for_sync"
