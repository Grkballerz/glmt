# GLMT Status - View Database and Statistics

Display current state of the game library database.

## Check Database
```bash
test -f "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" || echo "Database not found. Run /glmt-setup first."
```

## Quick Stats Overview
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT
    'Total Files' as metric,
    COUNT(*) as value
FROM files
UNION ALL
SELECT
    'ROMs',
    COUNT(*)
FROM files WHERE file_type='rom'
UNION ALL
SELECT
    'Patches',
    COUNT(*)
FROM files WHERE file_type='patch'
UNION ALL
SELECT
    'Texture Packs',
    COUNT(*)
FROM files WHERE file_type='texture'
UNION ALL
SELECT
    'Archives',
    COUNT(*)
FROM files WHERE file_type='archive';"
```

## Display Current Configuration
```bash
sqlite3 -header "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT key, value FROM config ORDER BY key;"
```

Format as:
```
=== GLMT Configuration ===
downloads_path: C:\Users\Owner\Downloads
roms_path: D:\ROMs
roms_structure: hierarchical
textures_mode: auto
hacks_location: subfolder
archive_handling: ask
[etc...]
```

## File Status Breakdown
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT
    file_type,
    status,
    COUNT(*) as count
FROM files
GROUP BY file_type, status
ORDER BY file_type, status;"
```

Format as:
```
=== File Status ===

ROMs:
  discovered: 15
  moved: 42
  patched: 8

Patches:
  discovered: 5
  processed: 12

Texture Packs:
  discovered: 3
  installed: 7

Archives:
  discovered: 8
  processed: 20
  deleted: 15
```

## Systems Summary
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT
    s.short_name,
    s.name,
    COUNT(f.id) as rom_count
FROM systems s
LEFT JOIN files f ON f.system_id = s.id AND f.file_type = 'rom'
GROUP BY s.id
HAVING rom_count > 0
ORDER BY rom_count DESC;"
```

Format as:
```
=== ROMs by System ===
N64    Nintendo 64           23 ROMs
SNES   Super Nintendo        18 ROMs
PS1    PlayStation           15 ROMs
GCN    GameCube              12 ROMs
[etc...]
```

## Detected Emulators
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT name, type, textures_path, detected_at FROM emulators;"
```

Format as:
```
=== Detected Emulators ===
Dolphin (GameCube/Wii)
  Textures: C:\Users\Owner\Documents\Dolphin Emulator\Load\Textures\
  Detected: 2024-01-15

Project64 (N64)
  Textures: C:\Project64\Plugin\GFX\hires_texture\
  Detected: 2024-01-15
[etc...]
```

## Recent Operations
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT
    operation_type,
    source_path,
    destination_path,
    status,
    created_at
FROM operations
ORDER BY created_at DESC
LIMIT 10;"
```

Format as:
```
=== Recent Operations ===
[2024-01-15 14:32] MOVE    Super Mario 64.z64 → ROMs/N64/    ✓
[2024-01-15 14:32] PATCH   Chaos Edition.bps applied         ✓
[2024-01-15 14:31] EXTRACT ROM_Pack.zip                      ✓
[2024-01-15 14:30] SCAN    Downloads folder                  ✓
[etc...]
```

## Pending Items
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT path, filename, file_type
FROM files
WHERE status = 'discovered'
ORDER BY file_type, filename;"
```

Format as:
```
=== Pending Items ===

Awaiting organization:
  [ROM] new_game.z64
  [ROM] another_rom.sfc

Awaiting patching:
  [PATCH] cool_hack.bps

Awaiting installation:
  [TEXTURE] hd_pack.zip

Total pending: [count] items
```

## Failed Operations
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT
    operation_type,
    source_path,
    error_message,
    created_at
FROM operations
WHERE status = 'failed'
ORDER BY created_at DESC;"
```

Format as:
```
=== Failed Operations ===
[2024-01-15 14:35] PATCH corrupt_patch.ips
                   Error: Invalid patch header

[2024-01-15 14:33] MOVE locked_file.z64
                   Error: Permission denied
```

## Storage Statistics
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT
    file_type,
    SUM(file_size) as total_bytes,
    COUNT(*) as file_count
FROM files
WHERE file_size IS NOT NULL
GROUP BY file_type;"
```

Format sizes nicely (KB, MB, GB).

## Menu Options
```
What would you like to do?

[1] View full file list
[2] View operations log
[3] Export report (JSON)
[4] Clear failed operations
[5] Purge deleted file records
[6] Back to main menu

Choice:
```

## Export Options

**JSON Export:**
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT json_group_array(json_object(
    'path', path,
    'filename', filename,
    'type', file_type,
    'status', status,
    'destination', destination_path
))
FROM files;" > glmt_export.json
```

**CSV Export:**
```bash
sqlite3 -header -csv "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT * FROM files;" > glmt_files.csv
```
