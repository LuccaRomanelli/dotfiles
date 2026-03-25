_help_docs() {
  case "$1" in
    ls)
      cat <<'EOF'
ls - List files with icons and git info
Lists files using eza with long format, icons, and directories first.
Usage: ls [path]
Deps: eza
Examples:
  ls              # list current directory
  ls ~/projects   # list a specific directory
  lsa             # include hidden files
  ll              # long format with all details
  lt              # tree view (2 levels deep)
EOF
      ;;
    cd|zd)
      cat <<'EOF'
cd / zd - Smart directory change
If no args: go home. If arg is a real directory: cd into it. Otherwise: use zoxide jump.
Usage: cd <dir|pattern>
Deps: zoxide
Examples:
  cd              # go to ~
  cd /tmp         # direct cd
  cd proj         # jump to best zoxide match for "proj"
EOF
      ;;
    ..)
      cat <<'EOF'
.. - Go up directory levels
Aliases for navigating up the directory tree.
Usage: ..  /  ...  /  ....
Examples:
  ..    # go up 1 level
  ...   # go up 2 levels
  ....  # go up 3 levels
EOF
      ;;
    y)
      cat <<'EOF'
y - Yazi file manager with cd-on-exit
Opens yazi and changes the shell's working directory to wherever yazi exits.
Usage: y [path]
Deps: yazi
Examples:
  y          # open yazi in current directory
  y ~/docs   # open yazi in ~/docs
EOF
      ;;
    ff)
      cat <<'EOF'
ff - Fuzzy find and open file
Uses fzf with bat preview to select a file, then opens it smart (nvim for text, system open otherwise).
Usage: ff
Deps: fzf, bat, nvim
Examples:
  ff   # launch fuzzy finder; select a file to open it
EOF
      ;;
    ffh)
      cat <<'EOF'
ffh - Fuzzy find files including hidden
Uses fd + fzf to search all files (including hidden, excluding .git) with preview.
Usage: ffh
Deps: fd, fzf, bat
Examples:
  ffh   # launch fuzzy finder over all files including hidden
EOF
      ;;
    s)
      cat <<'EOF'
s - Fuzzy search file contents
Uses ripgrep to search all file contents, then fzf to pick a result. Opens at the matching line.
Usage: s
Deps: rg (ripgrep), fzf, bat, nvim
Examples:
  s   # search all file contents interactively
EOF
      ;;
    cdf)
      cat <<'EOF'
cdf - Fuzzy find file and cd to its directory
Uses fzf to pick a file, then changes to the directory containing that file.
Usage: cdf
Deps: fzf, bat
Examples:
  cdf   # select a file; shell moves to its parent directory
EOF
      ;;
    g)
      cat <<'EOF'
g - Git shorthand
Usage: g <git-command>
Examples:
  g log --oneline   # short git log
  g diff HEAD~1     # diff against previous commit
EOF
      ;;
    ga)
      cat <<'EOF'
ga - Stage all changes
Runs: git add .
Usage: ga
Examples:
  ga   # stage everything in current directory
EOF
      ;;
    gcam)
      cat <<'EOF'
gcam - Commit all tracked changes with message
Runs: git commit -a -m
Usage: gcam "<message>"
Examples:
  gcam "fix: typo in README"
EOF
      ;;
    gl)
      cat <<'EOF'
gl - Pull from remote
Runs: git pull
Usage: gl
EOF
      ;;
    gp)
      cat <<'EOF'
gp - Push to remote
Runs: git push
Usage: gp
EOF
      ;;
    gs)
      cat <<'EOF'
gs - Git status
Runs: git status
Usage: gs
EOF
      ;;
    gco)
      cat <<'EOF'
gco - Checkout branch or file
Runs: git checkout
Usage: gco <branch|file>
Examples:
  gco main          # switch to main branch
  gco -b feature    # create and switch to new branch
EOF
      ;;
    gb)
      cat <<'EOF'
gb - List or manage branches
Runs: git branch
Usage: gb [-a|-d <branch>]
Examples:
  gb          # list local branches
  gb -a       # list all branches including remote
  gb -d old   # delete branch "old"
EOF
      ;;
    lg)
      cat <<'EOF'
lg - Lazygit TUI
Opens lazygit for an interactive git interface.
Usage: lg
Deps: lazygit
EOF
      ;;
    gf)
      cat <<'EOF'
gf - Add, commit, and push in one step
Runs: git add . && git commit -m "<msg>" && git push
Usage: gf "<message>"
Examples:
  gf "chore: update deps"
