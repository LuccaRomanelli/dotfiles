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

# Java configuration (added by devtools)
if [[ "$_DOTFILES_OS" == "Darwin" ]]; then
  export JAVA_HOME="/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

# Set cursor to blinking vertical bar
if [[ "$_DOTFILES_OS" == "Darwin" ]]; then
  echo -ne '\e[5 q'
  preexec() { echo -ne '\e[5 q'; }
fi


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

# Optional local secrets
[[ -r "$HOME/.config/zsh/secrets.zsh" ]] && source "$HOME/.config/zsh/secrets.zsh"

# Load custom aliases and help system
for f in ~/.zsh/aliases/*.zsh(N); do [[ -r "$f" ]] && source "$f"; done
[[ -r ~/.zsh/help.zsh ]] && source ~/.zsh/help.zsh
[[ -r ~/.zsh/help_docs.zsh ]] && source ~/.zsh/help_docs.zsh

# NVM default bin no PATH (para que `node` etc. resolvam em /bin/sh subshells)
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

# Zoxide (smarter cd) — installs `cd` and `cdi`; native fallback to builtin cd for real paths.
# MUST be last: zoxide hooks chpwd/precmd and warns if any config runs after its init.
command -v zoxide &> /dev/null && eval "$(zoxide init zsh --cmd cd)"
