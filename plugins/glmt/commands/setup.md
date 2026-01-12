---
description: "Configure or reconfigure GLMT settings"
allowed-tools: [Read, Write, Bash, AskUserQuestion]
---

# GLMT Setup

Interactive configuration wizard for GLMT.

## Config Location

Store config in platform-appropriate location:

```bash
case "$(uname -s)" in
    Darwin|Linux)
        CONFIG_DIR="$HOME/.config/glmt"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        CONFIG_DIR="$USERPROFILE/.glmt"
        ;;
    *)
        CONFIG_DIR="$HOME/.glmt"
        ;;
esac

mkdir -p "$CONFIG_DIR"
```

## Questions to Ask

Use AskUserQuestion for each:

### 1. Frontend
- RetroArch
- LaunchBox
- EmulationStation
- Standalone emulators
- Mixed setup

### 2. Downloads Path
Ask for full path, validate it exists.

### 3. ROMs Path
Ask for full path, create if needed.

### 4. Folder Structure
- Hierarchical (ROMs/N64/, ROMs/SNES/)
- Flat (all in one folder)

### 5. Texture Detection
- Auto-detect from emulator configs
- Manual (specify path)
- Skip (don't manage textures)

### 6. ROM Hacks Location
- Same folder as ROMs
- Subfolder per system (Hacks/)
- Separate dedicated folder

### 7. Patched File Naming
- Hack name (e.g., "Mario 64 Chaos Edition.z64")
- Suffix style (e.g., "Mario 64 [Chaos Edition].z64")
- Ask each time

### 8. Archive Handling
- Always ask before deleting
- Confirm once per session
- Move to archive folder
- Keep all (never delete)

### 9. Exclusions
Comma-separated patterns to ignore (e.g., "beta, proto, [b]")

### 10. Verification
- Always verify checksums
- Never verify
- Ask per operation

## Save Config

Write JSON to config directory:

```json
{
  "frontend": "retroarch",
  "downloads_path": "/path/to/downloads",
  "roms_path": "/path/to/roms",
  "structure": "hierarchical",
  "textures_mode": "auto",
  "hacks_location": "subfolder",
  "naming": "hack_name",
  "archive_handling": "ask",
  "exclusions": ["beta", "proto"],
  "verification": "never",
  "emulators": {}
}
```

## Emulator Detection

After saving basic config, scan for installed emulators:

```bash
# Dolphin
if [[ -d "$HOME/.local/share/dolphin-emu" ]] || \
   [[ -d "$HOME/Library/Application Support/Dolphin" ]] || \
   [[ -d "$USERPROFILE/Documents/Dolphin Emulator" ]]; then
    echo "Dolphin detected"
fi

# RetroArch
if [[ -d "$HOME/.config/retroarch" ]] || \
   [[ -d "$HOME/Library/Application Support/RetroArch" ]] || \
   [[ -d "$APPDATA/RetroArch" ]]; then
    echo "RetroArch detected"
fi
```

## Completion

```
Setup complete!

Configuration saved to: [config_path]

Run /glmt to start organizing your game library.
```
