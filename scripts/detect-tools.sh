#!/bin/bash
# GLMT Tool Detector
# Check for required tools and provide installation instructions

detect_os() {
    case "$(uname -s)" in
        Darwin)  echo "macos" ;;
        Linux)
            if [[ -d "/data/data/com.termux" ]]; then
                echo "android"
            else
                echo "linux"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
        *)       echo "unknown" ;;
    esac
}

OS=$(detect_os)
MISSING=()

# Check extraction tools
if ! command -v 7z &>/dev/null && ! command -v 7zz &>/dev/null; then
    if ! command -v unzip &>/dev/null; then
        MISSING+=("7z/unzip")
    fi
fi

# Check patching tools
if ! command -v flips &>/dev/null && ! command -v flips-cli &>/dev/null; then
    MISSING+=("flips")
fi

if ! command -v xdelta3 &>/dev/null && ! command -v xdelta &>/dev/null; then
    MISSING+=("xdelta3")
fi

# Report results
if [[ ${#MISSING[@]} -eq 0 ]]; then
    echo "All required tools are installed."
    exit 0
fi

echo "Missing tools: ${MISSING[*]}"
echo ""
echo "Installation instructions for $OS:"
echo ""

case "$OS" in
    macos)
        echo "  brew install p7zip xdelta"
        echo "  # For flips, download from: https://github.com/Alcaro/Flips/releases"
        ;;
    linux)
        echo "  # Debian/Ubuntu:"
        echo "  sudo apt install p7zip-full xdelta3"
        echo ""
        echo "  # Arch:"
        echo "  sudo pacman -S p7zip xdelta3"
        echo ""
        echo "  # For flips, download from: https://github.com/Alcaro/Flips/releases"
        ;;
    android)
        echo "  pkg install p7zip xdelta3"
        echo "  # For flips, you may need to compile from source or find an ARM binary"
        ;;
    windows)
        echo "  winget install 7zip.7zip"
        echo "  # Or download from: https://www.7-zip.org/"
        echo ""
        echo "  # For flips: https://github.com/Alcaro/Flips/releases"
        echo "  # For xdelta3: https://github.com/jmacd/xdelta-gpl/releases"
        ;;
esac

exit 1
