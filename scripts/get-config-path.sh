#!/bin/bash
# GLMT Config Path Helper
# Returns the appropriate config directory for the current platform

case "$(uname -s)" in
    Darwin|Linux)
        CONFIG_DIR="$HOME/.config/glmt"
        ;;
    MINGW*|MSYS*|CYGWIN*)
        CONFIG_DIR="$USERPROFILE/.glmt"
        ;;
    *)
        # Android/Termux or unknown
        if [[ -d "/data/data/com.termux" ]]; then
            CONFIG_DIR="$HOME/.config/glmt"
        else
            CONFIG_DIR="$HOME/.glmt"
        fi
        ;;
esac

# Create directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

echo "$CONFIG_DIR"
