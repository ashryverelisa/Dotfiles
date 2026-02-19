#!/usr/bin/env bash
set -euo pipefail

nmcli -w 5 device wifi rescan

current=$(nmcli -g NAME connection show --active | grep -v '^lo$' | head -n1 || true)

mapfile -t wifi_lines < <(
    nmcli -g SSID,SECURITY,SIGNAL device wifi list |
    awk -F: 'NF && !seen[$1]++' |
    sort -t: -k3 -rn
)

declare -A MAP
entries=()

entries+=(" Open network manager TUI")

[[ -n "${current:-}" ]] && \
    entries+=("󰖪 Disconnect from: $current")

for line in "${wifi_lines[@]}"; do
    IFS=: read -r ssid security signal <<< "$line"
    [[ -z "$ssid" ]] && continue

    if [[ "$security" == "--" ]]; then
        icon=""
        sec="Open"
    else
        icon=""
        sec="$security"
    fi

    display="$icon $ssid ($sec) ${signal}%"
    entries+=("$display")
    MAP["$display"]="$ssid:$security"
done

selected=$(printf '%s\n' "${entries[@]}" | \
    rofi -dmenu -i -p "Select WiFi")

[[ -z "$selected" ]] && exit 0

case "$selected" in
    " Open network manager TUI")
        kitty --class floating --title 'nmtui' -e nmtui
        exit 0
        ;;
    "󰖪 Disconnect from:"*)
        if nmcli connection down "$current"; then
            notify-send "WiFi" "Disconnected from $current"
        else
            notify-send -u critical "WiFi" "Disconnect failed"
        fi
        exit 0
        ;;
esac

IFS=: read -r ssid security <<< "${MAP[$selected]}"

# ---- Connect Logic
if [[ -z "$security" || "$security" == "--" ]]; then
    nmcli device wifi connect "$ssid"

elif [[ "$security" == *EAP* ]]; then
    nmcli connection up id "$ssid"

else
    if nmcli connection show "$ssid" &>/dev/null; then
        nmcli connection up id "$ssid"
    else
        password=$(rofi -dmenu -password -p "Password for $ssid")
        [[ -z "$password" ]] && exit 0
        nmcli device wifi connect "$ssid" password "$password"
    fi
fi

# ---- Result Notification
if [[ $? -eq 0 ]]; then
    sleep 2
    connectivity=$(nmcli -g CONNECTIVITY general)

    if [[ "$connectivity" == "portal" ]]; then
        notify-send "WiFi" "Connected to $ssid (Login required)"
    else
        notify-send "WiFi" "Connected to $ssid"
    fi
else
    notify-send -u critical "WiFi" "Failed to connect to $ssid"
fi