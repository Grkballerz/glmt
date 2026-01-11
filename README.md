# GLMT - Game Library Management Tool

A Claude Code plugin for autonomous ROM and game file organization.

## Features

- **Scan** downloads folder for ROMs, ROM hacks, texture packs, and archives
- **Organize** ROMs into system-specific folders automatically
- **Patch** ROMs with IPS, BPS, UPS, and xdelta patches
- **Install** texture packs to correct emulator directories
- **Track** all operations in a SQLite database
- **Auto-install** required tools (7-Zip, Flips, xdelta3, UnRAR)

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

1. Copy the command files to your Claude Code commands directory:
   ```
   ~/.claude/commands/glmt*.md
   ```

2. Copy the project folder:
   ```
   ~/.claude/projects/glmt/
   ```

3. Run `/glmt` in Claude Code to start setup

## Commands

| Command | Description |
|---------|-------------|
| `/glmt` | Main menu / setup wizard |
| `/glmt-setup` | Re-run configuration wizard |
| `/glmt-scan` | Scan downloads for new files |
| `/glmt-organize` | Move ROMs to system folders |
| `/glmt-patch` | Apply ROM hack patches |
| `/glmt-textures` | Install texture packs |
| `/glmt-auto` | Run all operations autonomously |
| `/glmt-status` | View database and statistics |
| `/glmt-install-tools` | Reinstall required tools |

## How It Works

1. **First Run**: Tools are automatically downloaded and installed
2. **Setup Wizard**: Answer 10 questions about your setup
3. **Autonomous Mode**: GLMT scans, categorizes, and organizes your files
4. **User Confirmation**: Always asks before deleting archives or when multiple patches exist

## Project Structure

```
glmt/
├── .glmt/
│   ├── schema.sql      # Database schema
│   └── glmt.db         # SQLite database (created on first run)
├── tools/
│   └── bin/            # Auto-installed tools
├── emulator-paths.json # Emulator detection reference
├── .gitignore
└── README.md
```

## Requirements

- Windows 10/11
- Claude Code CLI
- Internet connection (for tool downloads on first run)

## License

MIT
