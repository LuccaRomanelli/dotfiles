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
# ls/lsa/ll/la/lt/lta are now defined in listing.zsh (macOS folder emoji + Finder tag color).

## @cmd cd
## @desc cd <dir|pattern> — zoxide-powered smart cd (uses `zoxide init --cmd cd` from .zshrc)
# zoxide installs `cd` and `cdi` directly; nothing to do here besides documentation.

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
