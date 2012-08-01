#! /bin/sh

#usage: install-installer-compiler.sh <architecture> <output>
#returns: 0 copy it yourself
#         2 compiled


sharedir="$(dirname "$(dirname "$(realpath "$0")")")"

architecture="$1"
output="$2"



if [ "$(uname -m)" != "$architecture" ];then
  #cd "$sharedir/src"
  #gcc -o "$output" main.cc `pkg-config --libs --cflags vte-2.90,gtkmm-3.0`
  return 2
fi
