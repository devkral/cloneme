#! /usr/bin/env bash

#backup
#program <mode> <drive(/dev/sdX)> <syncdir>



#intern dependencies: umountscript.sh

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



drive="$2"


backup()
{
count=1

while [[ -e "${drive}${count}" ]];
do
"$sharedir"/sh/mountscript.sh "${drive}${count}" "$syncdir"/tmpmount
if ls "$syncdir"/tmpmount/ > /dev/null; then
  mkdir -p "$syncdir"/transferdir/"$(basename "${drive}${count}")"
  rsync -a -A --progress --delete "$syncdir"/tmpmount "$syncdir"/transferdir/"$(basename "${drive}${count}")"


fi

"$sharedir"/sh/umountscript.sh n "$syncdir"/tmpmount
((count=count+1))
done
}

#FIXME: fragezeichen = false
if [ "$fragezeichen" = "restore" ]; then
  mkdir -p "$syncdir"/dest/backup
  rsync -a -A --progress --delete "$syncdir"/transferdir "$syncdir"/dest/backupoldfiles
fi

