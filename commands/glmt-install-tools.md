# GLMT Tool Installer

Automatically download and install required tools for GLMT.

## Tools Directory
```bash
TOOLS_DIR="C:\Users\Owner\.claude\projects\glmt\tools"
mkdir -p "$TOOLS_DIR"
mkdir -p "$TOOLS_DIR/bin"
```

## Tool Definitions

### 7-Zip (Archive Extraction)
- **Purpose**: Extract ZIP, 7z, RAR archives
- **Download**: https://www.7-zip.org/a/7zr.exe (standalone console version)
- **Alt**: https://www.7-zip.org/a/7z2301-extra.7z (full extra package)

### Flips (ROM Patching)
- **Purpose**: Apply IPS, BPS, UPS patches
- **Download**: https://github.com/Alcaro/Flips/releases
- **Direct**: https://github.com/Alcaro/Flips/releases/download/v1.40/flips-windows.zip

### xdelta3 (Delta Patching)
- **Purpose**: Apply xdelta/vcdiff patches
- **Download**: https://github.com/jmacd/xdelta/releases
- **Direct**: https://github.com/jmacd/xdelta-gpl/releases/download/v3.1.0/xdelta3-3.1.0-x86_64.exe.zip

### UnRAR (RAR Extraction)
- **Purpose**: Extract RAR archives (7z can also do this)
- **Download**: https://www.rarlab.com/rar/unrarw64.exe

## Installation Process

### Step 1: Check Existing Tools
```powershell
# Check if tools already exist in PATH or tools directory
$tools = @{
    "7z" = @("7z.exe", "7zr.exe")
    "flips" = @("flips.exe", "flips-windows.exe")
    "xdelta3" = @("xdelta3.exe", "xdelta.exe")
}

foreach ($tool in $tools.Keys) {
    $found = $false
    # Check PATH
    foreach ($exe in $tools[$tool]) {
        if (Get-Command $exe -ErrorAction SilentlyContinue) {
            Write-Host "$tool found in PATH"
            $found = $true
            break
        }
    }
    # Check tools directory
    if (-not $found) {
        foreach ($exe in $tools[$tool]) {
            if (Test-Path "C:\Users\Owner\.claude\projects\glmt\tools\bin\$exe") {
                Write-Host "$tool found in tools directory"
                $found = $true
                break
            }
        }
    }
    if (-not $found) {
        Write-Host "$tool NOT FOUND - will install"
    }
}
```

### Step 2: Download Missing Tools

Use PowerShell for downloads:

```powershell
$toolsDir = "C:\Users\Owner\.claude\projects\glmt\tools"
$binDir = "$toolsDir\bin"
$tempDir = "$toolsDir\temp"

New-Item -ItemType Directory -Force -Path $binDir | Out-Null
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

# Download function
function Download-Tool {
    param($url, $output)
    Write-Host "Downloading $output..."
    Invoke-WebRequest -Uri $url -OutFile "$tempDir\$output" -UseBasicParsing
}
```

**Install 7-Zip:**
```powershell
# Download 7-Zip standalone
$7zUrl = "https://www.7-zip.org/a/7zr.exe"
Download-Tool $7zUrl "7zr.exe"
Copy-Item "$tempDir\7zr.exe" "$binDir\7zr.exe"

# Also get full 7z for better format support
$7zExtraUrl = "https://www.7-zip.org/a/7z2301-extra.7z"
Download-Tool $7zExtraUrl "7z-extra.7z"
# Extract using 7zr
& "$binDir\7zr.exe" x "$tempDir\7z-extra.7z" -o"$tempDir\7z-extra" -y
Copy-Item "$tempDir\7z-extra\x64\7za.exe" "$binDir\7z.exe"
```

**Install Flips:**
```powershell
$flipsUrl = "https://github.com/Alcaro/Flips/releases/download/v1.40/flips-windows.zip"
Download-Tool $flipsUrl "flips.zip"
Expand-Archive -Path "$tempDir\flips.zip" -DestinationPath "$tempDir\flips" -Force
Copy-Item "$tempDir\flips\flips.exe" "$binDir\flips.exe"
```

**Install xdelta3:**
```powershell
$xdeltaUrl = "https://github.com/jmacd/xdelta-gpl/releases/download/v3.1.0/xdelta3-3.1.0-x86_64.exe.zip"
Download-Tool $xdeltaUrl "xdelta3.zip"
Expand-Archive -Path "$tempDir\xdelta3.zip" -DestinationPath "$tempDir\xdelta" -Force
# Find the exe and copy it
Get-ChildItem "$tempDir\xdelta" -Filter "*.exe" -Recurse |
    Select-Object -First 1 |
    Copy-Item -Destination "$binDir\xdelta3.exe"
```

