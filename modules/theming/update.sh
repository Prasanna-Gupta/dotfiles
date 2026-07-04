#!/bin/bash
# Prasanna OS Theme Orchestrator
# Single entry point for all theme updates

HOOK_DIR="$HOME/.config/prasanna/hooks"
LOG_DIR="$HOME/.local/share/prasanna/logs"
LOG="$LOG_DIR/update-$(date +%Y%m%d).log"

mkdir -p "$LOG_DIR"
echo "=== Theme update started: $(date) ===" >> "$LOG"

for hook in "$HOOK_DIR"/[0-9]*.sh; do
    HOOK_NAME=$(basename "$hook")
    echo "[$(date +%H:%M:%S)] Starting $HOOK_NAME" >> "$LOG"
    
    if bash "$hook" >> "$LOG" 2>&1; then
        echo "[$(date +%H:%M:%S)] OK: $HOOK_NAME" >> "$LOG"
    else
        echo "[$(date +%H:%M:%S)] FAILED: $HOOK_NAME" >> "$LOG"
        notify-send -u critical "Prasanna OS" \
            "Theme update failed at $HOOK_NAME\nCheck $LOG"
        exit 1
    fi
done

echo "=== Theme update complete: $(date) ===" >> "$LOG"
notify-send -i preferences-desktop-theme "Prasanna OS" "Theme synchronized"