EOF
      ;;
    d)
      cat <<'EOF'
d - Docker shorthand
Usage: d <docker-command>
Examples:
  d ps       # list running containers
  d images   # list images
EOF
      ;;
    ports)
      cat <<'EOF'
ports - List listening ports
Runs: sudo lsof -i -P -n | grep LISTEN
Usage: ports
EOF
      ;;
    kp)
      cat <<'EOF'
kp - Kill process on a port
Finds and kills all processes listening on the specified port.
Usage: kp <port>
Examples:
  kp 3000   # kill whatever is on port 3000
EOF
      ;;
    dcou)
      cat <<'EOF'
dcou - Docker Compose up (detached)
Runs: docker compose up -d
Usage: dcou
EOF
      ;;
    down)
      cat <<'EOF'
down - Docker Compose down
Runs: docker compose down
Usage: down
EOF
      ;;
    vim|vi)
      cat <<'EOF'
vim / vi - Neovim
Both vim and vi are aliased to nvim.
Usage: vim [file]  /  vi [file]
Deps: nvim
EOF
      ;;
    n)
      cat <<'EOF'
n - Open neovim (smart)
Opens nvim on the current directory if no args; otherwise opens the given files.
Usage: n [files...]
Deps: nvim
Examples:
  n           # open nvim in current dir
  n file.txt  # open a specific file
EOF
      ;;
    ndiff)
      cat <<'EOF'
ndiff - Neovim git diff review
Opens neovim with GitReview plugin to diff against a base branch.
Usage: ndiff [base-branch]
Deps: nvim, GitReview plugin
Examples:
  ndiff              # diff against origin/main
  ndiff origin/dev   # diff against origin/dev
EOF
      ;;
    c)
      cat <<'EOF'
c - Claude CLI (all permissions)
Runs claude with --dangerously-skip-permissions flag.
Usage: c [claude-args]
Deps: claude
Examples:
  c                 # start interactive Claude session
  c "explain this"  # one-shot prompt
EOF
      ;;
    cr)
      cat <<'EOF'
cr - Resume Claude session
Runs: claude --resume
Usage: cr
Deps: claude
EOF
      ;;
    zet)
      cat <<'EOF'
zet - Create Zettelkasten note
Runs: ~/shell/zet.sh
Usage: zet [args]
EOF
      ;;
    nn)
      cat <<'EOF'
nn - Create a new note
Runs: ~/shell/nn.sh
Usage: nn [args]
EOF
      ;;
    todo)
      cat <<'EOF'
todo - Show todo list
Runs: ~/shell/todo.sh
Usage: todo
EOF
      ;;
    todoadd)
      cat <<'EOF'
todoadd - Add item to todo list
Runs: ~/shell/todoadd.sh
Usage: todoadd "<item>"
EOF
      ;;
    workday)
      cat <<'EOF'
workday - Show workday log
Runs: ~/shell/workday.sh
Usage: workday
EOF
      ;;
    workdayadd)
      cat <<'EOF'
workdayadd - Add entry to workday log
Runs: ~/shell/workdayadd.sh
Usage: workdayadd "<entry>"
EOF
      ;;
    devb)
      cat <<'EOF'
devb - Build devcontainer
Runs: devcontainer build --workspace-folder .
Usage: devb
Deps: devcontainer CLI
EOF
      ;;
    devup)
      cat <<'EOF'
devup - Start devcontainer
Runs: devcontainer up --workspace-folder .
Usage: devup
Deps: devcontainer CLI
EOF
      ;;
    devdown)
      cat <<'EOF'
devdown - Stop devcontainer
Runs: devcontainer down --workspace-folder .
Usage: devdown
Deps: devcontainer CLI
EOF
      ;;
    dev)
      cat <<'EOF'
dev - Shell into devcontainer
Runs: devcontainer exec --workspace-folder . zsh
Usage: dev
Deps: devcontainer CLI
EOF
      ;;
    nu)
      cat <<'EOF'
nu - Nu CLI tooling
Nu CLI commands are available directly. Use `help nu <subcmd>` to delegate to nu's own help.
Usage: nu [subcommand] [args]
       help nu              # show nu top-level help
       help nu <subcmd>     # show help for a specific nu subcommand
Deps: nu (nucli)
EOF
      ;;
    *)
      echo "No documentation found for: $1"
      echo "Run 'help' to see all available commands."
      ;;
  esac
}
