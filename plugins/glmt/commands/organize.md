---
description: "Move ROMs to correct system folders"
allowed-tools: [Read, Write, Bash, Glob, AskUserQuestion]
---

# GLMT Organize

Move discovered ROMs to their correct system folders.

## Process

1. Load config to get ROMs destination path and structure preference
2. For each discovered ROM:
   - Identify system from extension/filename
   - Build destination path based on structure (hierarchical or flat)
   - Check for duplicates
   - Move file

## Cross-Platform Move

```bash
# Works on all platforms
mv "$source" "$destination"

# Or copy if keeping originals
cp "$source" "$destination"
```

## Directory Creation

```bash
# Create system folder if needed (works everywhere)
mkdir -p "$roms_path/$system_name"
```

## Archive Extraction

```bash
# Cross-platform extraction
if command -v 7z &>/dev/null; then
    7z x "$archive" -o"$temp_dir" -y
elif command -v 7zz &>/dev/null; then
    7zz x "$archive" -o"$temp_dir" -y
elif command -v unzip &>/dev/null && [[ "$archive" == *.zip ]]; then
    unzip -o "$archive" -d "$temp_dir"
elif command -v tar &>/dev/null && [[ "$archive" == *.tar.gz || "$archive" == *.tgz ]]; then
    tar -xzf "$archive" -C "$temp_dir"
fi
```

## Duplicate Handling

If destination file exists:
1. Compare file sizes
2. If identical: skip with note
3. If different: ask user - keep both (rename), replace, or skip

## After Organizing

Based on archive_handling config:
- **always_ask**: Confirm before deleting each archive
- **session_confirm**: Ask once per session
- **archive_folder**: Move to archive folder
- **keep_all**: Leave archives alone

## Output

```
=== Organization Complete ===

Moved: X ROMs
  N64: X → /path/to/ROMs/N64/
  SNES: X → /path/to/ROMs/SNES/
  ...

Skipped (duplicates): X
Archives processed: X
```
