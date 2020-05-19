set -e

URL=https://raw.githubusercontent.com/jeromedecoster/{{REPOSITORY}}/master

log()   { echo -e "\e[30;47m ${1^^} \e[0m ${@:2}"; }
info()  { echo -e "\e[48;5;28m ${1^^} \e[0m ${@:2}"; }
warn()  { echo -e "\e[48;5;202m ${1^^} \e[0m ${@:2}" >&2; }
error() { echo -e "\e[48;5;196m ${1^^} \e[0m ${@:2}" >&2; }

# no file overwrite
while read file
do
    [[ -f $file ]] && { warn abort $file already exists; exit 0; }
done < <(echo {{CONTENT}} | base64 -d)

CWD=$(pwd)
TEMP=$(mktemp --directory)

info create from merged files
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

log md5 check
[[ $(md5sum archive.zip | cut -d ' ' -f 1) != {{MD5}} ]] \
    && { error md5 checksum error; exit; }

log unzip archive.zip
unzip archive.zip

# check if $CWD is writable by the user
if [[ -z $(sudo --user $(whoami) --set-home bash -c "[[ -w $CWD ]] && echo 1;") ]]
then
    SUDO=1
    warn warn sudo access is required
    sudo echo >/dev/null
fi

# inline the filenames in the zip
CONTENT=$(unzip -l archive.zip \
    | tail -n +4 \
    | head -n -2 \
    | sed --expression 's|^.*:[0-9]*\s*||')

while read file
do
    [[ $SUDO -eq 1 ]] \
        && sudo mv "$file" $CWD \
        || mv "$file" $CWD;
        
    info created "$file"
done < <(echo "$CONTENT")

rm --force --recursive $TEMP
