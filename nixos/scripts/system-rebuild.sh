#!/usr/bin/env bash
set -e

if [ -z $1 ]; then
    export HOST=$1
else
    export HOST=$(hostname)
fi

pushd ~/dotfiles/nixos

$EDITOR ${HOST}.nix

if git diff --quiet '*.nix'; then
    echo "No changes detected, exiting."
    popd
    exit 0
fi

# Autoformat nix files
alejandra . &>/dev/null || ( alejandra . ; echo "formatting failed!" && popd && exit 1)

git diff -U0 '*.nix'

echo "NixOS Rebuilding..."

if sudo nixos-rebuild switch &>.nixos-switch.log; then
    echo -e "Done\n"
else
    echo ""
    cat nixos-switch.log | grep --color error

    git restore --staged ./**/*.nix

    if read -p "Open log? (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
        cat .nixos-switch.log | vim -
    fi

    shopt -u globstar
    popd > /dev/null
    exit 1
fi

current=$(nixos-rebuild list-generations | grep current)

git commit -am "$current"

popd

notify-send -e "NixOS Rebuild OK!" --icon=software-udpate-available

