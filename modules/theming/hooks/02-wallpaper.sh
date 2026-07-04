#!/bin/bash
# Hook 02: Detect active KDE wallpaper and sync to canonical path
# No sudo needed - ACL grants write access to backgrounds/

CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
DEST_USER="$HOME/.config/prasanna/wallpaper/current.jpg"
DEST_SDDM="/usr/share/sddm/themes/silent/backgrounds/current.jpg"

WALLPAPER=$(awk '/\[Wallpaper\]/{found=1} found && /^Image=/{print; exit}' "$CONFIG" \
    | cut -d'=' -f2- | sed 's|^file://||' | tr -d '\n\r')

if [ -z "$WALLPAPER" ]; then
    WALLPAPER=$(grep "^Image=" "$CONFIG" | head -n1 \
        | cut -d'=' -f2- | sed 's|^file://||' | tr -d '\n\r')
fi

if [ ! -f "$WALLPAPER" ]; then
    echo "ERROR: Wallpaper not found: $WALLPAPER"
    exit 1
fi

cp -f "$WALLPAPER" "$DEST_USER"
echo "Wallpaper cached: $DEST_USER"

cp -f "$DEST_USER" "$DEST_SDDM"
echo "SDDM wallpaper updated: $DEST_SDDM"
