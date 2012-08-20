#! /usr/bin/env bash

usage()
{
  echo "usage: grub-installer_phase_1.sh <targetsystem> [command for sysconfig like adding users] [ args ] (currently just one)"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
  usage
fi

#intern dependencies: grub-installer_phase_2.sh
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
clonetargetdir="$(realpath "$1")"

if [ -e "${clonetargetdir}"/boot/grub/device.map ];then
  tempdev="$(sed -e "s/\((hd0)\)/# \1/" "${clonetargetdir}"/boot/grub/device.map)"
  echo "$tempdev" > "${clonetargetdir}"/boot/grub/device.map
  sed -i -e "/#--specialclone-me--/d" "${clonetargetdir}"/boot/grub/device.map
fi

echo "some temporary adjustments to ${clonetargetdir}/boot/grub/device.map"
mkdir -p "${clonetargetdir}"/boot/grub/
tempprobegrub="$("$sharedir"/sh/devicefinder.sh dev "${clonetargetdir}" | sed -e "s|[0-9]*$||")"
echo "(hd0) ${tempprobegrub} #--specialclone-me--" >> "${clonetargetdir}"/boot/grub/device.map
echo "finished"

# display can be opened with tmp and run
if [ $# -gt 1 ];then
  chroot "${clonetargetdir}" "$sharedir"/sh/grub-installer_phase_2.sh
else
  chroot "${clonetargetdir}" "$sharedir"/sh/grub-installer_phase_2 "$2" "$3"
fi
echo "back from chroot"
tempsed=$(sed -e "/#--specialclone-me--/d" "${clonetargetdir}"/boot/grub/device.map)
echo "$tempsed" > "${clonetargetdir}"/boot/grub/device.map
#sed -i -e "s/# (hd0)/(hd0)/" "${clonetargetdir}"/boot/grub/device.map
echo "device.map cleaned"
if [ "$cloneme_ui_mode" = "false" ];then
  echo "if you want to use device.map please type \"yes\" and edit it now"
  read shall_devicemap
  if [ "$shall_devicemap" = "yes" ]; then
    if ! ${EDITOR} "${clonetargetdir}"/boot/grub/device.map; then
      echo "Fall back to vi"
      vi "${clonetargetdir}"/boot/grub/device.map
    fi
  fi
fi
