#!/bin/bash
# GLMT Configuration Checker
# Cross-platform script to verify GLMT is configured

# Detect OS and set config path
detect_config_path() {
    case "$(uname -s)" in
        Darwin|Linux)
            echo "$HOME/.config/glmt/config.json"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            echo "$USERPROFILE/.glmt/config.json"
            ;;
        *)
            # Fallback for unknown systems (including Android/Termux)
            if [[ -d "/data/data/com.termux" ]]; then
                echo "$HOME/.config/glmt/config.json"
            else
                echo "$HOME/.glmt/config.json"
            fi
            ;;
    esac
}

CONFIG_PATH=$(detect_config_path)

if [[ -f "$CONFIG_PATH" ]]; then
    echo "GLMT configured: $CONFIG_PATH"
    exit 0
else
    echo "GLMT not configured. Run /glmt:setup to configure."
    exit 1
fi
