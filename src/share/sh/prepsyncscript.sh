#! /usr/bin/env bash

usage()
{
  echo "usage: prepsyncscript.sh <syncdir>"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
  usage
fi
#intern dependencies: -

#dir where sync folder are located
syncdir="$(realpath "$1")"

mkdir -p "${syncdir}"/src

mkdir -p "${syncdir}"/dest


