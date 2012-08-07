#! /bin/sh


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
myself="$(realpath -L "$0")"
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
clonetargetdevice=""



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
    clonetargetdevice="$(realpath "$3")";
    graphic_interface_path="$(realpath "$4")"
    installbootloader="$(realpath "$5")";
    if [ "x$graphic_interface_path" != "x" ] && [ -f "$graphic_interface_path" ] ;then
      cloneme_ui_mode="true";
    fi
    ;;
  "3")clonesource="$(realpath "$2")"; clonetargetdevice="$(realpath "$3")";;
  "2")clonetargetdevice="$(realpath "$2")";;
  "1");; # because of syncdir
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
if [ "$cloneme_ui_mode" = "false" ] && [ "$choosemode" != "syncdir" ];then
  if "$sharedir"/sh/mountscript.sh needpart "$clonesource"; then
    echo "Please enter the partition number (beginning with p)"
    read partitions
    if ! clonesourcedir=$("$sharedir"/sh/mountscript.sh mount "$clonesource" "$partitions" "$syncdir"/src)"; then
      echo "$clonesourcedir"
      exit 1
    fi
  else
    if ! clonesourcedir=$("$sharedir"/sh/mountscript.sh mount "$clonesource" "$syncdir"/src)"; then
      echo "$clonesourcedir"
      exit 1
    fi
  fi

  if "$sharedir"/sh/mountscript.sh needpart "$clonetarget"; then
    echo "Please enter the partition number (beginning with p)"
    read partitiond
    if ! clonedestdir=$("$sharedir"/sh/mountscript.sh mount "$clonetarget" "$partitiond" "$syncdir"/dest)"; then
      echo "$clonedestdir"
      exit 1
    fi
  else
    if ! clonedestdir=$("$sharedir"/sh/mountscript.sh mount "$clonetarget" "$syncdir"/dest)"; then
      echo "$clonedestdir"
      exit 1
    fi
  fi
fi

#loop shouldn't happen
if [ "$clonesourcedir" = "$clonetargetdir" ] || [ "$clonesourcedir" = "$clonetargetdir/" ];then
  echo "error: source = target"
  echo "target: $clonetargetdir"
  exit 1
fi


copyuser(){
local usertemp
for usertemp in $(ls "${clonesourcedir}"/home)
do
  if [ "$cloneme_ui_mode" = "true" ];then
    ${graphic_interface_path} --copyuser --src "${clonesourcedir}" --dest "${clonetargetdir}" --user "${usertemp}"
  else
    "${sharedir}"/sh/copyuser.sh "${clonesourcedir}" "${clonetargetdir}" "${usertemp}"
  fi
done
}

installer(){
  rsyncing="true"
  if [ "$cloneme_ui_mode" = "false" ];then
    if [ "$(ls -A "${clonetargetdir}")" != "" ];then
      echo "The target partition is not empty. Shall I clean it? Type \"yes\""
      read shall_clean
      if [ "${shall_clean}" = "yes" ];then
        rm -r "${clonetargetdir}"/*
      fi
      echo "Skip rsync? Type \"yes\""
      read rsyncing_quest
      if [ "${rsyncing_quest}" = "yes" ];then
        rsyncing="false"
      fi
      
    fi
  fi
  if [ "$rsyncing" = "true" ];then
     if ! "$sharedir"/sh/rsyncci.sh install "${clonesourcedir}" "${clonetargetdir}";then
       exit 1;
     fi
  fi
  
  if [ -f "${clonetargetdir}"/etc/fstab ];then
   
    local tempprobefstab="$("$sharedir"/sh/devicefinder.sh uuid "${clonetargetdir}")"
    local tempsed="$(sed -e "s/.\+\( \/ .\+\)/UUID=${tempprobe}\1/" "${clonetargetdir}"/etc/fstab)"
    echo "$tempsed" > "${clonetargetdir}"/etc/fstab

    echo "root in fstab updated"
    if [ "$cloneme_ui_mode" = false ];then
      echo "If you use more partitions (e.g.swap) please type \"yes\" to update the rest"
      read shall_fstab
      if [ "$shall_fstab" = "yes" ]; then
        if ! ${EDITOR} "${clonetargetdir}/etc/fstab"; then
          echo "Fall back to vi"
          vi "${clonetargetdir}"/etc/fstab
        fi
      fi
    fi
  else
    echo "no fstab found"
    exit 1
  fi
  copyuser
  "$sharedir"/sh/install_installer.sh "$(dir "$myself")" "$(dir "$sharedir")"/applications/cloneme.desktop "${clonetargetdir}"
  
  mount -o bind /proc "${clonetargetdir}"/proc
  mount -o bind /sys "${clonetargetdir}"/sys
  mount -o bind /dev "${clonetargetdir}"/dev
 
  if [ "$cloneme_ui_mode" = "true" ];then
    mount -o bind /tmp "${clonetargetdir}"/tmp
    mount -o bind /run "${clonetargetdir}"/run
    $installbootloader "${clonetargetdir}" "${graphic_interface_path}" "--createuser"
  else
    $installbootloader "${clonetargetdir}" "$config_new_sys"
  fi
  
  
  umount "${clonetargetdir}"/{proc,sys,dev}
  if [ "$cloneme_ui_mode" = "true" ];then
    umount "${clonetargetdir}"/{tmp,run}
  fi
}

updater(){
  if ! "$sharedir"/sh/rsyncci.sh update "${clonesourcedir}" "${clonetargetdir}"; then
    exit 1
  fi
  #"$sharedir"/sh/install_installer.sh "$(dir "$myself")" "$(dir "$sharedir")"/applications/cloneme.desktop "${clonetargetdir}"
  copyuser
}


case "$choosemode" in
  "update")updater;;
  "install")installer;;
  "syncdir")echo "$syncdir";;
  *)help;exit 1;;
esac

if [ "$cloneme_ui_mode" = "false" ] && [ "$choosemode" != "syncdir" ];then
  "$sharedir"/sh/umountsyncscript.sh
fi

exit 0;
