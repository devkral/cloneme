#! /bin/sh

#usage: install_installer.sh <programdir> <targetsystem> (mustn't end with /")
share_dir="$(dirname "$(dirname "$(realpath "$0")")")"

programdir="$1"
targetdir="$2"

cp "$programdir"/{cloneme,clonemecmd.sh} "$targetdir"/"$programdir"
mkdir -p "$targetdir"/"$share_dir" 2> /dev/null
cp -r "$share_dir"/* "$targetdir"/"$share_dir"
