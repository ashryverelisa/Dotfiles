#!/bin/bash
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/src"
CONFIG_TARGET="$HOME/.config"
CONFIG_SOURCE="$REPO_DIR/.config"

Rice_configs=(

)
  
for config in "${Rice_configs[@]}"; do
    if [ -e "$CONFIG_SOURCE/$config" ]; then
        if [ -d "$CONFIG_SOURCE/$config" ]; then
            mkdir -p "$CONFIG_TARGET/$config"
            rsync -a --delete "$CONFIG_SOURCE/$config/" "$CONFIG_TARGET/$config/" || {
                echo "  ✗ Failed to sync $config"
                continue
            }
        else
            cp "$CONFIG_SOURCE/$config" "$CONFIG_TARGET/$config" || {
                echo "  ✗ Failed to copy $config"
                continue
            }
        fi
        echo "  ✓ Copied $config"
        ((SYNCED_COUNT++))
    fi
done

echo "Copying ~/.zshrc and .pk10k.zsh"
cp "$REPO_DIR/.zshrc" "$HOME/.zshrc"
cp "$REPO_DIR/.pk10k.zsh" "$HOME/.pk10k.zsh"

echo "Enabling execution for scripts"
# TODO: add scripts

echo "Create files/directories"
LATITUDE="0.0"
LONGITUDE="0.0"
mkdir ~/Pictures
mkdir ~/Pictures/Wallpapers
mkdir ~/Pictures/Screenshots