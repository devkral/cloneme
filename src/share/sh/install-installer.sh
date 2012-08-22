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
  echo "usage: install-installer.sh <programdir/programfile> [linkdir] <targetsystem>"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
  usage
fi

#intern dependencies: install-installer-compiler.sh clonemecmd.sh

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

programdir="$(realpath "$1")"
if [ ! -d $programdir ]; then
  programdir="$(dirname "$programdir")"
fi


if [[ $# > 2 ]];then
  linkdir="$(realpath "$2")"
  targetdir="$(realpath "$3")"
else
  targetdir="$(realpath "$2")"
fi

mkdir -p "${targetdir}${programdir}" 2> /dev/null
mkdir -p "${targetdir}${sharedir}" 2> /dev/null
cp "$programdir"/clonemecmd.sh "${targetdir}${programdir}"
sed -i -e "s|.* #--replacepattern--|sharedir=\"${sharedir}\" #--replacepattern--|" "$targetdir$programdir"/clonemecmd.sh

if [ -e "$programdir"/cloneme ] && "${sharedir}"/sh/install-installer-compiler.sh "$(uname -m)" "$targetdir$programdir"/cloneme;then
  cp "$programdir"/cloneme "$targetdir$programdir"
fi

mkdir -p "$targetdir$share_dir" 2> /dev/null
if ! cp -r "$sharedir"/* "$targetdir$sharedir";then
  exit 1
fi

if [ "$linkdir" != "" ];then
  mkdir -p "$targetdir$linkdir" 2> /dev/null
  cp "$linkdir"/cloneme.desktop "$targetdir$linkdir"
fi


