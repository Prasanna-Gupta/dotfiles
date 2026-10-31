#!/usr/bin/env bash
# Replace current Plasma panels with the minimal floating panel (panel.js).
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../../lib/common.sh
source "$DOTFILES/lib/common.sh"
step "Panel"
APPLETS="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
bak="$APPLETS.bak.$(date +%Y%m%d-%H%M%S)"
run cp "$APPLETS" "$bak"
log "Layout backed up → ${bak/#$HOME/\~}"
run qdbus6 org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "$(cat "$DOTFILES/modules/kde/panel.js")"
log "New panel created. Don't like it? Restore with:"
echo "    kquitapp6 plasmashell; cp '$bak' '$APPLETS'; kstart plasmashell"
