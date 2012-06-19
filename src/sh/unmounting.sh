#! /bin/bash

src="$1";
dest="$2";

umount $src;
umount $dest;
