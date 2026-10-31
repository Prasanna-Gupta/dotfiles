#!/usr/bin/env bash
# 04 — inject accent into VS Code (skips quietly if VS Code isn't used)
set -euo pipefail
: "${STATE_DIR:=${XDG_STATE_HOME:-$HOME/.local/state}/prasanna}"
: "${PRASANNA_THEMING:=$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)}"

found=false
for s in "$HOME/.config/Code/User/settings.json" "$HOME/.config/Code - OSS/User/settings.json" "$HOME/.config/VSCodium/User/settings.json"; do
    [[ -f "$s" ]] || continue
    found=true
    python3 "$PRASANNA_THEMING/lib/vscode_inject.py" "$s" "$STATE_DIR/colors.json"
done
$found || echo "No VS Code settings.json found — skipped"
