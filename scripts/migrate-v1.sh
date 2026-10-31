#!/usr/bin/env bash
# One-time step BEFORE switching the repo to v2.
#
# v1 symlinked files like ~/.config/kdeglobals and ~/.config/gtk-3.0 straight
# into the repo. v2 deletes those files from git, so a plain `git checkout`
# would leave dangling links (KDE would forget fonts, colours, everything).
# This script turns every such link into a real file/folder copy first.
#
#   bash <(git show upgrade/v2:scripts/migrate-v1.sh)        # from your ~/dotfiles
set -euo pipefail
DOTFILES="${DOTFILES:-$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/dotfiles")}"
DOTFILES_RAW="$DOTFILES"
DOTFILES="$(readlink -f "$DOTFILES")"
echo "Dotfiles repo: $DOTFILES"
n=0
while IFS= read -r -d '' link; do
    [[ -L "$link" ]] || continue   # may already be handled via another search root
    [[ "$link" == "$DOTFILES"/* || "$link" == "$DOTFILES_RAW"/* ]] && continue
    # Only links that point *directly* into the repo (not e.g. systemd's
    # default.target.wants → ~/.config/systemd/user/x → repo chains)
    imm="$(cd "$(dirname "$link")" && realpath -sm "$(readlink "$link")")" || continue
    [[ "$imm" == "$DOTFILES"/* || "$imm" == "$DOTFILES_RAW"/* ]] || continue
    target="$(readlink -f "$link" || true)"
    if [[ -e "$target" ]]; then
        tmp="$link.prasanna-tmp"
        cp -a --dereference "$target" "$tmp"
        rm "$link"
        mv "$tmp" "$link"
        echo "  materialised ${link/#$HOME/\~}"
        n=$((n+1))
    fi
done < <(find "$HOME/.config" "$HOME/.local/share/plasma" "$HOME/.local/bin" "$HOME" -maxdepth 3 -type l -print0 2>/dev/null)
echo "Done: $n link(s) converted to real files. Now: git checkout upgrade/v2 && ./install.sh all"
