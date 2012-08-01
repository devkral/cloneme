#! /bin/sh

#default groups of new users
usergroupargs="video,audio,optical,power"
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
      if grep "wheel" /etc/group > /dev/null;then
        usergroupargs+=",wheel"
      fi
      if grep "adm" /etc/group > /dev/null;then
        usergroupargs+=",adm"
      fi
      if grep "admin" /etc/group > /dev/null;then
        usergroupargs+=",admin"
      fi
    fi
    useradd -m -U "$user_name" -p "" -G "$usergroupargs"
    passwd -e "$user_name"
  fi
  if [ "$n_user" = "no" ];then
    break
  fi
done
