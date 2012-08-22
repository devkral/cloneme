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



#create absolut path name for this program
myself="$(realpath "$0")"
#scriptdirectory (changed by installer)
sharedir="./src/share" #--replacepattern--


#defaults
#the command which configures the target system
config_new_sys="$sharedir/sh/addnewusers.sh"
#the command to install the bootloader
installbootloader="$sharedir/sh/grub-installer_phase_1.sh"
#folder which is copied by default
clonesource="/"
#dir where sync folder are located
syncdir="/run/syncdir"
#pidfile
pidfile="$syncdir/cloneme.pid"
#graphic interface
#don't comment or change this
clonetarget=""

usage(){
  echo "$0 <mode> [<source>] <target> [ graphic bootloader ]"
  echo "valid modes are:"
  echo "update: updates the target system to the level of the source"
  echo "install: clone running system with respect for privacy of users"
  echo ""
  echo "Explaination"
  echo "<source> is the folder which is copied"
  echo "<target> is the partition on the device which is meant to contain the target system"
}

#use readlink -f if realpath isn't available
if [ ! -e "/usr/bin/realpath" ];then
  realpath()
  {
    echo "$(readlink -f "$1")"
    exit 0;
  }
fi	

# basic checks

# translate into more informative names and check arguments
choosemode="$1"
case "$#" in
  "3")clonesource="$(realpath "$2")"; clonetarget="$(realpath "$3")";;
  "2")clonetarget="$(realpath "$2")";;
  *)usage;exit 1;;
esac

if [ "$choosemode" = "--help" ]; then
  usage; exit 1;
fi

#just one instance can run simultanous
if [ ! -e "$pidfile" ]; then
  echo "$$" > "$pidfile"
else
  echo "an other instance is running, abort!"
  exit 1;
fi




#check if runs with root permission
if [ ! "$UID" = "0" ] && [ ! "$EUID" = "0" ]; then
  echo "error: needs root permissions"
  exit 1;
fi


#check syncdir; it mustn't end with /"
tempp="$(echo "$syncdir" | sed "s/\/$//")"
syncdir="$tempp"

if ! "$sharedir"/sh/report-missing-packages.sh; then
  exit 1
fi


if [ ! -e "/usr/bin/$EDITOR" ] && [ ! -e "/bin/$EDITOR" ] && [ ! -e "$EDITOR" ]; then
  echo "error: no default editor found"
  echo "please enter your favourite editor"
  read EDITOR
  echo "Shall I set this editor as default editor? [yes] (writes into ~/bashrc)"
  read write_bashrc
  if [ "$write_bashrc" = "yes" ]; then
    echo "EDITOR=\"$EDITOR\"" >> ~/.bashrc
  fi
fi

"$sharedir"/sh/prepsyncscript.sh "${syncdir}"
if ! "$sharedir"/sh/mountscript.sh mount "$clonesource" "$syncdir"/src; then
  exit 1
fi
 
if ! "$sharedir"/sh/mountscript.sh mount "$clonetarget" "$syncdir"/dest; then
  exit 1
fi




installer(){
#  rsyncing="true"


#    if [ "$(ls -A "${clonedestdir}")" != "" ];then
#      echo "The target partition is not empty. Shall I clean it? Type \"yes\""
#      read shall_clean
#      if [ "${shall_clean}" = "yes" ];then
#        rm -r "${clonedestdir}"/*
#      fi
#      echo "Skip rsync? Type \"yes\""
#      read rsyncing_quest
#      if [ "${rsyncing_quest}" = "yes" ];then
#        rsyncing="false"
#      fi
#    fi

  
#  if [ "$rsyncing" = "true" ];then
#     if ! "$sharedir"/sh/rsyncci.sh install "${clonesourcedir}" "${clonedestdir}";then
#       exit 1;
#     fi
#  fi
  
#    echo "root in fstab updated"
#    if [ "$cloneme_ui_mode" = false ];then
#      echo "If you use more partitions (e.g.swap) please type \"yes\" to update the rest"
#      read shall_fstab
#      if [ "$shall_fstab" = "yes" ]; then
#        if ! ${EDITOR} "${clonedestdir}"/etc/fstab; then
#          echo "Fall back to vi"
#          vi "${clonedestdir}"/etc/fstab
#        fi
#      fi
#    fi

#  copyuser
#  "$sharedir"/sh/install-installer.sh "$(dirname "$myself")" "$(dirname "$sharedir")"/applications/cloneme.desktop "${clonedestdir}"
  if ! "$sharedir"/sh/rsyncci.sh \
--mode install \
--src "$syncdir"/src \
--dest "$syncdir"/dest \
--bootloader "${sharedir}/sh/grub-installer_phase_1.sh $config_new_sys" \
--installinstaller "$sharedir/sh/install-installer.sh $0 $(dirname "$sharedir")/applications/cloneme.desktop ${clonedestdir}";then
    exit 1;
  fi 
}

updater(){
   if ! "$sharedir"/sh/rsyncci.sh \
--mode update \
--src "${clonesourcedir}" \
--dest "${clonedestdir}"; then
    exit 1;
  fi 
# \
# --bootloader "${sharedir}/sh/grub-installer_phase_1.sh $config_new_sys" \
# --installinstaller "$sharedir/sh/install-installer.sh $0 $(dirname "$sharedir")/applications/cloneme.desktop ${clonedestdir}";then
}


case "$choosemode" in
  "update")updater;;
  "install")installer;;
  *)usage;exit 1;;
esac


"$sharedir"/sh/umountsyncscript.sh "$syncdir"
rm "$pidfile"
##trap "$sharedir/sh/umountsyncscript.sh \"$syncdir\";rm \"$pidfile\"" SIGINT

exit 0;
