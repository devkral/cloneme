#! /bin/sh

#License: Do what you want with this script. But no warranty.

#the command which configures the target system
config_new_sys="addnewusersmanually"
#the command to install the bootloader
installbootloader="installer_grub2"

#defaults
#folder which is copied
clonesource="/"
#folder where sync takes place
syncdir="/syncdir"
#dpartition which is mounted
clonetargetdevice="/dev/sda1"

help(){
  echo "cloneme <mode> [<source>] <target> [<syncdir>]"
  echo "valid modes are:"
  echo "update: updates the target system to the level of the source"
  echo "install: clone running system with respect for privacy of users"
  echo ""
  echo "Explaination"
  echo "<source> is the folder which is copied"
  echo "<target> is the partition on the device which is meant to contain the target system"
  echo "<syncdir> is the directory where target is mounted"
}
	

#basic checks

#translate into more informative names and check arguments
choosemode="$1"
case "$#" in
  4)clonesource="$2";clonetargetdevice="$3";clonetarget="$4";;
  3)clonesource="$2";clonetargetdevice="$3";;
  2)clonetargetdevice="$2";;
  1);;
  *)help;exit 1;;
esac

if [ "$choosemode" = "--help" ]; then
  help; exit 0;
fi

#check syncdir; it mustn't end with /"
tempp="$(echo "$clonesource" | sed "s/\/$//")"
clonesource="$tempp"

#loop shouldn't happen
if [ "$clonesource" = "$clonetargetdevice" ] || [ "$clonesource/" = "$clonetargetdevice" ] || [ "$clonesource" = "$clonetargetdevice/" ];then
  echo "error: source = target"
  exit 1
fi

#check if needed programs exists
if [ ! -e /usr/bin/rsync ] && [ ! -e /usr/sbin/rsync ]; then
  echo "error command: rsync not found"
  echo "please install rsync"
  exit 1
fi

if [ ! -e /sbin/losetup ] && [ ! -e /usr/bin/losetup ]; then
  echo "error command: /sbin/losetup not found"
  echo "error command: /usr/bin/losetup not found"
  echo "Have you loop tools (name can differ) installed?"
  exit 1
fi

if [ ! -e /usr/bin/"$EDITOR" ] && [ ! -e /bin/"$EDITOR" ] && [ ! -e "$EDITOR" ]; then
  echo "error no default editor found"
  echo "please enter your favourite editor"
  read EDITOR
  echo "Shall I set this editor as default editor? [yes] (writes into ~/bashrc)"
  read write_bashrc
  if [ "$write_bashrc" = "yes" ]; then
    echo "EDITOR=\"$EDITOR\"" >> ~/.bashrc
  fi
fi

if [ ! -e /bin/mount ] && [ ! -e /usr/bin/mount ]; then
  echo "error command: mount not found"
  exit 1
fi

if [ ! -e /bin/mountpoint ] && [ ! -e /usr/bin/mountpoint ]; then
  echo "error command: mountpoint not found"
  exit 1
fi


#check if runs with root permission
if [ ! "$UID" = "0" ]; then
  echo "error: needs root permissions"
  exit 1;
fi

#howto call mounting <"device"> <"mountpoint">
#mount or use directory
#mounting()
#{
#  local device="$1"
#  local mountpoint="$2"
#  if [ ! -d ${device} ];then
#    if mountpoint "${device}" &> /dev/null; then
#      echo "Debug: ${device} is already mounted."
#      return 
#    else
#      if ! mount "${clonetargetdevice}" "${mountpoint}"; then
#        # error message by mount itself
#        echo "Hint: have you restarted the kernel after last update?"
#        exit 1
#      fi
#    fi
#  fi
#}

