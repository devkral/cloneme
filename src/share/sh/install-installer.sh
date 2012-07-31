#! /bin/sh

#usage: install-installer.sh <programdir> [linkdir] <targetsystem>
#dir where the cloneme files are located
#TODO: recompile when another version compare uname -m
sharedir="$(dirname "$(dirname "$(realpath "$0")")")"

programdir="$(realpath "$1")"

if [ $# > 2 ];then
  linkdir="$2"
  #targetdir mustn't end with /
  targetdir="$(echo "$3" | sed "s/\/$//")"
else
  #targetdir mustn't end with /
  targetdir="$(echo "$2" | sed "s/\/$//")"
fi



cp "$programdir"/clonemecmd.sh "$targetdir"/"$programdir"
sed -i -e "s|.* #--replacepattern--|sharedir=\"${sharedir}\" #--replacepattern--|" "$targetdir"/"$programdir"/clonemecmd.sh

if [ -e "$programdir"/cloneme ] && "${sharedir}"/sh/install-installer-compiler.sh;then
  cp "$programdir"/cloneme "$targetdir"/"$programdir"
fi

mkdir -p "$targetdir"/"$share_dir" 2> /dev/null
if ! cp -r "$share_dir"/* "$targetdir"/"$sharedir";then
  exit 1
fi

if [ "x$linkdir" != "x" ];then
  mkdir -p "$targetdir"/"$linkdir" 2> /dev/null
  cp "$linkdir"/cloneme.desktop "$targetdir"/"$linkdir"
fi


