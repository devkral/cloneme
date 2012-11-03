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
  echo "usage: useraddroot.sh <destsys> <groups(commaseparated)> <user>"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" != "3" ] ;then
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

if [ "$1" = "/" ]; then
  destsys=""
else
  destsys="$(realpath "$1")"
fi
if [ ! -e "$destsys" ]; then
  echo "Error: $destsys doesn't exist"
  exit 1
fi

ugroups="$2"
#check groups:
if echo "$ugroups" | grep -o "^," || echo "$ugroups" | grep -o ",$" || echo "$ugroups" | grep -o ",," || echo "$ugroups" | grep -o ";" || echo "$ugroups" | grep -o ":"; then
  echo "Groups contain invalid element. Abort!"
  echo "$ugroups"
  exit 1
fi
uname="$3"

#update files (shadow, passwd, gshadow, group)
update_files()
{
  echo "${uname}::0:0:99999:7:::" >> "$destsys"/etc/shadow
  echo "${uname}:x::${ugroups}" >> "$destsys"/etc/gshadow
  counter=1000
  while grep ":${counter}:" "$destsys"/etc/passwd > /dev/null 2> /dev/null && grep ":${counter}:" "$destsys"/etc/group > /dev/null  2> /dev/null
  do
    ((counter+=1))
  done
  echo "${uname}:x:${counter}:${counter}:${uname}:/home/${uname}:/bin/bash" >> "$destsys"/etc/passwd
  echo "${uname}:x:${counter}:${ugroups}" >> "$destsys"/etc/group
}



if [ -e "$destsys"/etc/shadow ] && [ -e "$destsys"/etc/passwd ] && [ -e "$destsys"/etc/gshadow ] && [ -e "$destsys"/etc/group ]; then
  if grep "^${uname}:" "$destsys"/etc/shadow > /dev/null && grep "^${uname}:" "$destsys"/etc/passwd > /dev/null &&  grep "^${uname}:" "$destsys"/etc/group > /dev/null && grep "^${uname}:" "$destsys"/etc/gshadow > /dev/null; then
    echo "error: user (or a group with similar name) already exists"
  else
    update_files
  fi
else
  echo "Debug: /etc/shadow, /etc/gshadow, /etc/passwd and/or /etc/group doesn't exist"
  if [ ! -e "$destsys/etc/" ]; then
    echo "Debug: create /etc directory"
    if ! mkdir "$destsys/etc/"; then
      exit 1
    fi
  fi
  
  update_files
fi

#create an home directory when it doesn't exist
if [ -e "$destsys/home/${uname}" ]; then
  echo "Debug: home directory already exists"
else
  if [ ! -e "$destsys/home/" ]; then
    echo "Debug: create /home directory"
    if ! mkdir "$destsys/home/"; then
      exit 1
    fi
  fi
  if ! cp -r "$destsys/etc/skel" "$destsys/home/${uname}"; then
    exit 1
  fi
fi

exit 0
