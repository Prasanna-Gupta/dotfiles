#!/usr/bin/env bash

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Restoring KDE..."

KDE_FILES=(
    kdeglobals
    kwinrc
    plasmarc
    konsolerc
    dolphinrc
)

for file in "${KDE_FILES[@]}"; do
    cp "$ROOT/kde/$file" "$HOME/.config/"
done

echo "Restoring Konsole..."
rm -rf "$HOME/.local/share/konsole"
cp -r "$ROOT/terminal/konsole" "$HOME/.local/share/"

echo "Restoring Kvantum..."
rm -rf "$HOME/.config/Kvantum"
cp -r "$ROOT/qt/Kvantum" "$HOME/.config/"
cp "$ROOT/qt/kvantum.kvconfig" "$HOME/.config/"

echo "Restoring Material You..."
rm -rf "$HOME/.config/kde-material-you-colors"
cp -r "$ROOT/qt/kde-material-you-colors" "$HOME/.config/"

if [ -d "$ROOT/qt/matugen" ]; then
    rm -rf "$HOME/.config/matugen"
    cp -r "$ROOT/qt/matugen" "$HOME/.config/"
fi

echo "Restoring GTK..."
rm -rf "$HOME/.config/gtk-3.0"
rm -rf "$HOME/.config/gtk-4.0"

cp -r "$ROOT/gtk/gtk-3.0" "$HOME/.config/"
cp -r "$ROOT/gtk/gtk-4.0" "$HOME/.config/"

echo
echo "Configuration restored."
echo "Log out and back in (or reboot) for all changes to take effect."
