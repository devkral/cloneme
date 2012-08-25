#! /usr/bin/env bash

#
# Created by alex devkral@web.de
#
# Copyright (c) 2012
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# Neither the name of the project's author nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


usage()
{
  echo "usage: install-installer-compiler.sh <architecture against which is checked> <output>"
  echo "warning: cloneme specific"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
  usage
fi
#intern dependencies: src dir
#cloneme specific; doesn't work

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
if [ -d "$output" ]; then
  output="$output/cloneme"
fi
outputdir="$(dirname "$output")"

echo "check architecture…"
if [ "$(uname -m)" != "$architecture" ];then
  echo "false architecture. compile"
  cd "$sharedir/src"
  #safety guard: restrict to .cc .h
  compilefiles="$(ls ./*.{cc,h})"
  if ! g++ -o "$output" `pkg-config --libs --cflags vte-2.90 gtkmm-3.0` -std=c++0x -Wall \
	-DPACKAGE_DATA_DIR="\"${sharedir}\"" -DPACKAGE_BIN_DIR="\"$outputdir\"" -O2 $compilefiles; then
    echo "error"
    exit 1
  fi
fi

exit 0
