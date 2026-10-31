#!/usr/bin/env bash
# Prasanna OS — theme orchestrator.
# Triggered by prasanna-theme.path whenever kde-material-you-colors rewrites
# MaterialYouDark.colors (i.e. on wallpaper change). Safe to run by hand:
#   prasanna-theme            # full pipeline
#   prasanna-theme 05         # just hooks whose name starts with 05

set -uo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
export PRASANNA_THEMING="$ROOT"
export STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/prasanna"
LOG_DIR="$STATE_DIR/logs"
LOG="$LOG_DIR/update-$(date +%Y%m%d).log"
mkdir -p "$LOG_DIR"

# One run at a time (the colours file is written several times in a burst)
exec 9>"$STATE_DIR/.lock"
flock -n 9 || { echo "Another theme update is running — skipping"; exit 0; }

# Keep a week of logs
find "$LOG_DIR" -name 'update-*.log' -mtime +7 -delete 2>/dev/null

FILTER="${1:-}"
FAILED=()

echo "=== Theme update $(date '+%F %T') ===" >>"$LOG"
for hook in "$ROOT"/hooks/[0-9]*.sh; do
    name="$(basename "$hook")"
    [[ -n "$FILTER" && "$name" != "$FILTER"* ]] && continue
    if bash "$hook" >>"$LOG" 2>&1; then
        echo "[$(date +%T)] ok    $name" >>"$LOG"
    else
        rc=$?
        echo "[$(date +%T)] FAIL  $name (exit $rc)" >>"$LOG"
        FAILED+=("$name")
        # 01 produces the accent everything else needs — stop if it fails
        [[ "$name" == 01-* ]] && break
    fi
done

if ((${#FAILED[@]})); then
    notify-send -u critical -a "Prasanna OS" "Theme sync failed" \
        "${FAILED[*]}\nLog: ${LOG/#$HOME/\~}" 2>/dev/null
    exit 1
fi
echo "=== done ===" >>"$LOG"
