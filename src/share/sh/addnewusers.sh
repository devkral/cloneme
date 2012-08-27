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
  echo "usage: addnewuser.sh <destsys>"
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" != "1" ] ;then
  usage
fi

#intern dependencies: groupexist.sh

#use readlink -f if realpath isn't available
if [ ! -e "/usr/bin/realpath" ];then
  realpath()
  {
    echo "$(readlink -f "$1")"
    exit 0;
  }
fi

destsys="$(realpath "$1")"

#dir where the cloneme files are located
sharedir="$(dirname "$(dirname "$(realpath "$0")")")"

#default groups of new users
usergroup="video audio optical power"
admingroup="wheel adm admin"


usergroupargs="$("${sharedir}"/sh/groupexist.sh $usergroup)"
usercounter=0
for (( ; ; ))
do
  if [ ${usercounter} = 0 ];then
    usercounter=1;
    echo "Create new user? [yes/no]"
  else
    echo "Create another new user? [yes/no]"
  fi
  read n_user
  if [ "$n_user" = "yes" ];then
    echo "Enter user name"
    read user_name;
    echo "Shall this user account have admin (can change to root) permissions? [yes] default: no"
    read admin_perm
    if [ "$admin_perm" = "yes" ];then
      usergroupargs+="$usergroupargs,$("${sharedir}"/sh/groupexist.sh $admingroup)"
    fi
    useradd -m -U "$user_name" -p "" -R "$destsys" -G "$usergroupargs"
    passwd -R "$destsys" -e "$user_name"
  fi
  if [ "$n_user" = "no" ];then
    break
  fi
done
