#! /bin/sh

#usage: umountscript.sh <syncdir>

syncdir="$(realpath "$1")"
staticmounts="$(cat /proc/mounts)"

if [ -d "${syncdir}/src" ]; then
  umount "${syncdir}/src"
  srcmountpoint="$(echo "$staticmounts" | grep "${syncdir}/src" | sed "s/^\([^ ]\+\) .*/\1/")"
  if losetup -a | grep "$(echo "$srcmountpoint" | sed "s/p[0-9]\+$//")"  > /dev/null;then
    losetup -d "$(echo "$srcmountpoint" | sed "s/p[0-9]\+$//")";
  fi
  
fi

if [ -d "${syncdir}/dest" ]; then
  umount "${syncdir}/dest"
  destmountpoint="$(echo "$staticmounts" | grep "${syncdir}/dest" | sed "s/^\([^ ]\+\) .*/\1/")"
  if losetup -a | grep "$(echo "$destmountpoint" | sed "s/p[0-9]\+$//")"  > /dev/null;then
    losetup -d "$(echo "$destmountpoint" | sed "s/p[0-9]\+$//")";
  fi
fi


#delete if exist
if [ -d "${syncdir}" ]; then 
  rmdir "${syncdir}"
fi

