# GLMT Textures - Install Texture Packs

Install texture packs to the correct emulator directories.

## Prerequisites
1. Database with config and detected emulators
2. Texture packs discovered via scan
3. Tools auto-installed by GLMT setup

## Tools Directory
```powershell
$toolsDir = "C:\Users\Owner\.claude\projects\glmt\tools\bin"
$env:Path = "$toolsDir;$env:Path"
```

## Load Configuration
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "SELECT value FROM config WHERE key='textures_mode';"
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "SELECT value FROM config WHERE key='textures_path';"
```

## Load Emulator Configurations
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT id, name, type, textures_path FROM emulators;"
```

## Emulator Texture Paths Reference

### Dolphin (GameCube/Wii)
- Windows: `%USERPROFILE%\Documents\Dolphin Emulator\Load\Textures\[GAMEID]\`
- Game ID format: 6 characters (e.g., GALE01 for Melee)
- Files: .png, .dds

### Project64 (N64)
- Windows: `[P64 Install]\Plugin\GFX\hires_texture\[GAMEID]\`
- Or Rice Video plugin: `[P64]\Plugin\HiResTextures\`
- Game ID: varies by plugin (often internal ROM name)

### RetroArch
- Mupen64Plus-Next: `[RetroArch]\system\Mupen64plus\hires_texture\[GAMEID]\`
- Or: `[RetroArch]\system\HiResTextures\[GAMEID]\`
- Parallel-N64: Different location

### PCSX2 (PS2)
- Windows: `%USERPROFILE%\Documents\PCSX2\textures\[SERIAL]\replacements\`
- Serial format: SLUS-12345, SLES-12345, etc.

### Cemu (Wii U)
- Windows: `[Cemu]\graphicPacks\[TitleID]\`
- Title ID: 16-character hex

### PPSSPP (PSP)
- Windows: `%USERPROFILE%\Documents\PPSSPP\PSP\TEXTURES\[GAMEID]\`

## Get Discovered Texture Packs
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT id, path, filename, game_id
FROM files
WHERE file_type = 'texture' AND status = 'discovered';"
```

## Texture Pack Processing

### For Each Texture Pack:

**1. Identify Game ID**

From folder name:
- Look for patterns: `[GAMEID]`, hash-like folders, known game ID formats
- Example: "GALE01_HD_Textures" → GALE01

From archive name:
- "Super Smash Bros Melee HD Textures.zip" → lookup or ask

From folder contents:
- Internal structure often has GAMEID as subfolder

```bash
# If texture is a folder, check for game ID subfolder
ls "[texture_path]" | head -5
```

**2. Determine Target Emulator**

Based on Game ID format:
- 6-char alphanumeric (GALE01) → GameCube/Wii → Dolphin
- N64 internal name → N64 → Project64/RetroArch Mupen
- SLUS/SLES-##### → PS2 → PCSX2
- 16-char hex → Wii U → Cemu

If ambiguous, ask user:
```
Texture pack: "Mario 64 HD Textures"
Could be for:
  [1] Project64 (N64)
  [2] RetroArch Mupen64Plus-Next (N64)
  [3] Other

Which emulator?
```

**3. Extract if Archive**

```powershell
$toolsDir = "C:\Users\Owner\.claude\projects\glmt\tools\bin"
$tempDir = "C:\Users\Owner\.claude\projects\glmt\tools\temp"

# Create temp directory
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

# 7z handles all formats
& "$toolsDir\7z.exe" x "[archive]" -o"$tempDir" -y
```

**4. Find Texture Files**

Valid texture formats:
- `.png` - Most common
- `.dds` - DirectX texture
- `.htc` - Custom HTC format
- Folders containing above

```bash
find "[texture_dir]" -type f \( -name "*.png" -o -name "*.dds" -o -name "*.htc" \) | wc -l
```

**5. Determine Structure**

Texture packs may be:
- Pre-structured: Already has GAMEID folder at root
- Flat: All textures loose, need to create GAMEID folder
- Nested: GAMEID folder buried inside other folders

Detect and handle appropriately.

**6. Copy to Emulator Directory**

```bash
# Get emulator texture path from database
emulator_textures=$(sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" \
    "SELECT textures_path FROM emulators WHERE type='[emulator_type]';")

# Create game directory
mkdir -p "$emulator_textures/[GAMEID]"

# Copy textures
cp -r "[source_textures]/"* "$emulator_textures/[GAMEID]/"
```

**7. Verify Installation**

```bash
# Count installed textures
find "$emulator_textures/[GAMEID]" -type f | wc -l
```

**8. Update Database**

```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
UPDATE files
SET status = 'installed',
    destination_path = '[emulator_path]/[GAMEID]',
    processed_at = datetime('now')
WHERE id = [texture_id];"

sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
INSERT INTO operations (operation_type, file_id, source_path, destination_path, status, details)
VALUES (
    'install_texture',
    [texture_id],
    '[source_path]',
    '[dest_path]',
    'success',
    '{\"game_id\": \"[GAMEID]\", \"emulator\": \"[type]\", \"file_count\": [count]}'
);"
```

## Handle Conflicts

If textures already exist for a game:
```
Existing textures found for GALE01 (Super Smash Bros Melee)
  Current: 1,234 texture files
  New pack: 2,456 texture files

Options:
  [1] Replace all (backup existing first)
  [2] Merge (keep existing, add new)
  [3] Skip this pack
  [4] View differences
```

## Progress Display

```
Installing Texture Packs...

[1/4] GALE01_HD_Textures/
      Game: Super Smash Bros Melee (GameCube)
      Emulator: Dolphin
      Destination: Documents\Dolphin Emulator\Load\Textures\GALE01\
      Installing 2,456 textures... ✓

[2/4] SM64_HiRes.zip
      Game ID: [UNKNOWN]
      → This appears to be an N64 texture pack.
        Which emulator should receive it?
        [1] Project64
        [2] RetroArch (Mupen64Plus)
```

## Summary Report

```
=== Texture Installation Complete ===

Successfully installed: [count] texture packs
  - GALE01 (Melee): 2,456 textures → Dolphin
  - SM64: 1,890 textures → Project64
  - [etc...]

Skipped (already installed): [count]
Failed: [count]

Total textures installed: [total_count]

Archives processed: [count]
Archives pending deletion: [count]
  → Delete processed texture archives? (y/n)
```

## Error Handling

- Emulator not detected: Ask for manual path
- Unknown game ID: Ask user to identify or provide ID
- Permission denied: Report and suggest running as admin
- Disk space low: Warn before large operations
- Corrupt archive: Report and continue with others
