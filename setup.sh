#!/bin/bash

CONFIGS=(
    ghostty
    gitconfig
    nvim
    starship
    tmux
    voxtype
    waybar
    xcompose
    zshrc
)

for config in "${CONFIGS[@]}"; do
    echo "Stowing $config..."
    stow "$config"
done

echo "Done!"
