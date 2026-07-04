#!/usr/bin/env bash

set -e

THEME_DIR="/usr/share/sddm/themes/silent/backgrounds"

WALLPAPER=$(grep -m1 "^Image=" ~/.config/plasma-org.kde.plasma.desktop-appletsrc | cut -d= -f2)

WALLPAPER="${WALLPAPER#file://}"

sudo ln -sfn "$WALLPAPER" "$THEME_DIR/current.jpg"

echo "✓ SDDM wallpaper updated"
