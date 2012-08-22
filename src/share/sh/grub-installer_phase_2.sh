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
  echo "don't use directly!!!"
  echo "usage: grub-installer_phase_2.sh [command for sysconfig like adding users] [ args ]"
  echo ""
  echo "the used grub-probe can lead to a kill of an usb memory stick (some models?)"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] ;then
  usage
fi

#intern dependencies: addnewusers.sh

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
#the command which configures the target system
if [ "$1" = "" ]; then
  config_new_sys="${sharedir}/sh/addnewusers.sh"
else
  config_new_sys="$1"
fi

echo "Install grub…"
  #/ is clonetargetdir
  get_dev="$(grub-probe -t device "/" | sed  -e "s|[0-9]*$||")"
if ! grub-install "${get_dev}";then
  echo "Error: ${get_dev} not found"
  echo "I failed please do it yourself or type \"exit\" and press <enter> to escape"
  /usr/bin/env bash
fi
  
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "\ngrub installation finished.\nStart with the configuration of the new system\n"
eval "$@"
