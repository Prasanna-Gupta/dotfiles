#!/usr/bin/env bash
# KDE Plasma look + behaviour, applied with kwriteconfig6.
#
# Why not symlink kdeglobals/kwinrc like v1? KDE rewrites those files all the
# time (Material You writes colours into kdeglobals, kwin stores tiling UUIDs),
# so symlinked copies keep the repo permanently dirty and carry machine junk.
# Here we only set the keys we actually care about.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../../lib/common.sh
source "$DOTFILES/lib/common.sh"
have kwriteconfig6 || { err "kwriteconfig6 not found — is this Plasma 6?"; exit 1; }

step "KDE Plasma"

# ── Look-and-feel package (custom logout dialog) ─────────────────────────────
symlink "$DOTFILES/modules/kde/look-and-feel/com.prasanna.desktop" \
    "$HOME/.local/share/plasma/look-and-feel/com.prasanna.desktop"
# Applies only its defaults file — does NOT reset your panels/layout
have plasma-apply-lookandfeel && run plasma-apply-lookandfeel --apply com.prasanna.desktop || true

# ── Unified stack: everything reads the MaterialYouDark colour scheme ─────────
kwrite kdeglobals KDE widgetStyle Breeze
kwrite kdeglobals Icons Theme Papirus-Dark
kwrite kdeglobals General TerminalApplication kitty
kwrite kdeglobals General TerminalService kitty.desktop
# Snappier animations (one notch faster than default) — feels more "premium"
kwrite kdeglobals KDE AnimationDurationFactor 0.7071067811865475
# v1 forced Qt Quick software rendering: laggy panel, high CPU. Remove it.
kdelete kdeglobals QtQuickRendererSettings SceneGraphBackend

# Fonts: Inter for UI, JetBrains Mono Nerd for monospace
kwrite kdeglobals General font "Inter,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kwrite kdeglobals General menuFont "Inter,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kwrite kdeglobals General toolBarFont "Inter,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kwrite kdeglobals General smallestReadableFont "Inter,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kwrite kdeglobals General fixed "JetBrainsMono Nerd Font,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
kwrite kdeglobals WM activeFont "Inter,10,-1,5,600,0,0,0,0,0,0,0,0,0,0,1,SemiBold"

# Plasma style "default" = Breeze, which follows the colour scheme (so the
# panel picks up the wallpaper accent). Cursor stays Bibata.
have plasma-apply-desktoptheme && run plasma-apply-desktoptheme default || true
have plasma-apply-cursortheme && run plasma-apply-cursortheme Bibata-Modern-Ice || true

# GTK apps: Breeze GTK reads KDE colours through kde-gtk-config
kwrite gtk-3.0/settings.ini Settings gtk-theme-name Breeze
kwrite gtk-4.0/settings.ini Settings gtk-theme-name Breeze
have gsettings && run gsettings set org.gnome.desktop.interface gtk-theme Breeze || true
have gsettings && run gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark || true
have gsettings && run gsettings set org.gnome.desktop.interface color-scheme prefer-dark || true

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

# ── Effects: one blur, subtle motion, nothing gimmicky ───────────────────────
# Stock Blur only. Better Blur DX + stock Blur both on = conflict (and the AUR
# plugin breaks on every Plasma release). kitty asks KWin for blur itself.
kwrite kwinrc Plugins blurEnabled true
kwrite kwinrc Plugins better_blur_dxEnabled false
kwrite kwinrc Plugins contrastEnabled true
kwrite kwinrc Effect-blur BlurStrength 6
kwrite kwinrc Effect-blur NoiseStrength 2
kwrite kwinrc Plugins magiclampEnabled false
kwrite kwinrc Plugins squashEnabled false
kwrite kwinrc Plugins diminactiveEnabled false
kwrite kwinrc Plugins translucencyEnabled false
kwrite kwinrc Plugins glideEnabled false
kwrite kwinrc Plugins scaleEnabled true
kwrite kwinrc Plugins hidecursorEnabled true
kwrite kwinrc Effect-hidecursor InactivityDuration 3

# ── Behaviour ────────────────────────────────────────────────────────────────
kwrite kwinrc Windows BorderSnapZone 12
kwrite kwinrc Windows Placement Centered
kwrite kwinrc NightColor Active true              # easier on the eyes at night
kwrite kwinrc Xwayland Scale 1
kwrite ksmserverrc General loginMode emptySession # start clean, no restored junk
kwrite kscreenlockerrc Daemon Timeout 10
kwrite krunnerrc General FreeFloating true        # Spotlight-style, centred

# Dolphin: clean chrome
kwrite dolphinrc General ShowFullPath true
kwrite dolphinrc General ShowStatusBar false
kwrite dolphinrc General ShowSelectionToggle false
kwrite dolphinrc MainWindow MenuBar Disabled
kwrite dolphinrc "MainWindow/Toolbar mainToolBar" ToolButtonStyle IconOnly

# Material You: keep accent from wallpaper, slightly more colourful surfaces
kwrite kdeglobals General accentColorFromWallpaper true
mkdir -p "$HOME/.config/kde-material-you-colors"
[[ -f "$HOME/.config/kde-material-you-colors/config.conf" ]] || \
    run cp "$DOTFILES/modules/kde/material-you.conf" "$HOME/.config/kde-material-you-colors/config.conf"

# Fontconfig: make "sans-serif"/"monospace" resolve to Inter/JetBrains Mono everywhere
symlink "$DOTFILES/modules/fontconfig/fonts.conf" "$HOME/.config/fontconfig/fonts.conf"

# Reload KWin without logging out
if have qdbus6; then
    run qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
fi
log "KDE settings applied (log out/in once for fonts + decorations everywhere)"
