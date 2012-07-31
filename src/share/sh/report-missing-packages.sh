#! /bin/bash



#echo list of missing packages
#returns 0 if no compilation is needed
#returns 2 if compiled versiion has been installed

does_not_exist=false

#check if needed programs exists
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
