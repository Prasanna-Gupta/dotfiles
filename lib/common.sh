#!/usr/bin/env bash
# Prasanna OS — shared helpers for install.sh and module setup scripts.
# Source this file; do not execute it.

# shellcheck disable=SC2034
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; DIM='\033[2m'; RESET='\033[0m'

log()  { echo -e "${GREEN}[ OK ]${RESET} $*"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $*"; }
err()  { echo -e "${RED}[FAIL]${RESET} $*" >&2; }
info() { echo -e "${CYAN}[....]${RESET} $*"; }
step() { echo -e "\n${CYAN}━━ $* ━━${RESET}"; }

DRY_RUN="${DRY_RUN:-false}"
ASSUME_YES="${ASSUME_YES:-false}"

# run CMD... — executes, or prints in dry-run mode
run() {
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${DIM}  would run: $*${RESET}"
    else
        "$@"
    fi
}

have() { command -v "$1" &>/dev/null; }

# kwrite FILE GROUP KEY VALUE  (GROUP may be "A/B" for nested groups)
kwrite() {
    local file="$1" group="$2" key="$3" value="$4"
    local args=(--file "$file")
    local IFS='/'
    for g in $group; do args+=(--group "$g"); done
    unset IFS
    run kwriteconfig6 "${args[@]}" --key "$key" "$value"
}

# kdelete FILE GROUP KEY
kdelete() {
    local file="$1" group="$2" key="$3"
    local args=(--file "$file")
    local IFS='/'
    for g in $group; do args+=(--group "$g"); done
    unset IFS
    run kwriteconfig6 "${args[@]}" --key "$key" --delete
}

# symlink SRC DST — idempotent; backs up a real file at DST to DST.bak.<date>
symlink() {
    local src="$1" dst="$2"
    if [[ ! -e "$src" ]]; then
        err "Source missing: $src"
        return 1
    fi
    if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
        log "Already linked: ${dst/#$HOME/\~}"
        return 0
    fi
    run mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" || -L "$dst" ]]; then
        local bak
        bak="$dst.bak.$(date +%Y%m%d-%H%M%S)"
        warn "Backing up ${dst/#$HOME/\~} → ${bak/#$HOME/\~}"
        run mv "$dst" "$bak"
    fi
    run ln -s "$src" "$dst"
    log "Linked ${dst/#$HOME/\~}"
}

# pkg_install LISTFILE — installs uncommented lines with yay (--needed)
pkg_install() {
    local list="$1"
    have yay || { err "yay not found — install it first (see README)"; return 1; }
    mapfile -t pkgs < <(grep -vE '^\s*(#|$)' "$list" | awk '{print $1}')
    [[ ${#pkgs[@]} -eq 0 ]] && return 0
    local flags=(-S --needed)
    [[ "$ASSUME_YES" == true ]] && flags+=(--noconfirm)
    info "Installing from $(basename "$list"): ${pkgs[*]}"
    run yay "${flags[@]}" "${pkgs[@]}"
}

pkg_installed() { pacman -Qq "$1" &>/dev/null; }
