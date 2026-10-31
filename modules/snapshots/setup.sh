#!/usr/bin/env bash
# Snapshot before every pacman update + boot old snapshots from GRUB.
# Requires a btrfs root. Uses Timeshift (already on EndeavourOS) — no new tooling to learn.
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../../lib/common.sh
source "$DOTFILES/lib/common.sh"
step "Snapshot safety"

fs="$(findmnt -no FSTYPE /)"
if [[ "$fs" != btrfs ]]; then
    warn "Root filesystem is '$fs', not btrfs — skipping."
    echo "    Timeshift can still do rsync snapshots: open Timeshift → RSYNC → schedule daily."
    echo "    (Pre-update auto-snapshots on rsync are slow, so they're not enabled here.)"
    exit 0
fi

pkg_install "$DOTFILES/packages/snapshots.txt"

# Timeshift must be in btrfs mode; create the first snapshot (also initialises config)
if ! sudo timeshift --list >/dev/null 2>&1 || ! sudo timeshift --list 2>/dev/null | grep -q 'Mode.*BTRFS'; then
    info "Initialising Timeshift in BTRFS mode with a baseline snapshot…"
    run sudo timeshift --btrfs --create --comments "prasanna-os baseline" --tags D
fi

# Keep 5 pre-update snapshots instead of 3
if [[ -f /etc/timeshift-autosnap.conf ]]; then
    run sudo sed -i 's/^maxSnapshots=.*/maxSnapshots=5/' /etc/timeshift-autosnap.conf
fi

if [[ -d /boot/grub ]]; then
    # Drop-in override (survives grub-btrfs package updates)
    run sudo mkdir -p /etc/systemd/system/grub-btrfsd.service.d
    if [[ "$DRY_RUN" != true ]]; then
        printf '[Service]\nExecStart=\nExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto\n' |
            sudo tee /etc/systemd/system/grub-btrfsd.service.d/override.conf >/dev/null
    fi
    run sudo systemctl daemon-reload
    run sudo systemctl enable --now grub-btrfsd.service
    run sudo grub-mkconfig -o /boot/grub/grub.cfg
    log "Snapshots will show in GRUB → 'EndeavourOS snapshots'"
else
    warn "No /boot/grub (systemd-boot?) — snapshots are taken, but not bootable from the menu."
    echo "    Restore from a live USB with: timeshift --restore"
fi
log "Every 'yay -Syu' now snapshots first (keeps 5)."
