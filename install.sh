#!/bin/bash
# Prasanna OS - Install Script
# Idempotent: safe to run multiple times
# Usage: bash install.sh [--dry-run]

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'

log()  { echo -e "${GREEN}[OK]${RESET} $*"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $*"; }
err()  { echo -e "${RED}[ERR]${RESET} $*"; }
info() { echo -e "${CYAN}[INFO]${RESET} $*"; }

symlink() {
    local src="$1"
    local dst="$2"
    local dst_dir
    dst_dir="$(dirname "$dst")"

    if [ ! -e "$src" ]; then
        err "Source does not exist: $src"
        return 1
    fi

    mkdir -p "$dst_dir"

    if $DRY_RUN; then
        info "DRY-RUN: ln -sf $src -> $dst"
        return 0
    fi

    # Backup existing file if it's not already a symlink to us
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        warn "Backing up existing: $dst -> $dst.bak"
        mv "$dst" "$dst.bak"
    elif [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        log "Already linked: $dst"
        return 0
    fi

    ln -sf "$src" "$dst"
    log "Linked: $dst -> $src"
}

install_packages() {
    info "Installing packages..."
    if ! command -v yay &>/dev/null; then
        err "yay not found. Install yay first."
        exit 1
    fi

    if [ -f "$DOTFILES/packages.txt" ]; then
        yay -S --needed --noconfirm - < "$DOTFILES/packages.txt"
        log "Packages installed"
    else
        warn "packages.txt not found, skipping"
    fi
}

setup_theming_engine() {
    info "Setting up Prasanna OS theming engine..."

    # Create runtime directories (not tracked in git)
    mkdir -p "$HOME/.config/prasanna/"{hooks,colors,wallpaper}
    mkdir -p "$HOME/.local/share/prasanna/logs"
    mkdir -p "$HOME/.config/matugen/templates"

    # Symlink hooks
    for hook in "$DOTFILES/modules/theming/hooks/"*.sh; do
        local name
        name=$(basename "$hook")
        symlink "$hook" "$HOME/.config/prasanna/hooks/$name"
    done

    # Symlink Python helper
    if [ -f "$DOTFILES/modules/theming/hooks/vscode_inject.py" ]; then
        symlink "$DOTFILES/modules/theming/hooks/vscode_inject.py" \
            "$HOME/.config/prasanna/hooks/vscode_inject.py"
    fi

    # Symlink orchestrator
    symlink "$DOTFILES/modules/theming/update.sh" \
        "$HOME/.config/prasanna/update.sh"
    chmod +x "$HOME/.config/prasanna/update.sh"

    # Symlink matugen templates
    symlink "$DOTFILES/modules/theming/templates/sddm.conf.tmpl" \
        "$HOME/.config/matugen/templates/sddm.conf.tmpl"
    symlink "$DOTFILES/modules/theming/templates/kitty-theme.conf" \
        "$HOME/.config/matugen/templates/kitty-theme.conf"

    # Write matugen config.toml (not symlinked - contains machine paths)
    cat > "$HOME/.config/matugen/config.toml" << TOMLEOF
[config]
mode = "dark"
source_color_index = 0

[templates.sddm]
input_path = "$HOME/.config/matugen/templates/sddm.conf.tmpl"
output_path = "$HOME/.config/matugen/sddm-colors.conf"
post_hook = "sudo cp $HOME/.config/matugen/sddm-colors.conf /etc/sddm-prasanna/prasanna.conf"

[templates.kitty]
input_path = "$HOME/.config/matugen/templates/kitty-theme.conf"
output_path = "$HOME/.config/kitty/theme.conf"
post_hook = "kill -SIGUSR1 \$(pgrep -x kitty) 2>/dev/null || true"
TOMLEOF
    log "matugen config.toml written"
}

setup_sddm() {
    info "Setting up SDDM..."

    # Create owned config directory
    sudo mkdir -p /etc/sddm-prasanna/

    # Copy base config (will be overwritten by matugen on first run)
    if [ ! -f /etc/sddm-prasanna/prasanna.conf ]; then
        sudo cp "$DOTFILES/system/sddm/prasanna.conf.tmpl" \
            /etc/sddm-prasanna/prasanna.conf
        log "SDDM base config installed"
    else
        log "SDDM config already exists, skipping"
    fi

    # Symlink into theme directory
    THEME_CONF="/usr/share/sddm/themes/silent/configs/prasanna.conf"
    if [ ! -L "$THEME_CONF" ]; then
        sudo ln -sf /etc/sddm-prasanna/prasanna.conf "$THEME_CONF"
        log "SDDM theme config symlinked"
    else
        log "SDDM symlink already exists"
    fi

    # Set up ACL for wallpaper sync (no sudo needed in hooks)
    sudo setfacl -m "u:$USER:rwx" /usr/share/sddm/themes/silent/backgrounds/
    log "SDDM backgrounds ACL set"
}

setup_sudoers() {
    info "Setting up sudoers rules..."
    local src="$DOTFILES/system/sudoers/prasanna-hooks"

    if [ ! -f "$src" ]; then
        warn "sudoers file not found at $src, skipping"
        return
    fi

    # Replace hardcoded username with current user
    local tmp
    tmp=$(mktemp)
    # Only replace standalone 'asur' username, not inside paths like root:rootsed "s|^asur |$USER |g" "$src" > "$tmp"

    sudo cp "$tmp" /etc/sudoers.d/prasanna-hooks
    sudo chmod 440 /etc/sudoers.d/prasanna-hooks
    rm -f "$tmp"

    if sudo visudo -c -f /etc/sudoers.d/prasanna-hooks; then
        log "Sudoers rules installed"
    else
        err "Sudoers syntax error — removing"
        sudo rm /etc/sudoers.d/prasanna-hooks
        exit 1
    fi
}

setup_systemd() {
    info "Setting up systemd units..."

    local systemd_user="$HOME/.config/systemd/user"
    mkdir -p "$systemd_user"

    symlink "$DOTFILES/system/systemd/prasanna-theme.path" \
        "$systemd_user/prasanna-theme.path"
    symlink "$DOTFILES/system/systemd/prasanna-theme.service" \
        "$systemd_user/prasanna-theme.service"

    if ! $DRY_RUN; then
        systemctl --user daemon-reload
        systemctl --user enable --now prasanna-theme.path
        log "systemd path watcher enabled"
    fi
}

setup_terminal() {
    info "Setting up terminal..."

    symlink "$DOTFILES/modules/terminal/kitty/kitty.conf" \
        "$HOME/.config/kitty/kitty.conf"
    symlink "$DOTFILES/modules/terminal/kitty/hyde.conf" \
        "$HOME/.config/kitty/hyde.conf"
    symlink "$DOTFILES/modules/terminal/starship/starship.toml" \
        "$HOME/.config/starship.toml"
}

setup_kde() {
    info "Setting up KDE configs..."

    symlink "$DOTFILES/modules/kde/kdeglobals" "$HOME/.config/kdeglobals"
    symlink "$DOTFILES/modules/kde/kwinrc" "$HOME/.config/kwinrc"
    symlink "$DOTFILES/modules/kde/plasmarc" "$HOME/.config/plasmarc"
    symlink "$DOTFILES/modules/kde/dolphinrc" "$HOME/.config/dolphinrc"
}

setup_shell() {
    info "Setting up shell..."
    symlink "$DOTFILES/modules/shell/.gitconfig" "$HOME/.gitconfig"
}

setup_gtk() {
    info "Setting up GTK..."
    symlink "$DOTFILES/modules/gtk/gtk-3.0" "$HOME/.config/gtk-3.0"
    symlink "$DOTFILES/modules/gtk/gtk-4.0" "$HOME/.config/gtk-4.0"
}

run_initial_theme() {
    info "Running initial theme synchronization..."
    if ! $DRY_RUN; then
        bash "$HOME/.config/prasanna/update.sh"
        log "Initial theme sync complete"
    fi
}

# ── Main ──────────────────────────────────────────────────────────────────────

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║        Prasanna OS Installer          ║"
echo "╚═══════════════════════════════════════╝"
echo ""

$DRY_RUN && warn "DRY RUN MODE — no changes will be made"
echo ""

install_packages
setup_theming_engine
setup_sddm
setup_sudoers
setup_systemd
setup_terminal
setup_kde
setup_shell
setup_gtk
run_initial_theme

echo ""
echo "╔═══════════════════════════════════════╗"
echo "║     Installation complete!            ║"
echo "║     Log out and back in to apply      ║"
echo "║     all KDE and SDDM changes.         ║"
echo "╚═══════════════════════════════════════╝"
echo ""
