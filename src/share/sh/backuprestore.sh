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

#backup
#program <mode> <partition> <syncdir>
options=""
softlimit=10  #values in percent

usage()
{
  echo "usage: backuprestore <mode> [<path to partition>] <syncdir>"
  echo "modes:"
  echo "backup: backup files, use partitionname for identification"
  echo "backup-ignore-sl: same as backup but ignore soft limit"
  echo "restore: rsync files to syncdir/dest/backup"
  echo ""
  echo "exit 2, when too less space"
  echo "exit 3, when backuped files maybe are too big and manual intervention is needed"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] ;then
  usage
fi
#intern dependencies: umountscript.sh mountscript

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


mode="$1"


partition_path="$(realpath "$2")"
partition="$(basename "$partition_path")"


backup()
{
"$sharedir"/sh/mountscript.sh "${partition_path}" "$syncdir"/tmpmount
if ls "$syncdir"/tmpmount/ > /dev/null; then
  if [[ "${mode}" != "backup-ignore-sl" ]] && [[ "$(((100-($(stat --file-system -c%f "$syncdir/tmpmount")*100 / $(stat --file-system -c%b "$syncdir/tmpmount"))))" -gt "$softlimit" ]]; then
    echo "Debug: over softlimit; exit"
    exit 3
  
  fi
  mkdir -p "$syncdir"/transferdir/"${partition}"
  rsync -a -A --progress --delete "$syncdir"/tmpmount "$syncdir"/transferdir/"${partition}"
  

fi

"$sharedir"/sh/umountscript.sh n "$syncdir"/tmpmount
}

restore()
{
  mkdir -p "$syncdir"/dest/backupoldfiles
  rsync -a -A --progress --delete "$syncdir"/transferdir "$syncdir"/dest/backupoldfiles
}

if [[ "${mode}" = "backup" ]] && [[ "$#" = "3" ]]; then
  backup
elif [[ "${mode}" = "backup-ignore-sl" ]] && [[ "$#" = "3" ]]; then
  backup
elif [[ "${mode}" = "restore" ]] && [[ "$#" -ge "2" ]]; then
  restore
else
  usage
fi
