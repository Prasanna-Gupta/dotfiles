#!/usr/bin/env bash
# OPTIONAL (./install.sh look): the "everything follows the wallpaper" stack.
# Not part of `all`. Changes application style, Plasma style, window
# decoration, icons, cursor and GTK theme. Your splash screen is never touched.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../../lib/common.sh
source "$DOTFILES/lib/common.sh"
have kwriteconfig6 || { err "kwriteconfig6 not found — is this Plasma 6?"; exit 1; }
step "Look (optional matching stack)"

kwrite kdeglobals KDE widgetStyle Breeze
kwrite kdeglobals Icons Theme Papirus-Dark
have plasma-apply-desktoptheme && run plasma-apply-desktoptheme default || true
have plasma-apply-cursortheme && run plasma-apply-cursortheme Bibata-Modern-Ice || true

# GTK apps: Breeze GTK reads KDE colours through kde-gtk-config
kwrite gtk-3.0/settings.ini Settings gtk-theme-name Breeze
kwrite gtk-4.0/settings.ini Settings gtk-theme-name Breeze
have gsettings && run gsettings set org.gnome.desktop.interface gtk-theme Breeze || true
have gsettings && run gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark || true

# ── Window decorations: borderless, three buttons on the right ───────────────
deco_lib=org.kde.breeze; deco_theme=Breeze
if find /usr/lib/qt6/plugins -iname '*klassy*' 2>/dev/null | grep -q .; then
    deco_lib=org.kde.klassy; deco_theme=Klassy
fi
kwrite kwinrc org.kde.kdecoration2 library "$deco_lib"
kwrite kwinrc org.kde.kdecoration2 theme "$deco_theme"
kwrite kwinrc org.kde.kdecoration2 BorderSize None
kwrite kwinrc org.kde.kdecoration2 BorderSizeAuto false
kwrite kwinrc org.kde.kdecoration2 ButtonsOnLeft ""
kwrite kwinrc org.kde.kdecoration2 ButtonsOnRight IAX
log "Window decoration: $deco_theme"

have qdbus6 && run qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
log "Matching look applied"
