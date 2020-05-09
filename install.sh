set -e

log()   { echo -e "\e[30;47m ${1^^} \e[0m ${@:2}"; }
info()  { echo -e "\e[48;5;28m ${1^^} \e[0m ${@:2}"; }
warn()  { echo -e "\e[48;5;202m ${1^^} \e[0m ${@:2}" >&2; }
error() { echo -e "\e[48;5;196m ${1^^} \e[0m ${@:2}" >&2; }

download() {
    log download "$1"
    if [[ -n $(which curl) ]]
    then
        sudo curl "$1" \
            --location \
            --remote-name \
            --progress-bar
    else
        sudo wget "$1" \
            --quiet \
            --no-clobber \
            --show-progress
    fi
}

info install github-split
cd /usr/local/bin

# abort if already installed
[[ -x github-split ]] && { error abort github-split already exists; exit 0; }

# ask sudo accesss if not already available
if [[ -z $(sudo -n uptime 2>/dev/null) ]]; then
    warn warn sudo access required
    sudo echo >/dev/null
    # one more check if the user abort the password question
    [[ -z `sudo -n uptime 2>/dev/null` ]] && { error abort sudo required; exit 1; }
fi

download raw.githubusercontent.com/jeromedecoster/github-split/master/github-split

sudo chmod +x github-split

mkdir --parents ~/.config/github-split
cd ~/.config/github-split
download raw.githubusercontent.com/jeromedecoster/github-split/master/tpl/README.md.tpl
download raw.githubusercontent.com/jeromedecoster/github-split/master/tpl/install.sh.tpl

info installed github-split
exit 0
