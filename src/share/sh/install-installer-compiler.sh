#! /usr/bin/env bash

usage()
{
  echo "usage: install-installer-compiler.sh <architecture> <output>"
  echo "returns: 0 copy it yourself"
  echo "         2 compiled"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
  usage
fi

#intern dependencies: src dir

#use readlink -f if realpath isn't available
if [ ! -e "/usr/bin/realpath" ];then
  realpath()
  {
    echo "$(readlink -f "$1")"
    exit 0;
  }
fi
#dir where the cloneme files are located
sharedir="$(dirname "$(dirname "$(realpath "$0")")")"

architecture="$1"
output="$(realpath "$2")"
outputdir="$(dirname "$output")"

if [ "$(uname -m)" != "$architecture" ];then
  cd "$sharedir/src"
  #safety guard: restrict to .cc .h
  compilefiles="$(ls ./*.{cc,h})"
  if ! g++ -o "$output" `pkg-config --libs --cflags vte-2.90 gtkmm-3.0` -std=c++11 -Wall \
	-DPACKAGE_DATA_DIR="\"${sharedir}\"" -DPACKAGE_BIN_DIR="\"$outputdir\"" -O2 $compilefiles; then
    exit 1
  fi
  
  exit 2
fi

exit 0
