## @cmd cat / rcat
## @desc Replace `cat` with `bat` (syntax-highlighted view) and keep `rcat`
##       as an escape hatch to the real /bin/cat for raw / scripting use.
##
## Paging is disabled in the alias (not the config file) because
## ~/.config/bat/config is DevTools-managed and may be overwritten on sync.

if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
  alias rcat='/bin/cat'
fi
