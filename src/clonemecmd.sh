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
sharedir="./src/share"


#defaults
#the command which configures the target system
config_new_sys="addnewusers"
#the command to install the bootloader
installbootloader="installer_grub2"
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



echo "$myself"

help(){
  echo "$0 <mode> [<source>] <target>"
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
  "3")clonesource="$(realpath "$2")";clonetargetdevice="$(realpath "$3")";;
  "2")clonetargetdevice="$(realpath "$2")";;
  *)help;exit 1;;
esac

  if [ "$choosemode" = "--help" ]; then
    help; exit 0;
  fi
fi

#check if runs with root permission
if [ ! "$UID" = "0" ] && [ ! "$EUID" = "0" ]; then
  echo "error: needs root permissions"
  exit 1;
fi


#check syncdir; it mustn't end with /"
tempp="$(echo "$syncdir" | sed "s/\/$//")"
syncdir="$tempp"


#check if needed programs exists
if [ ! -e "/usr/bin/rsync" ] && [ ! -e "/usr/sbin/rsync" ]; then
  echo "error command: rsync not found"
  echo "please install rsync"
  exit 1
fi

if [ ! -e "/usr/bin/realpath" ]; then
  echo "error command realpath not found"
  echo "Have you coreutils (name can differ) installed?"
  exit 1
fi


if [ ! -e "/sbin/losetup" ] && [ ! -e "/usr/bin/losetup" ]; then
  echo "error command /sbin/losetup | /usr/bin/losetup not found"
  echo "Have you loop tools (name can differ) installed?"
  echo "no raw file mount is supported"
  if [ -f "$clonesource" ] || [ -f "$clonetargetdevice" ];then
    echo "you try to mount raw files. Exit"
    exit 1
  fi
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

if [ ! -e "/bin/mount" ] && [ ! -e "/usr/bin/mount" ]; then
  echo "error command: mount not found"
  exit 1
fi

if [ ! -e "/bin/mountpoint" ] && [ ! -e "/usr/bin/mountpoint" ]; then
  echo "error command: mountpoint not found"
  exit 1
fi



#mount_blockdevice <"device"> <"mountpoint">
#mount blockdevices
mount_blockdevice()
{
  local device="$1"
  local mountpath="$2"
#safeguard for not killing innocent mounts
  if [ ! -b "$device" ];then
    echo "mount_blockdevice error: $device is no block device"
    exit 1
  fi

#sorry other mountpoints but we must be sure that this is the only mountpoint
#/proc/mounts of the real running system is used
  local pathtoumount="$(cat /proc/mounts | grep "$device" | sed -e "s/^[^ ]\+ \([^ ]\+\) .*/\1/g")"
  if [ "$pathtoumount" != "" ]; then
    for itemtoumount in $pathtoumount
    do
      echo "mount_blockdevice: umount $itemtoumount"
      umount "$(echo "$itemtoumount" | sed -e 's/\\040/\ /g')"
    done
  fi

  if mountpoint "${mountpath}" &> /dev/null; then
#sorry predecessor but we must be sure that is mounted as ROOT
    if ! umount "${mountpath}"; then
      echo "mount_blockdevice error: cannot unmount the mount directory"
      echo "an other service depending on this directory is still running"
      echo "abort!"
      exit 1
    else
      echo "mount_blockdevice success: unmount ${mountpath}"
    fi
  fi
  
  if ! mount "${device}" "${mountpath}"; then
    # error message by mount itself
    echo "mount_blockdevice hint: have you restarted the kernel after last update?"
    exit 1
  fi
  return 0
}

