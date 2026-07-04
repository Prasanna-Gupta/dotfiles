import re, sys, json

settings_path = sys.argv[1]
accent = sys.argv[2]

with open(settings_path, 'r') as f:
    content = f.read()

# Remove block comments /* ... */
content_clean = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
# Remove line comments // ...
content_clean = re.sub(r'//[^\n]*', '', content_clean)
# Remove trailing commas before } or ]
content_clean = re.sub(r',(\s*[}\]])', r'\1', content_clean)

try:
    settings = json.loads(content_clean)
except Exception as e:
    print(f"ERROR: {e}")
    sys.exit(1)

settings['workbench.colorCustomizations'] = {
    "activityBarBadge.background": accent,
    "activityBarBadge.foreground": "#000000",
    "statusBar.background": "#1a1f1a",
    "statusBar.foreground": accent,
    "statusBarItem.hoverBackground": accent + "22",
    "button.background": accent,
    "button.foreground": "#000000",
    "button.hoverBackground": accent + "cc",
    "focusBorder": accent + "88",
    "selection.background": accent + "33",
    "editor.selectionBackground": accent + "33",
    "editor.selectionHighlightBackground": accent + "22",
    "editorCursor.foreground": accent,
    "editorLink.activeForeground": accent,
    "tab.activeBorderTop": accent,
    "panelTitle.activeBorder": accent,
    "terminal.ansiGreen": accent,
    "terminal.ansiBrightGreen": accent + "cc"
}

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=4)

print(f"VS Code accent updated: {accent}")
