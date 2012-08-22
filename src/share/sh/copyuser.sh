#! /usr/bin/env bash

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

