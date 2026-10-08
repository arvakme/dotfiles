#!/bin/bash
# fzf picker for detached pi-* tmux sessions.
set -euo pipefail
if ! command -v fzf >/dev/null 2>&1; then
  tmux display-message "fzf not found"
  exit 0
fi
list="$(tmux list-sessions -F '#{session_name} #{session_path}' 2>/dev/null | awk '/^pi-/ {print}' || true)"
if [ -z "$list" ]; then
  tmux display-message "no pi sessions"
  exit 0
fi
choice="$(printf '%s\n' "$list" | fzf --prompt='pi> ' --with-nth=1,2 --delimiter=' ' --preview='tmux capture-pane -pt {1} -e -S -40 2>/dev/null' || true)"
[ -z "$choice" ] && exit 0
session="${choice%% *}"
tmux display-popup -w90% -h90% -E "tmux attach-session -t $session"
