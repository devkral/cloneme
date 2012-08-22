#! /usr/bin/env bash


#
# Created by alex devkral@web.de
#
# Copyright (c) 2012
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# Neither the name of the project's author nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

usage()
{
  echo "usage: umountscript.sh <mode> <mountpoint/mounteddevice>"
  echo "modes:"
  echo "rm: remove mountdir after unmount"
  echo "n/normal/umount: just umount; if mounteddevice is loop or blockdevice umount all depending mounts (and detach loop)"
  echo "related: unmount underlying blockdevice/loop/mountpoint from other mountpoints"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
  usage
fi
#intern dependencies: -

#use readlink -f if realpath isn't available
if [ ! -e "/usr/bin/realpath" ];then
  realpath()
  {
    echo "$(readlink -f "$1")"
    exit 0;
  }
fi

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
        echo "umountscript: cannot unmount mountpoint"
        echo "could mean that an other service depending on this directory is still running"
        echo "abort!"
        exit 1
      fi
  
      mountpointold="$(echo "$staticmounts" | grep "${umountpoint}" | sed -e "s/^\([^ ]\+\) .*/\1/" -e "s/p[0-9]\+$//")"
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
    #same behaviour
    local umountdevice="$mountpointt"
  elif [ -f "$mountpointt" ];then
    #same behaviour
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
  "normal")un_mount "$mountpointt";;
  "umount")un_mount "$mountpointt";;
  "rm")un_mount "$mountpointt"; rmdir "$mountpointt";;
  "related")umount_all;;
  *)usage  ;;
esac

exit 0
