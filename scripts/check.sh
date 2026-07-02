#!/usr/bin/env bash

echo "========== Evergreen Health Check =========="

echo
echo "Plasma:"
plasmashell --version

echo
echo "Qt:"
qmake6 --version 2>/dev/null || echo "Qt6 not found"

echo
echo "NVIDIA:"
nvidia-smi --query-gpu=name,driver_version --format=csv,noheader

echo
echo "Material You:"
if [ -d ~/.config/kde-material-you-colors ]; then
    echo "Installed"
else
    echo "Missing"
fi

echo
echo "Kvantum:"
kvantummanager --version 2>/dev/null || echo "Missing"

echo
echo "GTK Theme:"
gsettings get org.gnome.desktop.interface gtk-theme

echo
echo "Icon Theme:"
gsettings get org.gnome.desktop.interface icon-theme

echo
echo "Cursor:"
gsettings get org.gnome.desktop.interface cursor-theme

echo
echo "Done."
