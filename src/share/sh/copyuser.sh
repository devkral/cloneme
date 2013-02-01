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
  echo "copyuser.sh <args…>"
  echo "--src <srcsystem> needed"
  echo "--dest <destsystem> needed"
  echo "--user <user> needed"
  echo "[--action <action>] not necessary"
  echo "actions:"
  echo "s: syncronize/transfer home folder"
  echo "e: Eradicate user files/Create empty user account (with the same password and permissions as the existing one)."
  echo "i: breaks loop"
  echo "c: clean dest system from user"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
  usage
fi
#intern dependencies: cleanuser.sh

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

srcsys="";
destsys="";
curuser="";
action="";
shall_exit=false;
while [ $# -gt 0 ]
do
  case "$1" in
   "--src")srcsys="$(realpath "$2")"; shift;;
    "--dest")destsys="$(realpath "$2")";shift;;
    "--user")curuser="$2";shift;;
    "--action")action="$2";shift;;
  esac
  shift
done

if [ "$srcsys" = "" ] || [ ! -e "$srcsys" ]; then
  echo "Error: no source system specified";
 shall_exit=true;
fi

if [ "$destsys" = "" ] || [ ! -e "$destsys" ]; then
  echo "Error: no destination system specified";
  shall_exit=true;
fi

if [ "$curuser" = "" ]; then
  echo "Error: no user specified";
  shall_exit=true;
fi

# exit if a needed arg wasn't specified elsewise echo choosen options
if [ $shall_exit = true ]; then
  exit 1
else
  echo "choosed options:"
  echo "$srcsys"
  echo "$destsys"
  echo "$curuser"
  echo "$action"
fi

for (( ; ; ))
do
  if [ "$action" = "" ];then
    echo "What shall be done with user ${curuser}?"
    if [ -d "${destsys}"/home/"${curuser}" ]; then
      if [ -d "${srcsys}"/home/"${curuser}" ]; then
        echo -e "Synchronize user account. Type \"s\""
      fi
      echo -e "Eradicate user files. Type \"e\""
      echo -e "Don't touch the user account. Type \"i\""
      echo -e "Clean target system from user account. Type \"c\""
    else
      if [ -d "${srcsys}"/home/"${curuser}" ]; then
        echo -e "Copy user account. Type \"s\""
        echo -e "Create empty user account (with the same password and permissions as the existing one). Type \"e\""
        echo -e "Go on without copying the user account. Type \"i\""
      else
        echo -e "Go on. Type \"i\""
      fi
      echo -e "Clean target system from the user. Type \"c\""
    fi
    
    read -n 1 answer_useracc
    # for newline
    echo ""
  else
    answer_useracc="$action"
  fi
  
  if [ "$answer_useracc" = "s" ]; then
    if ! rsync -a -A --progress --delete --exclude "${destsys}" "${srcsys}"/home/"${curuser}" "${destsys}"/home/ ;then
      echo "error: rsync could not sync"
      exit 1
    fi
    if [ -f "${srcsys}"/var/spool/mail/"${curuser}" ]; then
      rsync -a -A --delete "${srcsys}"/var/spool/mail/"${curuser}" "${destsys}"/var/spool/mail/
    fi
    if [ -e "${srcsys}"/home/.ecryptfs/"${curuser}" ]; then
      mkdir -p "${destsys}"/home/.ecryptfs/ 2> /dev/null
      rsync -a -A --delete "${srcsys}"/home/.ecryptfs/"${curuser}" "${destsys}"/home/.ecryptfs/
    fi
    
    break
  fi
  if [ "$answer_useracc" = "e" ]; then
    rm -r "${destsys}"/home/"${curuser}"
    mkdir -p "${destsys}"/home/"${curuser}"
    cp -R "${srcsys}"/etc/skel/* "${destsys}"/home/"${curuser}"
    #if destsys have already passwd file
    if [ ! -e "${destsys}"/etc/passwd ]; then
      echo "Debug: no passwd file available on destsys; use source sys instead"
      userid="$(sed "/^${curuser}/ s/^[^:]*:[^:]*:\([^:]*\):.*$/\1/g p" "${srcsys}"/etc/passwd 2> /dev/null)" 
      groupid="$(sed "/^${curuser}/ s/^[^:]*:[^:]*:\([^:]*\):.*$/\1/g p" "${srcsys}"/etc/group 2> /dev/null)" 
    else
      userid="$(sed "/^${curuser}/ s/^[^:]*:[^:]*:\([^:]*\):.*$/\1/g p" "${destsys}"/etc/passwd 2> /dev/null)" 
      groupid="$(sed "/^${curuser}/ s/^[^:]*:[^:]*:\([^:]*\):.*$/\1/g p" "${destsys}"/etc/group 2> /dev/null)"     
    fi
    
    if [[ "$userid" != "" ]] && [[ "$groupid" != "" ]]; then
      chown "${userid}:${groupid}" "${destsys}"/home/"${curuser}"
    elif [[ "$userid" != "" ]]; then
      chown "${userid}" "${destsys}"/home/"${curuser}"
    else
      echo "Error: no user id found"
    fi

    # and remove email folder
    shred -u "${destsys}/var/spool/mail/${curuser}" 2> /dev/null
    break
    # and remove ecryptfs user files if available
    if [ -e "${destsys}"/home/.ecryptfs/"${curuser}" ]; then
      rm -r "${destsys}"/home/.ecryptfs/"${curuser}"/.Private/*
    fi
    break
  fi

  if [ "$answer_useracc" = "i" ]; then
    break
  fi
  if [ "$answer_useracc" = "c" ]; then
    "${sharedir}"/sh/cleanuser.sh "${curuser}" "${destsys}"
    break
  fi
  
  #break loop if action is used
  if [ "$action" != "" ];then
    echo "error: specified action doesn't exist"
    exit 1;
  fi
done

