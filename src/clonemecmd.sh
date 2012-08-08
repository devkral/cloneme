#! /bin/bash


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
#folder which is copied
clonesource="/"
#folder where sync takes place
syncdir="/run/syncdir"
#graphic interface
#don't comment or change this
graphic_interface_path=""
cloneme_ui_mode="false"
clonesourceloop=""
clonetargetloop=""
clonetarget=""

clonesourcedir="$syncdir"/src
clonedestdir="$syncdir"/dest



help(){
  echo "$0 <mode> [<source>] <target> [ graphic bootloader ]"
  echo "valid modes are:"
  echo "update: updates the target system to the level of the source"
  echo "install: clone running system with respect for privacy of users"
  echo ""
  echo "Explaination"
  echo "<source> is the folder which is copied"
  echo "<target> is the partition on the device which is meant to contain the target system"
}
	

# basic checks

# translate into more informative names and check arguments
choosemode="$1"
case "$#" in
  "5")
    clonesource="$(realpath "$2")";
    clonetarget="$(realpath "$3")";
    graphic_interface_path="$(realpath "$4")"
    installbootloader="$(realpath "$5")";
    if [ "x$graphic_interface_path" != "x" ] && [ -f "$graphic_interface_path" ] ;then
      cloneme_ui_mode="true";
    fi
    ;;
  "3")clonesource="$(realpath "$2")"; clonetarget="$(realpath "$3")";;
  "2")clonetarget="$(realpath "$2")";;
  *)help;exit 1;;
esac

if [ "$choosemode" = "--help" ]; then
  help; exit 0;
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

if [ "$cloneme_ui_mode" = "false" ];then
  "$sharedir"/sh/prepsyncscript.sh "${syncdir}"

  
  if ! "$sharedir"/sh/mountscript.sh mount "$clonesource" "$syncdir"/src; then
      exit 1
    fi
  fi
 
  if ! "$sharedir"/sh/mountscript.sh mount "$clonetarget" "$syncdir"/dest; then
      exit 1
    fi
  fi
fi


copyuser(){
local usertemp
for usertemp in $(ls "${clonesourcedir}"/home)
do
  if [ "$cloneme_ui_mode" = "true" ];then
    ${graphic_interface_path} --copyuser --src "${clonesourcedir}" --dest "${clonedestdir}" --user "${usertemp}"
  else
    "${sharedir}"/sh/copyuser.sh "${clonesourcedir}" "${clonedestdir}" "${usertemp}"
  fi
done
}

installer(){
  rsyncing="true"

  if [ "$cloneme_ui_mode" = "false" ];then
    if [ "$(ls -A "${clonedestdir}")" != "" ];then
      echo "The target partition is not empty. Shall I clean it? Type \"yes\""
      read shall_clean
      if [ "${shall_clean}" = "yes" ];then
        rm -r "${clonedestdir}"/*
      fi
      echo "Skip rsync? Type \"yes\""
      read rsyncing_quest
      if [ "${rsyncing_quest}" = "yes" ];then
        rsyncing="false"
      fi
    fi
  fi

  
  if [ "$rsyncing" = "true" ];then
     if ! "$sharedir"/sh/rsyncci.sh install "${clonesourcedir}" "${clonedestdir}";then
       exit 1;
     fi
  fi
  
  if [ -f "${clonedestdir}"/etc/fstab ];then
   
    local tempprobefstab="$("$sharedir"/sh/devicefinder.sh uuid "${clonedestdir}")"
    local tempsed="$(sed -e "s/.\+\( \/ .\+\)/UUID=${tempprobe}\1/" "${clonedestdir}"/etc/fstab)"
    echo "$tempsed" > "${clonedestdir}"/etc/fstab

    echo "root in fstab updated"
    if [ "$cloneme_ui_mode" = false ];then
      echo "If you use more partitions (e.g.swap) please type \"yes\" to update the rest"
      read shall_fstab
      if [ "$shall_fstab" = "yes" ]; then
        if ! ${EDITOR} "${clonedestdir}"/etc/fstab; then
          echo "Fall back to vi"
          vi "${clonedestdir}"/etc/fstab
        fi
      fi
    fi
  else
    echo "no fstab found"
    exit 1
  fi
  copyuser
  "$sharedir"/sh/install_installer.sh "$(dir "$myself")" "$(dir "$sharedir")"/applications/cloneme.desktop "${clonedestdir}"
  
  mount -o bind /proc "${clonedestdir}"/proc
  mount -o bind /sys "${clonedestdir}"/sys
  mount -o bind /dev "${clonedestdir}"/dev
 
  if [ "$cloneme_ui_mode" = "true" ];then
    mount -o bind /tmp "${clonedestdir}"/tmp
    mount -o bind /run "${clonedestdir}"/run
    "$installbootloader" "${clonedestdir}" "${graphic_interface_path}" "--createuser"
  else
    "$installbootloader" "${clonedestdir}" "$config_new_sys"
  fi
  
  
  umount "${clonedestdir}"/{proc,sys,dev}
  if [ "$cloneme_ui_mode" = "true" ];then
    umount "${clonedestdir}"/{tmp,run}
  fi
}

updater(){
  if ! "$sharedir"/sh/rsyncci.sh update "${clonesourcedir}" "${clonedestdir}"; then
    exit 1
  fi
  #"$sharedir"/sh/install_installer.sh "$(dir "$myself")" "$(dir "$sharedir")"/applications/cloneme.desktop "${clonedestdir}"
  copyuser
}


case "$choosemode" in
  "update")updater;;
  "install")installer;;
  *)help;exit 1;;
esac

if [ "$cloneme_ui_mode" = "false" ];then
  "$sharedir"/sh/umountsyncscript.sh "$syncdir"
fi

exit 0;
