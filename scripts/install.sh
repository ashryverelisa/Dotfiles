#!/bin/bash

readonly RESET=$'\e[0m'
readonly BLUE=$'\e[34m'
readonly GREEN=$'\e[32m'
readonly YELLOW=$'\e[33m'
readonly RED=$'\e[31m'

log() {
    local level=$1 color=$2
    shift 2
    printf "%b[%s]%b %s\n" "$color" "$level" "$RESET" "$*"
}

info()    { log INFO    "$BLUE"   "$@"; }
success() { log SUCCESS "$GREEN"  "$@"; }
warn()    { log WARN    "$YELLOW" "$@"; }
error()   { log ERROR   "$RED"    "$@"; }

ask_yes_no() {
    local reply
    read -r -p "$1 [Y/n]: " reply
    reply=${reply,,}
    [[ -z "$reply" || "$reply" =~ ^y(es)?$ ]] 
}

select_aur_helper() {
    PS3="$(printf "%bEnter choice (default 1): %b")"

    select helper in yay paru; do
        AUR_HELPER="${helper:-yay}"
        break
    done

    if ! command -v "$AUR_HELPER" >/dev/null 2>&1; then
        printf "%bError:%b %s is not installed.\n"
        exit 1
    fi

    printf "%bUsing %s as AUR helper%b\n"
}

echo -e "\n────────────────────────────────────────────"
echo -e "       Package Installation Script"
echo -e "────────────────────────────────────────────\n"

INSTALL_SYSTEM=false
INSTALL_APPLICATIONS=false
INSTALL_RICE=false

if ask_yes_no "Install System packages?"; then
    INSTALL_SYSTEM=true
fi

if ask_yes_no "Install Application packages?"; then
    INSTALL_APPLICATIONS=true
fi

if ask_yes_no "Install Rice packages?"; then
    INSTALL_RICE=true
fi

INSTALL_AUR=false
if ask_yes_no "Install AUR packages?"; then
    INSTALL_AUR=true
    select_aur_helper

    INSTALL_AUR_SYSTEM=false
    INSTALL_AUR_RICE=false
    INSTALL_AUR_APPS=false

    if ask_yes_no "  Install Important AUR packages?"; then
        INSTALL_AUR_SYSTEM=true
    fi

    if ask_yes_no "  Install Rice AUR packages?"; then
        INSTALL_AUR_RICE=true
    fi

    if ask_yes_no "  Install Application AUR packages?"; then
        INSTALL_AUR_APPS=true
    fi
fi

echo -e "\n Starting installation...\n"

# PACKAGE DEFINITIONS 
System_Packages=(
    # audio system
    pipewire
    pipewire-alsa
    pipewire-jack
    pipewire-pulse
    gst-plugin-pipewire
    libpulse
    wireplumber
    
    # network essentials
    bluez
    bluez-utils
    dnsmasq
    iwd
    openssh
    network-manager-applet
    wireless_tools
    wpa_supplicant
    
    # system utilities
    polkit-gnome
    stow
    
    # wayland essentials
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
)

Application_Packages=(
    # Browser
    firefox
    
    # Development
    git
  
    # Container platform
    docker
    docker-compose
    
    # creative
    gimp
    
    # media players
    vlc
    mpv
    
    # file management
    dolphin
    
    # office
    libreoffice-still 
)
  
Rice_Packages=(
    # hyprland
    hyprland
    hyprgraphics
    hyprlang
    hyprlock
    hyprpicker
    hyprsunset
    hyprutils
    
    # utilities
    grim
    slurp
    
    # notification
    swaync
    waybar
    
    # application launchers
    rofi
    rofi-calc
    rofi-emoji
    
    # terminal
    kitty
    
    # shell utilities
    zsh
    btop
    cava
    fastfetch
    htop
    lolcat
    jq
    nano
    neovim
    
    # system tools for rice
    brightnessctl
    imagemagick
    inotify-tools
    libnotify
    socat
    strace
    unzip
    unrar
    wget
    zip
)
  
Aur_Packages=(
    pwvucontrol
)  
  
Aur_App_Packages=(
    # browser
    vesktop
    
    # ide
    rider
)

Aur_Rice_Packages=(
    gslapper
    wlogout
    matugen-bin
    awww-bin
)
  
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

# Installation
Final_Packages=()

[ "$INSTALL_SYSTEM" = true ] && {
    info "Including System packages"
    Final_Packages+=("${System_Packages[@]}")
}

[ "$INSTALL_APPLICATIONS" = true ] && {
    info "Including Application packages"
    Final_Packages+=("${Application_Packages[@]}")
}

[ "$INSTALL_RICE" = true ] && {
    info "Including Rice packages"
    Final_Packages+=("${Rice_Packages[@]}")
}

if [ ${#Final_Packages[@]} -gt 0 ]; then
    info "Installing ${#Final_Packages[@]} official packages"

    if sudo pacman -Syu --needed "${Final_Packages[@]}"; then
        success "Official packages installed successfully"
    else
        error "Some official packages failed to install"
    fi
else
    warn "No official packages selected"
fi

if [ "$INSTALL_AUR" = true ]; then
    Aur_Final_Packages=()

    [ "$INSTALL_AUR_SYSTEM" = true ] && {
        info "Including Important AUR packages"
        Aur_Final_Packages+=("${Aur_Packages[@]}")
    }

    [ "$INSTALL_AUR_RICE" = true ] && {
        info "Including Rice AUR packages"
        Aur_Final_Packages+=("${Aur_Rice_Packages[@]}")
    }

    [ "$INSTALL_AUR_APPS" = true ] && {
        info "Including Application AUR packages"
        Aur_Final_Packages+=("${Aur_App_Packages[@]}")
    }

    if [ ${#Aur_Final_Packages[@]} -gt 0 ]; then
        info "Installing ${#Aur_Final_Packages[@]} AUR packages using $AUR_HELPER"

        if "$AUR_HELPER" -S --needed "${Aur_Final_Packages[@]}"; then
            success "AUR packages installed successfully"
        else
            error "Some AUR packages failed to install"
        fi
    else
        warn "No AUR packages selected"
    fi
fi

set_zsh_default

printf "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
printf "          Installation Complete!\n"
printf "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n"