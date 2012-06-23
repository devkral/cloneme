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
#partition which is mounted
# too dangerous
###clonetargetdevice="/dev/sdb1"

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
	

# basic checks

# translate into more informative names and check arguments
choosemode="$1"
case "$#" in
  4)clonesource="$2";clonetargetdevice="$3";clonetarget="$4";;
  3)clonesource="$2";clonetargetdevice="$3";;
  2)clonetargetdevice="$2";;
  *)help;exit 1;;
esac

if [ "$choosemode" = "--help" ]; then
  help; exit 0;
fi


#check if runs with root permission
if [ ! "$UID" = "0" ]; then
  echo "error: needs root permissions"
  exit 1;
fi


#check syncdir; it mustn't end with /"
tempp="$(echo "$syncdir" | sed "s/\/$//")"
syncdir="$tempp"



#loop shouldn't happen
if [ "$clonesource" = "$clonetargetdevice" ] || [ "$clonesource" = "$clonetargetdevice/" ];then
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



#howto call mounting <"device"> <"mountpoint">
#mount or use directory
mounting()
{
  local device="$1"
  local mountpath="$2"

  if mountpoint "${mountpath}" &> /dev/null; then
#sorry predecessor but we must be sure that is mounted as ROOT
    if ! umount "${mountpath}"; then
      echo "can\'t unmount the partition"
      echo "means: an other service depending on theis directory is still running"
      echo "abort!"
      exit 1
    fi
  fi

  if ! mount "${clonetargetdevice}" "${mountpath}"; then
    # error message by mount itself
    echo "Hint: have you restarted the kernel after last update?"
    exit 1
  fi
  return 0
}

#mount
##don't run this when the process is a subprocess beyond syncdir
if [ "$choosemode" != "---special-mode---" ]; then
  if [ -d "${clonesource}" ];then
    clonesource2="${clonesource}"
  elif [ -b "${clonesource}" ];then
    mkdir -p "${syncdir}"/src 2> /dev/null
    mounting "${clonesource}" "${syncdir}"/src
    clonesource2="${syncdir}"/src
  elif [ -f "${clonesource}" ];then
    mkdir -p "${syncdir}"/src 2> /dev/null
    mounting "${clonesource}" "${syncdir}"/src
    clonesource2="${syncdir}"/src
  else
    echo "source not recognized"
    exit 1
  fi

  if [ -d "${clonetargetdevice}" ];then
    clonetargetdevice2="${clonetargetdevice}"
  elif [ -b "${clonetargetdevice}" ];then
    mkdir -p "${syncdir}"/dest 2> /dev/null
    mounting "${clonetargetdevice}" "${syncdir}"/dest
    clonetargetdevice2="${syncdir}"/dest
  else
    echo "target not recognized"
    exit 1
  fi
#check clonesource2; it has to end with /"
  tempp="$(echo "$clonesource2" | sed "s/\/$//")"
  clonesource2="$tempp"
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
    if [ -d "${clonetargetdevice2}"/home/"$usertemp" ]; then
      echo -e "Synchronize user account. Type \"s\""
    else
      echo -e "Copy user account. Type \"s\""
      echo -e "Create empty user account (with same password as the existing). Type \"e\""
    fi
    echo -e "Don't use the user account. Type \"c\""
    read -n 1 answer_useracc
    if [ "$answer_useracc" = "s" ]; then
      rsync -a -A --progress --delete --exclude "${clonetargetdevice2}" "${clonesource2}"home/"${usertemp}" "${clonetargetdevice2}"/home/
      break
    fi
    
    if [ "$answer_useracc" = "e" ]; then
      mkdir -p "${clonetargetdevice2}"/home/"$usertemp"
      
      if grep "$usertemp" "${clonesource2}"etc/passwd > /dev/null;then
        chown $usertemp "${clonetargetdevice2}"/home/"$usertemp"
        if grep "$usertemp" "${clonesource2}"etc/group > /dev/null;then
          chown $usertemp:$usertemp "${clonetargetdevice2}"/home/"$usertemp"
        fi
      fi
    fi
    
    if [ "$answer_useracc" = "c" ]; then
      if [ ! -d "${clonetargetdevice2}"/home/"$usertemp" ];then
        echo "Delete superfluous user entries in passwd, shadow, etc. on the target system? Type yes (not the default)"
        read question_delete
        if [ "$question_delete" = "yes" ]; then
          #still experimental
          sed -i -e "/^${usertemp}/d" "${clonetargetdevice2}"/etc/passwd
          sed -i -e "/^${usertemp}/d" "${clonetargetdevice2}"/etc/passwd-
          sed -i -e "/^${usertemp}/d" "${clonetargetdevice2}"/etc/group
          sed -i -e "s/\b${usertemp}\b//g" "${clonetargetdevice2}"/etc/group
          sed -i -e "/^${usertemp}/d" "${clonetargetdevice2}"/etc/group-
          sed -i -e "s/\b${usertemp}\b//g" "${clonetargetdevice2}"/etc/group-
          sed -i -e "/^${usertemp}/d" "${clonetargetdevice2}"/etc/gshadow
          sed -i -e "s/\b${usertemp}\b//g" "${clonetargetdevice2}"/etc/gshadow
          sed -i -e "/^${usertemp}/d" "${clonetargetdevice2}"/etc/gshadow-
          sed -i -e "s/\b${usertemp}\b//g" "${clonetargetdevice2}"/etc/gshadow-
          rm "/var/spool/mail/${usertemp}"
          echo "remove finished"
        fi
      fi
      break
    fi
  done
