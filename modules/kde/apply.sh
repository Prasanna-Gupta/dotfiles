#!/usr/bin/env bash
# KDE Plasma behaviour + performance, applied with kwriteconfig6.
# Does NOT touch: application style, Plasma style, window decoration, icons,
# cursor, splash screen, GTK theme. Those are yours; the optional, matching
# stack lives in look.sh (`./install.sh look`).
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

# ── Defaults that don't change your theme choices ────────────────────────────
kwrite kdeglobals General TerminalApplication kitty
kwrite kdeglobals General TerminalService kitty.desktop
# Snappier animations (one notch faster than default)
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

# Install (not apply) the look-and-feel package so its logout dialog is available
symlink "$DOTFILES/modules/kde/look-and-feel/com.prasanna.desktop" \
    "$HOME/.local/share/plasma/look-and-feel/com.prasanna.desktop"

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
