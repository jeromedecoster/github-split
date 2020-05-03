#!/bin/bash
set -e

usage() { echo 'usage: github-split <repository> <file> [file] ...'; exit; }

log() { echo -e "\e[38;5;82;4m${1}\e[0m \e[38;5;226m${@:2}\e[0m"; }
err() { echo -e "\e[38;5;196;4m${1}\e[0m \e[38;5;87m${@:2}\e[0m" >&2; }

[[ $1 == '-h' || $1 == '--help' || $# -lt 2 || ! -f $2 ]] && { usage; }
[[ -d split-$1 ]] && { err abort split-$1 already exists; exit; }

CWD=$(pwd)
TEMP=$(mktemp --directory)

log zip create archive.zip
zip --junk-paths -9 $TEMP/archive.zip ${@:2}

cd $TEMP
MD5=$(md5sum archive.zip | cut -d ' ' -f 1)
log md5 $MD5

SIZE=$(du archive.zip | sed 's|[^0-9].*$||g')
BYTES=500KB
[[ $SIZE -gt 5120 ]] && BYTES=1MB;
[[ $SIZE -gt 10240 ]] && BYTES=2MB; 
[[ $SIZE -gt 15360 ]] && BYTES=3MB;
[[ $SIZE -gt 20480 ]] && BYTES=4MB;
[[ $SIZE -gt 25600 ]] && BYTES=5MB;

log split archive.zip into pieces of $BYTES
split --bytes=$BYTES archive.zip
rm archive.zip
FILES=$(ls -1 | tr '\n' ' ')
FILES=${FILES::-1}

log create README.md
sed "s|{{REPOSITORY}}|$1|" ~/.config/github-split/README.md.tpl > README.md

log create script.sh
sed --expression "s|{{REPOSITORY}}|$1|" \
    --expression "s|{{FILES}}|$FILES|" \
    --expression "s|{{MD5}}|$MD5|" \
    ~/.config/github-split/script.sh.tpl > script.sh

mv $TEMP $CWD/split-$1
log complete split-$1 successfully created

rm --force --recursive $TEMP
