#!/usr/bin/env bash

set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "== Evergreen Installer =="

if ! command -v pacman >/dev/null; then
    echo "This installer only supports Arch-based distributions."
    exit 1
fi

echo
echo "Installing packages..."

sudo pacman -Syu --needed --noconfirm $(<"$ROOT/packages.txt")

echo
echo "Done."

echo
echo "Run:"
echo "./scripts/restore.sh"
