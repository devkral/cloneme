#! /bin/sh

#usage: install_installer.sh <programdir> <targetsystem> [linkdir]
#dir where the cloneme files are located
share_dir="$(dirname "$(dirname "$(realpath "$0")")")"

programdir="$(realpath "$1")"

#if [ $# > 2 ];then
  linkdir="$3"
#fi
#targetdir mustn't end with /
targetdir="$(echo "$2" | sed "s/\/$//")"

cp "$programdir"/clonemecmd.sh "$targetdir"/"$programdir"
sed -i -e "s|.* #--replacepattern--|sharedir=\"${share_dir}\" #--replacepattern--|" "$targetdir"/"$programdir"/clonemecmd.sh
if [ -e "$programdir"/cloneme ];then
  cp "$programdir"/cloneme "$targetdir"/"$programdir"
fi

mkdir -p "$targetdir"/"$share_dir" 2> /dev/null
if ! cp -r "$share_dir"/* "$targetdir"/"$share_dir";then
  exit 1
fi

if [ "x$linkdir" != "x" ];then
  mkdir -p "$targetdir"/"$linkdir" 2> /dev/null
  cp "$linkdir"/cloneme "$targetdir"/"$linkdir"
fi