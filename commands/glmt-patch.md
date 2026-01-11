# GLMT Patch - Apply ROM Hacks and Patches

Apply IPS, BPS, UPS, and xdelta patches to ROMs.

## Prerequisites
1. Database must exist with config
2. Tools auto-installed by GLMT setup

## Tools Directory
```powershell
$toolsDir = "C:\Users\Owner\.claude\projects\glmt\tools\bin"
$flips = "$toolsDir\flips.exe"
$xdelta3 = "$toolsDir\xdelta3.exe"
$env:Path = "$toolsDir;$env:Path"
```

## Verify Tools
```powershell
if (-not (Test-Path $flips)) {
    Write-Host "Flips not found. Running /glmt to reinstall tools..."
    # Tools will be auto-installed
}
if (-not (Test-Path $xdelta3)) {
    Write-Host "xdelta3 not found. Running /glmt to reinstall tools..."
}
```

## Load Configuration
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "SELECT value FROM config WHERE key='hacks_location';"
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "SELECT value FROM config WHERE key='patched_naming';"
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "SELECT value FROM config WHERE key='roms_path';"
```

## Get Discovered Patches
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT id, path, filename
FROM files
WHERE file_type = 'patch' AND status = 'discovered';"
```

## Patching Workflow

### For Each Patch:

**1. Identify Patch Type**
```bash
ext="${filename##*.}"
case "$ext" in
    ips) patch_type="ips" ;;
    bps) patch_type="bps" ;;
    ups) patch_type="ups" ;;
    xdelta|vcdiff) patch_type="xdelta" ;;
esac
```

**2. Find Target ROM**

Strategy A - Filename matching:
- Extract base name from patch: "Super Mario 64 - Chaos Edition.bps" → "Super Mario 64"
- Search for ROMs with similar names

```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT id, path, filename, destination_path
FROM files
WHERE file_type = 'rom'
AND (filename LIKE '%[base_name]%' OR destination_path LIKE '%[base_name]%');"
```

Strategy B - BPS/UPS header (contains target CRC):
```bash
# BPS files contain source CRC in header
# Read first bytes to extract target ROM hash
```

Strategy C - Ask user:
If no automatic match found, present options or ask for ROM path.

**3. Handle Multiple Patches for Same ROM**

IMPORTANT: When multiple patches target the same ROM, ALWAYS ask user which to apply.

```
Found 3 patches for "Super Mario 64.z64":
  [1] Super Mario 64 - Chaos Edition.bps
  [2] Super Mario 64 - Star Road.bps
  [3] SM64 - Last Impact.bps

Apply which patches? (comma-separated numbers, or 'all'):
```

**4. Create Patched ROM**

Determine output path based on config:

- **Same folder**: `[rom_folder]/[patched_name].[ext]`
- **Subfolder**: `[rom_folder]/Hacks/[patched_name].[ext]`
- **Separate folder**: `[hacks_path]/[system]/[patched_name].[ext]`

Determine output name based on config:
- **Hack name**: Use patch filename (minus extension) + ROM extension
- **Suffix style**: `[ROM name] [Hack name].[ext]`

**5. Apply Patch**

```powershell
$toolsDir = "C:\Users\Owner\.claude\projects\glmt\tools\bin"

# IPS, BPS, UPS patches with flips
& "$toolsDir\flips.exe" --apply "[patch_file]" "[source_rom]" "[output_rom]"

# xdelta patches
& "$toolsDir\xdelta3.exe" -d -s "[source_rom]" "[patch_file]" "[output_rom]"
```

**6. Verify Patch Applied**
```bash
# Check output file exists and has reasonable size
test -f "[output_rom]" && stat -f%z "[output_rom]"

# Optional: if verification enabled, check known hash
```

**7. Update Database**
```bash
# Update patch record
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
UPDATE files
SET status = 'processed', processed_at = datetime('now')
WHERE id = [patch_id];"

# Record the patched ROM as new file
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
INSERT INTO files (path, filename, file_type, system_id, status, original_path, metadata)
VALUES (
    '[output_path]',
    '[output_filename]',
    'rom',
    [system_id],
    'patched',
    '[source_rom_path]',
    '{\"patch_applied\": \"[patch_filename]\", \"patch_type\": \"[type]\"}'
);"

# Log operation
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
INSERT INTO operations (operation_type, file_id, source_path, destination_path, status, details)
VALUES (
    'patch',
    [patch_id],
    '[source_rom]',
    '[output_rom]',
    'success',
    '{\"patch_type\": \"[type]\", \"patch_file\": \"[patch_path]\"}'
);"
```

## Handling Patch Archives

Many ROM hacks come as archives containing:
- The patch file (.ips, .bps, etc.)
- A readme or instructions
- Sometimes the original ROM (skip this)

Process:
1. Extract archive to temp
2. Find patch file(s) inside
3. Read any readme for base ROM requirements
4. Apply standard patching workflow
5. Clean up temp files

```powershell
$toolsDir = "C:\Users\Owner\.claude\projects\glmt\tools\bin"
$tempDir = "C:\Users\Owner\.claude\projects\glmt\tools\temp"

# Extract archive
& "$toolsDir\7z.exe" x "[archive]" -o"$tempDir" -y

# Find patches
Get-ChildItem "$tempDir" -Recurse -Include "*.ips","*.bps","*.ups","*.xdelta" | Select-Object FullName
```

## Progress Display
```
Applying ROM Patches...

[1/5] Super Mario 64 - Chaos Edition.bps
      Target ROM: Super Mario 64.z64
      Output: ROMs/N64/Hacks/Super Mario 64 - Chaos Edition.z64
      Applying... ✓

[2/5] Zelda OOT - Randomizer Seed 12345.bps
      Target ROM: [NOT FOUND]
      → Please specify the base ROM path:
```

## Summary Report
```
=== Patching Complete ===

Successfully patched: [count] ROMs
  Created:
  - Super Mario 64 - Chaos Edition.z64
  - [etc...]

Failed patches: [count]
  - [patch name]: [reason]

Patches without target ROM: [count]
  → These patches need manual ROM assignment

Archives processed: [count]
```

## Error Handling

- Patch tool not found: Provide installation instructions
- Target ROM not found: Queue for manual assignment
- Patch fails (checksum mismatch): Try anyway with warning, or skip
- Output already exists: Ask to overwrite, rename, or skip
- Corrupt patch file: Report and continue
