# GLMT Setup Wizard

You are running the GLMT Setup Wizard. Initialize the database and collect user configuration.

## Step 1: Initialize Database
```bash
cd "C:\Users\Owner\.claude\projects\glmt\.glmt"
sqlite3 glmt.db < schema.sql
```

If database already exists with config, ask: "Configuration already exists. Reset and reconfigure? (y/n)"

## Step 2: Interactive Setup

Use the AskUserQuestion tool to collect each setting. After each answer, immediately save to database:

```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "INSERT OR REPLACE INTO config (key, value) VALUES ('key_name', 'value');"
```

### Questions to Ask (in order):

**Q1 - Frontend** (header: "Frontend")
Options:
- RetroArch - Multi-system emulator frontend
- LaunchBox - Game launcher and organizer
- EmulationStation - Lightweight frontend for RetroPie/etc
- Standalone - Individual emulators (Dolphin, Project64, etc)
- Mixed - Combination of multiple frontends

**Q2 - Downloads Path** (header: "Downloads")
Ask: "Enter the full path to your downloads folder:"
- Validate path exists with: `test -d "path" && echo "valid"`
- Config key: `downloads_path`

**Q3 - ROMs Path** (header: "ROMs Folder")
Ask: "Enter the full path to your main ROMs folder:"
- Validate path exists
- Config key: `roms_path`

**Q4 - ROMs Structure** (header: "ROM Structure")
Options:
- Hierarchical - Organized by system (ROMs/N64/, ROMs/SNES/)
- Flat - All ROMs in one folder
- Custom - Let me specify the pattern

**Q5 - Texture Detection** (header: "Textures")
Options:
- Auto-detect - Scan emulator configs for texture paths (recommended)
- Manual - I'll specify the texture folder path
- Skip - I don't use texture packs

**Q6 - ROM Hacks Location** (header: "Hacks Folder")
Options:
- Same folder - Put hacks alongside original ROMs
- Subfolder - Create Hacks/ subfolder per system
- Separate - Use a dedicated hacks folder (will ask for path)

**Q7 - Patched Naming** (header: "Patch Names")
Options:
- Hack name - Name after the hack (e.g., "Mario 64 Chaos Edition.z64")
- Suffix style - Base ROM with suffix (e.g., "Super Mario 64 [Chaos Edition].z64")
- Ask each time - Prompt for each patch operation

**Q8 - Archive Handling** (header: "Archives")
Options:
- Always ask - Confirm before deleting each archive
- Session confirm - One confirmation per session, then auto-delete
- Archive folder - Move to Archive/ folder instead of deleting
- Keep all - Never delete original archives

**Q9 - Naming Convention** (header: "File Names")
Options:
- Keep original - Don't rename files
- No-Intro - Clean names with region tags
- Custom - Specify a naming pattern

**Q10 - Exclusions** (header: "Exclusions")
Ask: "Enter patterns to exclude (comma-separated, or 'none'):"
Examples: "beta, proto, sample, [b], [h]"
Config key: `exclusions`

**Q11 - Verification** (header: "Verify")
Options:
- Always verify - Check checksums after every operation
- Never verify - Skip verification for speed
- Ask per operation - Prompt each time

## Step 3: Emulator Detection (if Auto-detect textures)

Scan for emulator configurations:

```bash
# RetroArch
test -f "$APPDATA/RetroArch/retroarch.cfg" && echo "RetroArch found"

# Dolphin
test -d "$USERPROFILE/Documents/Dolphin Emulator" && echo "Dolphin found"

# Project64
test -d "$APPDATA/Project64" && echo "Project64 found"

# PCSX2
test -d "$USERPROFILE/Documents/PCSX2" && echo "PCSX2 found"

# Cemu
test -d "$USERPROFILE/.cemu" && echo "Cemu found"
```

For each found emulator, extract texture paths and save to `emulators` table.

## Step 4: Confirmation

Display summary of all settings:
```
=== GLMT Configuration ===
Frontend: [value]
Downloads: [path]
ROMs: [path] ([structure])
Textures: [mode]
Hacks: [location]
Naming: [style]
Archives: [handling]
Verification: [mode]
Exclusions: [list]

Detected Emulators:
- [emulator]: [texture_path]
...

Save this configuration? (y/n)
```

## Step 5: Complete

After saving, display:
```
Setup complete! Run /glmt to start organizing your game library.

Quick commands:
- /glmt scan    - Scan downloads for new files
- /glmt organize - Move ROMs to correct folders
- /glmt patch   - Apply ROM hacks
- /glmt textures - Install texture packs
- /glmt auto    - Run everything automatically
```
