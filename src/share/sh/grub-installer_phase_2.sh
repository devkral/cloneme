#! /usr/bin/env bash

usage()
{
  echo "don't use directly!!!"
  echo "usage: grub-installer_phase_2.sh [command for sysconfig like adding users] [ args ] (currently just one)"
  echo ""
  echo "the used grub-probe can lead to a kill of an usb memory stick (some models?)"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
  usage
fi


#
#

#intern dependencies: addnewusers.sh

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
#the command which configures the target system
if [ "x$1" = "x" ]; then
  config_new_sys="${sharedir}/sh/addnewusers.sh"
else
  config_new_sys="$1"
fi

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
"$config_new_sys" "$2"
