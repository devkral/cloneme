#! /bin/bash

if [ "$1" = "--help" ];then
echo "Usage:"
echo "$0 <path to bash files>…"
exit 0;
fi

echo "std::string sum=\"\";"

sed  -e 's/\"/\\\"/g' -e 's/\${\?clonetargetdevice2}\?/\"+dest+\"/g' -e 's/\${\?targetn}\?/\"+dest+\"/g' -e 's/\${\?clonesource2}\?/\"+src+\"/g' \
-e 's/\${\?usertemp}\?/\"+name+\"/g' -e 's/\${\?user_name}\?/\"+username->get_text()+\"/g' -e 's/#.*//' -e '/^$/d' -e 's/\(.*\)$/\sum+=\"\1\\n\";/g' $@
