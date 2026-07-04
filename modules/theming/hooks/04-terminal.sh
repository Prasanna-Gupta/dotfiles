#!/bin/bash
# Hook 04: Terminal theming
# Writes kitty theme.conf via matugen template
# Reloads kitty live via SIGUSR1

WALLPAPER="$HOME/.config/prasanna/wallpaper/current.jpg"

if [ ! -f "$WALLPAPER" ]; then
    echo "ERROR: Wallpaper not found at canonical path"
    exit 1
fi

# matugen writes theme.conf and sends SIGUSR1 to kitty
matugen image "$WALLPAPER" \
    --source-color-index 0 \
    --config "$HOME/.config/matugen/config.toml"

echo "Kitty theme updated and reloaded"
