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

for copyfiledest in $(ls "${destsys}"/etc/{?,""}shadow{?,""}; ls "${destsys}"/etc/group{?,""})
do
  cp "${destsys}"/etc/"$copyfiledest" "${destsys}"/etc/"${copyfiledest}.oldrm"
done

for copyfilesrc in $(ls "${srcsys}"/etc/{?,""}shadow{?,""}; ls "${srcsys}"/etc/group{?,""})
do
  cp "${srcsys}"/etc/"$copyfiles" "${destsys}"/etc/"${copyfilesrc}"
  if [ -f "${destsys}"/etc/"${copyfilesrc}.oldrm" ]; then
    for destuser in $(ls /home/*)
    do
      # check if user is alread
      if ! grep "^$destuser" "${destsys}"/etc/"${copyfilesrc}"; then
        #should be just one line
        grep "^$destuser" "${destsys}"/etc/"${copyfilesrc}.oldrm" > "${destsys}"/etc/"${copyfilesrc}"
      fi
      if echo "${copyfilesrc}" | grep "group" > /dev/null || echo "${copyfilesrc}" | grep "gshadow" > /dev/null; then
        for curgroup in $(grep ":.*\b${usertemp}\b" "${destsys}"/etc/"${copyfilesrc}.oldrm" | sed -e "s/:.*//" | tr "\n" " " | sed -e "s/ $//")
        do
          sed -i -e "/${usertemp}/! s/^\($curgroup.*\)$/\1,${usertemp}/g" "${destsys}"/etc/"${copyfilesrc}"
        done
      fi
    done
  fi
  rm "${destsys}"/etc/"${copyfile}.oldrm"
done

