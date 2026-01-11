# GLMT - Game Library Management Tool

A cross-platform Claude Code plugin for autonomous ROM and game file organization.

## Features

- **Scan** downloads folder for ROMs, ROM hacks, texture packs, and archives
- **Organize** ROMs into system-specific folders automatically
- **Patch** ROMs with IPS, BPS, UPS, and xdelta patches
- **Install** texture packs to correct emulator directories
- **Cross-platform** - works on Windows, macOS, Linux, and Android (Termux)
- **Intelligent agents** for ROM identification and patch matching
- **Proactive skill** - Claude can offer to help when it detects game files

## Supported Systems

NES, SNES, N64, GameCube, Wii, Wii U, Switch, GB, GBC, GBA, DS, 3DS, PS1, PS2, PSP, Genesis, Saturn, Dreamcast, and more.

## Supported Emulators

- RetroArch (multi-system)
- Dolphin (GameCube/Wii)
- Project64 (N64)
- PCSX2 (PS2)
- Cemu (Wii U)
- PPSSPP (PSP)
- DuckStation (PS1)
- Citra (3DS)
- mupen64plus
- And more...

## Installation

### Via Plugin Manager (Recommended)

```bash
/plugin add Grkballerz/glmt
```

### Manual Installation

Clone this repository and install as a local plugin:

```bash
git clone https://github.com/Grkballerz/glmt.git
claude --plugin-dir ./glmt
```

## Commands

After installation, these commands are available:

| Command | Description |
|---------|-------------|
| `/glmt:glmt` | Main menu / setup wizard |
| `/glmt:setup` | Re-run configuration wizard |
| `/glmt:scan` | Scan downloads for new files |
| `/glmt:organize` | Move ROMs to system folders |
| `/glmt:patch` | Apply ROM hack patches |
| `/glmt:textures` | Install texture packs |
| `/glmt:auto` | Run all operations autonomously |
| `/glmt:status` | View configuration and stats |

## How It Works

1. **First Run**: Setup wizard asks 10 questions about your setup
2. **Configuration**: Settings saved to `~/.config/glmt/` (Linux/macOS/Android) or `%USERPROFILE%\.glmt\` (Windows)
3. **Autonomous Mode**: GLMT scans, categorizes, and organizes your files
4. **User Confirmation**: Always asks before deleting archives or when multiple patches exist for the same ROM

## Proactive Help

GLMT includes a **skill** that allows Claude to proactively offer help when it detects:
- Game-related file extensions (.z64, .nes, .iso, etc.)
- Mentions of ROMs, emulators, or game organization
- Texture packs or ROM hack patches

## Required Tools

GLMT needs these tools for full functionality:

| Tool | Purpose | Installation |
|------|---------|--------------|
| 7z/unzip | Archive extraction | See below |
| flips | IPS/BPS/UPS patching | [GitHub](https://github.com/Alcaro/Flips/releases) |
| xdelta3 | xdelta patching | See below |

### Installation by Platform

**macOS:**
```bash
brew install p7zip xdelta
```

**Linux (Debian/Ubuntu):**
```bash
sudo apt install p7zip-full xdelta3
```

**Linux (Arch):**
```bash
sudo pacman -S p7zip xdelta3
```

**Android (Termux):**
```bash
pkg install p7zip xdelta3
```

**Windows:**
```powershell
winget install 7zip.7zip
```

GLMT will detect missing tools and provide platform-specific installation instructions.

## Plugin Structure

```
glmt/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest
├── agents/
│   ├── rom-identifier.md     # ROM header analysis agent
│   ├── patch-matcher.md      # Patch-to-ROM matching agent
│   └── emulator-detector.md  # Emulator detection agent
├── commands/
│   ├── glmt.md               # Main command
│   ├── setup.md              # Setup wizard
│   ├── scan.md               # File scanner
│   ├── organize.md           # ROM organizer
│   ├── patch.md              # Patch applier
│   ├── textures.md           # Texture installer
│   ├── auto.md               # Autonomous mode
│   └── status.md             # Status viewer
├── skills/
│   └── SKILL.md              # Proactive organization skill
├── hooks/
│   └── hooks.json            # Event handlers
├── scripts/
│   ├── check-config.sh       # Config verification
│   ├── detect-tools.sh       # Tool detection
│   └── get-config-path.sh    # Cross-platform path helper
├── data/
│   ├── emulator-paths.json   # Emulator path reference
│   ├── config-schema.json    # Configuration schema
│   └── state-schema.json     # State tracking schema
├── README.md
└── .gitignore
```

## Configuration

Configuration is stored in JSON format:

- **Linux/macOS/Android**: `~/.config/glmt/config.json`
- **Windows**: `%USERPROFILE%\.glmt\config.json`

### Config Options

| Option | Description |
|--------|-------------|
| `downloads_path` | Folder to scan for new files |
| `roms_path` | Destination for organized ROMs |
| `structure` | `hierarchical` (by system) or `flat` |
| `textures.mode` | `auto`, `manual`, or `skip` |
| `hacks.location` | `same`, `subfolder`, or `separate` |
| `archives.handling` | `ask`, `session_confirm`, `archive_folder`, or `keep` |

## Agents

GLMT includes specialized agents for complex tasks:

### ROM Identifier
Analyzes file headers to identify:
- Gaming system (not just by extension)
- Internal game name
- Region information
- File format (headered, interleaved, etc.)

### Patch Matcher
Matches ROM hack patches to base ROMs by:
- CRC32 checksums (BPS/UPS)
- Filename analysis
- Readme parsing

### Emulator Detector
Finds installed emulators and their:
- Configuration paths
- Texture directories
- ROM folders

## Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Windows 10/11 | ✅ Full | Native support |
| macOS 10.15+ | ✅ Full | Native support |
| Linux | ✅ Full | Ubuntu, Debian, Arch tested |
| Android (Termux) | ✅ Full | Requires Termux + Claude Code |
| Steam Deck | ✅ Full | Desktop mode |

## License

MIT
