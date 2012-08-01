#! /bin/sh

#usage: cleanuser.sh <user> <targetsystem>

usertemp="$1"
targetn="$(realpath "$2")"
if [ "$targetn" = "" ];then
  echo "targetsystem empty; break: to high risk to clean the user from the false system"
  exit 1
fi

if [ -e "$targetn"/"$usertemp" ];then
  rm -r "$targetn"/"$usertemp"
fi


sed -i -e "/^${usertemp}/d" "${targetn}"/etc/passwd
sed -i -e "/^${usertemp}/d" "${targetn}"/etc/passwd-
sed -i -e "/^${usertemp}/d" "${targetn}"/etc/group
sed -i -e "s/\b${usertemp}\b//g" "${targetn}"/etc/group
sed -i -e "/^${usertemp}/d" "${targetn}"/etc/group-
sed -i -e "s/\b${usertemp}\b//g" "${targetn}"/etc/group-
sed -i -e "/^${usertemp}/d" "${targetn}"/etc/gshadow
sed -i -e "s/\b${usertemp}\b//g" "${targetn}"/etc/gshadow
sed -i -e "/^${usertemp}/d" "${targetn}"/etc/gshadow-
sed -i -e "s/\b${usertemp}\b//g" "${targetn}"/etc/gshadow-

if [ -d "${targetn}"/home/"$usertemp" ];then
  rm -r "${targetn}"/home/"$usertemp"
fi
# and remove email folder
shred -u "${targetn}/var/spool/mail/${usertemp}" 2> /dev/null
echo "email box shreded"
