#!/usr/bin/env python3
"""Inject Material You colours into VS Code's workbench.colorCustomizations.

Usage: vscode_inject.py <settings.json> <colors.json>
Only the keys below are touched; the rest of your settings are preserved.
A one-time backup is written to settings.json.prasanna-backup.
"""
import json
import re
import shutil
import sys
from pathlib import Path

settings_path, colors_path = Path(sys.argv[1]), Path(sys.argv[2])
c = json.loads(colors_path.read_text())

raw = settings_path.read_text()
backup = settings_path.with_suffix(".json.prasanna-backup")
if not backup.exists():
    shutil.copy2(settings_path, backup)

# VS Code allows JSONC: strip comments (not inside strings) + trailing commas
clean = re.sub(r'("(?:\\.|[^"\\])*")|//[^\n]*|/\*.*?\*/',
               lambda m: m.group(1) or "", raw, flags=re.S)
clean = re.sub(r",(\s*[}\]])", r"\1", clean)
try:
    settings = json.loads(clean) if clean.strip() else {}
except json.JSONDecodeError as e:
    sys.exit(f"Could not parse {settings_path}: {e}")

a, on_a = c["primary"], c["on_primary"]
managed = {
    "activityBarBadge.background": a,
    "activityBarBadge.foreground": on_a,
    "activityBar.activeBorder": a,
    "statusBar.background": c["surface_container"],
    "statusBar.foreground": c["on_surface_variant"],
    "statusBar.border": c["surface_container"],
    "statusBarItem.remoteBackground": a,
    "statusBarItem.remoteForeground": on_a,
    "button.background": a,
    "button.foreground": on_a,
    "button.hoverBackground": a + "cc",
    "focusBorder": a + "88",
    "progressBar.background": a,
    "selection.background": a + "44",
    "editor.selectionBackground": a + "33",
    "editor.selectionHighlightBackground": a + "22",
    "editorCursor.foreground": a,
    "editorLink.activeForeground": a,
    "tab.activeBorderTop": a,
    "panelTitle.activeBorder": a,
    "textLink.foreground": a,
}
custom = settings.get("workbench.colorCustomizations", {})
custom.update(managed)
settings["workbench.colorCustomizations"] = custom

settings_path.write_text(json.dumps(settings, indent=4) + "\n")
print(f"VS Code accent: {a} ({settings_path})")
