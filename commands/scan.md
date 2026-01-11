---
description: "Scan downloads folder for ROMs, patches, and texture packs"
allowed-tools: [Read, Bash, Glob, Grep, AskUserQuestion]
---

# GLMT Scan

Scan the configured downloads folder for game files.

## Load Config

Read config from platform-appropriate location:
```bash
if [[ -f "$HOME/.config/glmt/config.json" ]]; then
    CONFIG="$HOME/.config/glmt/config.json"
elif [[ -f "$USERPROFILE/.glmt/config.json" ]]; then
    CONFIG="$USERPROFILE/.glmt/config.json"
else
    echo "Not configured. Run /glmt first."
    exit 1
fi
```

## Scan Process

Use Glob tool to find files by extension in the downloads folder:

**ROMs:**
```
**/*.{nes,smc,sfc,z64,n64,v64,iso,gcm,gcz,rvz,wbfs,nds,3ds,cia,gba,gb,gbc,bin,cue,pbp,chd,md,gen,smd}
```

**Patches:**
```
**/*.{ips,bps,ups,xdelta,vcdiff}
```

**Texture Packs:**
- Look for folders containing .png/.dds files with hash-like names
- Check for "texture", "hd", "hires" in folder names

**Archives:**
```
**/*.{zip,7z,rar,tar.gz,tgz}
```

## Categorize Files

For each file found:
1. Identify type by extension
2. For ROMs: detect system from extension
3. For archives: peek inside to categorize contents

### Archive Inspection (Cross-Platform)

```bash
# Try available tools in order
if command -v 7z &>/dev/null; then
    7z l "$archive"
elif command -v 7zz &>/dev/null; then
    7zz l "$archive"
elif command -v unzip &>/dev/null && [[ "$archive" == *.zip ]]; then
    unzip -l "$archive"
fi
```

## System Detection by Extension

| Extension | Systems |
|-----------|---------|
| .nes | NES |
| .smc, .sfc | SNES |
| .z64, .n64, .v64 | N64 |
| .iso, .gcm, .gcz, .rvz | GameCube/Wii/PS1/PS2 |
| .wbfs | Wii |
| .gba | GBA |
| .gb | GB |
| .gbc | GBC |
| .nds | DS |
| .3ds, .cia | 3DS |
| .bin, .cue, .pbp, .chd | PS1/PS2 |
| .md, .gen, .smd | Genesis |

## Output Report

```
=== GLMT Scan Results ===

ROMs found: X
  N64: X
  SNES: X
  PS1: X
  ...

Patches found: X
  IPS: X
  BPS: X

Texture packs: X

Archives: X

Run /glmt:organize to move files.
```
