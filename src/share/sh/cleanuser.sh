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
  echo "usage: cleanuser.sh <user> <targetsystem>"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" != "2" ] ;then
  usage
fi

#intern dependencies: -


#use readlink -f if realpath isn't available
if [ ! -e "/usr/bin/realpath" ];then
  realpath()
  {
    echo "$(readlink -f "$1")"
    exit 0;
  }
fi

usertemp="$1"
targetn="$(realpath "$2")"

if [ "$targetn" = "" ];then
  echo "targetsystem empty; break: to high risk to clean the user from the false system"
  exit 1
fi

echo "remove home directory…"
if [ -d "${targetn}"/home/"$usertemp" ];then
  rm -r "${targetn}"/home/"$usertemp"
fi
echo "finished"

if [ -e "${targetn}"/home/.ecryptfs/"$usertemp" ]; then
  echo "remove ecryptfs user files"
  rm -r "${targetn}"/home/.ecryptfs/"$usertemp"
fi

sed -i -e "/^${usertemp}/d" "${targetn}"/etc/passwd{?,""}
sed -i -e "/^${usertemp}/d" "${targetn}"/etc/group{?,""}
#never run such a command in passwd:
sed -i -e "s/\b${usertemp}\b//g" -e "s/,,\+/,/g" -e "s/: *,/:/g" -e "s/, *$//g" "${targetn}"/etc/group{?,""}
sed -i -e "/^${usertemp}/d" "${targetn}"/etc/{?,""}shadow{?,""}
sed -i -e "s/\b${usertemp}\b//g" -e "s/,,\+/,/g" -e "s/: *,/:/g" -e "s/, *$//g" "${targetn}"/etc/gshadow{?,""}


# and remove email folder
shred -u "${targetn}/var/spool/mail/${usertemp}" 2> /dev/null
echo "email box shredded"
