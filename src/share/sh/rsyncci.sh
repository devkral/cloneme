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
  echo "usage: rsyncci.sh <args…>"
  echo "needed args:"
  echo "  --src <system copied from>"
  echo "  --dest <folder copied to>"
  echo "  --mode <mode which should be used> see mode section"
  echo "  --copyuser <target>:"
  echo "    - specify program to copy users"
  echo "    - syntax of target program:"
  echo "        <target> --src <src> --dest <dest> --user <name>"
  echo ""
  echo "mode:"
  echo "  update: just sync and ask for each user which files should be copied"
  echo "  install: like update+fstab update and other things; see install section"
  echo "  test: echo parameters and exit"
  echo ""
  echo "install:"
  echo "  --bootloader <target>: optional (default: none):"
  echo "      specify prog to install bootloader"
  # be careful: default bootloader needs installinstaller
  echo ""
  echo "  --editfstab <editor>: optional (default: skip):"
  echo "      edit fstab with editor"
  echo "  --adduser <target>: optional (default: skip:"
  echo "    - specify program to add new users"
  echo "    - syntax of target program:"
  echo "        <target> --dest <dest>"
  echo "general options:"
  echo "  --installinstaller <target> optional (default: skip):"
  echo "      use target prog to install installer"

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



#dir where the cloneme files are located
sharedir="$(dirname "$(dirname "$(realpath "$0")")")"
#"$sharedir"/sh/install-installer.sh "$(dirname "$0")" "$(dirname "$sharedir")"/applications/cloneme.desktop "${clonedestdir}"

shall_exit=false
installinstallertarget=""
addusertarget=""
editfstab=""
installinstaller=""
bootloadertarget=""

while [ $# -gt 0 ]
do
  case "$1" in
    "--mode")mode="$2";shift;;
    "--src")srcsys="$(realpath "$2")"; shift;;
    "--dest")destsys="$(realpath "$2")"; shift;;
    "--copyuser")copyusertarget="$2"; shift;;
    "--adduser")addusertarget="$2"; shift;;
    "--editfstab")editfstabtarget="$2"; shift;;
    "--installinstaller")installinstallertarget="$2"; shift;;
    "--bootloader")bootloadertarget="$2"; shift;;
  esac
  shift
done

if [ -n $srcsys ] || [ ! -e "$srcsys" ]; then
  echo "Error: no source system specified";
  shall_exit=true;
fi

if [ -n $destsys ] || [ ! -e "$destsys" ]; then
  echo "Error: no destination system specified";
  shall_exit=true;
fi

if [ -n $mode ]; then
  echo "Error: no mode is specified";
  shall_exit=true;
fi

if [ -n $copyusertarget ]; then
  echo "Error: command for copying userfiles specified";
  shall_exit=true;
fi

# exit if a needed arg wasn't specified elsewise echo choosen options
if [ $shall_exit = true ]; then
  exit 1
else
  echo "selected options:"
  echo "$mode"
  echo "$srcsys"
  echo "$destsys"
  echo ""
  echo "$copyusertarget"
  echo "$addusertarget"
  echo "$editfstabtarget"
  echo "$installinstallertarget"
  echo "$bootloadertarget"
  if [ "$mode" = "test" ]; then
    exit 0;
  fi
fi

#won't be sync anymore
#for check_if_mounted in tmp run proc sys dev
#do
#  if mountpoint -q "$destsys"/"$check_if_mounted"; then
#    echo "$check_if_mounted is mounted! abort!"
#    exit 1;
#  fi
#done

copyuser()
{
  local usertemp
  for usertemp in $(ls "${srcsys}"/home)
  do
    eval "$copyusertarget --src ${srcsys} --dest ${destsys} --user ${usertemp}"
  done
  if [ "$addusertarget" != "" ]; then
    eval "$addusertarget --dest ${destsys}"
  fi
  
}
 
updater()
{
  if ! rsync -a -A --progress --delete --exclude "/etc/fstab" --exclude "/run/*" --exclude "/var/spool/mail/*" --exclude "/etc/passwd" --exclude "/etc/passwd?"  --exclude "/etc/group" --exclude "/etc/group?" --exclude "/etc/shadow" --exclude "/etc/shadow?" --exclude "/etc/gshadow" --exclude "/etc/gshadow?" --exclude "/boot/grub/grub.cfg" --exclude "/boot/grub/device.map" --exclude "${dest}" --exclude "/home/*" --exclude "/sys/*" --exclude "/dev/*" --exclude "/proc/*" --exclude "/var/log/*" --exclude "/tmp/*" --exclude "/run/*" --exclude "/var/run/*" --exclude "/var/tmp/*" "${srcsys}"/* "${destsys}" ; then
    echo "error: rsync could not sync"
    exit 1
  fi
  "$sharedir"/sh/update-users.sh "${srcsys}" "${destsys}"
  copyuser
  if [ "$installinstallertarget" != "" ]; then
    eval "$installinstallertarget"
  fi
}

installer()
{
  if ! rsync -a -A --progress --delete --exclude "/run/*" --exclude "/var/spool/mail/*" --exclude "/etc/passwd" --exclude "/etc/passwd?"  --exclude "/etc/group" --exclude "/etc/group?" --exclude "/etc/shadow" --exclude "/etc/shadow?" --exclude "/etc/gshadow" --exclude "/etc/gshadow?" --exclude "/boot/grub/grub.cfg" --exclude "/boot/grub/device.map" --exclude "${dest}" --exclude "/home/*" --exclude "/sys/*" --exclude "/dev/*" --exclude "/proc/*" --exclude "/var/log/*" --exclude "/tmp/*" --exclude "/run/*" --exclude "/var/run/*" --exclude "/var/tmp/*" "${srcsys}"/* "${destsys}" ;then
    echo "error: rsync could not sync"
    exit 1
  fi
  "$sharedir"/sh/update-users.sh "${srcsys}" "${destsys}"
  
  if [ -f "${destsys}"/etc/fstab ];then
    local tempprobefstab="$("$sharedir"/sh/devicefinder.sh uuid "${destsys}")"
    local tempsed="$(sed -e "s/.\+\( \/ .\+\)/UUID=${tempprobe}\1/" "${destsys}"/etc/fstab)"
    echo "$tempsed" > "${destsys}"/etc/fstab
    echo "root in fstab updated"
    if [ -n "$editfstabtarget" ]; then
      echo "Open fstab with $editfstabtarget"
      eval "$editfstabtarget" "${destsys}"/etc/fstab
    fi
  else
    echo "no fstab found"
    exit 1
  fi
  
  copyuser
  if [ "$installinstallertarget" != "" ]; then
    eval "$installinstallertarget"
  fi
#optional add bootflag to partition target dir is on (thinkpad boot) This should be done in the bootloader script.
  if [ "$bootloadertarget" != "" ]; then
    eval "$bootloadertarget"
  fi
}

if [ "$mode" = "install" ];then
  installer
fi

if [ "$mode" = "update" ];then
  updater
fi

#exit 0
