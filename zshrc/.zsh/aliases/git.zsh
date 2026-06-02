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

### @cmd gsc
## @desc gsc — git stash clear
alias gsc='git stash clear'

### @cmd gsh
## @desc gsh — git stash
alias gsh='git stash'

# @cmd gco
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
  echo '→ Stashing changes...'
  git stash --include-untracked || { echo '✗ Stash failed'; return 1; }

  echo '→ Fetching origin...'
  git fetch origin || { echo '✗ Fetch failed, restoring...'; git stash pop; return 1; }

  echo '→ Rebasing on origin/main...'
  if ! git rebase origin/main; then
    echo '✗ Rebase failed, aborting and restoring...'
    git rebase --abort
    git stash pop
    return 1
  fi

  echo '→ Restoring changes...'
  git stash pop || { echo '✗ Stash pop failed (possible conflict with rebase)'; return 1; }

  echo '→ Committing...'
  git add . && git commit -m "$1" && git push
}

## @cmd gnuke
## @desc gnuke — remove all linked worktrees, force-delete all local branches except main, clear stash
unalias gnuke 2>/dev/null
gnuke() {
  local main_wt
  main_wt=$(git worktree list --porcelain 2>/dev/null | awk '/^worktree / {print $2; exit}')
  if [[ -z "$main_wt" ]]; then
    echo '✗ Not in a git repo'; return 1
  fi
  if [[ "$PWD" != "$main_wt" ]]; then
    echo "✗ Run from main worktree: $main_wt"; return 1
  fi

  echo '→ Checking out main...'
  git checkout main || { echo '✗ Checkout main failed (dirty tree or no main branch)'; return 1; }

  echo '→ Removing all linked worktrees...'
  git worktree list --porcelain \
    | awk '/^worktree / {print $2}' \
    | tail -n +2 \
    | while read -r wt; do
        echo "  remove $wt"
        git worktree remove --force "$wt"
      done

  echo '→ Pruning worktree metadata...'
  git worktree prune

  echo '→ Force-deleting all local branches except main...'
  git for-each-ref --format='%(refname:short)' refs/heads \
    | grep -v '^main$' \
    | while read -r branch; do
        git branch -D "$branch"
      done

  echo '→ Clearing stash...'
  git stash clear

  echo '✓ Done.'
}