#mount
##don't run this when a subprocess of itself
echo "$1"
if [ "$choosemode" != "---special-mode---" ] && [ "$choosemode" != "---special-mode-graphic---" ]; then
  if [ -d "${clonesource}" ];then
    clonesourcedir="${clonesource}"
  elif [ -b "${clonesource}" ];then
    mkdir -p "${syncdir}/src" 2> /dev/null
    mount_blockdevice "${clonesource}" "${syncdir}/src"
    clonesourcedir="${syncdir}/src"
  elif [ -f "${clonesource}" ];then
    mkdir -p "${syncdir}"/src 2> /dev/null
    if ! losetup -a | grep "${clonesource}" > /dev/null;then
      if ! losetup -f -P "${clonesource}";then
        echo "Hint: have you restarted the kernel after last update?"
        exit 1
      fi
    else
      echo "raw file already loop mounted but this is no issue"
    fi
    clonesourceloop="$(losetup -a | grep "${clonesource}" | sed -e "s/:.*//" -e 's/^ \+//' -e 's/ \+$//')"
    echo "Please enter the partition number (beginning with p)"
    read parts
    mount_blockdevice "${clonesourceloop}$parts" "${syncdir}/src"
    clonesourcedir="${syncdir}/src"
  else
    echo "source not recognized"
    exit 1
  fi

  if [ -d "${clonetargetdevice}" ];then
    clonetargetdir="${clonetargetdevice}"
  elif [ -b "${clonetargetdevice}" ];then
    mkdir -p "${syncdir}/dest" 2> /dev/null
    mount_blockdevice "${clonetargetdevice}" "${syncdir}/dest"
    clonetargetdir="${syncdir}/dest"
  elif [ -f "${clonetargetdevice}" ];then
    mkdir -p "${syncdir}/dest" 2> /dev/null
    if ! losetup -a | grep "${clonetargetdevice}" > /dev/null;then
      if ! losetup -f -P "${clonetargetdevice}";then 
        echo "Hint: have you restarted the kernel after last update?"
        exit 1
      fi
    fi
    clonetargetloop="$(losetup -a | grep "${clonetargetdevice}" | sed -e "s/:.*//")"
    echo "Please enter the partition number (beginning with p)"
    read partd
    mount_blockdevice "${clonetargetloop}$partd" "${syncdir}/dest"
    clonetargetdir="${syncdir}/dest"
  else
    echo "target not recognized"
    exit 1
  fi
#check clonesourcedir; it has to end with /"
  tempp="$(echo "$clonesourcedir" | sed "s/\/$//")"
  clonesourcedir="$tempp/"
else
  clonetargetdir="$2"
fi

#loop shouldn't happen
if [ "$clonesourcedir" = "$clonetargetdir" ] || [ "$clonesourcedir" = "$clonetargetdir/" ];then
  echo "error: source = target"
  echo "target: $clonetargetdir"
  exit 1
fi



# $1 username $2 prefix
_cleanuser(){
  local usertemp=$1
  local targetn=$2
  sed -i -e "/^${usertemp}/d" "${targetn}"/etc/passwd
  sed -i -e "/^${usertemp}/d" "${targetn}"/etc/passwd-
  sed -i -e "/^${usertemp}/d" "${targetn}"/etc/group
  sed -i -e "s/\b${usertemp}\b//g" "${targetn}"/etc/group
  sed -i -e "/^${usertemp}/d" "${targetn}"/etc/group-
  sed -i -e "s/\b${usertemp}\b//g" "${targetn}"/etc/group-
  sed -i -e "/^${usertemp}/d" "${targetn}"/etc/gshadow
  sed -i -e "s/\b${usertemp}\b//g" "${targetn}"/etc/gshadow
  sed -i -e "/^${usertemp}/d" "${targetn}"/etc/gshadow-
  sed -i -e "s/\b${usertemp}\b//g" "${targetn}"/etc/gshadow-

  if [ -d "${targetn}"/home/"$usertemp" ];then
    rm -r "${targetn}"/home/"$usertemp"
  fi
  # and remove email folder
  shred -u "${targetn}/var/spool/mail/${usertemp}" 2> /dev/null
  echo "cleaning finished"
}



copyuser(){
local usertemp
for usertemp in $(ls "${clonesourcedir}"/home)
do
  if [ "$cloneme_ui_mode" = "true" ];then
    ${graphic_interface_path} --copyuser --src "${clonesourcedir}" --dest "${clonetargetdir}" --user "${usertemp}"
  else
    for (( ; ; ))
    do
      echo "What shall be done with user $usertemp?"
      if [ -d "${clonetargetdir}"/home/"$usertemp" ]; then
        echo -e "Synchronize user account. Type \"s\""
		echo -e "Eradicate user files. Type \"e\""
		echo -e "Don't touch the user account. Type \"i\""
        echo -e "Clean target system from user account. Type \"c\""
      else
        echo -e "Copy user account. Type \"s\""
        echo -e "Create empty user account (with the same password and permissions as the existing one). Type \"e\""
        echo -e "Don't copy the user account. Type \"i\""  
        echo -e "Clean target system from the user account. Type \"c\""
      fi
      
      read -n 1 answer_useracc
      if [ "$answer_useracc" = "s" ]; then
        if ! rsync -a -A --progress --delete --exclude "${clonetargetdir}" "${clonesourcedir}"home/"${usertemp}" "${clonetargetdir}"/home/ ;then
          echo "error: rsync could not sync"
          exit 1
        fi  
        break
      fi
    
      if [ "$answer_useracc" = "e" ]; then
        rm -r "${clonetargetdir}"/home/"$usertemp"
        mkdir -p "${clonetargetdir}"/home/"$usertemp"
        #
        if grep "$usertemp" "${clonesourcedir}"etc/passwd > /dev/null;then
          chown "$usertemp" "${clonetargetdir}"/home/"$usertemp"
          #chown group
          if grep "$usertemp" "${clonesourcedir}"etc/group > /dev/null;then
            chown "${usertemp}:${usertemp}" "${clonetargetdir}"/home/"$usertemp"
          fi
        fi
        # and remove email folder
        shred -u "${clonetargetdir}/var/spool/mail/${usertemp}" 2> /dev/null
        break
      fi
    
      if [ "$answer_useracc" = "i" ]; then
        if [ ! -d "${clonetargetdir}/home/$usertemp" ]; then
          echo "Delete superfluous user entries in passwd, shadow, etc. on the target system? Type \"yes\" (not the default)"
          read question_delete
          if [ "$question_delete" = "yes" ]; then
            _cleanuser "$usertemp" "$clonetargetdir"
          fi
        fi
        break
      fi
      if [ "$answer_useracc" = "c" ]; then
        _cleanuser "$usertemp" "$clonetargetdir"
        break
      fi
    done
  fi
done
}

