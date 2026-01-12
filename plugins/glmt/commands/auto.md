---
description: "Run all GLMT operations autonomously"
allowed-tools: [Read, Write, Bash, Glob, Grep, AskUserQuestion]
---

# GLMT Auto

Run all operations with minimal user intervention.

## Pre-Flight Checks

1. Verify config exists
2. Verify downloads folder exists
3. Check for required tools

```bash
# Check config
CONFIG=""
if [[ -f "$HOME/.config/glmt/config.json" ]]; then
    CONFIG="$HOME/.config/glmt/config.json"
elif [[ -f "$USERPROFILE/.glmt/config.json" ]]; then
    CONFIG="$USERPROFILE/.glmt/config.json"
fi

if [[ -z "$CONFIG" ]]; then
    echo "Not configured. Run /glmt first."
    exit 1
fi

# Check tools
MISSING=""
command -v 7z &>/dev/null || command -v unzip &>/dev/null || MISSING="extraction tool"
```

## Autonomous Workflow

### Phase 1: Scan
- Find all files in downloads
- Categorize by type
- Report findings

### Phase 2: Organize
- Extract archives
- Move ROMs to system folders
- Automatic for clear cases

### Phase 3: Patch
- Match patches to ROMs
- **STOP AND ASK** when multiple patches for one ROM
- Apply matched patches

### Phase 4: Textures
- Identify game IDs
- Install to emulator directories
- Ask if emulator unclear

### Phase 5: Cleanup
Based on config, handle processed archives:
- Delete (with confirmation)
- Move to archive folder
- Keep

## User Intervention Points

Auto mode will STOP and ask user for:
1. Multiple patches for same ROM
2. Unknown file systems
3. Ambiguous emulator targets
4. Archive deletion confirmation

## Final Summary

```
╔══════════════════════════════════════════╗
║      GLMT Auto-Organization Complete     ║
╠══════════════════════════════════════════╣
║  Scanned: X files                        ║
║  ROMs moved: X                           ║
║  Patches applied: X                      ║
║  Textures installed: X                   ║
║  Archives cleaned: X                     ║
╚══════════════════════════════════════════╝
```
