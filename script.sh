set -e

log() { echo -e "\033[0;4m${1}\033[0m ${@:2}"; }

# abort if sudo access is already enabled
[[ -n $(sudo -n uptime 2>/dev/null) ]] && { log abort root access unauthorized; exit; }

# ask sudo access
log warn sudo access required...
sudo echo >/dev/null
# one more check if the user abort the password question
[[ -z `sudo -n uptime 2>/dev/null` ]] && { log abort sudo required; exit; }

cd /usr/local/bin

sudo curl raw.githubusercontent.com/jeromedecoster/github-split/master/github-split \
    --location \
    --remote-name \
    --progress-bar

sudo chmod ug+x github-split
sudo chown $UID:$UID github-split

log complete github-split successfully installed
