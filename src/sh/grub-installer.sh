#! /bin/bash

#dir where the cloneme files are located
share_dir="$(dirname "$(dirname "$(realpath "$0")")")"
#the command which configures the target system
config_new_sys="${share_dir}/sh/addnewusers.sh"


echo "Install grub…"
  #/ is clonetargetdir
  get_dev="$(grub-probe -t device "/" | sed  -e "s|[0-9]*$||")"
if ! grub-install "${get_dev}";then
  echo "Error: ${get_dev} not found"
  echo "I failed please do it yourself or type \"exit\" and press <enter> to escape"
  /bin/sh
fi
  
grub-mkconfig -o /boot/grub/grub.cfg
echo -e "grub installation finished.\nStart with the configuration of the new system"
"$config_new_sys"
