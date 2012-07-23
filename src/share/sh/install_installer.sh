#! /bin/sh

#usage: install_installer.sh <programdir> <targetsystem>
#dir where the cloneme files are located
share_dir="$(dirname "$(dirname "$(realpath "$0")")")"

programdir="$1"
#targetdir mustn't end with /
targetdir="$(echo "$2" | sed "s/\/$//")"

cp "$programdir"/clonemecmd.sh "$targetdir"/"$programdir"
if [ -e "$programdir"/cloneme ];then
  cp "$programdir"/cloneme "$targetdir"/"$programdir"
fi

mkdir -p "$targetdir"/"$share_dir" 2> /dev/null
if ! cp -r "$share_dir"/* "$targetdir"/"$share_dir";then
  exit 1
fi
