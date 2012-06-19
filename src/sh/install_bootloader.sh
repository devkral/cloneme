#! /bin/bash
bootloader="$1"
clonetargetdevice="$2"
#TODO: move out /bin/sh

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
if [ "$bootloader" = grub2 ];then
  installer_grub2
fi
