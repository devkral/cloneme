#! /usr/bin/env bash

#echo list of missing packages
#intern dependencies: -


does_not_exist=false

#check if needed programs exists

if [ ! -e "/bin/mountpoint" ] && [ ! -e "/usr/bin/mountpoint" ] && [ ! -e "/bin/mount" ] && [ ! -e "/usr/bin/mount" ]; then
  echo "util-linux"
  does_not_exist=true
fi

if [ ! -e "/usr/bin/rsync" ] && [ ! -e "/usr/sbin/rsync" ]; then
  echo "rsync"
  does_not_exist=true
fi

if [ ! -e "/usr/bin/realpath" ]; then
  echo "coreutils"
  does_not_exist=true
fi


if [ ! -e "/sbin/losetup" ] && [ ! -e "/usr/bin/losetup" ]; then
  echo "losetup"
fi
