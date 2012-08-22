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


if [ ! -f "$sharedir/sh/grub-installer_phase_2.sh" ]; then
  echo "In target sys grub-installer_phase_2.sh isn't available"
  echo "run install-installer first"
  echo "Abort!"
  exit 1
fi

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



mount -o bind /proc "${clonedestdir}"/proc
mount -o bind /sys "${clonedestdir}"/sys
mount -o bind /dev "${clonedestdir}"/dev

# display can be opened with tmp and run
mount -o bind /tmp "${clonedestdir}"/tmp
mount -o bind /run "${clonedestdir}"/run
shift # currently just one arg which must vanish
chroot "${clonetargetdir}" "$sharedir"/sh/grub-installer_phase_2.sh "$@"
echo "back from chroot"
umount "${clonedestdir}"/{tmp,run,proc,sys,dev}
echo "mounts cleaned up"

tempsed=$(sed -e "/#--specialclone-me--/d" "${clonetargetdir}"/boot/grub/device.map)
echo "$tempsed" > "${clonetargetdir}"/boot/grub/device.map
#sed -i -e "s/# (hd0)/(hd0)/" "${clonetargetdir}"/boot/grub/device.map
echo "device.map cleaned"
