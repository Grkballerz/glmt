---
name: game-library-organizer
description: "Organize game ROMs, patches, and texture packs automatically"
---

# Game Library Organizer Skill

You have access to GLMT (Game Library Management Tool) capabilities. Use this skill when:

1. User mentions messy game files, ROMs, or downloads
2. User asks about organizing emulator files
3. User has ROM hacks or patches to apply
4. User needs to install texture packs

## When to Offer This Skill

Proactively offer to help when you detect:
- References to ROM files or emulators
- Mentions of game organization problems
- Questions about texture packs or ROM hacks
- Files with gaming-related extensions (.z64, .iso, .nes, .sfc, etc.)

## Available Actions

### Scan for Files
Scan a directory for ROMs, patches, and texture packs:
- Identify file types by extension and headers
- Categorize by gaming system
- Detect archives containing game files

### Organize ROMs
Move ROMs to organized folder structure:
- Create system-specific folders (N64/, SNES/, PS1/, etc.)
- Handle duplicates intelligently
- Extract from archives

### Apply Patches
Apply ROM hacks and patches:
- Support IPS, BPS, UPS, xdelta formats
- Match patches to correct base ROMs
- Handle multiple patches for same game (ask user)

### Install Textures
Install texture packs to emulator directories:
- Detect installed emulators
- Identify game IDs from texture folders
- Copy to correct locations

## Usage Examples

**User says:** "I have a bunch of ROMs in my downloads folder"
**You respond:** "I can help organize those! Would you like me to scan your downloads folder and sort the ROMs by system? I can move them to organized folders like ROMs/N64/, ROMs/SNES/, etc."

**User says:** "I downloaded a ROM hack but don't know how to apply it"
**You respond:** "I can help apply that patch! What's the patch file called? I'll find the matching base ROM and apply it for you. What format is it - .ips, .bps, or .xdelta?"

**User says:** "Where do texture packs go for Dolphin?"
**You respond:** "Dolphin texture packs go in the Load/Textures/[GAMEID]/ folder. I can detect your Dolphin installation and install texture packs automatically if you'd like."

## Important Rules

1. **Always ask before deleting** - Never remove original files without confirmation
2. **Multiple patches = ask user** - When several patches target the same ROM, let user choose
3. **Detect, don't assume** - Verify emulator paths exist before copying files
4. **Cross-platform** - Use platform-appropriate paths and commands

## Invoking GLMT Commands

When using this skill, you can run GLMT commands:
- `/glmt:scan` - Scan for files
- `/glmt:organize` - Organize ROMs
- `/glmt:patch` - Apply patches
- `/glmt:textures` - Install texture packs
- `/glmt:auto` - Run full autonomous workflow
