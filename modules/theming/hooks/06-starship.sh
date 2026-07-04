#!/bin/bash
# Hook 06: Starship prompt accent update
# Rewrites only the color values, preserves all format/structure

ACCENT_ENV="$HOME/.config/prasanna/colors/accent.env"
STARSHIP="$HOME/.config/starship.toml"

if [ ! -f "$ACCENT_ENV" ]; then
    echo "ERROR: accent.env not found"
    exit 1
fi

source "$ACCENT_ENV"

# Use python for safe TOML manipulation
python3 << PYEOF
import re

starship_path = "$STARSHIP"
accent = "$ACCENT"

with open(starship_path, 'r') as f:
    content = f.read()

# Replace directory style color with accent
content = re.sub(
    r'(\[directory\].*?style\s*=\s*")[^"]*(")',
    rf'\g<1>bold {accent}\g<2>',
    content, flags=re.DOTALL
)

# Replace character success symbol color
content = re.sub(
    r'(success_symbol\s*=\s*"\[❯\]\()[^)]*(\)")',
    rf'\g<1>bold {accent}\g<2>',
    content
)

with open(starship_path, 'w') as f:
    f.write(content)

print(f"Starship accent updated: {accent}")
PYEOF
