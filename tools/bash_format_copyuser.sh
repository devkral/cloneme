#! /bin/bash

if [ "$1" = "--help" ];then
echo "Usage:"
echo "bash_format_copy.sh <path to bash files>…"
exit 0;
fi

echo "std::string sum=\"\";"

sed  -e 's/\"/\\\"/g' -e 's/\${\?clonetargetdevice2}\?/\"+dest+\"/g' -e 's/\${\?clonesource2}\?/\"+src+\"/g' \
-e 's/\${\?usertemp}\?/\"+name+\"/g' -e 's/#.*//' -e 's/\(.*\)$/\sum+=\"\1\\n\";/g' $@
