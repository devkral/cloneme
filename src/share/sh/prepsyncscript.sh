#! /usr/bin/env bash

#usage: prepsyncscript.sh <syncdir>

#intern dependencies: umountscript.sh


syncdir="$(realpath "$1")"

mkdir -p "${syncdir}"/src

mkdir -p "${syncdir}"/dest


