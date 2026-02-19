#!/bin/bash

readonly DOTFILES_DIR="$HOME/Dotfiles/src"

install_dotfiles() {
    echo "Stowing dotfiles..."

    if [[ ! -d "$DOTFILES_DIR/.config" ]]; then
        echo "No .config directory found in $DOTFILES_DIR"
        return
    fi

    mkdir -p "$HOME/.config"

    pushd "$DOTFILES_DIR" >/dev/null
    stow --adopt -v -t "$HOME/.config" .config
    popd >/dev/null

    echo "Dotfiles stowed successfully!"
}

install_dotfiles

echo "Enabling execution for scripts"
# TODO: add scripts

echo "Create files/directories"
LATITUDE="0.0"
LONGITUDE="0.0"
mkdir -p ~/Pictures
mkdir -p ~/Pictures/Wallpapers
mkdir -p ~/Pictures/Screenshots