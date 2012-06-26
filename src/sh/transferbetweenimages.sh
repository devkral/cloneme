#! /bin/bash

#License: Do what you want with this script. But no warranty.
#be careful; this is a very hard topic. I won't use much safeguarding
transferscript="/sbin/cloneme.sh update"

if [ "$1" = "--help" ] || [ "$1" = "help" ];then
echo "Usage:"
echo "$0 [<path to transferscript> args… (src) (dest)]"
echo "Important: run as root"
exit 0
else
transferscript="$*"
fi

#check if runs with root permission
if [ ! "$UID" = "0" ]; then
  echo "error: needs root permissions"
  exit 1;
fi

mkdir -p /syncdir2/src
mkdir -p /syncdir2/dest

echo "enter path to source image"
read imagesource
losetup -f -P "$imagesource"
sleep 1;
temps=$(losetup -a | grep "$imagesource")
mounttemps=$(echo $temps | sed -e "s/:.*//")
if mountpoint /syncdir2/src &> /dev/null; then
echo "Abort: /syncdir2/src is already mounted"
exit 1
fi

echo "enter partitionnumber"
read partsource
if ! mount ${mounttemps}p${partsource} /syncdir2/src; then
# error message by mount itself
echo "Hint: have you restart the kernel after last update?"
exit 1
fi


echo "enter path to target image"
read imagesource
losetup -f -P "$imagedest"
sleep 1;
tempd=$(losetup -a | grep "$imagedest")
mounttempd=$(echo $tempd | sed -e "s/:.*//")
if mountpoint /syncdir2/dest &> /dev/null; then
echo "Abort: /syncdir2/dest is already mounted"
exit 1
fi

echo "enter partitionnumber"
read partdest
if ! mount ${mounttempd}p${partsource} /syncdir2/dest; then
# error message by mount itself
echo "Hint: have you restart the kernel after last update?"
exit 1
fi

$transferscript /syncdir2/src /syncdir2/dest




umount ${mounttemps}p${partsource}
losetup --detach ${mounttemps}
rmdir /syncdir2/src

umount ${mounttempd}p${partdest}
losetup --detach ${mounttempd}
rmdir /syncdir2/dest
rmdir /syncdir2