**Install UnRAR:**
```powershell
$unrarUrl = "https://www.rarlab.com/rar/unrarw64.exe"
Download-Tool $unrarUrl "unrar-setup.exe"
# This is a self-extracting archive, extract it
& "$tempDir\unrar-setup.exe" /s /d="$tempDir\unrar"
Copy-Item "$tempDir\unrar\UnRAR.exe" "$binDir\unrar.exe"
```

### Step 3: Cleanup Temp Files
```powershell
Remove-Item -Recurse -Force "$tempDir" -ErrorAction SilentlyContinue
```

### Step 4: Update Database with Tool Paths
```powershell
$dbPath = "C:\Users\Owner\.claude\projects\glmt\.glmt\glmt.db"

# Store tool paths in config
sqlite3 $dbPath "INSERT OR REPLACE INTO config (key, value) VALUES ('tools_dir', '$binDir');"
sqlite3 $dbPath "INSERT OR REPLACE INTO config (key, value) VALUES ('7z_path', '$binDir\7z.exe');"
sqlite3 $dbPath "INSERT OR REPLACE INTO config (key, value) VALUES ('flips_path', '$binDir\flips.exe');"
sqlite3 $dbPath "INSERT OR REPLACE INTO config (key, value) VALUES ('xdelta3_path', '$binDir\xdelta3.exe');"
sqlite3 $dbPath "INSERT OR REPLACE INTO config (key, value) VALUES ('unrar_path', '$binDir\unrar.exe');"
```

### Step 5: Add to PATH (Optional)
```powershell
# Add tools\bin to user PATH for current session
$env:Path = "$binDir;$env:Path"

# Optionally add permanently (ask user first)
# [Environment]::SetEnvironmentVariable("Path", "$binDir;" + [Environment]::GetEnvironmentVariable("Path", "User"), "User")
```

## Verification

After installation, verify all tools work:
```powershell
Write-Host "`n=== Tool Verification ==="

# Test 7z
Write-Host -NoNewline "7-Zip: "
try {
    $ver = & "$binDir\7z.exe" | Select-String "7-Zip"
    Write-Host "OK - $ver" -ForegroundColor Green
} catch {
    Write-Host "FAILED" -ForegroundColor Red
}

# Test flips
Write-Host -NoNewline "Flips: "
if (Test-Path "$binDir\flips.exe") {
    Write-Host "OK" -ForegroundColor Green
} else {
    Write-Host "FAILED" -ForegroundColor Red
}

# Test xdelta3
Write-Host -NoNewline "xdelta3: "
try {
    & "$binDir\xdelta3.exe" -V 2>&1 | Out-Null
    Write-Host "OK" -ForegroundColor Green
} catch {
    Write-Host "FAILED" -ForegroundColor Red
}

# Test unrar
Write-Host -NoNewline "UnRAR: "
try {
    & "$binDir\unrar.exe" 2>&1 | Out-Null
    Write-Host "OK" -ForegroundColor Green
} catch {
    Write-Host "FAILED" -ForegroundColor Red
}
```

## Output Summary
```
=== GLMT Tool Installation ===

Installing to: C:\Users\Owner\.claude\projects\glmt\tools\bin\

[1/4] 7-Zip....... OK (v23.01)
[2/4] Flips....... OK (v1.40)
[3/4] xdelta3..... OK (v3.1.0)
[4/4] UnRAR....... OK (v6.x)

All tools installed successfully!
Tools directory added to session PATH.

Add to permanent PATH? [y/n]:
```

## Error Handling

If download fails:
1. Check internet connection
2. Try alternate mirror
3. Provide manual download instructions

```powershell
try {
    Download-Tool $url $file
} catch {
    Write-Host "Download failed: $_"
    Write-Host "Please manually download from: $url"
    Write-Host "And place in: $binDir"
}
```

## Alternative: Winget/Chocolatey

If user has package managers:
```powershell
# Check for winget
if (Get-Command winget -ErrorAction SilentlyContinue) {
    winget install 7zip.7zip --accept-package-agreements --accept-source-agreements
}

# Check for chocolatey
if (Get-Command choco -ErrorAction SilentlyContinue) {
    choco install 7zip flips xdelta3 -y
}
```
