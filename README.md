# Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Setup

Run the setup script to symlink all configs:

```bash
./setup.sh
```

Or manually stow individual configs:

```bash
stow <config-name>
```

---

## Configs

### [Ghostty](https://ghostty.org/docs) — `ghostty/`

Terminal emulator config. JetBrainsMono Nerd Font (size 14), bar cursor, custom keybinds (Shift+Insert paste, Shift+Up/Down scroll), window padding, dynamic Omarchy theme colors.

### [Git](https://git-scm.com/doc) — `gitconfig/`

Minimal global git config: user identity, nvimdiff as diff tool.

### [Neovim (LazyVim)](https://www.lazyvim.org/) — `nvim/`

LazyVim-based setup with plugins for git integration (fugitive, gitsigns, git-review), markdown support, Neo-tree file explorer, Telescope fuzzy finder, LSP navigation helpers, and spell checking.

### [Starship](https://starship.rs/) — `starship/`

Catppuccin Mocha palette prompt with segments for OS, directory, git branch/status, language versions (C, Rust, Go, Node, PHP, Java, Kotlin, Haskell, Python), Docker context, and time. Multi-line layout with vi-mode indicators.

### [Tmux](https://github.com/tmux/tmux/wiki) — `tmux/`

Ctrl-S prefix, vi keybindings, mouse enabled, vim-tmux-navigator integration, Catppuccin theme, status bar at top.

### [Voxtype](https://github.com/omarchy/omarchy) — `voxtype/`

Speech-to-text via Whisper (large-v3-turbo model), auto-language detection (PT/EN), Hyprland hotkey integration, clipboard fallback, notifications.

### [Waybar](https://github.com/Alexays/Waybar/wiki) — `waybar/`

Wayland status bar with modules for Hyprland workspaces, clock, weather (Belo Horizonte), system updates, pomodoro timer, media player (mpris), network, audio, battery, CPU/GPU temps, memory, and disk usage.

### [XCompose](https://wiki.archlinux.org/title/Xorg/Keyboard_configuration#Using_X_keyboard_extension) — `xcompose/`

Compose key sequences for quickly typing personal data (name, email, phone, LinkedIn, GitHub).

### [Zsh + Oh-My-Zsh](https://ohmyz.sh/) — `zshrc/`

Cross-platform Zsh setup with Oh-My-Zsh, mise runtime activation, fzf widgets, zoxide smart navigation, NVM lazy loading, custom aliases, and local help docs.

- macOS (`Darwin`): Powerlevel10k prompt and Homebrew paths.
- Linux: Starship prompt, `~/.tmuxifier/bin`, Bun completions/bin, eza-based listing aliases.

---

## Aliases

Defined as modular files in `zshrc/.zsh/aliases/*.zsh`. `zshrc/.zshrc` loads all alias files plus `zshrc/.zsh/help.zsh` and `zshrc/.zsh/help_docs.zsh`.

### Navigation and Listing

| Alias | Command |
|-------|---------|
| `ls` `lsa` `ll` `la` | macOS-aware listing with icons, Finder tag colors, and custom folder emoji |
| `lt` `lta` | tree view wrappers |
| `cd` | installed by `zoxide init zsh --cmd cd` |
| `..` `...` `....` | Parent directory shortcuts |
| `y` | Yazi file manager with cwd return |

### Search and fzf

| Alias | Command |
|-------|---------|
| `ff` | Fuzzy find file and open smart |
| `ffh` | Fuzzy find hidden files and open smart |
| `s` | Ripgrep content search, open selected match |
| `cdf` | Fuzzy find file and cd to parent directory |

### Git — git, lazygit

| Alias | Command |
|-------|---------|
| `g` | `git` |
| `ga` | `git add .` |
| `gcam` | `git commit -a -m` |
| `gl` | `git pull` |
| `gp` | `git push` |
| `gs` | `git status` |
| `gco` | `git checkout` |
| `gb` | `git branch` |
| `gsc` | `git stash clear` |
| `gsh` | `git stash` |
| `gf` | Stash, fetch, rebase on `origin/main`, restore, commit, push |
| `gnuke` | Remove linked worktrees, delete local branches except main, clear stash |
| `lg` | `lazygit` |

### Docker

| Alias | Command |
|-------|---------|
| `d` | `docker` |
| `ports` | Show listening ports (`lsof`) |
| `kp` | Kill process on port |
| `dcou` | `docker compose up -d` |
| `down` | `docker compose down` |

### Neovim

| Alias | Command |
|-------|---------|
| `n` | `nvim` (opens `.` if no args) |
| `ndiff` | `nvim -c "GitReview"` for diff viewing |

### Claude

| Alias | Command |
|-------|---------|
| `c` | `claude --dangerously-skip-permissions` |
| `cr` | `claude --dangerously-skip-permissions --resume` |
| `inception` | `ai inception` |

### Dev Containers

| Alias | Command |
|-------|---------|
| `devb` | `devcontainer build --workspace-folder .` |
| `devup` | `devcontainer up --workspace-folder .` |
| `devdown` | `devcontainer down --workspace-folder .` |
| `dev` | `devcontainer exec --workspace-folder . zsh` |