#check if directory is mounted
##don't run this when the process is a subprocess beyond syncdir
if [ "$choosemode" != "---special-mode---" ]; then
#template for new version
#  if [ -d "${syncdir}"/src ]; then
#    if [ "$(grub-probe -t device -d ${clonesource})" != "$(grub-probe -t device "${syncdir}")" ] && [ "$(grub-probe -t fs_uuid -d ${clonetargetdevice})" != "$(grub-probe -t fs_uuid "${syncdir}")" ]; then
#        echo "error: mounted device is not target device"
#        exit 1;
#    fi

  if [ -d "${syncdir}" ]; then
    if mountpoint "${syncdir}" &> /dev/null; then
      echo "Debug: ${syncdir} is already mounted."
      if [ "$(grub-probe -t device -d ${clonetargetdevice})" != "$(grub-probe -t device "${syncdir}")" ] && [ "$(grub-probe -t fs_uuid -d ${clonetargetdevice})" != "$(grub-probe -t fs_uuid "${syncdir}")" ]; then
        echo "error: mounted device is not target device"
        exit 1;
      fi
    else
      if ! mount "${clonetargetdevice}" "${syncdir}"; then
        # error message by mount itself
        echo "Hint: have you restarted the kernel after last update?"
        exit 1
      fi
    fi
  else
    mkdir -p "${syncdir}"
    # error message by mount itself
    if ! mount "${clonetargetdevice}" "${syncdir}"; then
      echo "Hint: have you restarted the kernel after last update?"
      exit 1
    fi
  fi

fi


addnewusersmanually(){
  usercounter=0
  for (( ; ; ))
  do
    if [ $usercounter = 0 ];then
      usercounter=1;
      echo "Create new user? [yes/no]"
    else
      echo "Create another new user? [yes/no]"
    fi
    read n_user
    if [ "$n_user" = "yes" ];then
      usergroupargs="video,audio,optical,power"
      echo "Enter user name"
      read user_name;
      echo "Shall this user account have admin (can change to root) permissions? [yes] default: no"
      read admin_perm
      if [ "$admin_perm" = "yes" ];then
        if grep "wheel" /etc/group > /dev/null;then
          usergroupargs+=",wheel"
        fi
        if grep "adm" /etc/group > /dev/null;then
          usergroupargs+=",adm"
        fi
        if grep "admin" /etc/group > /dev/null;then
          usergroupargs+=",admin"
        fi
      fi
      useradd -m -U "$user_name" -p "" -G $usergroupargs
      passwd -e "$user_name"
    fi
    if [ "$n_user" = "no" ];then
      break
    fi
  done
}


copyuser(){

for usertemp in $(ls /home)
do
  for (( ; ; ))
  do
    echo "What shall be done with user $usertemp?"
    if [ -d "${syncdir}"/home/"$usertemp" ]; then
      echo -e "Synchronize user account. Type \"s\""
    else
      echo -e "Copy user account. Type \"s\""
      echo -e "Create empty user account (with same password as the existing). Type \"e\""
    fi
    echo -e "Don't use the user account. Type \"c\""
    read -n 1 answer_useracc
    if [ "$answer_useracc" = "s" ]; then
      rsync -a -A --progress --delete --exclude "${syncdir}" "${clonesource}"/home/"${usertemp}" "${syncdir}"/home/
      break
    fi
    
    if [ "$answer_useracc" = "e" ]; then
      mkdir -P "${syncdir}"/home/"$usertemp"
      
      if grep "$usertemp" "${clonesource}"/etc/passwd > /dev/null;then
        chown $usertemp "${syncdir}"/home/"$usertemp"
        if grep "$usertemp" "${clonesource}"/etc/group > /dev/null;then
          chown $usertemp:$usertemp "${syncdir}"/home/"$usertemp"
        fi
      fi
      
      
      #sudo -u
      break
    fi
    
    if [ "$answer_useracc" = "c" ]; then
      if [ ! -d "${syncdir}"/home/"$usertemp" ];then
        echo "Delete superfluous user entries in passwd, shadow, etc. on the target system? Type yes (not the default)"
        read question_delete
        if [ "$question_delete" = "yes" ]; then
          #still experimental
          sed -i -e "/^${usertemp}/d" "${syncdir}"/etc/passwd
          sed -i -e "/^${usertemp}/d" "${syncdir}"/etc/passwd-
          sed -i -e "/^${usertemp}/d" "${syncdir}"/etc/group
          sed -i -e "s/\b${usertemp}\b//g" "${syncdir}"/etc/group
          sed -i -e "/^${usertemp}/d" "${syncdir}"/etc/group-
          sed -i -e "s/\b${usertemp}\b//g" "${syncdir}"/etc/group-
          sed -i -e "/^${usertemp}/d" "${syncdir}"/etc/gshadow
          sed -i -e "s/\b${usertemp}\b//g" "${syncdir}"/etc/gshadow
          sed -i -e "/^${usertemp}/d" "${syncdir}"/etc/gshadow-
          sed -i -e "s/\b${usertemp}\b//g" "${syncdir}"/etc/gshadow-
          echo "remove finished"
        fi
      fi
      break
    fi
  done
done


}

