#! /usr/bin/env bash

usage()
{
  echo "usage: report-missing-packages.sh"
  echo "echo list of missing packages"
  echo "exit 2 if a package is missing"
  echo "exit 1 if help is opened"
  echo "exit 0 if no package is missing"
  
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" != "0" ] ;then
  usage
fi
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

#if [ ! -e "/usr/bin/dd" ] && [ ! -e "/bin/dd" ]; then
#  echo "coreutils"
#  does_not_exist=true
#fi

if [ ! -e "/sbin/losetup" ] && [ ! -e "/usr/bin/losetup" ]; then
  echo "losetup"
fi
