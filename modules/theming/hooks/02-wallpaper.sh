#!/usr/bin/env bash
# 02 — copy the active wallpaper to a stable path (+ SDDM backgrounds if set up)
set -euo pipefail
: "${STATE_DIR:=${XDG_STATE_HOME:-$HOME/.local/state}/prasanna}"

CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
SDDM_BG_DIR="/usr/share/sddm/themes/silent/backgrounds"

wp="$(awk '/\[Wallpaper\]\[org\.kde\.image\]\[General\]/{f=1;next} /^\[/{f=0} f&&/^Image=/{sub(/^Image=/,"");print;exit}' "$CONFIG")"
[[ -z "$wp" ]] && wp="$(grep -m1 '^Image=' "$CONFIG" | cut -d= -f2-)"
wp="${wp#file://}"
wp="$(printf '%b' "${wp//%/\\x}")"   # undo %20 etc.

# Slideshow / folder wallpapers: pick the newest image inside
if [[ -d "$wp" ]]; then
    wp="$(find "$wp" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%T@ %p\n' | sort -nr | head -1 | cut -d' ' -f2-)"
fi
[[ -f "$wp" ]] || { echo "Wallpaper not found: '$wp'"; exit 1; }

cp -f "$wp" "$STATE_DIR/wallpaper"
echo "Wallpaper: $wp"

if [[ -d "$SDDM_BG_DIR" && -w "$SDDM_BG_DIR" ]]; then
    cp -f "$wp" "$SDDM_BG_DIR/current.jpg"
    echo "SDDM background updated"
fi
