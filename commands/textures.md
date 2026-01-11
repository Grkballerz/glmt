---
description: "Install texture packs to emulator directories"
allowed-tools: [Read, Write, Bash, Glob, Grep, AskUserQuestion]
---

# GLMT Textures

Install texture packs to the correct emulator texture directories.

## Emulator Texture Paths

### Dolphin (GameCube/Wii)
- **macOS**: `~/Library/Application Support/Dolphin/Load/Textures/[GAMEID]/`
- **Linux**: `~/.local/share/dolphin-emu/Load/Textures/[GAMEID]/`
- **Windows**: `%USERPROFILE%/Documents/Dolphin Emulator/Load/Textures/[GAMEID]/`
- **Game ID**: 6 characters (e.g., GALE01, RSBE01)

### RetroArch (Mupen64Plus-Next)
- **All platforms**: `[RetroArch]/system/Mupen64plus/hires_texture/[GAMEID]/`

### Project64 (N64) - Windows only
- `[P64]/Plugin/GFX/hires_texture/[GAMEID]/`

### PCSX2 (PS2)
- **All platforms**: `[PCSX2 config]/textures/[SERIAL]/replacements/`
- **Serial format**: SLUS-12345, SLES-12345

### PPSSPP (PSP)
- **macOS**: `~/Library/Application Support/PPSSPP/PSP/TEXTURES/[GAMEID]/`
- **Linux**: `~/.config/ppsspp/PSP/TEXTURES/[GAMEID]/`
- **Windows**: `%USERPROFILE%/Documents/PPSSPP/PSP/TEXTURES/[GAMEID]/`

### Cemu (Wii U)
- **All platforms**: `[Cemu]/graphicPacks/[TITLEID]/`

## Auto-Detection

If textures_mode is "auto", scan common emulator locations:

```bash
# Detect platform
case "$(uname -s)" in
    Darwin)  # macOS
        DOLPHIN="$HOME/Library/Application Support/Dolphin"
        ;;
    Linux)
        DOLPHIN="$HOME/.local/share/dolphin-emu"
        ;;
    MINGW*|MSYS*|CYGWIN*)  # Windows
        DOLPHIN="$USERPROFILE/Documents/Dolphin Emulator"
        ;;
esac
```

## Process

1. Find texture packs (folders with .png/.dds files)
2. Identify game ID from folder name or contents
3. Detect target emulator from game ID format
4. Copy textures to emulator's texture directory

## Game ID Detection

- **6-char alphanumeric** (GALE01): GameCube/Wii → Dolphin
- **N64 internal name**: N64 → RetroArch/Project64
- **SLUS/SLES-#####**: PS2 → PCSX2
- **16-char hex**: Wii U → Cemu

If unknown, ask user to specify.

## Installation

```bash
# Cross-platform copy
cp -r "$texture_source/"* "$emulator_textures/$game_id/"
```

## Output

```
=== Texture Installation Complete ===

Installed: X packs
  - GALE01 (Melee) → Dolphin
  - SM64 → RetroArch

Emulators updated:
  - Dolphin: X games
  - RetroArch: X games
```
