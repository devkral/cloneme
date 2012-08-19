#! /usr/bin/env bash

usage()
{
  echo "usage: prepsyncscript.sh <syncdir>"
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

syncdir="$(realpath "$1")"

mkdir -p "${syncdir}"/src

mkdir -p "${syncdir}"/dest


