#! /bin/sh

#usage: install-installer.sh <programdir> [linkdir] <targetsystem>
#dir where the cloneme files are located
#intern dependencies: install-installer-compiler.sh clonemecmd.sh

sharedir="$(dirname "$(dirname "$(realpath "$0")")")"

programdir="$(realpath "$1")"

if [[ $# > 2 ]];then
  linkdir="$(realpath "$2")"
  targetdir="$(realpath "$3")"
else
  targetdir="$(realpath "$2")"
fi

mkdir -p "${targetdir}${programdir}" 2> /dev/null
mkdir -p "${targetdir}${sharedir}" 2> /dev/null
cp "$programdir"/clonemecmd.sh "${targetdir}${programdir}"
sed -i -e "s|.* #--replacepattern--|sharedir=\"${sharedir}\" #--replacepattern--|" "$targetdir$programdir"/clonemecmd.sh

if [ -e "$programdir"/cloneme ] && "${sharedir}"/sh/install-installer-compiler.sh "$(uname -m)" "$targetdir$programdir"/cloneme;then
  cp "$programdir"/cloneme "$targetdir$programdir"
fi

mkdir -p "$targetdir$share_dir" 2> /dev/null
if ! cp -r "$share_dir"/* "$targetdir$sharedir";then
  exit 1
fi

if [ "$linkdir" != "" ];then
  mkdir -p "$targetdir$linkdir" 2> /dev/null
  cp "$linkdir"/cloneme.desktop "$targetdir$linkdir"
fi


