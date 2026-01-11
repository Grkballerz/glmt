# GLMT Organize - Move ROMs to Correct Folders

Move discovered ROMs to their appropriate system folders.

## Prerequisites
1. Database must exist with config
2. Run `/glmt-scan` first if no discovered files

## Tools Directory
```powershell
$toolsDir = "C:\Users\Owner\.claude\projects\glmt\tools\bin"
$env:Path = "$toolsDir;$env:Path"
```

## Load Configuration
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "SELECT value FROM config WHERE key='roms_path';"
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "SELECT value FROM config WHERE key='roms_structure';"
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "SELECT value FROM config WHERE key='naming_convention';"
```

## Get Discovered ROMs
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
SELECT f.id, f.path, f.filename, s.name, s.short_name
FROM files f
LEFT JOIN systems s ON f.system_id = s.id
WHERE f.file_type = 'rom' AND f.status = 'discovered';"
```

## Organization Logic

### For Each ROM:

**1. Determine System (if not already set)**

If system_id is NULL, detect from:
- File extension match against systems table
- Filename patterns: "[N64]", "(Nintendo 64)", etc.
- File header analysis (for ambiguous extensions like .bin)

```bash
# Get system by extension
ext="${filename##*.}"
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" \
    "SELECT id, name, short_name FROM systems WHERE extensions LIKE '%\"$ext\"%' LIMIT 1;"
```

**2. Build Destination Path**

Based on `roms_structure` config:

- **Hierarchical**: `[roms_path]/[system_short_name]/[filename]`
  ```
  ROMs/N64/Super Mario 64.z64
  ROMs/SNES/Chrono Trigger.sfc
  ```

- **Flat**: `[roms_path]/[filename]`

- **Custom**: Use configured pattern

**3. Apply Naming Convention**

Based on `naming_convention` config:

- **Keep original**: No changes
- **No-Intro style**: Clean up filename
  - Remove bad dump tags: [b], [h], [o], [!]
  - Standardize region: (USA), (Europe), (Japan)
  - Remove extra info: [T+Eng], etc.
- **Custom**: Apply user pattern

**4. Handle Duplicates**

Check if destination already exists:
```bash
test -f "[destination_path]" && echo "exists"
```

If exists:
- Compare file sizes/hashes
- If identical: skip, mark as duplicate
- If different: ask user (keep both with suffix, replace, skip)

**5. Create Directory Structure**
```bash
mkdir -p "[destination_directory]"
```

**6. Move or Copy File**
```bash
# Move file
mv "[source_path]" "[destination_path]"

# Or copy if configured to keep originals
cp "[source_path]" "[destination_path]"
```

**7. Update Database**
```bash
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
UPDATE files
SET status = 'moved',
    destination_path = '[destination_path]',
    processed_at = datetime('now')
WHERE id = [file_id];"

# Log operation
sqlite3 "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db" "
INSERT INTO operations (operation_type, file_id, source_path, destination_path, status, completed_at)
VALUES ('move', [file_id], '[source]', '[destination]', 'success', datetime('now'));"
```

## Archive Extraction

For ROM archives:

**1. Extract to temp location**
```powershell
$toolsDir = "C:\Users\Owner\.claude\projects\glmt\tools\bin"
$tempDir = "[downloads_path]\.glmt_temp"

# Create temp directory
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

# 7z handles all formats (zip, 7z, rar, tar.gz)
& "$toolsDir\7z.exe" x "[archive]" -o"$tempDir" -y

# Or for RAR specifically if needed:
& "$toolsDir\unrar.exe" x "[archive]" "$tempDir\"
```

**2. Process extracted files**
Recursively scan extracted files and organize each ROM.

**3. Cleanup temp**
```bash
rm -rf "[downloads_path]/.glmt_temp"
```

**4. Handle original archive**
Based on `archive_handling` config:
- Ask user for confirmation
- Delete: `rm "[archive_path]"`
- Move to archive folder: `mv "[archive]" "[archive_folder]/"`

## Batch Operation Display

Show progress during organization:
```
Organizing ROMs...

[1/15] Super Mario 64.z64
       System: Nintendo 64
       → ROMs/N64/Super Mario 64.z64 ✓

[2/15] Chrono Trigger.sfc
       System: Super Nintendo
       → ROMs/SNES/Chrono Trigger.sfc ✓

[3/15] Unknown Game.bin
       System: [UNKNOWN - multiple matches]
       → Options: PS1, Genesis, or skip?
```

## Summary Report
```
=== Organization Complete ===

Successfully moved: [count] ROMs
  - N64: [count]
  - SNES: [count]
  - PS1: [count]
  - [etc...]

Skipped (duplicates): [count]
Failed: [count]

Archives processed: [count]
Archives pending deletion: [count]
  → Delete all pending archives? (y/n)
```

## Error Handling

- Permission denied: Report and continue with other files
- Disk full: Stop and alert user immediately
- Unknown system: Queue for manual classification
- Corrupt archive: Mark as failed, report to user
