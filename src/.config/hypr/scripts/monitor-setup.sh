#!/bin/bash

MONITORS=$(hyprctl monitors)

if echo "$MONITORS" | grep -q "DP-1"; then
    # Desktop Pc
    hyprctl keyword monitor "DP-1,5120x1440@239.76Hz,0x0,1"
    hyprctl keyword monitor "HDMI-A-1,disable"
else
    # Laptop only
    hyprctl keyword monitor "eDP-1,2560x1440@165.00Hz,0x0,1"
fi