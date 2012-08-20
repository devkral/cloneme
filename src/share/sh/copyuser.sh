#! /usr/bin/env bash

usage()
{
  echo "copyuser.sh <srcsystem> <destsystem> <user> [action]"
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
srcsys="$(realpath "$1")"
destsys="$(realpath "$2")"
curuser="$3"
action="$4"



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
      fi
      echo -e "Create empty user account (with the same password and permissions as the existing one). Type \"e\""
      if [ -d "${srcsys}"/home/"${curuser}" ]; then
        echo -e "Go on without copying the user account. Type \"i\""  
      else
        echo -e "Go on. Type \"i\""
      fi
      echo -e "Clean target system from the user. Type \"c\""
    fi
    
    read -n 1 answer_useracc
  else
    answer_useracc="$action"
  fi
  
  if [ "$answer_useracc" = "s" ]; then
    if ! rsync -a -A --progress --delete --exclude "${destsys}" "${srcsys}"/home/"${curuser}" "${destsys}"/home/ ;then
      echo "error: rsync could not sync"
      exit 1
    fi  
    break
  fi
  if [ "$answer_useracc" = "e" ]; then
    rm -r "${destsys}"/home/"${curuser}"
    mkdir -p "${destsys}"/home/"${curuser}"
    #
    if grep "${curuser}" "${srcsys}"/etc/passwd > /dev/null;then
      chown "${curuser}" "${destsys}"/home/"${curuser}"
      #chown group
      if grep "${curuser}" "${srcsys}"/etc/group > /dev/null;then
        chown "${curuser}:${curuser}" "${destsys}"/home/"${curuser}"
      fi
    fi
    # and remove email folder
    shred -u "${destsys}/var/spool/mail/${curuser}" 2> /dev/null
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
