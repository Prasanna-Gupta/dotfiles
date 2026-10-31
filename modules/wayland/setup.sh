#!/usr/bin/env bash
# Wayland on NVIDIA + Plasma 6: checks + per-app flags. Never removes the X11 session.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../../lib/common.sh
source "$DOTFILES/lib/common.sh"
step "Wayland"

modeset="$(cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null || echo '?')"
if [[ "$modeset" == Y ]]; then
    log "nvidia_drm modeset=Y (required for Wayland)"
else
    warn "nvidia_drm modeset is '$modeset'. Add kernel parameter nvidia_drm.modeset=1, then reboot:"
    echo "    sudo nano /etc/default/grub   → GRUB_CMDLINE_LINUX_DEFAULT=\"... nvidia_drm.modeset=1\""
    echo "    sudo grub-mkconfig -o /boot/grub/grub.cfg"
fi

# Chromium/Electron apps: run natively on Wayland (sharp text with scaling, IME, gestures)
for f in code-flags.conf brave-flags.conf chromium-flags.conf electron-flags.conf; do
    symlink "$DOTFILES/modules/wayland/electron-flags.conf" "$HOME/.config/$f"
done

# The SDDM greeter itself is left on X11 on purpose: a Wayland greeter on NVIDIA
# can black-screen, and the greeter has no effect on your session type.
info "At the login screen pick 'Plasma (Wayland)' once — SDDM remembers it."
info "X11 session stays installed as a fallback. After a week without issues: yay -Rns plasma-x11-session"
