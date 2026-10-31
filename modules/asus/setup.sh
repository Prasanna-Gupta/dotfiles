#!/usr/bin/env bash
# ASUS TUF A15: battery health, power profiles, GPU mode — via asus-linux tools.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../../lib/common.sh
source "$DOTFILES/lib/common.sh"
LIMIT="${BATTERY_LIMIT:-80}"
step "ASUS TUF tools"

vendor="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)"
[[ "$vendor" == *ASUS* ]] || { warn "Not an ASUS machine ($vendor) — skipping"; exit 0; }

pkg_install "$DOTFILES/packages/asus.txt"
run sudo systemctl enable --now power-profiles-daemon.service
run sudo systemctl enable --now supergfxd.service 2>/dev/null || true
run sudo systemctl start asusd.service 2>/dev/null || true   # also D-Bus/udev activated

# Battery charge limit: asusctl ≥6.3 syntax, then older syntax, then raw sysfs
set_limit() {
    asusctl battery limit "$LIMIT" 2>/dev/null && return 0
    asusctl -c "$LIMIT" 2>/dev/null && return 0
    local f
    f="$(ls /sys/class/power_supply/BAT*/charge_control_end_threshold 2>/dev/null | head -1)"
    [[ -n "$f" ]] && echo "$LIMIT" | sudo tee "$f" >/dev/null && return 0
    return 1
}
if [[ "$DRY_RUN" == true ]]; then
    echo "  would set battery charge limit to $LIMIT%"
elif set_limit; then
    log "Battery stops charging at $LIMIT% (asusd keeps it across reboots)"
    info "Need a full charge for travel? → asusctl battery oneshot   (or set BATTERY_LIMIT=100)"
else
    warn "Could not set a charge limit — check: asusctl info --show-supported"
fi

if have supergfxctl; then
    mode="$(supergfxctl -g 2>/dev/null || echo unknown)"
    info "GPU mode: $mode  (not changed by this script)"
    cat <<TXT
    • Hybrid      — iGPU drives the desktop, NVIDIA wakes for games/CUDA. Best battery.
    • AsusMuxDgpu — NVIDIA only (your current choice per earlier setup). Smoothest, worst battery.
    Switch with: supergfxctl -m Hybrid   (then log out / reboot as it tells you)
TXT
fi
log "ROG Control Center: launch 'rog-control-center' for fans, profiles, keyboard light"
