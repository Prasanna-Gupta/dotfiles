#!/usr/bin/env bash
# Prasanna OS v2 — installer. Idempotent: safe to re-run any time.
#
#   ./install.sh                  same as `all`
#   ./install.sh all              packages + theme + kde + shell + wayland + asus + tiling + snapshots
#   ./install.sh kde shell        run only the named modules, in order
#   ./install.sh --dry-run all    show what would happen, change nothing
#   ./install.sh --yes all        no package prompts (yay --noconfirm)
#
# Opt-in modules (never part of `all`):
#   look      matching theme stack (Breeze/Papirus/borderless) — changes your theme choices
#   panel     replace your panels with the minimal floating panel (backs up first)
#   apps      install your app list (packages/apps.txt)
#   cleanup   remove HyDE/old-theme leftovers (packages/remove.txt), asks first
#   doctor    health check, changes nothing

set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES
# shellcheck source=lib/common.sh
source "$DOTFILES/lib/common.sh"

ALL=(packages theme kde shell wayland asus snapshots)
mods=()
for a in "$@"; do
    case "$a" in
        --dry-run) export DRY_RUN=true ;;
        --yes|-y)  export ASSUME_YES=true ;;
        -h|--help) sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        all)       mods+=("${ALL[@]}") ;;
        *)         mods+=("$a") ;;
    esac
done
((${#mods[@]})) || mods=("${ALL[@]}")

[[ $EUID -eq 0 ]] && { err "Run as your user, not root (sudo is used where needed)."; exit 1; }
have pacman || { err "Arch-based systems only."; exit 1; }

echo -e "\n${CYAN}  Prasanna OS v2${RESET}  ·  modules: ${mods[*]}"
[[ "$DRY_RUN" == true ]] && warn "DRY RUN — nothing will be changed"

# Ask for sudo once up front (skip for doctor-only / dry runs)
if [[ "$DRY_RUN" != true && "${mods[*]}" != doctor ]]; then
    sudo -v
    while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
fi

for m in "${mods[@]}"; do
    case "$m" in
        packages)
            step "Packages"
            pkg_install "$DOTFILES/packages/core.txt"
            pkg_install "$DOTFILES/packages/utils.txt" ;;
        theme)     bash "$DOTFILES/modules/theming/setup.sh" ;;
        kde)       bash "$DOTFILES/modules/kde/apply.sh" ;;
        shell)     bash "$DOTFILES/modules/shell/setup.sh" ;;
        wayland)   bash "$DOTFILES/modules/wayland/setup.sh" ;;
        asus)      bash "$DOTFILES/modules/asus/setup.sh" ;;
        tiling)    bash "$DOTFILES/modules/tiling/setup.sh" ;;
        snapshots) bash "$DOTFILES/modules/snapshots/setup.sh" ;;
        look)      bash "$DOTFILES/modules/kde/look.sh" ;;
        panel)     bash "$DOTFILES/modules/kde/panel.sh" ;;
        apps)      step "Apps"; pkg_install "$DOTFILES/packages/apps.txt" ;;
        cleanup)
            step "Cleanup"
            mapfile -t gone < <(grep -vE '^\s*(#|$)' "$DOTFILES/packages/remove.txt" | awk '{print $1}' | while read -r p; do pkg_installed "$p" && echo "$p"; done)
            if ((${#gone[@]})); then
                info "Installed leftovers: ${gone[*]}"
                run yay -Rns "${gone[@]}"     # interactive on purpose — you confirm
            else
                log "Nothing to clean"
            fi ;;
        doctor)    bash "$DOTFILES/scripts/doctor.sh" || true ;;
        *)         err "Unknown module: $m (see ./install.sh --help)"; exit 1 ;;
    esac
done

echo
log "Finished: ${mods[*]}"
[[ " ${mods[*]} " == *" kde "* || " ${mods[*]} " == *" wayland "* ]] && \
    info "Log out, choose 'Plasma (Wayland)' at the login screen, log back in."
info "Check everything with: ./scripts/doctor.sh"
