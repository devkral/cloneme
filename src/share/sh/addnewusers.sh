#! /bin/sh

sharedir="$(dirname "$(dirname "$(realpath "$0")")")"

#default groups of new users
usergroup="video audio optical power"
admingroup="wheel adm admin"



usergroupargs="$("${sharedir}"/sh/groupexist.sh $usergroup)"
usercounter=0
for (( ; ; ))
do
  if [ ${usercounter} = 0 ];then
    usercounter=1;
    echo "Create new user? [yes/no]"
  else
    echo "Create another new user? [yes/no]"
  fi
  read n_user
  if [ "$n_user" = "yes" ];then
    echo "Enter user name"
    read user_name;
    echo "Shall this user account have admin (can change to root) permissions? [yes] default: no"
    read admin_perm
    if [ "$admin_perm" = "yes" ];then
      usergroupargs+="$usergroupargs,$("${sharedir}"/sh/groupexist.sh $admingroup)"
    fi
    useradd -m -U "$user_name" -p "" -G "$usergroupargs"
    passwd -e "$user_name"
  fi
  if [ "$n_user" = "no" ];then
    break
  fi
done
