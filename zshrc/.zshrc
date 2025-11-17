if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

if command -v fzf &> /dev/null; then
  if [[ -f /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
  fi
  if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
  fi
fi

export PATH="$HOME/.tmuxifier/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"
export DISABLE_AUTO_TITLE=true

eval "$(tmuxifier init -)"

plugins=(command-not-found zsh-autosuggestions sudo)

source $ZSH/oh-my-zsh.sh

# Aliases
if command -v eza &> /dev/null; then
  alias ls='eza -lh --group-directories-first --icons=auto'
  alias lsa='ls -a'
  alias lt='eza --tree --level=2 --long --icons --git'
  alias lta='lt -a'
fi

alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

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

open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

# Yopki
alias yopki='tmuxifier load-session yopki'

# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Tools
alias d='docker'
n() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }

# Git
alias g='git'
alias gcam='git commit -a -m'
alias gl='git pull'
alias gp='git push'

#Compression
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }
alias decompress="tar -xzf"

# Write iso file to sd card
iso2sd() {
  if [ $# -ne 2 ]; then
    echo "Usage: iso2sd <input_file> <output_device>"
    echo "Example: iso2sd ~/Downloads/ubuntu-25.04-desktop-amd64.iso /dev/sda"
    echo -e "\nAvailable SD cards:"
    lsblk -d -o NAME | grep -E '^sd[a-z]' | awk '{print "/dev/"$1}'
  else
    sudo dd bs=4M status=progress oflag=sync if="$1" of="$2"
    sudo eject $2
  fi
}

# Format an entire drive for a single partition using ext4
format-drive() {
  if [ $# -ne 2 ]; then
    echo "Usage: format-drive <device> <name>"
    echo "Example: format-drive /dev/sda 'My Stuff'"
    echo -e "\nAvailable drives:"
    lsblk -d -o NAME -n | awk '{print "/dev/"$1}'
  else
    echo "WARNING: This will completely erase all data on $1 and label it '$2'."
    read -rp "Are you sure you want to continue? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      sudo wipefs -a "$1"
      sudo dd if=/dev/zero of="$1" bs=1M count=100 status=progress
      sudo parted -s "$1" mklabel gpt
      sudo parted -s "$1" mkpart primary ext4 1MiB 100%
      sudo mkfs.ext4 -L "$2" "$([[ $1 == *"nvme"* ]] && echo "${1}p1" || echo "${1}1")"
      sudo chmod -R 777 "/run/media/$USER/$2"
      echo "Drive $1 formatted and labeled '$2'."
    fi
  fi
}

# Transcode a video to a good-balance 1080p that's great for sharing online
transcode-video-1080p() {
  ffmpeg -i $1 -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy ${1%.*}-1080p.mp4
}

# Transcode a video to a good-balance 4K that's great for sharing online
transcode-video-4K() {
  ffmpeg -i $1 -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k ${1%.*}-optimized.mp4
}

# Transcode any image to JPG image that's great for shrinking wallpapers
img2jpg() {
  magick $1 -quality 95 -strip ${1%.*}.jpg
}

# Transcode any image to JPG image that's great for sharing online without being too big
img2jpg-small() {
  magick $1 -resize 1080x\> -quality 95 -strip ${1%.*}.jpg
}

# Transcode any image to compressed-but-lossless PNG
img2png() {
  magick "$1" -strip -define png:compression-filter=5 \
    -define png:compression-level=9 \
    -define png:compression-strategy=1 \
    -define png:exclude-chunk=all \
    "${1%.*}.png"
}

# Old key-bindings
alias ports="sudo lsof -i -P -n | grep LISTEN"
alias dcou="docker compose up -d"
alias down="docker compose down"
alias last-commit="git for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'"

export APP_SERVICE=${APP_SERVICE:-"laravel.test"}
function _find_sail() {
  local dir=.
  until [ $dir -ef / ]; do
    if [ -f "$dir/sail" ]; then
      echo "$dir/sail"
      return 0
    elif [ -f "$dir/vendor/bin/sail" ]; then
      echo "$dir/vendor/bin/sail"
      return 0
    fi
    dir+=/..
  done
  return 1
}
function s() {
  local sail_path
  sail_path=$(_find_sail)

  if [[ $1 == "cinit" ]]; then
    docker run --rm \
      -u "$(id -u):$(id -g)" \
      -v $(pwd):/var/www/html \
      -w /var/www/html \
      laravelsail/php"${2:=83}"-composer:latest \
      composer install --ignore-platform-reqs
  elif [[ $1 == "ninit" ]]; then
    docker run --rm \
      -u "$(id -u):$(id -g)" \
      -v $(pwd):/var/www/html \
      -w /var/www/html \
      node:${2:=20} \
      npm install
  else
    if [ "$sail_path" = "" ]; then
      if [ $ZSH_SAIL_FALLBACK_TO_LOCAL = "true" ]; then
        $*
        else
        >&2 printf "laravel-sail: sail executable not found. Are you in a Laravel directory?\nif yes try install Dependencies using 's cinit' command\n"
        return 1
      fi
    fi
    $sail_path $*
  fi
}
function sa() {
  s artisan $*
}
function sc() {
  s composer $*
}
# alias s='bash ./vendor/bin/sail'
alias sup='s up'
alias sud='s up -d'
alias sdown='s down'
alias sa='s artisan'
alias saqw='sa queue:work'
alias saql='sa queue:listen'
alias sasw='sa schedule:work'
alias sasr='sa schedule:run'
alias sp='s php'
alias sn='s npm'
alias sdev='s npm run dev'
alias sbuild='s npm run build'
alias st='sp ./vendor/bin/pest'
alias stp='sp ./vendor/bin/pest --parallel'
alias std='sp ./vendor/bin/pest --dirty'
alias sta='sp ./vendor/bin/pest --testsuite Arch'
alias stf='sp ./vendor/bin/pest --testsuite Feature'
alias stu='sp  ./vendor/bin/pest --testsuite Unit'
alias stfl='sp ./vendor/bin/pest --filter'
alias stk='sa tinker'
alias stc='stp --coverage-clover .qodana/code-coverage/coverage.xml'
alias stan='sp ./vendor/bin/phpstan'
alias spint='sp ./vendor/bin/pint --dirty'
compdef _artisan sa
compdef _composer sc
function _artisan() {
  if [ -f "./vendor/bin/sail" ]; then
    compadd $(sa --raw --no-ansi list | sed "s/[[:space:]].*//g")
  fi
}
function _composer() {
  if [ -f "./vendor/bin/sail" ]; then
    compadd $(sc --raw --no-ansi list | sed "s/[[:space:]].*//g")
  fi
}
