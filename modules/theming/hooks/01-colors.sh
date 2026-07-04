#!/bin/bash
# Hook 01: Extract accent from kde-material-you-colors output
# Source of truth: MaterialYouDark.colors -> accent.env

COLORS_FILE="$HOME/.local/share/color-schemes/MaterialYouDark.colors"
ACCENT_ENV="$HOME/.config/prasanna/colors/accent.env"

if [ ! -f "$COLORS_FILE" ]; then
    echo "ERROR: MaterialYouDark.colors not found"
    exit 1
fi

# Extract accent (DecorationFocus is the Material You primary accent)
ACCENT=$(grep "^DecorationFocus=" "$COLORS_FILE" | head -n1 | cut -d'=' -f2 | tr -d '\n\r')

if [ -z "$ACCENT" ]; then
    echo "ERROR: Could not extract accent color"
    exit 1
fi

# Write accent.env — single source of truth for all downstream modules
cat > "$ACCENT_ENV" << ENVEOF
ACCENT=$ACCENT
ACCENT_R=$(printf "%d" 0x${ACCENT:1:2})
ACCENT_G=$(printf "%d" 0x${ACCENT:3:2})
ACCENT_B=$(printf "%d" 0x${ACCENT:5:2})
ENVEOF

echo "Accent extracted: $ACCENT"
