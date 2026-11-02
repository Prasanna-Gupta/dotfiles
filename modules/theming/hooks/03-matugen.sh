#!/usr/bin/env bash
# 03 — ONE matugen run, seeded from the KDE accent, renders every template:
#      kitty theme (live reload), SDDM colours, colors.json for later hooks.
set -euo pipefail
: "${STATE_DIR:=${XDG_STATE_HOME:-$HOME/.local/state}/prasanna}"
# shellcheck disable=SC1091
source "$STATE_DIR/accent.env"

CONFIG="$HOME/.config/matugen/config.toml"
[[ -f "$CONFIG" ]] || { echo "matugen config missing — run ./install.sh theme"; exit 1; }

# Pre-flight: every output file/dir must be writable (matugen only says "Permission denied")
while IFS= read -r out; do
    out="${out%\"}"; out="${out#*\"}"
    if [[ -e "$out" && ! -w "$out" ]] || [[ ! -e "$out" && ! -w "$(dirname "$out")" ]]; then
        echo "Not writable: $out  →  sudo chown $USER: '$out'"; exit 1
    fi
done < <(grep -E '^output_path' "$CONFIG")

matugen color hex "$ACCENT" --mode dark --config "$CONFIG"
echo "matugen rendered templates from $ACCENT"
