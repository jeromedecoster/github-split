set -e

log() { echo -e "\e[38;5;82;4m${1}\e[0m \e[38;5;226m${@:2}\e[0m"; }
err() { echo -e "\e[38;5;196;4m${1}\e[0m \e[38;5;87m${@:2}\e[0m" >&2; }

download() {
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

cd /usr/local/bin

# abort if already installed
[[ -x github-split ]] && { log abort github-split already exists; exit 0; }

# ask sudo accesss if not already available
if [[ -z $(sudo -n uptime 2>/dev/null) ]]; then
    log warn sudo access required
    sudo echo >/dev/null
    # one more check if the user abort the password question
    [[ -z `sudo -n uptime 2>/dev/null` ]] && { err abort sudo required; exit 1; }
fi

log install github-split
download raw.githubusercontent.com/jeromedecoster/github-split/master/github-split

sudo chmod +x github-split

mkdir --parents ~/.config/github-split
cd ~/.config/github-split
download raw.githubusercontent.com/jeromedecoster/github-split/master/README.md.tpl
download raw.githubusercontent.com/jeromedecoster/github-split/master/script.sh.tpl

log complete github-split successfully installed
exit 0
