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
  echo "usage: backuprestore <mode> <path to disk> <syncdir>"
  echo "modes:"
  echo "format: execute format disk dialog"
  echo "analyse: check if filesystem, return 0 if is filesystem"
  echo ""
  echo ""
  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] ;then
  usage
fi
#intern dependencies: backuprestore.sh

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


drive="$(realpath "$2")"


checkfilesystem()
{
  if blkid -p -u filesystem "$drive" > /dev/null; then
    return 0
  else
    return 2
  fi
}

backupdestroypartitions()
{
	if echo "$1" | grep "^[0-9]\+$"; then
	  begin=$1
	else
	  begin=0
	fi
	
	if echo "$2" | grep "^[0-9]\+$"; then
	  end="$2"
	else
	  counter2=$begin
	  while [ -b "${drive}/${counter2}" ];
	  do
	    ((counter2=${counter2}+1))
	  done
	  ((end=$counter2-1))
	fi
	
	count="$begin"
	while [[ "$begin" -le "$end" ];
	do
	  "$sharedir"/sh/backuprestore.sh "backup" "${drive}/${count}" "$syncdir"
	  if [ "$?" = "" ]; then
	    echo "Error: backup over softlimit. Should I continue? Type yes elsewise I skip."
	    read quser1
	    if [[ "$quser1" = "yes" ]] || [[ "$quser1" = "y" ]] [[ "$quser1" = "y" ]]; then 
	      "$sharedir"/sh/backuprestore.sh "backup-ignore-sl" "${drive}/${count}" "$syncdir"
	    fi
	  fi
	  if [ "$?" = "" ]; then
	    echo "Error: couldn't backup. Should I continue? Type \"YES\" uppercase elsewise I stop."
	    read quser
	    if [[ "$quser" != "YES" ]];then
	      exit 1	      
	    fi
	  fi
	  
	  parted "${drive}" rm "${count}"
	  ((count=$count+1))
	done 
	
	
}

formatdrive()
{
if checkfilesystem; then
  return 1
else
  echo -e "Available Partitions:"
  parted "$drive" print free
  
  echo "For manual partitioning (without backup) press \"M\""
  echo "Elsewise enter a partionnumber (partition content will be backuped)"
  echo "If you wish to specify a range in which the partitions are overwritten enter two partition numbers"
  echo "If you wish to use the whole disk, enter \"all\""
  local uinput
  read uinput
  if [[ "$uinput" = "M" ]]; then
    parted "$drive"
  elif [[ "$uinput" = "all" ]]; then
    for 
  
  elif echo "$uinput" | grep -q "^[0-9]\+ [0-9]\+$" ; then
    
  elif echo "$uinput" | grep -q "^[0-9]\+$"; then
    
  else
    return $(formatdrive)
  fi
  
  
  return 0
}

if [[ "$mode" = "analyse" ]]; then
  exit $(checkfilesystem)
elif [[ "$mode" = "format" ]]; then
  exit $(formatdrive)

fi
