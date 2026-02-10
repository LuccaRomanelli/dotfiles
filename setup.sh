#!/bin/bash

CONFIGS=(
    ghostty
    gitconfig
    nvim
    rclone
    starship
    tmux
    voxtype
    waybar
    msmtp
    xcompose
    zshrc
)

for config in "${CONFIGS[@]}"; do
    echo "Stowing $config..."

    # Get list of conflicts (files that exist but aren't stow symlinks)
    conflicts=$(stow -n -v "$config" 2>&1 | grep "existing target" | sed 's/.*existing target is not owned by stow: //')

    for file in $conflicts; do
        target="$HOME/$file"
        if [[ -e "$target" && ! -L "$target" ]]; then
            echo "  Removing conflicting file: $target"
            rm -rf "$target"
        elif [[ -L "$target" ]]; then
            # It's a symlink but not managed by stow, remove it
            echo "  Removing conflicting symlink: $target"
            rm "$target"
        fi
    done

    stow "$config"
done

# Zen Browser (requires special script due to random profile names)
echo "Configuring Zen Browser..."
./zen/install-zen.sh

echo "Done!"
