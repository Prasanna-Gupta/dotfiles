#!/bin/bash
# Hook 01: Extract accent from kde-material-you-colors output

COLORS_FILE="$HOME/.local/share/color-schemes/MaterialYouDark.colors"
ACCENT_ENV="$HOME/.config/prasanna/colors/accent.env"

if [ ! -f "$COLORS_FILE" ]; then
    echo "ERROR: MaterialYouDark.colors not found"
    exit 1
fi

ACCENT=$(grep "^DecorationFocus=" "$COLORS_FILE" | head -n1 | cut -d'=' -f2 | tr -d '\n\r')

if [ -z "$ACCENT" ]; then
    echo "ERROR: Could not extract accent color"
    exit 1
fi

cat > "$ACCENT_ENV" << ENVEOF
ACCENT=$ACCENT
ACCENT_R=$(printf "%d" 0x${ACCENT:1:2})
ACCENT_G=$(printf "%d" 0x${ACCENT:3:2})
ACCENT_B=$(printf "%d" 0x${ACCENT:5:2})
ENVEOF

echo "Accent extracted: $ACCENT"

# Regenerate circular avatar
FACE="$HOME/.face.icon"
DEST="/var/lib/AccountsService/icons/asur"

if [ -f "$FACE" ]; then
    python3 /home/asur/.config/prasanna/hooks/make_avatar.py "$FACE" /tmp/prasanna-avatar-circle.png
    if [ $? -eq 0 ]; then
        sudo cp /tmp/prasanna-avatar-circle.png "$DEST"
        sudo chmod 644 "$DEST"
        echo "Avatar updated"
    else
        echo "Avatar generation failed"
    fi
fi
