#!/usr/bin/env bash
# 01 — read the accent KDE/Material You just generated → $STATE_DIR/accent.env
set -euo pipefail
: "${STATE_DIR:=${XDG_STATE_HOME:-$HOME/.local/state}/prasanna}"
mkdir -p "$STATE_DIR"

COLORS_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/color-schemes/MaterialYouDark.colors"
[[ -f "$COLORS_FILE" ]] || { echo "MaterialYouDark.colors not found — is kde-material-you-colors running?"; exit 1; }

# Prefer [General] AccentColor, fall back to DecorationFocus
raw="$(awk -F= '/^\[General\]/{g=1;next} /^\[/{g=0} g&&$1=="AccentColor"{print $2;exit}' "$COLORS_FILE")"
[[ -z "$raw" ]] && raw="$(grep -m1 '^DecorationFocus=' "$COLORS_FILE" | cut -d= -f2)"
raw="$(tr -d ' \r\n' <<<"$raw")"

# KDE writes either "#rrggbb" or "r,g,b" — normalise to hex
if [[ "$raw" =~ ^#?([0-9a-fA-F]{6})$ ]]; then
    hex="#${BASH_REMATCH[1],,}"
elif [[ "$raw" =~ ^([0-9]{1,3}),([0-9]{1,3}),([0-9]{1,3})$ ]]; then
    hex="$(printf '#%02x%02x%02x' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}")"
else
    echo "Could not parse accent: '$raw'"; exit 1
fi

cat >"$STATE_DIR/accent.env" <<ENV
ACCENT=$hex
ACCENT_R=$((16#${hex:1:2}))
ACCENT_G=$((16#${hex:3:2}))
ACCENT_B=$((16#${hex:5:2}))
ENV
echo "Accent: $hex"
