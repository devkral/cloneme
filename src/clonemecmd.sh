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
  echo "usage: clonemecmd.sh <args…>"
  echo "opt arg"
  echo "  --src <where is copied from> (default: /) !!!"
  echo "needed args:"
  echo "  --dest <where is copied to> can be blockdevice, raw file (virt) or directory"
  echo "  --mode <mode which should be used> see mode section"
  echo ""
  echo "mode:"
  echo "  update: just sync and ask for each user which files should be copied"
  echo "  install: like update+fstab update and other things; see install section"
  echo "  cleandest: place --dest points to will be cleaned via rm -r *"
  echo ""
  echo "install:"
  echo "  --bootloader <target>: optional (default: grub2):"
  echo "      specify prog to install bootloader"
  # be careful: default bootloader needs installinstaller
  echo ""
  echo "  --editfstab <editor>: optional (default: skip):"
  echo "      edit fstab with editor"
  echo ""
  echo "general options:"
  echo "  --copyuser <target>: optional (default: copyuser.sh):"
  echo "    - specify program to copy users"
  echo "    - syntax of target program:"
  echo "        <target> --src <src> --dest <dest> --user <name>"
  echo ""
  echo "  --installinstaller <target> optional (default: install-installer):"
  echo "      use target prog to install installer"
  echo ""
  echo "The syntax is nearly the same as the one of rsyncci.sh. The reason:"
  echo "Most args are transmitted to rsyncci.sh but clonemecmd.sh adds useful things like mount of blockdevices/raw files and sane defaults"

  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
  usage
fi

#use readlink -f if realpath isn't available
if [ ! -e "/usr/bin/realpath" ];then
  realpath()
  {
    echo "$(readlink -f "$1")"
    exit 0;
  }
fi	

#create absolut path name for this program
myself="$(realpath "$0")"
#scriptdirectory (changed by installer)
sharedir="./src/share" #--replacepattern--


#defaults
#the command which configures the target system
config_new_sys="$sharedir/sh/addnewusers.sh"
#the command to install the bootloader
bootloadertarget="$sharedir/sh/grub-installer_phase_1.sh $syncdir/dest $config_new_sys"
#folder which is copied by default
clonesource="/"
#dir where sync folder are located
syncdir="/run/syncdir"
#command to copy users
copyusertarget="${sharedir}"/sh/copyuser.sh
#command to install the installer
installinstallertarget="--installinstaller $sharedir/sh/install-installer.sh $0 $(dirname "$sharedir")/applications/ ${clonedestdir}"
#don't comment or change this
clonetarget=""
mode=""
editfstabtarget=""
# temps
installinstallertarget2=""
bootloadertarget2=""
editfstabtarget2=""

# for updater (ne=nonempty means: nonempty if as arg specified)
bootloadertargetne=""
installinstallertargetne=""

while [ $# -gt 0 ]
do
  case "$1" in
    "--mode")mode="$2";shift;;
    "--src")clonesource="$(realpath "$2")"; shift;;
    "--dest")clonetarget="$(realpath "$2")"; shift;;
    "--copyuser")copyusertarget="$2"; shift;;
    "--editfstab")editfstabtarget2="$2"; shift;;
    "--installinstaller")installinstallertarget2="$2"; shift;;
    "--bootloader")bootloadertarget2="$2"; shift;;
  esac
  shift
done

if [ installinstallertarget2 != "" ]; then
  installinstallertarget="--installinstaller $installinstallertarget2"
  installinstallertargetne="--installinstaller $installinstallertarget2"
else
  installinstallertarget="--installinstaller $installinstallertarget"
fi 

if [ bootloadertarget2 != "" ]; then
  bootloadertarget="--bootloader $bootloadertarget2"
  bootloadertargetne="--bootloader $bootloadertarget2"
else
  bootloadertarget="--bootloader $bootloadertarget"
fi

if [ editfstabtarget2 != "" ]; then
  editfstabtarget="--editfstab $editfstabtarget2"
fi 

if [ "$clonetarget" = "" ] || [ ! -e "$clonetarget" ]; then
  echo "Error: no destination system specified";
  shall_exit=true;
fi

if [ "$mode" = "" ]; then
  echo "Error: no mode is specified";
  shall_exit=true;
fi

if [ "$UID" != "0" ] || [ "$EUID" != "0" ]; then
  echo "must run with root rights"
  exit 1
fi




# exit if a needed arg wasn't specified elsewise echo selected options
if [ $shall_exit = true ]; then
  exit 1
else
  echo "choosed options:"
  echo "$mode"
  echo "$srcsys"
  echo "$destsys"
  echo ""
  echo "$copyusertarget"
  echo "$editfstabtarget"
  echo "$installinstallertarget"
  echo "$bootloadertarget"
fi

# pidlocking
pidcreate()
{
#just one instance can run simultanous
if [ ! -e "$syncdir/cloneme.pid" ]; then
  echo "$$" > "$syncdir/cloneme.pid"
else
  if [ -d "/proc/$(cat "$syncdir/cloneme.pid")" ]; then
    echo "an other instance is running, abort!"
    exit 1;
  else
    echo "$$" > "$syncdir/cloneme.pid"
  fi
fi
}

pidremove()
{
if [ ! -e "$syncdir/cloneme.pid" ]; then
  echo "error: missing pidfile"
elif [ ! -f "$syncdir/cloneme.pid" ]; then
  echo -e "error: \"$syncdir/cloneme.pid\" is not a file\n"
else
  if [ "/proc/$(cat "$syncdir/cloneme.pid")" != "$$" ]; then
    echo "an other instance is running, abort!"
    exit 1;
  else
    rm "$syncdir/cloneme.pid"
  fi
fi
}

### basic checks:

pidcreate

#check if runs with root permission
if [ ! "$UID" = "0" ] && [ ! "$EUID" = "0" ]; then
  echo "error: needs root permissions"
  exit 1;
fi

#check syncdir; it mustn't end with /"
tempp="$(realpath "$syncdir")"

if [ "$("$sharedir"/sh/report-missing-packages.sh)" = "" ]; then
  exit 1
fi

"$sharedir"/sh/prepsyncscript.sh "${syncdir}"
if ! "$sharedir"/sh/mountscript.sh mount "$clonesource" "$syncdir"/src; then
  exit 1
fi
 
if ! "$sharedir"/sh/mountscript.sh mount "$clonetarget" "$syncdir"/dest; then
  exit 1
fi

installer(){
  if ! "$sharedir"/sh/rsyncci.sh \
--mode install \
--src "$syncdir"/src \
--dest "$syncdir"/dest \
"$editfstabtarget" \
"$bootloadertarget" \
"$installinstallertarget";then
    exit 1;
  fi 
}

updater(){
   if ! "$sharedir"/sh/rsyncci.sh \
--mode update \
--src "${clonesourcedir}" \
--dest "${clonedestdir}" \
"$editfstabtarget" \
"$bootloadertargetne" \
"$installinstallertargetne";then
    exit 1;
  fi 
}


case "$mode" in
  "update")updater;;
  "install")installer;;
  "cleandest")rm -r "$syncdir"/dest/*;;
  *)usage;exit 1;;
esac


"$sharedir"/sh/umountsyncscript.sh "$syncdir"
pidremove

trap "$sharedir/sh/umountsyncscript.sh \"$syncdir\";pidremove" SIGINT

exit 0;
