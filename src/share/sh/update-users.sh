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

srcsys="$(realpath "$1")"
destsys="$(realpath "$2")"


#must run before preploopdest because these files are needed and proceeding without them makes no sense
preploopsrc="$(basename -a  "${srcsys}"/etc/{?,""}shadow "${srcsys}"/etc/group "${srcsys}"/etc/passwd 2> /dev/null | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\" \"/g')"
if [ "$preploopsrc" = "" ]; then
  echo "\'${srcsys}\'̣’s etc folder contains no password files"
  exit 1
fi

preploopdest="$(basename -a  "${destsys}"/etc/{?,""}shadow "${destsys}"/etc/group "${destsys}"/etc/passwd 2> /dev/null | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\" \"/g')"

prepdestuser="\"$(basename -a  "${destsys}"/home/* 2> /dev/null | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\" \"/g')\""


#must run before copysrc loop (backups files)
if [ "$preploopdest" != "\"\"\"\"" ]; then
  for copyfiledest in $preploopdest
  do
    cp "${destsys}"/etc/"$copyfiledest" "${destsys}"/etc/"${copyfiledest}.oldrm"
  done
fi


for copyfilesrc in $preploopsrc
do
  cp "${srcsys}"/etc/"$copyfilesrc" "${destsys}"/etc/
  if [ -f "${destsys}"/etc/"${copyfilesrc}.oldrm" ] && [ "$prepdestuser" != "\"\"" ]; then
    for destuser in $prepdestuser
    do
      # check if user is already in file
      if ! grep "^$destuser" "${destsys}"/etc/"${copyfilesrc}"; then
        #should be just one line
        grep "^$destuser" "${destsys}"/etc/"${copyfilesrc}.oldrm" > "${destsys}"/etc/"${copyfilesrc}"
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
  rm "${destsys}"/etc/"${copyfilesrc}.oldrm"
done

