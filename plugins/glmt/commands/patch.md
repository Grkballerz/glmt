---
description: "Apply ROM hack patches (IPS, BPS, UPS, xdelta)"
allowed-tools: [Read, Write, Bash, Glob, Grep, AskUserQuestion]
---

# GLMT Patch

Apply ROM hack patches to base ROMs.

## Tool Detection

```bash
FLIPS=""
XDELTA=""

# Find flips
if command -v flips &>/dev/null; then
    FLIPS="flips"
elif command -v flips-cli &>/dev/null; then
    FLIPS="flips-cli"
fi

# Find xdelta
if command -v xdelta3 &>/dev/null; then
    XDELTA="xdelta3"
elif command -v xdelta &>/dev/null; then
    XDELTA="xdelta"
fi
```

If tools missing, show installation instructions:
- **macOS**: `brew install flips xdelta`
- **Linux (apt)**: Download flips from GitHub, `apt install xdelta3`
- **Linux (pacman)**: `pacman -S xdelta3`, download flips
- **Windows**: Download from GitHub releases
- **Termux**: `pkg install xdelta3`, download flips ARM binary

## Patching Process

1. Find all discovered patch files
2. For each patch:
   - Identify patch type from extension
   - Find matching base ROM (by name similarity)
   - If multiple patches for same ROM: **ALWAYS ASK USER**
   - Apply patch
   - Save to configured location

## Applying Patches

```bash
# IPS, BPS, UPS with flips
$FLIPS --apply "$patch_file" "$source_rom" "$output_rom"

# xdelta patches
$XDELTA -d -s "$source_rom" "$patch_file" "$output_rom"
```

## Multiple Patches Warning

**CRITICAL**: When multiple patches target the same ROM, present options:

```
Found 3 patches for "Super Mario 64.z64":
  [1] Chaos Edition.bps
  [2] Star Road.bps
  [3] Last Impact.bps
  [4] Skip all
  [5] Apply all as separate files

Which to apply?
```

## Output Location

Based on config:
- **same_folder**: Next to original ROM
- **subfolder**: `ROMs/N64/Hacks/`
- **separate**: Dedicated hacks folder

## Naming

Based on config:
- **hack_name**: "Super Mario 64 - Chaos Edition.z64"
- **suffix_style**: "Super Mario 64 [Chaos Edition].z64"
- **ask**: Prompt each time

## Output

```
=== Patching Complete ===

Applied: X patches
  - Super Mario 64 - Chaos Edition.z64
  - Zelda OOT Randomizer.z64

Skipped: X (no matching ROM)
Failed: X
```
