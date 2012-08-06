#! /bin/sh

#usage: install-installer-compiler.sh <architecture> <output>
#returns: 0 copy it yourself
#         2 compiled


sharedir="$(dirname "$(dirname "$(realpath "$0")")")"

architecture="$1"
output="$(realpath "$2")"
outputdir="$(dirname "$output")"

if [ "$(uname -m)" != "$architecture" ];then
  cd "$sharedir/src"
  compilefiles="$(ls ./)"
  #TODO: add missing options so it works 
  if ! g++ -o "$output" `pkg-config --libs --cflags vte-2.90 gtkmm-3.0` -std=gnu++11 -Wall \
	-DPACKAGE_DATA_DIR="\"${sharedir}\"" -DPACKAGE_BIN_DIR="\"$outputdir\"" -g -O2 $compilefiles; then
    
    exit 1
  fi
  
  exit 2
fi

exit 0
