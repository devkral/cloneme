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
  echo "usage: mountscript <mode> <device> [partition] <mountpoint> "
  echo "device can be a raw file (with use of partition!) or a blockdevice or something mount can mount"
  echo "modes:"
  echo "needpart: return 0 if partition doesn’t need to be specified (needs just device)"
  echo "mount: mount the device and partition"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
  usage
fi
#intern dependencies: umountscript.sh

#use readlink -f if realpath isn't available
if [ ! -e "/usr/bin/realpath" ];then
  realpath()
  {
    echo "$(readlink -f "$1")"
    exit 0;
  }
fi
#dir where the cloneme files are located
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
    echo "true"
    exit 0
  else
    echo "false"
    exit 1
  fi
fi

if [ "$mode" = "mount" ] || [ -e "$mountpath" ]; then

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
    mount -o bind "${thingtomount}" "${mountpath}"
  elif [ -b "${thingtomount}" ];then
    mount_blockdevice "${thingtomount}"
  elif [ -f "${thingtomount}" ];then
    if ! losetup -a | grep "${thingtomount}" > /dev/null;then
      if ! losetup -f -P "${thingtomount}";then
        echo "Hint: have you restarted the kernel after last update?"
        exit 1
      fi
    fi
    loopmount="$(losetup -a | grep "${thingtomount}" | sed -e "s/:.*//" -e 's/^ \+//' -e 's/ \+$//')"
    if [ "${partition}" = "" ]; then
      echo "Please enter the partition number (beginning with p)"
      read partition
    fi
    mount_blockdevice "${loopmount}${partition}"
  else
    echo "source not recognized"
    exit 1
  fi
  exit 0
fi

