#! /usr/bin/env bash

if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$#" = "0" ] ;then
echo "usage: groupexist.sh group1 group2 …"
echo "returns all existing groups (which are specified via args) commaseparated"
echo "exit 2 if a group doesn't exist; exit 0 when every group exist"
exit 1
fi
#intern dependencies: -


missing_group=false
existing_groups=""

for curgroup in "$@"
do
  if grep -e "$curgroup" /etc/group > /dev/null; then
    existing_groups="$existing_groups$curgroup,"
  else
    missing_group=true
  fi
done

echo "$existing_groups" | sed "s/,$//"

if [ $missing_group = true ];then
  exit 2
else
  exit 0
fi

