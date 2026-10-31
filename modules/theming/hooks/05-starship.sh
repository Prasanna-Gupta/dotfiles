#!/usr/bin/env bash
# 05 — render starship.toml from the tracked template (repo stays clean)
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

TEMPLATE="$PRASANNA_THEMING/../shell/starship.toml.tmpl"
OUT="$HOME/.config/starship.toml"
[[ -f "$TEMPLATE" ]] || { echo "starship template missing"; exit 1; }

# A starship.toml that isn't ours (no marker) is left alone
if [[ -f "$OUT" && ! -L "$OUT" ]] && ! grep -q 'prasanna-os:generated' "$OUT"; then
    echo "$OUT is hand-written — not overwriting (delete it to opt in)"
    exit 0
fi
[[ -L "$OUT" ]] && rm -f "$OUT"
sed "s/__ACCENT__/$ACCENT/g" "$TEMPLATE" >"$OUT.tmp" && mv "$OUT.tmp" "$OUT"
echo "Starship accent: $ACCENT"
