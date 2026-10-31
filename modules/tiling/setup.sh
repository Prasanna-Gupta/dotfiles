#!/usr/bin/env bash
# Keyboard-driven tiling inside Plasma via the Krohnkite KWin script.
# Toggle it off any time in System Settings → Window Management → KWin Scripts.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../../lib/common.sh
source "$DOTFILES/lib/common.sh"
step "Tiling (Krohnkite)"

found=""
for d in "$HOME/.local/share/kwin/scripts/krohnkite" /usr/share/kwin/scripts/krohnkite; do
    [[ -d "$d" ]] && found="$d" && break
done
if [[ -z "$found" ]]; then
    warn "Krohnkite isn't installed. Install it once, then re-run: ./install.sh tiling"
    echo "    System Settings → Window Management → KWin Scripts → Get New… → search 'Krohnkite'"
    exit 0
fi
log "Krohnkite found: ${found/#$HOME/\~}"

G=Script-krohnkite
kwrite kwinrc Plugins krohnkiteEnabled true
kwrite kwinrc "$G" screenGapBetween 8
kwrite kwinrc "$G" screenGapTop 8
kwrite kwinrc "$G" screenGapBottom 8
kwrite kwinrc "$G" screenGapLeft 8
kwrite kwinrc "$G" screenGapRight 8
kwrite kwinrc "$G" enableMonocleLayout true
kwrite kwinrc "$G" enableThreeColumnLayout true
kwrite kwinrc "$G" enableSpreadLayout false
kwrite kwinrc "$G" enableStairLayout false
kwrite kwinrc "$G" enableQuarterLayout false
# Dialogs, pickers and tools that should always float
kwrite kwinrc "$G" floatingClass "org.kde.polkit-kde-authentication-agent-1,org.kde.kdialog,org.kde.plasmashell,org.kde.spectacle,org.kde.kcalc,pavucontrol,rog-control-center,org.kde.kruler,steam,unityhub"
kwrite kwinrc "$G" ignoreClass "krunner,yakuake,spectacle,kded6,ksmserver-logout-greeter"
# Plasma's built-in tile editor (Meta+T) collides with Krohnkite's Meta+T
kwrite kglobalshortcutsrc kwin "Edit Tiles" "none,Meta+T,Toggle Tiles Editor"

have qdbus6 && run qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
log "Tiling on. Keys: docs/KEYBINDS.md   (log out/in once so shortcuts register)"
