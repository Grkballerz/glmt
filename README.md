# GLMT - Game Library Management Tool

A cross-platform Claude Code plugin for autonomous ROM and game file organization.

## Features

- **Scan** downloads folder for ROMs, ROM hacks, texture packs, and archives
- **Organize** ROMs into system-specific folders automatically
- **Patch** ROMs with IPS, BPS, UPS, and xdelta patches
- **Install** texture packs to correct emulator directories
- **Cross-platform** - works on Windows, macOS, Linux, and Android (Termux)

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
2. **Configuration**: Settings saved to `~/.config/glmt/` (Linux/macOS) or `%USERPROFILE%\.glmt\` (Windows)
3. **Autonomous Mode**: GLMT scans, categorizes, and organizes your files
4. **User Confirmation**: Always asks before deleting archives or when multiple patches exist for the same ROM

## Required Tools

GLMT needs these tools for full functionality:

| Tool | Purpose | Installation |
|------|---------|--------------|
| 7z/unzip | Archive extraction | `brew install p7zip` / `apt install p7zip-full` / `pkg install p7zip` |
| flips | IPS/BPS/UPS patching | Download from [GitHub](https://github.com/Alcaro/Flips/releases) |
| xdelta3 | xdelta patching | `brew install xdelta` / `apt install xdelta3` / `pkg install xdelta3` |

GLMT will detect missing tools and provide platform-specific installation instructions.

## Plugin Structure

```
glmt/
├── .claude-plugin/
│   └── plugin.json       # Plugin manifest
├── commands/
│   ├── glmt.md           # Main command
│   ├── setup.md          # Setup wizard
│   ├── scan.md           # Scanner
│   ├── organize.md       # ROM organizer
│   ├── patch.md          # Patcher
│   ├── textures.md       # Texture installer
│   ├── auto.md           # Autonomous mode
│   └── status.md         # Status viewer
├── data/
│   └── emulator-paths.json
├── README.md
└── .gitignore
```

## Platform Support

| Platform | Status |
|----------|--------|
| Windows 10/11 | Supported |
| macOS 10.15+ | Supported |
| Linux (Ubuntu/Debian) | Supported |
| Android (Termux) | Supported |

## License

MIT
