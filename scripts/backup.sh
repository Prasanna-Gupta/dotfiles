#!/usr/bin/env bash

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Backing up KDE..."

KDE_FILES=(
    kdeglobals
    kwinrc
    plasmarc
    konsolerc
    dolphinrc
)

for file in "${KDE_FILES[@]}"; do
    cp "$HOME/.config/$file" "$ROOT/kde/"
done

echo "Backing up Konsole..."
rm -rf "$ROOT/terminal/konsole"
cp -r "$HOME/.local/share/konsole" "$ROOT/terminal/"

echo "Backing up Kvantum..."
rm -rf "$ROOT/qt/Kvantum"
cp -r "$HOME/.config/Kvantum" "$ROOT/qt/"
cp "$HOME/.config/kvantum.kvconfig" "$ROOT/qt/"

echo "Backing up Material You..."
rm -rf "$ROOT/qt/kde-material-you-colors"
cp -r "$HOME/.config/kde-material-you-colors" "$ROOT/qt/"

if [ -d "$HOME/.config/matugen" ]; then
    rm -rf "$ROOT/qt/matugen"
    cp -r "$HOME/.config/matugen" "$ROOT/qt/"
fi

echo "Backing up GTK..."
rm -rf "$ROOT/gtk/gtk-3.0"
rm -rf "$ROOT/gtk/gtk-4.0"

cp -rL "$HOME/.config/gtk-3.0" "$ROOT/gtk/"
cp -rL "$HOME/.config/gtk-4.0" "$ROOT/gtk/"

echo "Updating package list..."
pacman -Qqe > "$ROOT/packages.txt"

echo "Backup complete."
