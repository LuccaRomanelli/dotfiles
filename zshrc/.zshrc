# Dedupe PATH automaticamente
typeset -U PATH path
_DOTFILES_OS="$(uname -s 2>/dev/null || echo unknown)"

# mise runtime/version manager
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# Locale and terminal settings
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export COLORTERM="truecolor"
[[ "$_DOTFILES_OS" == "Darwin" ]] && export LC_TERMINAL="iTerm2"

# Shell history
export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000
setopt inc_append_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt share_history
setopt hist_reduce_blanks
setopt hist_verify
setopt extended_history

# Oh-My-Zsh configuration
export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"

case "$_DOTFILES_OS" in
  Darwin)
    # Fastfetch greeting — must run BEFORE p10k instant prompt to preserve colors
    if [[ -o interactive ]] && command -v fastfetch &> /dev/null; then
      fastfetch
    fi

    # Powerlevel10k instant prompt (must be after any console output)
    if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
      source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
    fi

    ZSH_THEME="powerlevel10k/powerlevel10k"
    plugins=(git history z zsh-syntax-highlighting zsh-autosuggestions zsh-completions colored-man-pages aws)
    ;;
  Linux)
    ZSH_THEME=""
    plugins=(command-not-found git history z zsh-autosuggestions zsh-syntax-highlighting colored-man-pages sudo)
    ;;
  *)
    ZSH_THEME=""
    plugins=(git history z zsh-autosuggestions zsh-syntax-highlighting colored-man-pages)
    ;;
esac

# Perf — disable OMZ auto-update (~110ms saved) and skip OMZ compfix security audit (~50ms)
zstyle ':omz:update' mode disabled
export ZSH_DISABLE_COMPFIX=true

[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

case "$_DOTFILES_OS" in
  Darwin)
    # Powerlevel10k configuration
    [[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh
    ;;
  Linux)
    # Linux prompt
    command -v starship &> /dev/null && eval "$(starship init zsh)"
    ;;
esac

# BASIC CONFIGURATION
#   ------------------------------------------------------------
case "$_DOTFILES_OS" in
  Darwin)
    export PATH="/usr/local/bin:$PATH"
    export PATH="/usr/local/sbin:$PATH"
    export PATH="/opt/homebrew/bin:$PATH"
    export PATH="/opt/homebrew/sbin:$PATH"
    export PATH="/usr/local/opt/curl/bin:$PATH"

    # {mark} Homebrew PATH
    [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    ;;
  Linux)
    export PATH="$HOME/.tmuxifier/bin:$PATH"
    ;;
esac

# {mark} START DEVTOOLS SETUP ZSHRC
if [[ "$_DOTFILES_OS" == "Darwin" && -r "$HOME/.nurc" ]]; then
  source "$HOME/.nurc"
  export GOPATH="${NU_HOME}/go"
  export PATH="$GOPATH/bin:${PATH}"
fi
# {mark} END DEVTOOLS SETUP ZSHRC

# Java configuration (added by devtools)
if [[ "$_DOTFILES_OS" == "Darwin" ]]; then
  export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

# {mark} START DEVTOOLS TERMINAL EXTRAS
# Nucli completions
[[ -n "$NU_HOME" && -f "$NU_HOME/nucli/nu.bashcompletion" ]] && source "$NU_HOME/nucli/nu.bashcompletion"

# Set cursor to blinking vertical bar
if [[ "$_DOTFILES_OS" == "Darwin" ]]; then
  echo -ne '\e[5 q'
  preexec() { echo -ne '\e[5 q'; }
fi
# {mark} END DEVTOOLS TERMINAL EXTRAS


# Editor
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"
export DISABLE_AUTO_TITLE=true

# Completion
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*' completer _complete _correct _approximate
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'

# auto_cd: bare dir name = cd (still useful even with zoxide --cmd cd)
setopt auto_cd

# Quick shell reload
alias reload='exec zsh'

# Print pwd with nerd-font icon after every cd (replaces old zd wrapper output)
_pwd_icon() { printf "\U000F17A9 %s\n" "$PWD"; }
chpwd_functions+=(_pwd_icon)

# fzf
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
command -v fzf &> /dev/null && source <(fzf --zsh)

# Break fzf-completion ↔ zsh-z mutual fallback (FUNCNEST recursion)
fzf_default_completion=expand-or-complete
typeset -gA ZSHZ
ZSHZ[TAB_BINDING]=expand-or-complete

# fzf widgets
# Ctrl+T: file picker
fzf-file-widget() {
  local selected
  selected=$(fd . 2>/dev/null | fzf) || return
  LBUFFER+="$selected"
  zle redisplay
}
zle -N fzf-file-widget
bindkey '^T' fzf-file-widget

# Alt+C: cd into directory
fzf-cd-widget() {
  local dir
  dir=$(fd . --type d 2>/dev/null | fzf) || return
  builtin cd "$dir"
  zle reset-prompt
}
zle -N fzf-cd-widget
bindkey '^[c' fzf-cd-widget

