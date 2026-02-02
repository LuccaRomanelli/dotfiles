#!/bin/bash

ZEN_DIR="$HOME/.zen"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/zen-configs"

# Check if Zen is installed
if [ ! -d "$ZEN_DIR" ]; then
    echo "Zen Browser not found at $ZEN_DIR"
    exit 1
fi

# Find the default profile from Install section (most reliable for release builds)
PROFILE=$(grep -A1 "^\[Install" "$ZEN_DIR/profiles.ini" | grep "Default=" | cut -d'=' -f2)

# Fallback: look for profile with "(release)" in the name
if [ -z "$PROFILE" ]; then
    PROFILE=$(grep "Path=.*release" "$ZEN_DIR/profiles.ini" | cut -d'=' -f2)
fi

# Fallback: look for Default=1 profile
if [ -z "$PROFILE" ]; then
    PROFILE=$(grep -B2 "Default=1" "$ZEN_DIR/profiles.ini" | grep "Path=" | cut -d'=' -f2)
fi

# Last fallback: first profile found
if [ -z "$PROFILE" ]; then
    PROFILE=$(grep "Path=" "$ZEN_DIR/profiles.ini" | head -1 | cut -d'=' -f2)
fi

if [ -z "$PROFILE" ]; then
    echo "Could not find Zen profile"
    exit 1
fi

PROFILE_DIR="$ZEN_DIR/$PROFILE"

if [ ! -d "$PROFILE_DIR" ]; then
    echo "Profile directory not found: $PROFILE_DIR"
    exit 1
fi

echo "Installing configs to profile: $PROFILE_DIR"

# Backup and symlink config files
for file in zen-themes.json zen-keyboard-shortcuts.json user.js; do
    if [ -f "$PROFILE_DIR/$file" ] && [ ! -L "$PROFILE_DIR/$file" ]; then
        echo "Backing up $file..."
        mv "$PROFILE_DIR/$file" "$PROFILE_DIR/$file.bak"
    fi
    echo "Linking $file..."
    ln -sf "$CONFIGS_DIR/$file" "$PROFILE_DIR/$file"
done

# Symlink chrome/zen-themes folder
echo "Linking zen-themes..."
mkdir -p "$PROFILE_DIR/chrome"
rm -rf "$PROFILE_DIR/chrome/zen-themes"
ln -sf "$CONFIGS_DIR/chrome/zen-themes" "$PROFILE_DIR/chrome/zen-themes"

echo "Installation complete! Restart Zen Browser to apply changes."
