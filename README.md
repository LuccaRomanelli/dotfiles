# Dotfiles

My personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Configs

| Config | Description |
|--------|-------------|
| `ghostty` | Ghostty terminal emulator |
| `gitconfig` | Git configuration |
| `nvim` | Neovim editor |
| `starship` | Starship prompt |
| `tmux` | Tmux terminal multiplexer |
| `voxtype` | Voxtype speech-to-text |
| `waybar` | Waybar (Wayland status bar) |
| `xcompose` | X11 compose keys |
| `zshrc` | Zsh shell |

## Setup

Run the setup script to symlink all configs:

```bash
./setup.sh
```

Or manually stow individual configs:

```bash
stow <config-name>
```
