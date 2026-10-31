# Troubleshooting

Start with `./scripts/doctor.sh`. It checks most of the things below.

## Colours didn't change after a wallpaper switch
```bash
systemctl --user status prasanna-theme.path
prasanna-theme && tail -30 ~/.local/state/prasanna/logs/update-$(date +%Y%m%d).log
```
Run one hook alone: `prasanna-theme 03`. If hook 01 fails, kde-material-you-colors isn't
running. Start it from its Plasma widget or with `kde-material-you-colors` in a terminal.

## Kitty didn't recolour
Kitty reloads on `SIGUSR1`. Run `pkill -USR1 -x kitty`. If it still doesn't change, check that
`~/.config/kitty/theme.conf` exists and that `kitty.conf` ends with `include theme.conf`.

## Folder icons stay blue
Hook 06 only works with a Papirus icon theme, `papirus-folders` installed, and the sudoers
rule present (`sudo -l | grep papirus`). Re-run `./install.sh theme`.

## Panel / animations stutter
`kreadconfig6 --file kdeglobals --group QtQuickRendererSettings --key SceneGraphBackend` must
print nothing. If it prints `software`, run `./install.sh kde` and log out.

## Blur missing
Only stock Blur should be on: System Settings → Desktop Effects → Blur ✓, Better Blur ✗.
In kitty the blur only shows on Wayland.

## Login screen didn't update
Needs SilentSDDM at `/usr/share/sddm/themes/silent` and `/etc/sddm-prasanna` owned by you
(`ls -ld /etc/sddm-prasanna`). Re-run `./install.sh theme`.

## Wayland: black screen / falls back to X11
`cat /sys/module/nvidia_drm/parameters/modeset` must be `Y`. Choose "Plasma (X11)" at login to
get back in, then see `modules/wayland/setup.sh` output.

## Battery limit resets to 100%
```bash
asusctl battery info        # or: cat /sys/class/power_supply/BAT*/charge_control_end_threshold
./install.sh asus
```

## Undo tiling
System Settings → Window Management → KWin Scripts → untick Krohnkite → Apply.
