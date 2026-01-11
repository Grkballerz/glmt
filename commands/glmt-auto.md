# GLMT Auto - Full Autonomous Organization

Run all GLMT operations automatically with minimal user intervention.

## Prerequisites
1. Configuration must be complete (run `/glmt-setup` if not)
2. Tools auto-installed by GLMT setup

## Tools Directory
```powershell
$toolsDir = "C:\Users\Owner\.claude\projects\glmt\tools\bin"
$env:Path = "$toolsDir;$env:Path"
```

## Pre-Flight Checks

```powershell
$dbPath = "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db"
$toolsDir = "C:\Users\Owner\.claude\projects\glmt\tools\bin"
$errors = @()

# Check database exists
if (-not (Test-Path $dbPath)) {
    $errors += "NO_DB"
}

# Check config exists
try {
    $configCount = sqlite3 $dbPath "SELECT COUNT(*) FROM config;"
    if ($configCount -eq 0) { $errors += "NO_CONFIG" }
} catch {
    $errors += "NO_CONFIG"
}

# Check downloads path exists
$downloads = sqlite3 $dbPath "SELECT value FROM config WHERE key='downloads_path';"
if (-not (Test-Path $downloads)) {
    $errors += "NO_DOWNLOADS"
}

# Check tools installed
if (-not (Test-Path "$toolsDir\7z.exe")) { $errors += "MISSING_7Z" }
if (-not (Test-Path "$toolsDir\flips.exe")) { $errors += "MISSING_FLIPS" }
if (-not (Test-Path "$toolsDir\xdelta3.exe")) { $errors += "MISSING_XDELTA" }

if ($errors.Count -gt 0) {
    Write-Host "Pre-flight check failed: $($errors -join ', ')"
    Write-Host "Run /glmt to fix setup issues."
}
```

If any check fails, report and offer to fix or run setup.

## Autonomous Workflow

### Phase 1: Scan
```
=== Phase 1: Scanning Downloads ===
```
Execute full scan workflow from `/glmt-scan`:
- Find all files in downloads
- Categorize by type
- Record to database

Report findings before proceeding.

### Phase 2: Organize ROMs
```
=== Phase 2: Organizing ROMs ===
```
Execute organization from `/glmt-organize`:
- Extract ROM archives
- Identify systems
- Move to correct folders

**Automatic Decisions:**
- Known systems: auto-move
- Unknown systems: queue for end (batch ask)
- Duplicates: skip with note

### Phase 3: Apply Patches
```
=== Phase 3: Applying ROM Patches ===
```
Execute patching from `/glmt-patch`:
- Match patches to ROMs
- Apply patches

**IMPORTANT - User Interaction Required:**
When multiple patches exist for the same ROM, ALWAYS stop and ask:
```
Multiple patches found for "Super Mario 64.z64":
  [1] Chaos Edition.bps
  [2] Star Road.bps
  [3] Last Impact.bps
  [4] Skip all patches for this ROM
  [5] Apply all as separate files

Which patches to apply? (comma-separated):
```

**Automatic Decisions:**
- Single patch for ROM: auto-apply
- Target ROM not found: queue for manual at end

### Phase 4: Install Textures
```
=== Phase 4: Installing Texture Packs ===
```
Execute texture installation from `/glmt-textures`:
- Identify game IDs
- Match to emulators
- Copy to correct locations

**Automatic Decisions:**
- Clear game ID + single emulator match: auto-install
- Ambiguous: queue for end

### Phase 5: Cleanup
```
=== Phase 5: Cleanup ===
```
Based on `archive_handling` config:

**If "Always ask":**
```
The following archives were successfully processed:
  - ROM_Pack.zip (12 ROMs extracted)
  - SM64_Hack.7z (patch applied)
  - HD_Textures.rar (textures installed)

Delete these archives? [y/n/select]:
```

**If "Session confirm":**
First time: ask once, remember for session.

**If "Archive folder":**
```bash
archive_folder=$(sqlite3 "..." "SELECT value FROM config WHERE key='archive_folder';")
mkdir -p "$archive_folder"
mv [processed_archives] "$archive_folder/"
```

**If "Keep all":**
Skip cleanup, just report.

### Phase 6: Manual Queue
```
=== Phase 6: Items Needing Attention ===
```
Process any items that couldn't be handled automatically:

**Unknown Systems:**
```
These ROMs couldn't be auto-classified:
  [1] unknown_game.bin - Could be: PS1, Genesis, Saturn
  [2] mystery.iso - Could be: PS2, GameCube, Xbox

Classify manually or skip? [1-N/skip]:
```

**Unmatched Patches:**
```
These patches need target ROMs specified:
  [1] Cool Hack.ips - No matching ROM found
      → Enter ROM path or skip:
```

**Unknown Texture Game IDs:**
```
These texture packs need game identification:
  [1] awesome_textures/ - Unknown game
      → Enter Game ID or skip:
```

## Final Summary

```
╔════════════════════════════════════════════════════════╗
║           GLMT Auto-Organization Complete              ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  SCAN RESULTS:                                         ║
║    Files discovered: [count]                           ║
║    Archives processed: [count]                         ║
║                                                        ║
║  ROM ORGANIZATION:                                     ║
║    ROMs moved: [count]                                 ║
║    ├─ N64: [count]                                     ║
║    ├─ SNES: [count]                                    ║
║    ├─ PS1: [count]                                     ║
║    └─ [other systems...]                               ║
║    Skipped (duplicates): [count]                       ║
║    Failed: [count]                                     ║
║                                                        ║
║  ROM PATCHES:                                          ║
║    Patches applied: [count]                            ║
║    New hacked ROMs: [count]                            ║
║    Skipped: [count]                                    ║
║                                                        ║
║  TEXTURE PACKS:                                        ║
║    Packs installed: [count]                            ║
║    Total textures: [count]                             ║
║    Emulators updated:                                  ║
║    ├─ Dolphin: [count] games                           ║
║    ├─ Project64: [count] games                         ║
║    └─ [other emulators...]                             ║
║                                                        ║
║  CLEANUP:                                              ║
║    Archives deleted: [count]                           ║
║    Archives archived: [count]                          ║
║    Space recovered: [size]                             ║
║                                                        ║
║  NEEDS ATTENTION:                                      ║
║    Unclassified files: [count]                         ║
║    Unmatched patches: [count]                          ║
║                                                        ║
╚════════════════════════════════════════════════════════╝

Your game library is organized! Run /glmt status for details.
```

## Interrupt Handling

If user interrupts (Ctrl+C):
- Save current progress to database
- Mark in-progress operations as "interrupted"
- Report what was completed

Next run will resume from where it left off.

## Error Recovery

If errors occur:
- Log error to operations table
- Continue with other files
- Report all errors in summary
- Offer to retry failed operations

```bash
# Mark operation as failed
sqlite3 "..." "
UPDATE operations
SET status = 'failed', error_message = '[error]'
WHERE id = [op_id];"
```
