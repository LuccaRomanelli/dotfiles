## @cmd ff
## @desc [interactive] Fuzzy find file and open it
unalias ff 2>/dev/null
ff() {
  local file
  file=$(fzf --preview 'bat --style=numbers --color=always {}')
  [[ -n "$file" ]] && _open_smart "$file"
}

## @cmd ffh
## @desc [interactive] Fuzzy find file (incl. hidden) and open it
ffh() {
  local file
  file=$(fd --hidden --exclude .git . 2>/dev/null | fzf --height 40% --reverse --border --preview 'bat --style=numbers --color=always {} 2>/dev/null || file {}')
  [[ -n "$file" ]] && _open_smart "$file"
}

## @cmd s
## @desc [interactive] Search file contents with ripgrep and open at line
s() {
  local selection file line
  selection=$(rg --hidden --glob '!.git' --line-number --color=always . 2>/dev/null | \
    fzf --ansi --height 40% --reverse --border \
        --preview 'bat --style=numbers --color=always --highlight-line {2} {1} 2>/dev/null' \
        --preview-window '+{2}-5' \
        --delimiter ':')
  [[ -z "$selection" ]] && return
  file=$(echo "$selection" | cut -d':' -f1)
  line=$(echo "$selection" | cut -d':' -f2)
  _open_smart "$file" "$line"
}

## @cmd cdf
## @desc [interactive] Fuzzy find file and cd to its directory
cdf() {
  local file
  file=$(fzf --preview 'bat --style=numbers --color=always {}')
  [[ -n "$file" ]] && cd "$(dirname "$file")"
}


_open_smart() {
  local file="$1" line="${2:-1}"
  local mimetype=$(file --mime-type -b "$file")

  if [[ "$mimetype" == text/* || "$mimetype" == application/json || "$mimetype" == application/javascript ]]; then
    nvim "+$line" "$file"
  else
    open "$file" >/dev/null 2>&1 &
  fi
}
