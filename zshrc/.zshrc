# --- Ferramentas que você já tem ---
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

if command -v fzf &> /dev/null; then
  if [[ -f /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
  fi
  if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
  fi
fi

# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
plugins=(command-not-found zsh-autosuggestion zsh-sintax-highlighting sudo)
source $ZSH/oh-my-zsh.sh

# --- Completion padrão + cores ---
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*' completer _complete _correct _approximate
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*'

setopt auto_cd

# --- fzf base ---
source <(fzf --zsh)

# --- Widgets fzf personalizados ---
# Ctrl+T: arquivo
fzf-file-widget() {
  local selected
  selected=$(fd . 2>/dev/null | fzf --height 40% --reverse --border) || return
  LBUFFER+="$selected"
  zle redisplay
}
zle -N fzf-file-widget
bindkey '^T' fzf-file-widget

# Alt+C: cd
fzf-cd-widget() {
  local dir
  dir=$(fd . --type d 2>/dev/null | fzf --height 40% --reverse --border) || return
  builtin cd "$dir"
  zle reset-prompt
}
zle -N fzf-cd-widget
bindkey '^[c' fzf-cd-widget

# Ctrl+R: histórico
fzf-history-widget() {
  local selected
  selected=$(fc -rl 1 | fzf --height 40% --reverse --border \
    --tac --prompt='history> ' \
    | sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//') || return
  LBUFFER+="$selected"
  zle redisplay
}
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget

# Ctrl+F: comando
fzf-command-widget() {
  local selected
  selected=$(
    (
      compgen -c 2>/dev/null
      alias | sed 's/=.*//'
      functions | sed 's/ .*//' | sed 's/()//'
    ) | sort -u | fzf --height 40% --reverse --border --prompt='command> '
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
    selected=$(fc -rl 1 | fzf --height 40% --reverse --border \
      --tac --prompt='history> ' \
      | sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//') || return
    LBUFFER+="$selected"
  elif [[ -d "$token" || "$token" == */* ]]; then
    selected=$(fd . "${token%/*:-.}" 2>/dev/null | fzf --height 40% --reverse --border) || return
    LBUFFER="${LBUFFER%$token}$selected"
  else
    selected=$(
      (
        compgen -c 2>/dev/null
        alias | sed 's/=.*//'
        functions | sed 's/ .*//' | sed 's/()//'
      ) | sort -u | fzf --height 40% --reverse --border --prompt='command> '
    ) || return
    LBUFFER="${LBUFFER%$token}$selected "
  fi

  zle redisplay
}
zle -N fzf-smart-complete
bindkey '^ ' fzf-smart-complete

# --- resto do seu .zshrc ---
export PATH="$HOME/.tmuxifier/bin:$PATH"
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"
export DISABLE_AUTO_TITLE=true
export PATH="$HOME/.local/bin:$PATH"

HISTFILE=~/.history
HISTSIZE=10000
SAVEHIST=50000
setopt inc_append_history

source ~/.zsh_aliases
