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
    stow --adopt -v -t "$HOME" .
    popd >/dev/null

    echo "Dotfiles stowed successfully!"
}

create_picture_folders() {
    echo "Creating Pictures folders..."
    
    mkdir -p "$HOME/Pictures/Screenshots"
    mkdir -p "$HOME/Pictures/Thumbnails"
    mkdir -p "$HOME/Pictures/Wallpapers"
    
    echo "Pictures folders created."
}

make_scripts_executable() {
    echo "Setting executable permissions for .sh scripts in ~/.config/waybar and ~/.config/hypr..."

    find -L "$HOME/.config/waybar" -type f -name "*.sh" -exec chmod +x {} \; 2>/dev/null || true

    echo "Done."
}

set_zsh_default() {
    local zsh_path
    zsh_path="$(command -v zsh)"

    if [[ "${SHELL:-}" != "$zsh_path" ]]; then
        echo "Setting zsh as default shell..."
        chsh -s "$zsh_path"
        echo "Log out and back in for the change to take effect."
    else
        echo "zsh is already the default shell."
    fi
}

install_dotfiles
make_scripts_executable
create_picture_folders
set_zsh_default