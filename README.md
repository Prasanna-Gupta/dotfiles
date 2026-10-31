<div align="center">

# Prasanna OS
### EndeavourOS + KDE Plasma 6 (Wayland) on an ASUS TUF A15

*Minimal. Automated. Material You.*

<!-- add a screenshot: spectacle -b -n -o docs/preview.png -->

</div>

---

## Idea

**Change the wallpaper and everything else follows.**

```
wallpaper ─▶ kde-material-you-colors ─▶ MaterialYouDark.colors
                                            │  (systemd path watcher)
                                            ▼
                                     prasanna-theme
   01 colors    read KDE accent
   02 wallpaper cache it, copy to the login screen
   03 matugen   ONE run seeded from that accent → kitty · SDDM · colors.json
   04 vscode    accent → status bar, cursor, selections, buttons
   05 starship  render prompt from template
   06 icons     Papirus folder colour → nearest match to the accent
```

v2 uses **one visual stack where every piece reads the same colour scheme**,
so any wallpaper looks deliberate everywhere:

| Layer | Choice | Follows Material You? |
|---|---|---|
| Qt app style | Breeze | ✓ |
| Plasma style (panel, popups) | Breeze ("default") | ✓ |
| GTK apps | Breeze-GTK via kde-gtk-config | ✓ |
| Window borders | Klassy if installed, else Breeze · borderless · `– □ ×` | ✓ |
| Icons | Papirus-Dark, folders recoloured to accent | ✓ |
| Terminal | kitty, blur from KWin, fixed readable ANSI colours | chrome only |
| Fonts | Inter (UI) · JetBrains Mono Nerd (code) | — |
| Cursor | Bibata Modern Ice | — |
| Effects | stock Blur, Scale, hide idle cursor, Night Light | — |

## Utilities

| Module | What you get |
|---|---|
| `shell` | zsh + Starship, `fzf` (Ctrl+T / Alt+C), `atuin` (Ctrl+R history search), `zoxide` (`z proj`), eza/bat aliases, `y` (yazi that cd's), `x` (extract anything), weekly package-cache cleanup |
| `asus` | battery stops at **80%** (`BATTERY_LIMIT=…` to change), power profiles (`quiet` / `balanced` / `perf`), ROG Control Center, GPU mode info |
| `tiling` | Krohnkite auto-tiling with 8px gaps; dialogs float. Keys → [docs/KEYBINDS.md](docs/KEYBINDS.md) |
| `snapshots` | Timeshift snapshot before every `yay -Syu` (keeps 5), bootable from GRUB |
| `wayland` | NVIDIA checks, native-Wayland flags for VS Code / Brave / Electron |
| `doctor` | one command that tells you what's healthy and what isn't |

## Install

```bash
git clone https://github.com/Prasanna-Gupta/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run all     # preview
./install.sh all               # do it
./scripts/doctor.sh            # verify
```

Then log out and pick **Plasma (Wayland)** at the login screen.

Every module is independent and re-runnable: `./install.sh kde`, `./install.sh asus`, …
Opt-in extras (not in `all`): `panel` (minimal floating panel), `apps` (your app list), `cleanup` (remove leftovers).

**Coming from v1?** Read [docs/MIGRATION.md](docs/MIGRATION.md) first. One command keeps your desktop intact during the switch.

### Prerequisites
- `yay`
- Optional: [SilentSDDM](https://github.com/uiriansan/SilentSDDM) for the synced login screen (everything else works without it)
- Optional: Krohnkite (System Settings → KWin Scripts → Get New) for tiling

## Layout

```
install.sh              entry point (modules, --dry-run, --yes)
lib/common.sh           shared helpers (symlink, kwrite, run)
packages/               core · utils · asus · snapshots · apps (opt-in) · remove
modules/
  theming/              update.sh + hooks/01-06 + templates/ + lib/ (python helpers)
  kde/                  apply.sh (kwriteconfig6 keys), panel.js, look-and-feel/
  shell/                zshrc, aliases.zsh, starship.toml.tmpl, gitconfig
  terminal/kitty/       kitty.conf
  asus/ tiling/ snapshots/ wayland/ fontconfig/
system/                 systemd user units, sudoers template
scripts/                doctor.sh, set-avatar.sh, migrate-v1.sh
docs/                   MIGRATION, KEYBINDS, troubleshooting, material-you
```

**Design rules**
- KDE files that KDE itself rewrites (`kdeglobals`, `kwinrc`, …) are **not** symlinked. `kde/apply.sh` sets just the keys that matter, so the repo stays clean.
- Generated files never live in the repo. Runtime state goes to `~/.local/state/prasanna/`.
- Hooks fail soft: a missing app (no VS Code, no SDDM theme) is skipped, not an error.
- sudo is only used for exact, listed commands (`/etc/sudoers.d/prasanna-hooks`).

## Credits
[kde-material-you-colors](https://github.com/luisbocanegra/kde-material-you-colors) ·
[matugen](https://github.com/InioX/matugen) ·
[SilentSDDM](https://github.com/uiriansan/SilentSDDM) ·
[Klassy](https://github.com/paulmcauley/klassy) ·
[asus-linux](https://asus-linux.org) ·
[Krohnkite](https://github.com/anametologin/krohnkite) ·
[Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme)