done


}

installer(){
  if [ "$(ls -A "${clonetargetdevice2}")" != "" ];then
    echo "The target partition is not empty. Shall I clean it? Type \"yes\""
    read shall_clean
    if [ "${shall_clean}" = "yes" ];then
      rm -r "${clonetargetdevice2}"/*
    fi
  fi

  rsync -a -A --progress --delete --exclude "${clonesource2}"boot/grub/grub.cfg --exclude "${clonesource2}"boot/grub/device.map  --exclude "${syncdir}" --exclude "${clonetargetdevice2}" --exclude "${clonesource2}home/*" --exclude "${clonesource2}sys/*" --exclude "${clonesource2}dev/*" --exclude "${clonesource2}proc/*" --exclude "${clonesource2}var/log/*" --exclude "${clonesource2}tmp/*" --exclude "${clonesource2}run/*" --exclude "${clonesource2}var/run/*" --exclude "${clonesource2}var/tmp/*" "${clonesource2}"* "${clonetargetdevice2}"
  if [ -e "${clonetargetdevice2}"/boot/grub/device.map ];then
    sed -i -e "s/\((hd0)\)/# \1/" "${clonetargetdevice2}"/boot/grub/device.map
  fi
  echo "(hd0) $(grub-probe -t device "${clonetargetdevice2}" | sed -e "s|[0-9]*$||") #--specialclone-me--" >> "${clonetargetdevice2}"/boot/grub/device.map
  sed -i -e "s/.\+\( \/ .\+\)/UUID=$(grub-probe -t fs_uuid ${clonetargetdevice2})\1/" "${clonetargetdevice2}"/etc/fstab
  echo "root in fstab updated"
  echo "If you use more partitions (e.g.swap) please type \"yes\" to update the rest"
  read shall_fstab
  if [ "$shall_fstab" = "yes" ]; then
    if ! ${EDITOR} "${clonetargetdevice2}"/etc/fstab; then
      echo "Fall back to vi"
      vi "${clonetargetdevice2}"/etc/fstab
    fi
  fi
  copyuser

  mount -o bind /proc "${clonetargetdevice2}"/proc
  mount -o bind /sys "${clonetargetdevice2}"/sys
  mount -o bind /dev "${clonetargetdevice2}"/dev

  chroot "${clonetargetdevice2}" $0 "---special-mode---" "${clonetargetdevice2}"

  sed -i -e "/#--specialclone-me--/d" "${clonetargetdevice2}"/boot/grub/device.map
  #sed -i -e "s/# (hd0)/(hd0)/" "${clonetargetdevice2}"/boot/grub/device.map
  echo "if you want to use device.map please type \"yes\" and edit it now"
  read shall_devicemap
  if [ "$shall_devicemap" = "yes" ]; then
    if ! ${EDITOR} "${clonetargetdevice2}"/boot/grub/device.map; then
      echo "Fall back to vi"
      vi "${clonetargetdevice2}"/boot/grub/device.map
    fi
  fi

  umount "${clonetargetdevice2}"/{proc,sys,dev}
}



installer_grub2(){
  echo "Install grub…"
  #clonetargetdevice because mounting isn't executed
  get_dev="$(grub-probe -t device -d "${clonetargetdevice}" | sed  -e "s|[0-9]*$||")"
  if ! grub-install "$get_dev";then
    echo "I fail please do it yourself"
    /bin/sh
  fi
  
  #get_part="$(grub-probe -t device ${clonetargetdevice2}" | sed "s/.\+([0-9]*)/${clonetargetdevice2}/")"
  grub-mkconfig -o /boot/grub/grub.cfg
  echo "grub installation finished. Beginn of the configuration of the new system"
  $config_new_sys
}

updater(){
  rsync -a -A --progress --delete --exclude "${clonesource2}"boot/grub/grub.cfg --exclude "${clonesource2}"boot/grub/device.map --exclude "${clonesource2}"etc/fstab --exclude "${syncdir}" --exclude "$clonetargetdevice2" --exclude "${clonesource2}home/*" --exclude "${clonesource2}"sys/ --exclude "${clonesource2}dev/*" --exclude "${clonesource2}proc/*" --exclude "${clonesource2}var/log/*" --exclude "${clonesource2}tmp/*" --exclude "${clonesource2}run/*" --exclude "${clonesource2}var/run/*" --exclude "${clonesource2}var/tmp/*" "${clonesource2}"* "${clonetargetdevice2}"
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
  umount "${clonetargetdevice2}"
  rmdir "${clonetargetdevice2}"
  umount "${clonesource2}"
  rmdir "${clonesource2}"
  rmdir "${syncdir}"
fi
