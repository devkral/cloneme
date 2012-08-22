#! /usr/bin/env bash

usage()
{
  echo "usage: rsyncci.sh <args…>"
  echo "needed args:"
  echo "  --src <system copied from>"
  echo "  --dest <folder copied to>"
  echo "  --mode <mode which should be used> see mode section"
  echo ""
  echo "mode:"
  echo "  update: just sync and ask for each user which files should be copied"
  echo "  install: like update+fstab update and other things; see install section"
  echo ""
  echo "install:"
  echo "  --bootloader <target>: optional (default: none):"
  echo "      specify prog to install bootloader"
  # be careful: default bootloader needs installinstaller
  echo ""
  echo "  --editfstab <editor>: optional (default: skip):"
  echo "      edit fstab with editor"
  echo ""
  echo "general options:"
  echo "  --copyuser <target>: optional (default: copyuser.sh):"
  echo "    - specify program to copy users"
  echo "    - syntax of target program:"
  echo "        <target> --src <src> --dest <dest> --user <name>"
  echo ""
  echo "  --installinstaller <target> optional (default: skip):"
  echo "      use target prog to install installer"
  echo ""

  exit 1
}
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
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


mode=""
srcsys=""
destsys=""

copyusertarget="${sharedir}"/sh/copyuser.sh
editfstabtarget=""
installinstallertarget=""
#"$sharedir"/sh/install-installer.sh "$(dirname "$0")" "$(dirname "$sharedir")"/applications/cloneme.desktop "${clonedestdir}"
bootloadertarget=""

shall_exit=false

while [ $# -gt 0 ]
do
  case "$1" in
    "--mode")mode="$2";shift;;
    "--src")srcsys="$(realpath "$2")"; shift;;
    "--dest")destsys="$(realpath "$2")"; shift;;
    "--copyuser")copyusertarget="$(realpath "$2")"; shift;;
    "--editfstab")editfstabtarget="$(realpath "$2")"; shift;;
    "--installinstaller")installinstallertarget="$(realpath "$2")"; shift;;
    "--bootloader")bootloadertarget="$(realpath "$2")"; shift;;
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

if [ "$mode" = "" ]; then
  echo "Error: no mode is specified";
  shall_exit=true;
fi


# exit if a needed arg wasn't specified elsewise echo choosen options
if [ $shall_exit = true ]; then
  exit 1
else
  echo "choosed options"
  echo "$mode"
  echo "$srcsys"
  echo "$destsys"
  echo ""
  echo "$copyusertarget"
  echo "$editfstabtarget"
  echo "$installinstallertarget"
  echo "$bootloadertarget"
fi

#src end slash less
srcsl="$(echo "$srcsys" | sed "s|/$||")"

copyuser()
{
  local usertemp
  for usertemp in $(ls "${srcsys}"/home)
  do
    eval "$copyuserpath --src ${srcsys} --dest ${destsys} --user ${usertemp}"
  done
}

updater()
{
  if ! rsync -a -A --progress --delete --exclude "${srcsl}/run/*" --exclude "${srcsl}/"boot/grub/grub.cfg --exclude "${srcsl}"/boot/grub/device.map --exclude "${srcsl}"/etc/fstab --exclude "${dest}" --exclude "${srcsl}/home/*" --exclude "${srcsl}/sys/*" --exclude "${srcsl}/dev/*" --exclude "${srcsl}/proc/*" --exclude "${srcsl}/var/log/*" --exclude "${srcsl}/tmp/*" --exclude "${srcsl}/run/*" --exclude "${srcsl}/var/run/*" --exclude "${srcsl}/var/tmp/*" "${srcsl}"/* "${destsys}" ; then
    echo "error: rsync could not sync"
    exit 1
  fi
  copyuser
  if [ -n "$installinstallertarget" ]; then
    eval "$installinstallertarget"
  fi
  if [ -n "$bootloadertarget" ]; then
    eval "$bootloadertarget $destsys"
  fi
}

installer()
{
  if ! rsync -a -A --progress --delete --exclude "${srcsl}/run/*" --exclude "${srcsl}/"boot/grub/grub.cfg --exclude "${srcsl}/"boot/grub/device.map --exclude "${dest}" --exclude "${srcsl}/home/*" --exclude "${srcsl}/sys/*" --exclude "${srcsl}/dev/*" --exclude "${srcsl}/proc/*" --exclude "${srcsl}/var/log/*" --exclude "${srcsl}/tmp/*" --exclude "${srcsl}/run/*" --exclude "${srcsl}/var/run/*" --exclude "${srcsl}/var/tmp/*" "${srcsl}"/* "${destsys}" ;then
    echo "error: rsync could not sync"
    exit 1
  fi
  if [ -f "${dest}"/etc/fstab ];then
    local tempprobefstab="$("$sharedir"/sh/devicefinder.sh uuid "${destsys}")"
    local tempsed="$(sed -e "s/.\+\( \/ .\+\)/UUID=${tempprobe}\1/" "${destsys}"/etc/fstab)"
    echo "$tempsed" > "${destsys}"/etc/fstab
    echo "root in fstab updated"
    if [ -n "$editfstabtarget" ]; then
      echo "Open fstab with $editfstabtarget"
      eval "$editfstabtarget" "${destsys}"/etc/fstab
    fi
  else
    echo "no fstab found"
    exit 1
  fi
  copyuser
  if [ "$installinstallertarget" != "" ]; then
    eval "$installinstallertarget"
  fi

  if [ "$bootloadertarget" != "" ]; then
    eval "$bootloadertarget $destsys"
  fi
}

if [ "$mode" = "install" ];then
  installer
fi

if [ "$mode" = "update" ];then
  updater
fi

#exit 0
