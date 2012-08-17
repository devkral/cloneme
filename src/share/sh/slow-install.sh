#!/bin/bash

if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
echo "usage: slow-install.sh <src> <dest>"
echo "src/dest can be a blockdevice or a raw file"
echo "dest mustn't exist but the dir within it is written"
exit 1
fi


source="$1"
dest="$2"

if [ ! -f "$source" ] && [ ! -b "$source" ]; then
echo "source not recognized"
exit 1
fi

dd if="$source" of="$dest" bs=8M conv=fsync
