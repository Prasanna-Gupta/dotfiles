# Moving from v1 to v2

Takes about 10 minutes. Nothing here deletes your settings. Every file that gets replaced is backed up next to the original as `*.bak.<date>`.

## 0. Safety net
```bash
sudo timeshift --create --comments "before prasanna-os v2"   # if you use Timeshift
```

## 1. Get the branch
```bash
cd ~/dotfiles
git fetch origin
git status                      # commit or stash anything uncommitted first
```

## 2. Un-link v1 files (important)
v1 symlinked `~/.config/kdeglobals`, `kwinrc`, `gtk-3.0/`, the hooks, and more straight into the repo.
v2 removes those files from git, so switching branches without this step would leave KDE
pointing at nothing. This converts each link into a normal file with the same content:
```bash
bash <(git show origin/upgrade/v2:scripts/migrate-v1.sh)
```

## 3. Switch and install
```bash
git checkout upgrade/v2
./install.sh --dry-run all      # read what it will do
./install.sh all
```

## 4. Log out → choose **Plasma (Wayland)** → log in
Then change your wallpaper once and run:
```bash
./scripts/doctor.sh
```

## 5. Optional
```bash
./install.sh cleanup            # remove dunst, rofi, waybar, kvantum, old themes… (asks first)
./install.sh panel              # minimal floating panel (old layout backed up)
```

## What changed, and why

| v1 | v2 | Why |
|---|---|---|
| Layan + Utterly-Round + Kvantum (unused) + Decay-Green GTK + Tela green icons | Breeze everywhere + Papirus | Everything follows the wallpaper accent. Green themes clashed with non-green wallpapers |
| Stock Blur **and** Better Blur DX on | stock Blur only | They conflict, and the AUR plugin breaks on Plasma updates |
| `SceneGraphBackend=software` in kdeglobals | removed | Forced CPU rendering. This was the main cause of the laggy panel |
| matugen ran twice per wallpaper change (hooks 03 + 04) | once, seeded from the KDE accent | Faster, and terminal/SDDM/VS Code now match KDE exactly |
| SDDM colours written with `sudo cp` from a systemd service | `/etc/sddm-prasanna` owned by you | `sudo` can't prompt from a background service, so that step failed silently |
| Kitty ANSI green/red = wallpaper colours | fixed ANSI palette | `git diff` additions turned pink on pink wallpapers |
| Accent parse expected `#hex` only | handles `r,g,b` too | KDE often writes `57,113,61` |
| `install.sh` sudoers step installed an **empty** file | fixed, exact-command rules | A stray comment had swallowed the `sed` command |
| `setup_look_and_feel` defined after main, never ran | runs in `kde` module | Your custom logout dialog is now actually applied |
| `/home/asur` hard-coded | `$HOME` / `$USER` | Works on any machine or user |
| Single 300-package list with `--noconfirm` (incl. `linux`, `grub`) | core / utils / asus / snapshots / apps | Installing the dotfiles doesn't touch your kernel or bootloader |
| hyde.conf, wallbash, Evergreen scripts, duplicate gtk/sddm/shell trees | gone | Dead code |

## Rolling back
```bash
git checkout main
# restore any file from its backup, e.g.
mv ~/.zshrc.bak.<date> ~/.zshrc
systemctl --user daemon-reload
```
Old engine files are kept in `~/.local/state/prasanna/v1-backup/`.
