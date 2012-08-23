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
  echo "usage: grub-installer_phase_1.sh <targetsystem> [command for sysconfig like adding users] [ args ] (currently just one)"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
  usage
fi

#intern dependencies: grub-installer_phase_2.sh
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
targetdir="$(realpath "$1")"


if [ ! -f "$sharedir/sh/grub-installer_phase_2.sh" ]; then
  echo "In target sys grub-installer_phase_2.sh isn't available"
  echo "run install-installer first"
  echo "Abort!"
  exit 1
fi

if [ -e "${targetdir}"/boot/grub/device.map ];then
  tempdev="$(sed -e "s/\((hd0)\)/# \1/" "${targetdir}"/boot/grub/device.map)"
  echo "$tempdev" > "${targetdir}"/boot/grub/device.map
  sed -i -e "/#--specialclone-me--/d" "${targetdir}"/boot/grub/device.map
fi

echo "some temporary adjustments to ${targetdir}/boot/grub/device.map"
mkdir -p "${targetdir}"/boot/grub/
tempprobegrub="$("$sharedir"/sh/devicefinder.sh dev "${targetdir}" | sed -e "s|[0-9]*$||")"
echo "(hd0) ${tempprobegrub} #--specialclone-me--" >> "${targetdir}"/boot/grub/device.map
echo "finished"



mount -o bind /proc "${targetdir}"/proc
mount -o bind /sys "${targetdir}"/sys
mount -o bind /dev "${targetdir}"/dev

# display can be opened with tmp and run
mount -o bind /tmp "${targetdir}"/tmp
mount -o bind /run "${targetdir}"/run
shift # currently just one arg which must vanish
chroot "${targetdir}" "$sharedir/sh/grub-installer_phase_2.sh" "$@"
echo "back from chroot"
umount "${clonetargetdir}"/{tmp,run,proc,sys,dev}
echo "mounts cleaned up"

tempsed=$(sed -e "/#--specialclone-me--/d" "${targetdir}"/boot/grub/device.map)
echo "$tempsed" > "${targetdir}"/boot/grub/device.map
#sed -i -e "s/# (hd0)/(hd0)/" "${targetdir}"/boot/grub/device.map
echo "device.map cleaned"
