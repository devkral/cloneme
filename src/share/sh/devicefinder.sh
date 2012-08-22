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

options=""

usage()
{
  echo "usage: devicefinder [option] <directory>"
  echo "options:"
  echo "dev: print only block devices  (not e.g tmpfs) (checked by /dev)"
  echo "uuid: print the uuid of the device"
  echo "mount: print mountpoint"
  echo "all: print <device> <mountpoint> <uuid>"
  #echo "options separated by ,"
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

case "$#" in
 1) dirtemp="$(realpath "${1}")";;
 2) options="$1"; dirtemp="$(realpath "${2}")" ;;
esac

case "$options" in
 "uuid") staticmounts="$(cat /proc/mounts | grep "^/dev")";;
 "dev") staticmounts="$(cat /proc/mounts | grep "^/dev")";;
 "mount") staticmounts="$(cat /proc/mounts | grep "^/dev")";;
 "all") staticmounts="$(cat /proc/mounts | grep "^/dev")";;
 *) staticmounts="$(cat /proc/mounts)" ;;
esac


lastresult=""

if [ ! -e "$dirtemp" ]; then
  echo "$dirtemp doesn’t exist"
  exit 2
fi



for (( ; ; ))
do
#check if the dirtemp version is in /proc/mounts
  if dirtemp2="$(echo "$staticmounts" | grep "^[^ ]\+ $dirtemp ")"; then
    cleaned="$(echo "$dirtemp2" | sed "s/^\([^ ]\+\) .*/\1/")"
    UUID="$(lsblk --output UUID -n "$cleaned")"
    if [ "$options" = "uuid" ];then
      echo "$UUID"
      if [ "x$UUID" = "x" ];then
        exit 3
      fi
    elif [ "$options" = "mount" ]; then
      echo "$dirtemp"
      
    elif [ "$options" = "all" ]; then
      echo "$cleaned $dirtemp $UUID"
    else
      echo "$cleaned"
    fi
    
    exit 0
    break
  fi
  

  dirtemp="$(dirname "$dirtemp")"
#break endless loop
  if [ "$lastresult" = "$dirtemp" ];then
    echo "error: hangs at $dirtemp"
    exit 1
    break
  fi
  lastresult="$dirtemp"
done

