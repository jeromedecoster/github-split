set -e

URL=https://raw.githubusercontent.com/jeromedecoster/{{REPOSITORY}}/master

log() { echo -e "\e[0;4m${1}\e[0m ${@:2}"; }

CWD=$(pwd)
TEMP=$(mktemp --directory)

cd $TEMP
for file in {{FILES}}
do
    log download $URL/$file
    if [[ -n $(which curl) ]]
    then
        curl $URL/$file \
            --location \
            --remote-name \
            --progress-bar
    else
        wget $URL/$file \
            --quiet \
            --show-progress
    fi
done

log merge xa* as archive.zip
cat xa* > archive.zip

log check md5
[[ $(md5sum archive.zip | cut -d ' ' -f 1) != {{MD5}} ]] \
    && { log checksum error; exit; }

log unzip archive.zip
unzip archive.zip

# inline the filenames in the zip
CONTENT=$(unzip -l archive.zip \
    | tail -n +4 \
    | head -n -2 \
    | sed -E 's|^.*:[0-9]*\s*||' \
    | tr '\t' ' ')

# check if $CWD is writable by the user
if [[ -z $(sudo --user $(whoami) --set-home bash -c "[[ -w $CWD ]] && echo 1;") ]]
then
    log warn sudo access is required
    sudo mv $CONTENT $CWD
else
    mv $CONTENT $CWD
fi

log created $CONTENT

rm --force --recursive $TEMP
