## @cmd vim
## @desc vim <file> — nvim alias
alias vim='nvim'

## @cmd vi
## @desc vi <file> — nvim alias
alias vi='nvim'

## @cmd n
## @desc n [files...] — nvim (opens . if no args)
n() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }

## @cmd ndiff
## @desc ndiff [base] — git diff review in nvim (default: origin/main)
ndiff() {
  nvim -c "GitReview ${1:-origin/main}"
}
