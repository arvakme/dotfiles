#!/bin/bash
# Launch or re-attach a per-directory pi session in a tmux popup.
set -euo pipefail
dir="${1:-}"
if [ -z "$dir" ]; then
  dir="$(tmux display-message -p '#{pane_current_path}')"
fi
hash="$(printf '%s' "$dir" | md5 -q | cut -c1-8)"
session="pi-${hash}"
if ! tmux has-session -t "$session" 2>/dev/null; then
  tmux new-session -d -s "$session" -c "$dir" "$HOME/.local/bin/pi"
  tmux set-option -t "$session" @pi_origin "$dir"
fi
tmux display-popup -w90% -h90% -E "tmux attach-session -t $session"
