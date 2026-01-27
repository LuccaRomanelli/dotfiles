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

LazyVim-based setup with plugins for git integration (fugitive, gitsigns, git-review), markdown support, Neo-tree file explorer, Telescope fuzzy finder, custom Lua modules for todo management and zettelkasten notes, spell checking.

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

Oh-My-Zsh with fzf integration, zoxide smart navigation, mise version management, syntax highlighting, autosuggestions, and custom fzf widgets.

---

## Aliases

Defined in `zshrc/.zsh_aliases`. Grouped by tool below.

### Navigation — eza, zoxide, fzf, yazi

| Alias | Command |
|-------|---------|
| `ls` | `eza -lh --group-directories-first --icons=auto` |
| `lsa` | `ls -a` |
| `lt` | `eza --tree --level=2 --long --icons --git` |
| `lta` | `lt -a` |
| `ff` | `fzf --preview 'bat ...'` |
| `cd` | zoxide-enhanced (`zd` function) |
| `..` `...` `....` | Parent directory shortcuts |
| `y` | Yazi file manager with cwd return |

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
| `gc` | Formatted branch list with commit info |
| `gb` | `git branch` |
| `gf` | Add, commit, push in one command |
| `lg` | `lazygit` |

### Docker

| Alias | Command |
|-------|---------|
| `d` | `docker` |
| `ports` | Show listening ports (`lsof`) |
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
| `c` | `claude` |
| `cr` | `claude --resume` |

### Laravel Sail

| Alias | Command |
|-------|---------|
| `s` | Smart sail wrapper (also `cinit`, `ninit`) |
| `sa` | `s artisan` |
| `sc` | `s composer` |
| `sup` / `sud` | `s up` / `s up -d` |
| `sdown` | `s down` |
| `sp` / `sn` | `s php` / `s npm` |
| `sdev` / `sbuild` | `s npm run dev` / `s npm run build` |
| `st` / `stp` / `std` | Pest tests (normal / parallel / dirty) |
| `sta` / `stf` / `stu` | Pest by suite (Arch / Feature / Unit) |
| `stk` | `sa tinker` |
| `stan` | PHPStan |
| `spint` | Pint formatter (dirty) |

### Tmux

| Alias | Command |
|-------|---------|
| `tm` | fzf-based tmux session creator/attacher |

### Dev Containers

| Alias | Command |
|-------|---------|
| `devb` | `devcontainer build --workspace-folder .` |
| `devup` | `devcontainer up --workspace-folder .` |
| `dev` | `devcontainer exec --workspace-folder . zsh` |

### Shell Scripts — [shell repo](https://github.com/LuccaRomanelli/shell)

These aliases call scripts from a separate repository.

| Alias | Script | Description |
|-------|--------|-------------|
| `?` | `ask.sh` | Quick questions via Claude Haiku |
| `??` | `ddgr` | DuckDuckGo search |
| `pomo` | `pomo.sh` | Pomodoro timer with waybar integration |
| `todo` | `todo.sh` | Open todo list in Neovim |
| `todoadd` | `todoadd.sh` | Add a task to todo list |
| `zet` | `zet.sh` | Create zettelkasten notes |
| `md2pdf` | `md2pdf.sh` | Convert Markdown to PDF (pandoc) |
| `mailfile` | `mail_file.sh` | Send file attachments via email |
| `md2mail` | `md2pdf_mail.sh` | Convert Markdown to PDF and email it |
