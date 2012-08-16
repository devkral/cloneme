#! /usr/bin/env bash

if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
echo "usage: umountsyncscript.sh <syncdir>"
exit 1
fi

#intern dependencies: umountscript.sh


sharedir="$(dirname "$(dirname "$(realpath "$0")")")"
syncdir="$(realpath "$1")"

"$sharedir"/sh/umountscript.sh rm "${syncdir}"/src

"$sharedir"/sh/umountscript.sh rm "${syncdir}"/dest


#delete if exist
if [ -d "${syncdir}" ]; then 
  rmdir "${syncdir}"
fi

