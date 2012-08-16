#! /usr/bin/env bash

if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
echo "usage: prepsyncscript.sh <syncdir>"
exit 1
fi

#intern dependencies: umountscript.sh


syncdir="$(realpath "$1")"

mkdir -p "${syncdir}"/src

mkdir -p "${syncdir}"/dest


