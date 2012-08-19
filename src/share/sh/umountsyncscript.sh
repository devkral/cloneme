#! /usr/bin/env bash

usage()
{
  echo "usage: umountsyncscript.sh <syncdir>"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
  usage
fi
#intern dependencies: umountscript.sh

#use readlink -f if realpath isn't available
if [ ! -e "/usr/bin/realpath" ];then
  realpath()
  {
    echo "$(readlink -f "$1")"
    exit 0;
  }
fi

sharedir="$(dirname "$(dirname "$(realpath "$0")")")"
syncdir="$(realpath "$1")"

"$sharedir"/sh/umountscript.sh rm "${syncdir}"/src

"$sharedir"/sh/umountscript.sh rm "${syncdir}"/dest


#delete if exist
if [ -d "${syncdir}" ]; then 
  rmdir "${syncdir}"
fi

