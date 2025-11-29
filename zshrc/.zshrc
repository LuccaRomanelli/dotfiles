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

export PATH="$HOME/.tmuxifier/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"
export DISABLE_AUTO_TITLE=true

# eval "$(tmuxifier init -)"

# Source functions and aliases
source ~/.zsh_aliases
source ~/dev/dotfiles/scripts/__gh_cli.sh
