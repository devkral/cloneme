#! /bin/bash
#usage: devicefinder [options] <directory>


options=""

if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
  echo "usage: devicefinder [option] <directory>"
  echo "options:"
  echo "dev: print only block devices  (not e.g tmpfs) (checked by /dev)"
  echo "uuid: print the uuid of the device"
  echo "mount: print mountpoint"
  echo "all: print <device> <mountpoint> <uuid>"
  #echo "options separated by ,"
  exit 0
fi
case "$#" in
 1) dirtemp="$(realpath "${1}")";;
 2) options="$1"; dirtemp="$(realpath "${2}")" ;;
esac

case "$options" in
 "uuid") staticmounts="$(cat /proc/mounts | grep "^/dev")";;
 "dev") staticmounts="$(cat /proc/mounts | grep "^/dev")";;
 "mount") staticmounts="$(cat /proc/mounts | grep "^/dev")";;
 "all") staticmounts="$(cat /proc/mounts | grep "^/dev")";;
 *) staticmounts="$(cat /proc/mounts)" ;;
esac


lastresult=""

if [ ! -e "$dirtemp" ]; then
  echo "$dirtemp doesn\'t exist"
  exit 2
fi



for (( ; ; ))
do
#check if the goal is reached
  if dirtemp2="$(echo "$staticmounts" | grep "^[^ ]\+ $dirtemp ")"; then
    cleaned="$(echo "$dirtemp2" | sed "s/^\([^ ]\+\) .*/\1/")"
    UUID="$(lsblk --output UUID -n "$cleaned")"
    if [ "$options" = "uuid" ];then
      echo "$UUID"
      if [ "x$UUID" = "x" ];then
        exit 3
      fi
    elif [ "$options" = "mount" ]; then
      echo "$dirtemp"
      
    elif [ "$options" = "all" ]; then
      echo "$cleaned $dirtemp $UUID"
    else
      echo "$cleaned"
    fi
    
    exit 0
    break
  fi
  

  dirtemp="$(dirname "$dirtemp")"
#break endless loop
  if [ "$lastresult" = "$dirtemp" ];then
    echo "error: hangs at $dirtemp"
    exit 1
    break
  fi
  lastresult="$dirtemp"
done

