#! /bin/bash

## don't use this directly!!

clonesource="$1"
syncdir="$2"


 rsync -a -A --progress --delete --exclude "${clonesource}"/boot/grub/grub.cfg --exclude "${clonesource}"/boot/grub/device.map --exclude "${clonesource}"/etc/fstab --exclude "${syncdir}" --exclude "${clonesource}/home/*" --exclude "${clonesource}"/sys/ --exclude "${clonesource}/dev/*" --exclude "${clonesource}/proc/*" --exclude "${clonesource}/var/log/*" --exclude "${clonesource}/tmp/*" --exclude "${clonesource}/run/*" --exclude "${clonesource}/var/run/*" --exclude "${clonesource}/var/tmp/*" "${clonesource}"/* "${syncdir}"
