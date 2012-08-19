#! /usr/bin/env bash

usage()
  echo "usage: dd-install.sh <src> <dest>"
  echo "src/dest can be a blockdevice or a raw file"
  echo "dest mustn't exist but the dir within it is written"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
  usage
fi
#intern dependencies: -
#this script isn't in use yet maybe it will be an alternative option to rsync


source="$1"
dest="$2"

if [ ! -f "$source" ] && [ ! -b "$source" ]; then
echo "source not recognized"
exit 1
fi

dd if="$source" of="$dest" bs=8M conv=fsync
