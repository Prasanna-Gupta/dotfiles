#!/usr/bin/env bash

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Collecting system information..."

{
    echo "===== System ====="
    uname -a
    echo

    echo "===== Plasma ====="
    plasmashell --version
    echo

    echo "===== GPU ====="
    nvidia-smi --query-gpu=name,driver_version --format=csv,noheader
    echo

    echo "===== OpenGL ====="
    glxinfo | grep "OpenGL renderer"
    echo

    echo "===== GTK ====="
    gsettings get org.gnome.desktop.interface gtk-theme
    gsettings get org.gnome.desktop.interface icon-theme
    gsettings get org.gnome.desktop.interface cursor-theme
    echo

    echo "===== Fonts ====="
    fc-match sans
    fc-match monospace
} > "$ROOT/system/audit.txt"

echo "Audit written to system/audit.txt"
