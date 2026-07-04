<div align="center">

# Prasanna OS
### A personal Linux workstation experience built on Arch Linux + KDE Plasma 6

*Minimal. Automated. Material You.*

![Preview](docs/preview.png)

</div>

---

## Philosophy

This is not a collection of isolated dotfiles.
It is a coherent operating system experience where every component works together automatically.

**Change one thing. Everything updates.**
Wallpaper changes
↓
Material You extracts colors
↓
Desktop updates
↓
Terminal updates
↓
Login screen updates
↓
Editor accent updates
↓
Done. No manual work.
---

## System

| Component | Choice |
|-----------|--------|
| OS | Arch Linux |
| Desktop | KDE Plasma 6 |
| Display Server | Wayland |
| Display Manager | SDDM + SilentSDDM |
| Color Engine | kde-material-you-colors |
| Terminal | Kitty |
| Shell | Zsh + Starship |
| Editor | VS Code + JetBrains |
| Font | Inter + CaskaydiaCove Nerd Font |

---

## Modules

### 🎨 Dynamic Theming Engine
The core of Prasanna OS. A hook-based automation pipeline that synchronizes colors across every component.

**Pipeline:**
MaterialYouDark.colors (kde-material-you-colors)
↓ systemd path watcher
~/.config/prasanna/update.sh (orchestrator)
↓
01-colors.sh   → extract accent from KDE
02-wallpaper.sh → sync wallpaper to SDDM
03-sddm.sh     → regenerate SDDM config via matugen
04-terminal.sh → regenerate kitty theme via matugen
05-vscode.sh   → inject accent into VS Code settings
06-starship.sh → update prompt accent color
Triggers automatically on wallpaper change. Zero manual steps.

### 🔐 Login Experience
SilentSDDM theme with:
- Dynamic wallpaper (always matches desktop)
- Material You accent colors
- Glassmorphism UI
- Frosted blur background
- Inter typography
- Minimal pill-shaped controls
- Auto-updates when wallpaper changes

### 💻 Terminal
Kitty terminal with live Material You theming.
Colors reload without restarting the terminal (SIGUSR1).

### 🐚 Shell
Zsh + Starship prompt with Material You accent on directory and git indicators.

### 🖥️ VS Code
Catppuccin Macchiato base with Material You accent injected on:
- Status bar
- Cursor
- Selections
- Activity badge
- Tab indicators

### 🎭 KDE Plasma
- Klassy window decorations
- Layan theme
- Kvantum Qt styling
- Material You color scheme
- Colloid + Tela Circle icons
- Bibata cursor

### 🌿 GTK
GTK 3 + 4 theming consistent with KDE appearance.

---

## Installation

> Designed for Arch Linux + KDE Plasma 6. Single machine or multi-machine.

```bash
# Clone
git clone https://github.com/Prasanna-Gupta/dotfiles.git ~/dotfiles

# Review what will happen
bash ~/dotfiles/install.sh --dry-run

# Install
bash ~/dotfiles/install.sh
```

The installer:
- Installs all packages from `packages.txt`
- Creates symlinks from `~/dotfiles/modules/` to `~/.config/`
- Sets up SDDM config ownership
- Installs systemd path watcher
- Configures sudoers for passwordless hook operations
- Runs initial theme synchronization

Log out and back in after installation to apply all changes.

### Prerequisites
```bash
# Install yay (AUR helper) if not present
pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si

# Install SilentSDDM theme
# https://github.com/uiriansan/SilentSDDM
```

---

## Repository Structure
~/dotfiles/
├── install.sh                    # Entry point — idempotent installer
├── packages.txt                  # Full package list
│
├── modules/
│   ├── theming/                  # Prasanna OS automation engine
│   │   ├── hooks/                # 01-06 numbered hooks
│   │   ├── templates/            # matugen templates
│   │   └── update.sh             # Orchestrator
│   ├── terminal/                 # Kitty + Starship
│   ├── kde/                      # KDE Plasma configs
│   ├── shell/                    # Git config
│   └── gtk/                      # GTK 3 + 4 theming
│
├── system/
│   ├── systemd/                  # prasanna-theme path watcher
│   ├── sudoers/                  # passwordless hook rules
│   └── sddm/                     # SDDM config template
│
├── qt/                           # Qt/Kvantum themes
├── docs/                         # Documentation
└── local/                        # Machine-specific (gitignored)
---

## How It Works

### Color Pipeline
`kde-material-you-colors` runs as a user daemon and writes `~/.local/share/color-schemes/MaterialYouDark.colors` whenever the wallpaper changes. A systemd path unit watches this file and triggers the Prasanna OS orchestrator.

The orchestrator runs hooks in order. Each hook is independent and testable:
```bash
bash ~/.config/prasanna/hooks/01-colors.sh  # test individually
bash ~/.config/prasanna/update.sh           # run full pipeline
```

Logs at `~/.local/share/prasanna/logs/`.

### SDDM Wallpaper Sync
SDDM runs as a system user and cannot access home directories. Hook 02 copies the active wallpaper to `/usr/share/sddm/themes/silent/backgrounds/current.jpg` using ACL permissions — no sudo required.

### Generated Files
matugen templates produce generated output that is **never tracked in git**. Only templates are tracked. Generated files are gitignored.

---

## Roadmap

- [x] Dynamic wallpaper sync to SDDM
- [x] Material You color extraction
- [x] SDDM theming automation
- [x] Kitty terminal theming
- [x] VS Code accent injection
- [x] Starship prompt theming
- [x] Symlink-based installer
- [ ] JetBrains theming
- [ ] Dunst notification theming
- [ ] Firefox theming
- [ ] Waybar theming
- [ ] Animation polish
- [ ] Multi-monitor support

---

## Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md).

---

## Credits

- [SilentSDDM](https://github.com/uiriansan/SilentSDDM) — SDDM theme
- [kde-material-you-colors](https://github.com/luisbocanegra/kde-material-you-colors) — Material You for KDE
- [matugen](https://github.com/InioX/matugen) — Material You color generation
- [Klassy](https://github.com/paulmcauley/klassy) — Window decorations

---

<div align="center">
<sub>Built for personal use. Evolved continuously.</sub>
</div>
