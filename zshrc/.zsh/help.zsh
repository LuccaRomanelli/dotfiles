help() {
  if [[ $# -eq 0 ]]; then
    # List all commands grouped by category
    for f in ~/.zsh/aliases/*.zsh; do
      local category=$(basename "$f" .zsh)
      local cmds=$(grep '@cmd' "$f" | awk '/@cmd/{print $NF}')
      [[ -z "$cmds" ]] && continue
      printf "\n\033[1;36m%s\033[0m\n" "$category"
      while IFS= read -r cmd; do
        local desc=$(awk -v cmd="$cmd" '$0 == "## @cmd " cmd { getline; if (/## @desc /) { sub(/.*## @desc /, ""); print } }' "$f")
        printf "  \033[1m%-16s\033[0m %s\n" "$cmd" "$desc"
      done <<< "$cmds"
    done
    echo ""
  elif [[ "$1" == "nu" && $# -ge 2 ]]; then
    # Delegate to nu subcommand help
    shift
    nu "$@" --help
  elif [[ "$1" == "nu" ]]; then
    nu --help
  else
    # Show full doc from help_docs
    _help_docs "$1"
  fi
}
