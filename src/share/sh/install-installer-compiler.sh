#! /bin/sh

#usage: install-installer-compiler.sh <architecture> <output>
#returns: 0 copy it yourself
#         2 compiled


sharedir="$(dirname "$(dirname "$(realpath "$0")")")"

architecture="$1"
output="$(realpath "$2")"

if [ "$(uname -m)" != "$architecture" ];then
  cd "$sharedir/src"
  #TODO: add missing options so it works 
  if ! gcc -o "$output" `pkg-config --libs --cflags vte-2.90 gtkmm-3.0` -std=gnu++11 -Wall -DPACKAGE_DATA_DIR="\"${sharedir}\"" ./main.cc; then
    
    exit 1
  fi
  
  exit 2
fi

exit 0
