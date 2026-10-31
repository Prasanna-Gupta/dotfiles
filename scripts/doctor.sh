#!/usr/bin/env bash
# Prasanna OS — health check. Read-only: changes nothing.
#   ./scripts/doctor.sh        (alias: doctor)
DOTFILES="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$DOTFILES/lib/common.sh"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/prasanna"
ok=0; bad=0; meh=0
pass() { echo -e "  ${GREEN}✓${RESET} $*"; ok=$((ok+1)); }
fail() { echo -e "  ${RED}✗${RESET} $*"; bad=$((bad+1)); }
note() { echo -e "  ${YELLOW}!${RESET} $*"; meh=$((meh+1)); }
kread() { kreadconfig6 --file "$1" --group "$2" --key "$3" 2>/dev/null; }

echo -e "\n${CYAN}Prasanna OS doctor${RESET}  $(date '+%F %T')"

step "System"
echo "  $(. /etc/os-release; echo "$PRETTY_NAME") · kernel $(uname -r) · $(plasmashell --version 2>/dev/null)"
gpu="$(nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null)"
[[ -n "$gpu" ]] && pass "NVIDIA: $gpu" || note "nvidia-smi not responding (dGPU asleep in Hybrid mode is normal)"
[[ "${XDG_SESSION_TYPE:-}" == wayland ]] && pass "Session: Wayland" || note "Session: ${XDG_SESSION_TYPE:-unknown} (target is Wayland)"
[[ "$(cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null)" == Y ]] && pass "nvidia_drm modeset=Y" || fail "nvidia_drm modeset is off (Wayland needs it)"
dm=""; [[ -e /etc/systemd/system/display-manager.service ]] && dm="$(basename "$(readlink -f /etc/systemd/system/display-manager.service)" .service)"
echo "  Display manager: ${dm:-none}"
failed_sys="$(systemctl --failed --no-legend 2>/dev/null | wc -l)"; failed_usr="$(systemctl --user --failed --no-legend 2>/dev/null | wc -l)"
(( failed_sys + failed_usr == 0 )) && pass "No failed services" || fail "Failed services: $failed_sys system, $failed_usr user → run: failed"

step "Theme engine"
systemctl --user is-active -q prasanna-theme.path && pass "Wallpaper watcher active" || fail "prasanna-theme.path inactive → systemctl --user enable --now prasanna-theme.path"
pgrep -f kde-material-you-colors >/dev/null && pass "kde-material-you-colors running" || fail "kde-material-you-colors not running (enable it in its widget / autostart)"
if [[ -f "$STATE/accent.env" ]]; then
    # shellcheck disable=SC1091
    source "$STATE/accent.env"; pass "Accent: $ACCENT"
else
    fail "No accent yet → run: prasanna-theme"
fi
last="$(ls -t "$STATE"/logs/update-*.log 2>/dev/null | head -1)"
if [[ -n "$last" ]]; then
    if tail -20 "$last" | grep -q FAIL; then fail "Last sync had failures → $(tail -20 "$last" | grep FAIL | tr '\n' ' ')"; else pass "Last sync clean ($(basename "$last"))"; fi
fi
[[ -d "$HOME/.config/prasanna/hooks" ]] && fail "v1 hooks still in ~/.config/prasanna — run ./install.sh theme"

step "Look"
[[ "$(kread kwinrc Plugins blurEnabled)" == true && "$(kread kwinrc Plugins better_blur_dxEnabled)" == true ]] \
    && fail "Stock Blur AND Better Blur DX both on (conflict)" || pass "Single blur effect"
[[ -n "$(kread kdeglobals QtQuickRendererSettings SceneGraphBackend)" ]] \
    && fail "Qt Quick forced to software rendering (laggy) → ./install.sh kde" || pass "GPU rendering for Qt Quick"
[[ "$(kread kdeglobals KDE widgetStyle)" == Breeze ]] && pass "App style: Breeze" || note "App style: $(kread kdeglobals KDE widgetStyle)"
[[ "$(kread kdeglobals Icons Theme)" == Papirus* ]] && pass "Icons: $(kread kdeglobals Icons Theme)" || note "Icons: $(kread kdeglobals Icons Theme)"
[[ "$(fc-match -f '%{family}' sans-serif)" == Inter* ]] && pass "sans-serif → Inter" || note "sans-serif → $(fc-match -f '%{family}' sans-serif)"
for p in $(grep -vE '^\s*(#|$)' "$DOTFILES/packages/remove.txt" | awk '{print $1}'); do
    pkg_installed "$p" && note "Leftover package: $p   (./install.sh cleanup)"
done

step "Laptop"
if have asusctl; then
    lim="$(cat /sys/class/power_supply/BAT*/charge_control_end_threshold 2>/dev/null | head -1)"
    [[ -n "$lim" && "$lim" -lt 100 ]] && pass "Battery charge limit: $lim%" || note "Battery charges to 100% → ./install.sh asus"
    have supergfxctl && echo "  GPU mode: $(supergfxctl -g 2>/dev/null)"
    echo "  Power profile: $(powerprofilesctl get 2>/dev/null)"
else
    note "asusctl not installed (./install.sh asus)"
fi

step "Safety"
if [[ "$(findmnt -no FSTYPE /)" == btrfs ]]; then
    pkg_installed timeshift-autosnap && pass "Pre-update snapshots on" || note "No pre-update snapshots → ./install.sh snapshots"
    systemctl is-active -q grub-btrfsd 2>/dev/null && pass "Snapshots in GRUB menu" || note "grub-btrfsd not running"
else
    note "Root is $(findmnt -no FSTYPE /) — btrfs snapshots unavailable"
fi
systemctl is-enabled -q paccache.timer 2>/dev/null && pass "Package cache auto-cleaned" || note "paccache.timer off"
dirty="$(git -C "$DOTFILES" status --porcelain 2>/dev/null | wc -l)"
(( dirty == 0 )) && pass "Dotfiles repo clean" || note "Dotfiles repo has $dirty uncommitted change(s)"

echo -e "\n  ${GREEN}$ok ok${RESET} · ${YELLOW}$meh notes${RESET} · ${RED}$bad problems${RESET}\n"
(( bad == 0 ))
