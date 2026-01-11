# GLMT Scan - Discover and Categorize Files

Scan the downloads folder for ROMs, patches, texture packs, and archives.

## Prerequisites
1. Check database exists: `C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db`
2. If not, tell user to run `/glmt-setup` first
3. Load config from database

## Tools Directory
```powershell
$toolsDir = "C:\Users\Owner\.claude\projects\glmt\tools\bin"
$env:Path = "$toolsDir;$env:Path"
```

## Load Configuration
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "SELECT value FROM config WHERE key='downloads_path';"
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "SELECT value FROM config WHERE key='exclusions';"
```

## Scan Process

### Step 1: Find All Files
```bash
# Find all files in downloads, excluding configured patterns
find "[downloads_path]" -type f \( -name "*.zip" -o -name "*.7z" -o -name "*.rar" -o -name "*.tar.gz" \
    -o -name "*.nes" -o -name "*.smc" -o -name "*.sfc" -o -name "*.z64" -o -name "*.n64" -o -name "*.v64" \
    -o -name "*.iso" -o -name "*.gcm" -o -name "*.wbfs" -o -name "*.nds" -o -name "*.3ds" -o -name "*.cia" \
    -o -name "*.gba" -o -name "*.gb" -o -name "*.gbc" -o -name "*.bin" -o -name "*.cue" -o -name "*.pbp" \
    -o -name "*.md" -o -name "*.gen" -o -name "*.smd" -o -name "*.chd" \
    -o -name "*.ips" -o -name "*.bps" -o -name "*.ups" -o -name "*.xdelta" \
    -o -name "*.png" -o -name "*.dds" -o -name "*.htc" \) 2>/dev/null
```

### Step 2: Categorize Each File

For each file found, determine its type:

**ROM Detection:**
- Match extension against systems table
- Check filename for system hints (e.g., "[N64]", "(USA)", etc.)
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" \
    "SELECT id, name FROM systems WHERE extensions LIKE '%\"ext\"%';"
```

**Patch Detection:**
- Extensions: .ips, .bps, .ups, .xdelta, .vcdiff
- Often named after the hack or target ROM

**Texture Pack Detection:**
- Look for folders containing hash-named directories
- Files: .png, .dds with hash-like names
- Check for texture pack indicators: "HD", "Texture", "Pack", "HiRes"

**Archive Detection:**
- Extensions: .zip, .7z, .rar, .tar.gz
- Peek inside to categorize contents

### Step 3: Archive Inspection

For each archive, list contents without extracting:
```powershell
$toolsDir = "C:\Users\Owner\.claude\projects\glmt\tools\bin"

# All archive types - use 7z (handles zip, 7z, rar, tar.gz)
& "$toolsDir\7z.exe" l "archive.zip"
& "$toolsDir\7z.exe" l "archive.7z"
& "$toolsDir\7z.exe" l "archive.rar"

# Or use specific tools:
# RAR (if 7z fails)
& "$toolsDir\unrar.exe" l "archive.rar"
```

Categorize archive by its contents:
- Contains ROMs → ROM archive
- Contains patches → Patch archive
- Contains textures (by folder structure or file types) → Texture pack
- Mixed → Multi-type archive

### Step 4: Insert to Database

For each discovered file:
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
INSERT OR IGNORE INTO files (path, filename, file_type, system_id, status, file_size, discovered_at)
VALUES (
    '[full_path]',
    '[filename]',
    '[type]',  -- rom, patch, texture, archive
    [system_id or NULL],
    'discovered',
    [size_bytes],
    datetime('now')
);"
```

For archives, also record contents:
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
INSERT INTO archive_contents (archive_id, internal_path, file_type, file_size)
VALUES ([archive_file_id], '[internal_path]', '[type]', [size]);"
```

### Step 5: Generate Report

Query and display summary:
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT file_type, COUNT(*) as count
FROM files
WHERE status='discovered'
GROUP BY file_type;"
```

Display to user:
```
=== GLMT Scan Results ===

New files discovered:
  ROMs: [count] files
    - N64: [count]
    - SNES: [count]
    - [etc...]

  Patches: [count] files
    - IPS: [count]
    - BPS: [count]

  Texture Packs: [count] items

  Archives: [count] files
    - ROM archives: [count]
    - Texture archives: [count]
    - Mixed: [count]

Files matching exclusion patterns (skipped): [count]

Ready to organize? Run:
- /glmt organize  - Move ROMs to system folders
- /glmt patch     - Apply ROM patches
- /glmt textures  - Install texture packs
- /glmt auto      - Do everything
```

## Duplicate Detection

Check for files already tracked:
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT path FROM files WHERE filename='[name]' AND status != 'deleted';"
```

If duplicates found, flag and report separately.

## Error Handling

- If downloads path doesn't exist: prompt to update config
- If no files found: report "No new files to organize"
- If archive inspection fails: mark as "needs_manual" and continue
