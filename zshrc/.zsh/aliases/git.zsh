## @cmd g
## @desc g <cmd> — git shorthand
alias g='git'

## @cmd ga
## @desc Stage all changes (git add .)
alias ga='git add .'

## @cmd gcam
## @desc gcam "<msg>" — commit all with message
alias gcam='git commit -a -m'

## @cmd gl
## @desc Pull from remote (git pull)
alias gl='git pull'

## @cmd gp
## @desc Push to remote (git push)
alias gp='git push'

## @cmd gs
## @desc Show git status
alias gs='git status'

## @cmd gco
## @desc gco <branch|file> — git checkout
alias gco='git checkout'

## @cmd gb
## @desc gb [-a|-d <name>] — list/manage branches
alias gb="git branch"

## @cmd lg
## @desc [interactive] Lazygit TUI
alias lg="lazygit"

## @cmd gf
## @desc gf "<msg>" — add all, commit, push
unalias gf 2>/dev/null
gf() {
  git add . && git commit -m "$1" && git push
}