installer(){
  rsyncing="true"
  if [ "$cloneme_ui_mode" = "false" ];then
    if [ "x$(ls -A "${clonetargetdir}")" != "x" ];then
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
  if [ "$rsyncing" = true ];then
    if ! rsync -a -A --progress --delete --exclude "${clonesourcedir}/run/*" --exclude "${clonesourcedir}"boot/grub/grub.cfg --exclude "${clonesourcedir}"boot/grub/device.map  --exclude "${syncdir}" --exclude "${clonetargetdir}" --exclude "${clonesourcedir}home/*" --exclude "${clonesourcedir}sys/*" --exclude "${clonesourcedir}dev/*" --exclude "${clonesourcedir}proc/*" --exclude "${clonesourcedir}var/log/*" --exclude "${clonesourcedir}tmp/*" --exclude "${clonesourcedir}run/*" --exclude "${clonesourcedir}var/run/*" --exclude "${clonesourcedir}var/tmp/*" "${clonesourcedir}"* "${clonetargetdir}" ;then
    echo "error: rsync could not sync"
    exit 1
    fi
  fi
  
  if [ -f "${clonetargetdir}"/etc/fstab ];then
    #grub-probe can lead to a kill of an usb memory stick (some models?); now replaced!
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
  install_installer
  
  mount -o bind /proc "${clonetargetdir}"/proc
  mount -o bind /sys "${clonetargetdir}"/sys
  mount -o bind /dev "${clonetargetdir}"/dev
 
  if [ "$cloneme_ui_mode" = "true" ];then
    mount -o bind /tmp "${clonetargetdir}"/tmp
    mount -o bind /run "${clonetargetdir}"/run
    "$share_dir"/sh/grub-installer_phase1 "${clonetargetdir}" "${graphic_interface_path}" "--createuser"
  else
    "$share_dir"/sh/grub-installer_phase1 "${clonetargetdir}"
  fi
  
  
  umount "${clonetargetdir}"/{proc,sys,dev}
  if [ "$cloneme_ui_mode" = "true" ];then
    umount "${clonetargetdir}"/{tmp,run}
  fi
}

updater(){
  if ! rsync -a -A --progress --delete --exclude "${clonesourcedir}/run/*" --exclude "${clonesourcedir}"boot/grub/grub.cfg --exclude "${clonesourcedir}"boot/grub/device.map --exclude "${clonesourcedir}"etc/fstab --exclude "${syncdir}" --exclude "$clonetargetdir" --exclude "${clonesourcedir}home/*" --exclude "${clonesourcedir}"sys/ --exclude "${clonesourcedir}dev/*" --exclude "${clonesourcedir}proc/*" --exclude "${clonesourcedir}var/log/*" --exclude "${clonesourcedir}tmp/*" --exclude "${clonesourcedir}run/*" --exclude "${clonesourcedir}var/run/*" --exclude "${clonesourcedir}var/tmp/*" "${clonesourcedir}"* "${clonetargetdir}" ; then
    echo "error: rsync could not sync"
    exit 1
  fi
  install_installer
  copyuser
}


case "$choosemode" in
  "---special-mode---") ${installbootloader};;
  "---special-mode-graphic---") ${installbootloader};;
  "update")updater;;
  "install")installer;;
  *)help;exit 1;;
esac


"$sharedir"/sh/umountscript.sh

exit 0;
