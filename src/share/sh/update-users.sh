#! /usr/bin/env bash

usage()
{
echo "usage: update-users <src> <dest>"
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

#because some oudated popular linux distros haven't the -a switch
#basenamea path1 path2…
basenamea()
{
  for currrentpath in "$@"
  do
    if [ -e "$currrentpath" ]; then
      basename "$currrentpath"
    fi
  done
}

echo "update user password files…"

srcsys="$(realpath "$1")"
destsys="$(realpath "$2")"

#must run before preploopdest because these files are needed and proceeding without them makes no sense
preploopsrc="$(basenamea  "${srcsys}"/etc/{?,""}shadow "${srcsys}"/etc/group "${srcsys}"/etc/passwd 2> /dev/null | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g')"
if [ "$preploopsrc" = "" ]; then
  echo -e "\"${srcsys}\"’s etc folder contains no password files\n"
  exit 1
fi

preploopdest="$(basenamea  "${destsys}"/etc/?shadow "${destsys}"/etc/shadow "${destsys}"/etc/group "${destsys}"/etc/passwd 2> /dev/null | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g')"

prepdestuser="\"$(basename -a  "${destsys}"/home/* 2> /dev/null | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\" \"/g')\""


for copyfilesrc in $preploopsrc
do
  #copy
  #use relaxed attributes, which need to be enforced for secret files like shadow
  install -b -S .oldrm -g 0 -o 0 -m 755 "${srcsys}"/etc/"$copyfilesrc" "${destsys}"/etc/
  if [ -f "${destsys}"/etc/"${copyfilesrc}.oldrm" ] && [ "$prepdestuser" != "" ]; then
    for destuser in $prepdestuser
    do
      # check if user is already in file
      #should be just one match
      if ! grep "^$destuser" "${destsys}"/etc/"${copyfilesrc}"; then
        #should be just one match
        grep "^$destuser" "${destsys}"/etc/"${copyfilesrc}.oldrm" >> "${destsys}"/etc/"${copyfilesrc}" 2> /dev/null
      fi
      if echo "${copyfilesrc}" | grep "group" > /dev/null || echo "${copyfilesrc}" | grep "gshadow" > /dev/null; then
      #not saved via \" but should work anyway
        for curgroup in $(grep ":.*\b${destuser}\b" "${destsys}"/etc/"${copyfilesrc}.oldrm" | sed -e "s/:.*//" | tr "\n" " " | sed -e "s/ $//")
        do
          sed -i -e "/${destuser}/! s/^\($curgroup.*\)$/\1,${destuser}/g" "${destsys}"/etc/"${copyfilesrc}"
        done
      fi
  
    done
  fi
  #fix permissions  copyfilesrc is ok
  if echo "${copyfilesrc}" | grep -q "shadow"; then
    chmod 700 "${destsys}"/etc/"${copyfilesrc}"
  fi
  
  rm "${destsys}"/etc/"${copyfilesrc}.oldrm" 2> /dev/null
done
echo "update-users.sh: finished"
