## @cmd ls
## @desc ls — long format, icons, dirs first
## @cmd lsa
## @desc lsa — ls + hidden files
## @cmd ll
## @desc ll — long format, all details
## @cmd la
## @desc la — short format, show hidden
## @cmd lt
## @desc lt — tree view (2 levels)
## @cmd lta
## @desc lta — tree view + hidden
if command -v eza &> /dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias ll='eza -la --icons --group-directories-first'
  alias la='eza -a --icons --group-directories-first'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

## @cmd cd
## @desc cd <dir|pattern> — zoxide-powered smart cd
if command -v zoxide &> /dev/null; then
  alias cd="zd"
  zd() {
    if [ $# -eq 0 ]; then
      builtin cd ~ && return
    elif [ -d "$1" ]; then
      builtin cd "$1"
    else
      z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
    fi
  }
fi

## @cmd ..
## @desc Go up 1 level (also ... and ....)
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

## @cmd y
## @desc [interactive] Yazi file manager, cd on exit
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}
