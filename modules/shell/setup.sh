#!/usr/bin/env bash
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../../lib/common.sh
source "$DOTFILES/lib/common.sh"
S="$DOTFILES/modules/shell"
step "Shell"

# Keep the old ~/.zshrc content: it becomes ~/.zshrc.local (sourced by the new one)
if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" && ! -f "$HOME/.zshrc.local" ]]; then
    run cp "$HOME/.zshrc" "$HOME/.zshrc.local"
    warn "Old ~/.zshrc copied to ~/.zshrc.local — trim anything now duplicated"
fi
symlink "$S/zshrc"       "$HOME/.zshrc"
symlink "$S/aliases.zsh" "$HOME/.config/zsh/aliases.zsh"
symlink "$S/gitconfig"   "$HOME/.gitconfig"
symlink "$DOTFILES/modules/terminal/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# Old v1 kitty include
[[ -L "$HOME/.config/kitty/hyde.conf" || -f "$HOME/.config/kitty/hyde.conf" ]] && run rm -f "$HOME/.config/kitty/hyde.conf"

# Starship: v1 symlinked/copied the repo file; hook 05 now renders it from a template.
st="$HOME/.config/starship.toml"
if [[ -L "$st" ]]; then
    run rm -f "$st"
elif [[ -f "$st" ]] && ! grep -q 'prasanna-os:generated' "$st"; then
    run mv "$st" "$st.bak.$(date +%Y%m%d-%H%M%S)"
    warn "Old starship.toml backed up — prompt is now rendered from modules/shell/starship.toml.tmpl"
fi

if [[ "$(basename "${SHELL:-}")" != zsh ]] && have zsh; then
    run chsh -s "$(command -v zsh)"
    log "Default shell → zsh (takes effect next login)"
fi
have atuin && [[ ! -f "$HOME/.local/share/atuin/history.db" ]] && run atuin import zsh >/dev/null 2>&1 || true
run systemctl enable --now paccache.timer 2>/dev/null || run sudo systemctl enable --now paccache.timer
log "Shell ready (paccache.timer keeps 3 versions of each package)"
