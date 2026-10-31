#!/usr/bin/env bash
# Make a circular avatar from ~/.face.icon (or the given image) for SDDM/lock screen.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/prasanna"
src="${1:-$HOME/.face.icon}"
[[ -f "$src" ]] || { echo "No image at $src"; exit 1; }
mkdir -p "$STATE"
python3 "$DOTFILES/modules/theming/lib/make_avatar.py" "$src" "$STATE/avatar.png"
sudo /usr/bin/install -m 644 "$STATE/avatar.png" "/var/lib/AccountsService/icons/$USER"
echo "Avatar updated"
