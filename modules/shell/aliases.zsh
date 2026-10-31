# Prasanna OS — aliases & small functions (sourced by ~/.zshrc)

# Files
if (( $+commands[eza] )); then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -l --icons=auto --group-directories-first --git --time-style=relative'
  alias la='eza -la --icons=auto --group-directories-first --git --time-style=relative'
  alias lt='eza --tree --level=2 --icons=auto --git-ignore'
fi
(( $+commands[bat] )) && alias cat='bat --paging=never --style=plain'
alias df='duf'
alias du='dust'
alias ..='cd ..' ...='cd ../..'
alias mkdir='mkdir -pv'
alias cp='cp -iv' mv='mv -iv'

# Packages (yay)
alias up='yay -Syu'                          # full update (snapshot is taken first if snapshots module is on)
alias get='yay -S'
alias un='yay -Rns'
alias search='yay -Ss'
alias orphans='yay -Qdtq'                    # list orphaned deps
alias cleanup='yay -Rns $(yay -Qdtq) ; paccache -rk2'
alias pkgsize="expac -H M '%m\t%n' | sort -h | tail -20"
alias mirrors='eos-rankmirrors'

# Git
alias g='git'
alias gs='git status -sb'
alias gl='git lg'
alias lg='lazygit'

# System
alias ff='fastfetch'
alias top='btop'
alias ports='ss -tulpn'
alias logs='journalctl -p 3 -b'              # errors from this boot
alias failed='systemctl --failed; systemctl --user --failed'
alias doctor='~/dotfiles/scripts/doctor.sh'
alias theme='prasanna-theme'                 # re-run colour sync manually

# ASUS (only meaningful with the asus module)
if (( $+commands[asusctl] )); then
  alias quiet='asusctl profile set Quiet 2>/dev/null || asusctl profile -P Quiet'
  alias balanced='asusctl profile set Balanced 2>/dev/null || asusctl profile -P Balanced'
  alias perf='asusctl profile set Performance 2>/dev/null || asusctl profile -P Performance'
fi
(( $+commands[supergfxctl] )) && alias gpu='supergfxctl -g'

# y: yazi that cd's into the folder you quit in
y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$tmp"
  cwd="$(<"$tmp")"
  [[ -n "$cwd" && "$cwd" != "$PWD" ]] && cd -- "$cwd"
  rm -f -- "$tmp"
}

# mkcd: make a dir and enter it
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# extract anything
x() {
  case "$1" in
    *.tar.gz|*.tgz) tar xzf "$1" ;; *.tar.xz) tar xJf "$1" ;; *.tar.zst) tar --zstd -xf "$1" ;;
    *.tar.bz2) tar xjf "$1" ;; *.tar) tar xf "$1" ;; *.zip) unzip "$1" ;;
    *.7z) 7z x "$1" ;; *.rar) unrar x "$1" ;; *.gz) gunzip "$1" ;;
    *) echo "x: don't know how to extract '$1'" ;;
  esac
}