installer(){
  if [ "$(ls -A "${syncdir}"/*)" != "" ];then
    echo "The target partition is not empty. Shall I clean it? Type \"yes\""
    read shall_clean
    if [ "${shall_clean}" = "yes" ];then
      rm -r "${syncdir}"/*
    fi
  fi
  rsync -a -A --progress --delete --exclude "${clonesource}"/boot/grub/grub.cfg --exclude "${clonesource}"/boot/grub/device.map  --exclude "${syncdir}" --exclude "${clonesource}/home/*" --exclude "${clonesource}/sys/*" --exclude "${clonesource}/dev/*" --exclude "${clonesource}/proc/*" --exclude "${clonesource}/var/log/*" --exclude "${clonesource}/tmp/*" --exclude "${clonesource}/run/*" --exclude "${clonesource}/var/run/*" --exclude "${clonesource}/var/tmp/*" "${clonesource}"/* "${syncdir}"
  if [ -e "${syncdir}"/boot/grub/device.map ];then
    sed -i -e "s/\((hd0)\)/# \1/" "${syncdir}"/boot/grub/device.map
  fi
  echo "(hd0) $(grub-probe -t device -d "${clonetargetdevice}" | sed -e "s|[0-9]*$||") #--specialclone-me--" >> "${syncdir}"/boot/grub/device.map
  sed -i -e "s/.\+\( \/ .\+\)/UUID=$(grub-probe -t fs_uuid -d ${clonetargetdevice})\1/" "${syncdir}"/etc/fstab
  echo "root in fstab updated"
  echo "If you use more partitions (e.g.swap) please type \"yes\" to update the rest"
  read shall_fstab
  if [ "$shall_fstab" = "yes" ]; then
    if ! ${EDITOR} "${syncdir}"/etc/fstab; then
      echo "Fall back to vi"
      vi "${syncdir}"/etc/fstab
    fi
  fi
  copyuser

  mount -o bind /proc "${syncdir}"/proc
  mount -o bind /sys "${syncdir}"/sys
  mount -o bind /dev "${syncdir}"/dev

  chroot "${syncdir}" $0 "---special-mode---" "${clonetargetdevice}"

  sed -i -e "/#--specialclone-me--/d" "${syncdir}"/boot/grub/device.map
  #sed -i -e "s/# (hd0)/(hd0)/" "${syncdir}"/boot/grub/device.map
  echo "if you want to use device.map please type \"yes\" and edit it now"
  read shall_devicemap
  if [ "$shall_devicemap" = "yes" ]; then
    if ! ${EDITOR} "${syncdir}"/boot/grub/device.map; then
      echo "Fall back to vi"
      vi "${syncdir}"/boot/grub/device.map
    fi
  fi

  umount "${syncdir}"/{proc,sys,dev}
}



installer_grub2(){
  echo "Install grub…"
  get_dev="$(grub-probe -t device -d "${clonetargetdevice}" | sed  -e "s|[0-9]*$||")"
  if ! grub-install "$get_dev";then
    echo "I fail please do it yourself"
    /bin/sh
  fi
  
  #get_part="$(grub-probe -t device ${syncdir}" | sed "s/.\+([0-9]*)/${clonetargetdevice}/")"
  grub-mkconfig -o /boot/grub/grub.cfg
  echo "grub installation finished. Beginn of the configuration of the new system"
  $config_new_sys
}

updater(){
  rsync -a -A --progress --delete --exclude "${clonesource}"/boot/grub/grub.cfg --exclude "${clonesource}"/boot/grub/device.map --exclude "${clonesource}"/etc/fstab --exclude "${syncdir}" --exclude "${clonesource}/home/*" --exclude "${clonesource}"/sys/ --exclude "${clonesource}/dev/*" --exclude "${clonesource}/proc/*" --exclude "${clonesource}/var/log/*" --exclude "${clonesource}/tmp/*" --exclude "${clonesource}/run/*" --exclude "${clonesource}/var/run/*" --exclude "${clonesource}/var/tmp/*" "${clonesource}"/* "${syncdir}"
  copyuser
}


case "$choosemode" in
  "---special-mode---") ${installbootloader};;
  "update")updater;;
  "install")installer;;
  *)help;exit 1;;
esac


#clean up
if [ "$choosemode" != "---special-mode---" ]; then
  umount "${syncdir}"
  rmdir "${syncdir}"
fi
