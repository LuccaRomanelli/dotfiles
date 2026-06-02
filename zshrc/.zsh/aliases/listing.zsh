## @cmd ls / lsa / ll / la / lt / lta
## @desc macOS-aware listings: shows custom folder emoji + Finder tag color,
##       falls back to file-type defaults, batches metadata for speed.
##
## Reads two extended attributes per entry:
##   xattr  com.apple.icon.folder#S       → {"emoji":"🤖"} (macOS Tahoe folder emoji)
##   mdls   kMDItemUserTags               → Finder color tag (Red/Orange/.../Gray)
##
## Precedence:
##   color: Finder-tag color > extension default color > folder/document base color
##   emoji: xattr custom emoji > extension default emoji > folder/document base emoji
##
## Performance: prefetch runs stat/mdls/ls -@ in parallel; render path is
## fork-free (helpers set REPLY, strftime/printf use -s/inline).

if [[ "$(uname -s 2>/dev/null)" != "Darwin" ]]; then
  if command -v eza &> /dev/null; then
    alias ls='eza -lh --group-directories-first --icons=auto'
    alias lsa='ls -a'
    alias ll='eza -la --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
  fi
  return 0
fi

zmodload -F zsh/datetime b:strftime b:EPOCHREALTIME 2>/dev/null

# ──────────────────────────────────────────────────────────────────────
# DEFAULTS — file-type emoji + ANSI 24-bit color tables.
# ──────────────────────────────────────────────────────────────────────

typeset -gA _MACOS_EXT_EMOJI _MACOS_EXT_COLOR

# Source code
for x in clj cljs cljc edn;          do _MACOS_EXT_EMOJI[$x]='λ';   _MACOS_EXT_COLOR[$x]=$'\e[38;2;99;179;237m';  done
for x in py;                         do _MACOS_EXT_EMOJI[$x]='🐍';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;255;212;59m';  done
for x in rb;                         do _MACOS_EXT_EMOJI[$x]='💎';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;204;52;45m';   done
for x in js jsx;                     do _MACOS_EXT_EMOJI[$x]='🟨';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;240;219;79m';  done
for x in ts tsx;                     do _MACOS_EXT_EMOJI[$x]='🟦';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;49;120;198m';  done
for x in go;                         do _MACOS_EXT_EMOJI[$x]='🐹';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;0;173;216m';   done
for x in rs;                         do _MACOS_EXT_EMOJI[$x]='🦀';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;222;165;132m'; done
for x in java kt;                    do _MACOS_EXT_EMOJI[$x]='☕';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;176;114;25m';  done
for x in swift;                      do _MACOS_EXT_EMOJI[$x]='🦅';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;240;101;41m';  done
for x in c h;                        do _MACOS_EXT_EMOJI[$x]='⚙️';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;160;176;196m'; done
for x in cpp hpp;                    do _MACOS_EXT_EMOJI[$x]='⚙️';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;0;153;188m';   done
for x in html;                       do _MACOS_EXT_EMOJI[$x]='🌐';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;227;79;38m';   done
for x in css scss;                   do _MACOS_EXT_EMOJI[$x]='🎨';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;38;77;228m';   done

# Documents
for x in md rst;                     do _MACOS_EXT_EMOJI[$x]='📝';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;200;200;210m'; done
for x in txt log;                    do _MACOS_EXT_EMOJI[$x]='📜';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;170;170;170m'; done
for x in pdf;                        do _MACOS_EXT_EMOJI[$x]='📕';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;180;70;70m';   done
for x in doc docx;                   do _MACOS_EXT_EMOJI[$x]='📘';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;66;133;244m';  done
for x in csv tsv;                    do _MACOS_EXT_EMOJI[$x]='📊';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;120;180;120m'; done

# Configs / data
for x in json;                       do _MACOS_EXT_EMOJI[$x]='🔧';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;200;160;90m';  done
for x in yaml yml;                   do _MACOS_EXT_EMOJI[$x]='🔧';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;203;75;75m';   done
for x in toml ini conf env;          do _MACOS_EXT_EMOJI[$x]='🔧';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;156;134;192m'; done

# Shell / executables
for x in sh zsh bash fish;           do _MACOS_EXT_EMOJI[$x]='💻';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;130;200;130m'; done

