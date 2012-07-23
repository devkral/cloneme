#! /bin/bash

#usage: umountscript.sh <syncdir>

syncdir="$1"
staticmounts="$(cat /proc/mounts)"

if [ -d "${syncdir}/src" ]; then
  umount "${syncdir}/src"
  srcmountpoint="$(echo "$staticmounts" | grep "${syncdir}/src" | sed "")" #implement
  
  
fi

if [ -d "${syncdir}/dest" ]; then
  umount "${syncdir}/dest"
  destmountpoint="$($staticmounts)" #implement
  
fi


#unmount loops
if [ "${clonesourceloop}" != "" ];then
  losetup -d "${clonesourceloop}"
fi

if [ "${clonetargetloop}" != "" ];then
  losetup -d "${clonetargetloop}"
fi

#delete if exist
if [ -d "${syncdir}" ]; then 
  rmdir "${syncdir}"
fi

