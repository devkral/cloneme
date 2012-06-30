#! /bin/bash

if [ "$1" = "--help" ];then
echo "Usage:"
echo "bash_format_createuser.sh <path to bash files>…"
exit 0;
fi

echo "std::string sum=\"\";"

sed  -e 's/\"/\\\"/g' -e 's/\${\?clonetargetdevice2}\?/\"+dest+\"/g' -e 's/\${\?clonesource2}\?/\"+src+\"/g' \
-e 's/\${\?usertemp}\?/\"+username->get_text()+\"/g' -e 's/#.*//' -e 's/\(.*\)$/\sum+=\"\1\\n\";/g' $@