# Images / video / audio
for x in png jpg jpeg gif webp;      do _MACOS_EXT_EMOJI[$x]='🖼️';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;236;131;191m'; done
for x in svg;                        do _MACOS_EXT_EMOJI[$x]='🖌️';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;255;179;71m';  done
for x in mp4 mov mkv;                do _MACOS_EXT_EMOJI[$x]='🎬';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;195;130;230m'; done
for x in mp3 wav flac;               do _MACOS_EXT_EMOJI[$x]='🎵';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;130;215;200m'; done

# Archives, lockfiles, db, secrets
for x in zip tar gz tgz xz 7z bz2;   do _MACOS_EXT_EMOJI[$x]='📦';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;180;140;100m'; done
for x in lock;                       do _MACOS_EXT_EMOJI[$x]='🔒';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;140;140;150m'; done
for x in sqlite db parquet;          do _MACOS_EXT_EMOJI[$x]='🗄️';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;110;180;220m'; done
for x in pem key crt;                do _MACOS_EXT_EMOJI[$x]='🔑';  _MACOS_EXT_COLOR[$x]=$'\e[38;2;230;200;100m'; done

typeset -gA _MACOS_NAME_EMOJI _MACOS_NAME_COLOR
_MACOS_NAME_EMOJI[Dockerfile]='🐳'; _MACOS_NAME_COLOR[Dockerfile]=$'\e[38;2;52;152;219m'
_MACOS_NAME_EMOJI[Makefile]='🛠️';   _MACOS_NAME_COLOR[Makefile]=$'\e[38;2;200;120;80m'
_MACOS_NAME_EMOJI[Justfile]='🛠️';   _MACOS_NAME_COLOR[Justfile]=$'\e[38;2;200;120;80m'

# Tag → ANSI color (precomputed at prefetch time, stored in _LL_TAG_COLOR).
typeset -gA _MACOS_TAG_ANSI
_MACOS_TAG_ANSI[Red]=$'\e[31m'
_MACOS_TAG_ANSI[Orange]=$'\e[38;5;208m'
_MACOS_TAG_ANSI[Yellow]=$'\e[33m'
_MACOS_TAG_ANSI[Green]=$'\e[32m'
_MACOS_TAG_ANSI[Blue]=$'\e[34m'
_MACOS_TAG_ANSI[Purple]=$'\e[35m'
_MACOS_TAG_ANSI[Gray]=$'\e[90m'

_MACOS_BASE_FOLDER_COLOR=$'\e[38;2;130;170;230m'
_MACOS_BASE_FOLDER_EMOJI='📁'
_MACOS_BASE_DOC_COLOR=''
_MACOS_BASE_DOC_EMOJI='📄'

# ──────────────────────────────────────────────────────────────────────
# PERFORMANCE — batch metadata cache, parallel I/O, fork-free render.
# Globals populated by _macos_prefetch:
#   _LL_TAG_COLOR[$path]  → ANSI color from Finder tag (or '')
#   _LL_STAT[$path]       → "perms|links|size|mtime|owner"
#   _LL_EMOJI[$path]      → custom xattr emoji (or '')
# ──────────────────────────────────────────────────────────────────────

typeset -gA _LL_TAG_COLOR _LL_STAT _LL_EMOJI

