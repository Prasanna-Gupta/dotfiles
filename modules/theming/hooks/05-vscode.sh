#!/bin/bash
ACCENT_ENV="$HOME/.config/prasanna/colors/accent.env"
SETTINGS="$HOME/.config/Code/User/settings.json"

if [ ! -f "$ACCENT_ENV" ]; then
    echo "ERROR: accent.env not found"
    exit 1
fi

source "$ACCENT_ENV"
python3 "$HOME/.config/prasanna/hooks/vscode_inject.py" "$SETTINGS" "$ACCENT"