# Ctrl+R: history search
fzf-history-widget() {
  local selected
  selected=$(fc -rl 1 | fzf --tac --prompt='history> ' \
    | sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//') || return
  LBUFFER+="$selected"
  zle redisplay
}
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

# Ctrl+F: command picker
fzf-command-widget() {
  local selected
  selected=$(
    (
      compgen -c 2>/dev/null
      alias | sed 's/=.*//'
      functions | sed 's/ .*//' | sed 's/()//'
    ) | sort -u | fzf --prompt='command> '
  ) || return
  LBUFFER+="$selected "
  zle redisplay
}
zle -N fzf-command-widget
bindkey '^F' fzf-command-widget

# Ctrl+Space: smart complete
fzf-smart-complete() {
  local token selected
  token=${LBUFFER##* }

  if [[ -z "$token" ]]; then
    selected=$(fc -rl 1 | fzf --tac --prompt='history> ' \
      | sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//') || return
    LBUFFER+="$selected"
  elif [[ -d "$token" || "$token" == */* ]]; then
    selected=$(fd . "${token%/*:-.}" 2>/dev/null | fzf) || return
    LBUFFER="${LBUFFER%$token}$selected"
  else
    selected=$(
      (
        compgen -c 2>/dev/null
        alias | sed 's/=.*//'
        functions | sed 's/ .*//' | sed 's/()//'
      ) | sort -u | fzf --prompt='command> '
    ) || return
    LBUFFER="${LBUFFER%$token}$selected "
  fi

  zle redisplay
}
zle -N fzf-smart-complete
bindkey '^ ' fzf-smart-complete

# Secrets (JIRA / LITELLM / FIGMA) carregados via ~/.config/zsh/secrets.zsh
[[ -r "$HOME/.config/zsh/secrets.zsh" ]] && source "$HOME/.config/zsh/secrets.zsh"
# unset OPENAI_API_KEY  # removed: was wiping LiteLLM key needed by Codex

# Load custom aliases and help system
for f in ~/.zsh/aliases/*.zsh(N); do [[ -r "$f" ]] && source "$f"; done
[[ -r ~/.zsh/help.zsh ]] && source ~/.zsh/help.zsh
[[ -r ~/.zsh/help_docs.zsh ]] && source ~/.zsh/help_docs.zsh

# {mark} START IT-ENG JAMF SETUP MOBILE ZSHRC
if [[ "$_DOTFILES_OS" == "Darwin" && -n "$NU_HOME" ]]; then
  export MONOREPO_ROOT="$NU_HOME/mini-meta-repo"
  export FLUTTER_SDK_HOME="$HOME/sdk-flutter"
  export FLUTTER_ROOT="$FLUTTER_SDK_HOME"
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export ANDROID_SDK="$ANDROID_HOME"
  export PATH="$MONOREPO_ROOT/monocli/bin:$FLUTTER_SDK_HOME/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$NU_HOME/.pub-cache/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
fi
# {mark} END IT-ENG JAMF SETUP MOBILE ZSHRC

# NVM default bin no PATH (para que `pi`, `node` etc. resolvam em /bin/sh subshells)
# Lê ~/.nvm/alias/default (ex.: "24") e escolhe a maior versão instalada com esse prefixo.
_nvm_default_alias="$(cat "$HOME/.nvm/alias/default" 2>/dev/null)"
if [ -n "$_nvm_default_alias" ]; then
  _nvm_prefix="v${_nvm_default_alias#v}"
  _nvm_bin="$(/bin/ls -1d "$HOME/.nvm/versions/node/${_nvm_prefix}"*/bin 2>/dev/null | sort -V | tail -n1)"
  [ -d "$_nvm_bin" ] && export PATH="$_nvm_bin:$PATH"
fi
unset _nvm_default_alias _nvm_prefix _nvm_bin

# NVM lazy-load — só carrega no primeiro uso (economiza ~200ms startup)
export NVM_DIR="$HOME/.nvm"
_nvm_lazy_load() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}
nvm() { _nvm_lazy_load; nvm "$@"; }
node() { _nvm_lazy_load; node "$@"; }
npm() { _nvm_lazy_load; npm "$@"; }
npx() { _nvm_lazy_load; npx "$@"; }

# Bun completions and bin (Linux)
if [[ "$_DOTFILES_OS" == "Linux" ]]; then
  [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# ── Langfuse (local) ──────────────────────────────────────────
if [[ "$_DOTFILES_OS" == "Darwin" ]]; then
  export LANGFUSE_PUBLIC_KEY=pk-lf-local
  export LANGFUSE_SECRET_KEY=sk-lf-local
  export LANGFUSE_HOST=http://localhost:3100
fi

# ── NU Voice ──────────────────────────────────────────────────
# macOS grants Microphone per-bundle: nu-voice inherits mic from the host
# terminal (cmux), so it MUST stay a child of this shell. We background a
# SUBSHELL as a job — `( … ) &` — NOT `( … & )`, which reparents the process
# to init(1) and silently breaks the mic. Closing this shell stops nu-voice;
# the next shell auto-starts it again.
_nuvoice_launch() {
  ( cd "$HOME/nu-voice" && ./run.sh --config configs/user.yaml --skip-preflight --debug >/tmp/nu-voice.log 2>&1 ) &
}
nuvoice() {
  case "$1" in
    stop)    pkill -f voice_transcriber; rm -f /tmp/nu-voice.lock; echo "nu-voice stopped" ;;
    restart) pkill -f voice_transcriber; sleep 1; rm -f /tmp/nu-voice.lock; _nuvoice_launch; echo "nu-voice restarted" ;;
    status)  pgrep -fl -- '-m voice_transcriber ' || echo "nu-voice not running" ;;
    log)     tail -f /tmp/nu-voice.log ;;
    *)       _nuvoice_launch; echo "nu-voice started (log: nuvoice log)" ;;
  esac
}
# Auto-start once (skip if already running). Disable with NU_VOICE_NO_AUTOSTART=1.
if [[ "$_DOTFILES_OS" == "Darwin" && -z "$NU_VOICE_NO_AUTOSTART" ]] && ! pgrep -f -- '-m voice_transcriber ' >/dev/null 2>&1; then
  _nuvoice_launch
fi


# Zoxide (smarter cd) — installs `cd` and `cdi`; native fallback to builtin cd for real paths.
# MUST be last: zoxide hooks chpwd/precmd and warns if any config runs after its init.
command -v zoxide &> /dev/null && eval "$(zoxide init zsh --cmd cd)"
