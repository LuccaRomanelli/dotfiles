#!/usr/bin/env bash
if [ -f "$HOME/.pomodoro/waybar.json" ]; then
  cat "$HOME/.pomodoro/waybar.json"
else
  echo '{"text":"","tooltip":"","class":""}'
fi
