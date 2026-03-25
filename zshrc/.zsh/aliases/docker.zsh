## @cmd d
## @desc d <cmd> — docker shorthand
alias d='docker'

## @cmd ports
## @desc List all listening ports (sudo)
alias ports="sudo lsof -i -P -n | grep LISTEN"

## @cmd kp
## @desc kp <port> — kill process on port
alias kp='clean-port'


clean-port() {
  if [ -z "$1" ]; then
    echo "Usage: clean-port <port>"
    return 1
  fi
  local pids=""
  # Try ss first (more reliable on modern Linux)
  pids=$(ss -tlnp 2>/dev/null | grep ":$1 " | grep -oP 'pid=\K[0-9]+' | sort -u)
  # Fallback to lsof if ss didn't find anything
  if [ -z "$pids" ]; then
    pids=$(lsof -t -i:"$1" 2>/dev/null | sort -u)
  fi
  if [ -z "$pids" ]; then
    echo "No process found on port $1"
    return 1
  fi
  for pid in $pids; do
    local pname=$(ps -p $pid -o comm= 2>/dev/null)
    kill -9 $pid && echo "Killed $pname (PID $pid) on port $1"
  done
}

## @cmd dcou
## @desc Docker compose up -d
alias dcou="docker compose up -d"

## @cmd down
## @desc Docker compose down
alias down="docker compose down"
