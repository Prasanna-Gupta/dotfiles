#!/bin/bash
# Hook 03: Generate SDDM prasanna.conf from accent.env + matugen template

ACCENT_ENV="$HOME/.config/prasanna/colors/accent.env"
TEMPLATE="$HOME/.config/prasanna/templates/sddm.conf.tmpl"
OUTPUT="/etc/sddm-prasanna/prasanna.conf"
SDDM_LINK="/usr/share/sddm/themes/silent/configs/prasanna.conf"

if [ ! -f "$ACCENT_ENV" ]; then
    echo "ERROR: accent.env not found, run 01-colors.sh first"
    exit 1
fi

source "$ACCENT_ENV"

# Run matugen to generate the full palette from current wallpaper
# Pass the KDE accent as the source color so palettes stay in sync
matugen image "$HOME/.config/prasanna/wallpaper/current.jpg" \
    --source-color-index 0 \
    --config "$HOME/.config/matugen/config.toml"

echo "SDDM config generated with accent: $ACCENT"
