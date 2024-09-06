#!/usr/bin/env bash
set -e

USER=$(whoami)
if [ $1 ]; then
    USER=$1
fi

pushd $HOME/dotfiles/home-manager

$EDITOR ${USER}.nix

if git diff --quiet '*.nix'; then
    echo "No changes detected, exiting."
    popd
    exit 0
fi

# Autoformat nix files
alejandra . &>/dev/null || ( alejandra . ; echo "formatting failed!" && popd && exit 1)

git diff -U0 '*.nix'

echo "home-manager ($USER) rebuilding..."

if home-manager -f ${USER}.nix switch &>.hm-switch.log; then
    echo -e "Done\n"
else
    echo ""
    cat .hm-switch.log | grep --color error

    git restore --staged ./**/*.nix

    if read -p "Open log? (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        cat .hm-switch.log | vim -
    fi

    shopt -u globstar
    popd > /dev/null
    exit 1
fi

current=$(home-manager generations | head -n1)

git commit -a -m "home-manager ($USER): $current" -e

popd

notify-send -e "home-manger rebuild ($USER) OK!" --icon=software-udpate-available

