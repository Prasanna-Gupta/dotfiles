#!/usr/bin/env bash
# 06 — recolour Papirus folder icons to the closest accent colour.
#      Only calls sudo when the colour actually changes.
set -euo pipefail
: "${STATE_DIR:=${XDG_STATE_HOME:-$HOME/.local/state}/prasanna}"
: "${PRASANNA_THEMING:=$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)}"
# shellcheck disable=SC1091
source "$STATE_DIR/accent.env"
# Prefer matugen's dark-mode primary (tone 80): readable on dark backgrounds,
# where KDE's DecorationFocus accent can be too dark for text.
if [[ -f "$STATE_DIR/colors.json" ]]; then
    p="$(python3 -c 'import json,sys;print(json.load(open(sys.argv[1]))["primary"])' "$STATE_DIR/colors.json" 2>/dev/null || true)"
    [[ "$p" =~ ^#[0-9a-fA-F]{6}$ ]] && ACCENT="$p"
fi

command -v papirus-folders >/dev/null || { echo "papirus-folders not installed — skipped"; exit 0; }
theme="$(kreadconfig6 --file kdeglobals --group Icons --key Theme 2>/dev/null || true)"
[[ "$theme" == Papirus* ]] || { echo "Icon theme is '$theme', not Papirus — skipped"; exit 0; }

color="$(python3 "$PRASANNA_THEMING/lib/papirus_color.py" "$ACCENT")"
last="$(cat "$STATE_DIR/folder-color" 2>/dev/null || true)"
[[ "$color" == "$last" ]] && { echo "Folder colour unchanged ($color)"; exit 0; }

sudo -n /usr/bin/papirus-folders -C "$color" --theme "$theme"
echo "$color" >"$STATE_DIR/folder-color"
echo "Folder icons: $color"