_macos_prefetch() {
  emulate -L zsh
  setopt local_options typeset_silent no_monitor no_notify
  _LL_TAG_COLOR=(); _LL_STAT=(); _LL_EMOJI=()
  (( $# == 0 )) && return 0
  local -a entries; entries=( "${(@)@}" )

  # Three batched commands run in PARALLEL via background jobs writing to
  # tmpfiles. Wall time = max(stat, mdls, ls -@) instead of sum.
  local tdir; tdir="${TMPDIR:-/tmp}/llrun.$$.$RANDOM"
  command mkdir -p "$tdir" 2>/dev/null || return 0

  # Run all three commands in a SUBSHELL so background-job
  # notifications never reach the interactive shell's job table.
  local has_mdls=0; (( ${+commands[mdls]} )) && has_mdls=1
  (
    command stat -f '%Sp|%l|%z|%m|%Su' "${(@)entries}" >"$tdir/stat" 2>/dev/null &
    if (( has_mdls )); then
      command mdls -name kMDItemUserTags "${(@)entries}" >"$tdir/mdls" 2>/dev/null &
    fi
    command ls -@ -d "${(@)entries}" >"$tdir/ls" 2>/dev/null &
    wait
  )
  local pid_mdls=$has_mdls

  # stat — one line per path in input order.
  local stat_out; stat_out="$(<$tdir/stat)"
  if [[ -n "$stat_out" ]]; then
    local -a stat_lines; stat_lines=( "${(@f)stat_out}" )
    local i
    for (( i=1; i <= $#entries; i++ )); do
      _LL_STAT[${entries[i]}]="${stat_lines[i]:-}"
    done
  fi

  # mdls — re-group multi-line records by `kMDItemUserTags` marker.
  if (( pid_mdls )); then
    local mdls_out; mdls_out="$(<$tdir/mdls)"
    if [[ -n "$mdls_out" ]]; then
      local -a mdls_lines; mdls_lines=( "${(@f)mdls_out}" )
      local -a records; records=()
      local cur='' line in_rec=0
      for line in "${mdls_lines[@]}"; do
        if [[ "$line" == "kMDItemUserTags"* ]]; then
          (( in_rec )) && records+=("$cur")
          cur="$line"; in_rec=1
        else
          cur+=$'\n'"$line"
        fi
      done
      (( in_rec )) && records+=("$cur")
      local idx
      for (( idx=1; idx <= $#entries; idx++ )); do
        local rec="${records[idx]:-}" color=''
        case "$rec" in
          *Red*)    color=$'\e[31m'      ;;
          *Orange*) color=$'\e[38;5;208m' ;;
          *Yellow*) color=$'\e[33m'      ;;
          *Green*)  color=$'\e[32m'      ;;
          *Blue*)   color=$'\e[34m'      ;;
          *Purple*) color=$'\e[35m'      ;;
          *Gray*)   color=$'\e[90m'      ;;
        esac
        _LL_TAG_COLOR[${entries[idx]}]="$color"
      done
    fi
  fi

  # xattr — only fork on entries that actually carry com.apple.icon.folder#S.
  local ls_out; ls_out="$(<$tdir/ls)"
  command rm -rf "$tdir" 2>/dev/null
  if [[ -n "$ls_out" ]]; then
    local -a ls_lines; ls_lines=( "${(@f)ls_out}" )
    local cur_path='' l
    local -a needs_xattr; needs_xattr=()
    for l in "${ls_lines[@]}"; do
      if [[ "$l" == $'\t'* ]]; then
        [[ "$l" == *com.apple.icon.folder#S* && -n "$cur_path" ]] && \
          needs_xattr+=("$cur_path")
      else
        cur_path="${l##* }"
      fi
    done
    local p raw e
    for p in "${needs_xattr[@]}"; do
      raw=$(command xattr -p 'com.apple.icon.folder#S' "$p" 2>/dev/null)
      [[ -z "$raw" ]] && continue
      e="${raw#*\"emoji\":\"}"; e="${e%%\"*}"
      [[ -n "$e" ]] && _LL_EMOJI[$p]="$e"
    done
  fi
}

# ──────────────────────────────────────────────────────────────────────
# FORK-FREE LOOKUPS — set REPLY, no subshell.
# Caller: `_ll_emoji_r "$p"; emoji=$REPLY`
# ──────────────────────────────────────────────────────────────────────

_ll_emoji_r() {
  local p="$1" base="${1:t}" ext="${1:e}"
  REPLY="${_LL_EMOJI[$p]:-}"
  [[ -n "$REPLY" ]] && return
  if [[ -d "$p" ]]; then REPLY="$_MACOS_BASE_FOLDER_EMOJI"; return; fi
  REPLY="${_MACOS_NAME_EMOJI[$base]:-}"; [[ -n "$REPLY" ]] && return
  REPLY="${_MACOS_EXT_EMOJI[$ext]:-}";   [[ -n "$REPLY" ]] && return
  REPLY="$_MACOS_BASE_DOC_EMOJI"
}

_ll_color_r() {
  local p="$1" base="${1:t}" ext="${1:e}"
  REPLY="${_LL_TAG_COLOR[$p]:-}"
  [[ -n "$REPLY" ]] && return
  if [[ -d "$p" ]]; then REPLY="$_MACOS_BASE_FOLDER_COLOR"; return; fi
  REPLY="${_MACOS_NAME_COLOR[$base]:-}"; [[ -n "$REPLY" ]] && return
  REPLY="${_MACOS_EXT_COLOR[$ext]:-}";   [[ -n "$REPLY" ]] && return
  REPLY="$_MACOS_BASE_DOC_COLOR"
}

_ll_size_r() {
  local b=$1 v whole frac
  if (( b < 1024 )); then
    REPLY="${b}B"
  elif (( b < 1024 * 1024 )); then
    v=$(( b * 10 / 1024 )); whole=$(( v / 10 )); frac=$(( v % 10 )); REPLY="${whole}.${frac}K"
  elif (( b < 1024 * 1024 * 1024 )); then
    v=$(( b * 10 / (1024 * 1024) )); whole=$(( v / 10 )); frac=$(( v % 10 )); REPLY="${whole}.${frac}M"
  else
    v=$(( b * 10 / (1024 * 1024 * 1024) )); whole=$(( v / 10 )); frac=$(( v % 10 )); REPLY="${whole}.${frac}G"
  fi
}

_ll_mtime_r() {
  local epoch="$1" now="$2"
  if (( now - epoch < 15552000 )); then
    strftime -s REPLY '%b %e %H:%M' "$epoch"
  else
    strftime -s REPLY '%b %e  %Y'   "$epoch"
  fi
}

# Sort entries: dirs first then files, alpha within each.
_macos_sort_entries() {
  local -a dirs files e
  for e in "$@"; do
    [[ -d "$e" ]] && dirs+=("$e") || files+=("$e")
  done
  print -rl -- ${(o)dirs} ${(o)files}
}

# Back-compat shims for any external caller; not used on hot path.
_macos_emoji_for()     { _ll_emoji_r "$1"; print -r -- "$REPLY"; }
_macos_tag_color_for() { _ll_color_r "$1"; print -r -- "$REPLY"; }

_macos_listing_long() {
  emulate -L zsh
  setopt local_options typeset_silent
  (( $# == 0 )) && return
  local reset=$'\e[0m' now=$EPOCHSECONDS
  local -a perms_a links_a sizes_a mtimes_a owners_a emoji_a color_a name_a
  local entry max_size=0 max_owner=0 max_links=0
  for entry in "$@"; do
    local row="${_LL_STAT[$entry]:-}"
    [[ -z "$row" ]] && continue
    local perms="${row%%|*}"; row="${row#*|}"
    local links="${row%%|*}"; row="${row#*|}"
    local sizeb="${row%%|*}"; row="${row#*|}"
    local mtime="${row%%|*}"; local owner="${row#*|}"
    _ll_size_r  "$sizeb";        local sizeh="$REPLY"
    _ll_mtime_r "$mtime" "$now"; local mts="$REPLY"
    _ll_emoji_r "$entry";        local emoji="$REPLY"
    _ll_color_r "$entry";        local color="$REPLY"
    local name="${entry:t}"
    [[ -d "$entry" ]] && name+='/'
    perms_a+=("$perms"); links_a+=("$links")
    sizes_a+=("$sizeh"); mtimes_a+=("$mts");  owners_a+=("$owner")
    emoji_a+=("$emoji"); color_a+=("$color"); name_a+=("$name")
    (( ${#sizeh}  > max_size  )) && max_size=${#sizeh}
    (( ${#owner}  > max_owner )) && max_owner=${#owner}
    (( ${#links}  > max_links )) && max_links=${#links}
  done

  local n=$#perms_a i
  for (( i=1; i <= n; i++ )); do
    printf '%s  %s%s  %*s  %-*s  %*s  %s  %s%s\n' \
      "${emoji_a[i]}" \
      "${color_a[i]}" "${perms_a[i]}" \
      "$max_links"    "${links_a[i]}" \
      "$max_owner"    "${owners_a[i]}" \
      "$max_size"     "${sizes_a[i]}" \
      "${mtimes_a[i]}" \
      "${name_a[i]}" "$reset"
  done
}

_macos_listing_short() {
  emulate -L zsh
  setopt local_options typeset_silent
  (( $# == 0 )) && return
  local reset=$'\e[0m'
  local cols=${COLUMNS:-80}
  local -a labels widths
  local entry max_w=0
  for entry in "$@"; do
    _ll_emoji_r "$entry"; local emoji="$REPLY"
    _ll_color_r "$entry"; local color="$REPLY"
    local name="${entry:t}"
    [[ -d "$entry" ]] && name+='/'
    local vw=$(( 4 + ${#name} ))
    labels+=("${emoji}  ${color}${name}${reset}")
    widths+=("$vw")
    (( vw > max_w )) && max_w=$vw
  done
  local cell=$(( max_w + 2 ))
  local per_row=$(( cols / cell )); (( per_row < 1 )) && per_row=1
  local n=$#labels i
  for (( i=1; i <= n; i++ )); do
    local pad=$(( cell - widths[i] )); (( pad < 0 )) && pad=0
    printf '%s%*s' "${labels[i]}" $pad ''
    (( i % per_row == 0 )) && print
  done
  (( n % per_row != 0 )) && print
}

# Usage: _macos_listing [--all] [--short] [-lah ...] [dir]
_macos_listing() {
  emulate -L zsh
  setopt local_options null_glob extended_glob typeset_silent
  local show_hidden=0 short=0 dir
  while (( $# )); do
    case "$1" in
      --all)   show_hidden=1 ;;
      --short) short=1 ;;
      -*)      [[ "$1" == *a* ]] && show_hidden=1 ;;
      *)       dir="$1" ;;
    esac
    shift
  done
  dir="${dir:-.}"
  [[ ! -d "$dir" ]] && { print -u2 -- "${0}: $dir: not a directory"; return 1; }

  local -a entries
  if (( show_hidden )); then
    entries=( "$dir"/*(DN) )
  else
    entries=( "$dir"/*(N) )
  fi
  (( ${#entries} == 0 )) && return 0
  entries=( ${(f)"$(_macos_sort_entries "${entries[@]}")"} )

  _macos_prefetch "${entries[@]}"

  if (( short )); then
    _macos_listing_short "${entries[@]}"
  else
    _macos_listing_long "${entries[@]}"
  fi
}

_macos_listing_tree() {
  emulate -L zsh
  setopt local_options null_glob extended_glob typeset_silent
  local show_hidden=0 max_depth=2 dir
  while (( $# )); do
    case "$1" in
      --all)     show_hidden=1 ;;
      --level=*) max_depth="${1#--level=}" ;;
      -*)        [[ "$1" == *a* ]] && show_hidden=1 ;;
      *)         dir="$1" ;;
    esac
    shift
  done
  dir="${dir:-.}"
  [[ ! -d "$dir" ]] && { print -u2 -- "${0}: $dir: not a directory"; return 1; }

  _macos_prefetch "$dir"
  local reset=$'\e[0m' emoji color
  _ll_emoji_r "$dir"; emoji="$REPLY"
  _ll_color_r "$dir"; color="$REPLY"
  printf '%s  %s%s%s\n' "$emoji" "$color" "${dir%/}/" "$reset"
  _macos_listing_tree_recurse "$dir" '' 1 "$max_depth" "$show_hidden"
}

_macos_listing_tree_recurse() {
  emulate -L zsh
  setopt local_options null_glob typeset_silent
  local dir="$1" prefix="$2" depth="$3" max_depth="$4" show_hidden="$5"
  (( depth > max_depth )) && return
  local reset=$'\e[0m'
  local -a entries
  if (( show_hidden )); then
    entries=( "$dir"/*(DN) )
  else
    entries=( "$dir"/*(N) )
  fi
  (( ${#entries} == 0 )) && return
  entries=( ${(f)"$(_macos_sort_entries "${entries[@]}")"} )

  _macos_prefetch "${entries[@]}"

  local n=${#entries} i e
  for (( i=1; i <= n; i++ )); do
    e="${entries[i]}"
    local connector next_prefix
    if (( i == n )); then
      connector='└── '; next_prefix="${prefix}    "
    else
      connector='├── '; next_prefix="${prefix}│   "
    fi
    local emoji color
    _ll_emoji_r "$e"; emoji="$REPLY"
    _ll_color_r "$e"; color="$REPLY"
    local name="${e:t}"
    [[ -d "$e" ]] && name+='/'
    printf '%s%s%s%s  %s%s\n' "$prefix" "$color" "$connector" "$emoji" "$name" "$reset"
    [[ -d "$e" && ! -L "$e" ]] && \
      _macos_listing_tree_recurse "$e" "$next_prefix" $(( depth + 1 )) "$max_depth" "$show_hidden"
  done
}

if command -v eza &> /dev/null || true; then
  alias ls='_macos_listing'
  alias lsa='_macos_listing --all'
  alias ll='_macos_listing --all'
  alias la='_macos_listing --all --short'
  alias lt='_macos_listing_tree --level=2'
  alias lta='_macos_listing_tree --all --level=2'
fi
