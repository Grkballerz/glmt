---
description: "View GLMT status and tracked files"
allowed-tools: [Read, Bash, Glob]
---

# GLMT Status

Display current configuration and operation history.

## Show Configuration

Read and display the config file:

```bash
CONFIG=""
if [[ -f "$HOME/.config/glmt/config.json" ]]; then
    CONFIG="$HOME/.config/glmt/config.json"
elif [[ -f "$USERPROFILE/.glmt/config.json" ]]; then
    CONFIG="$USERPROFILE/.glmt/config.json"
fi

if [[ -n "$CONFIG" ]]; then
    cat "$CONFIG"
else
    echo "Not configured. Run /glmt first."
fi
```

## Display Format

```
=== GLMT Configuration ===

Downloads: /path/to/downloads
ROMs: /path/to/roms
Structure: hierarchical

Frontend: RetroArch
Texture Mode: auto-detect
Hacks Location: subfolder
Archive Handling: ask

Detected Emulators:
  - Dolphin: ~/.local/share/dolphin-emu/
  - RetroArch: ~/.config/retroarch/

=== Quick Stats ===

Last scan: [date]
ROMs organized: X
Patches applied: X
Textures installed: X
```

## Options

```
[1] View full operation log
[2] Show detected emulators
[3] Rescan emulator paths
[4] Export config
[5] Back to main menu
```
