#!/bin/bash
# Launch or re-attach a per-directory grok session in a tmux popup.
set -euo pipefail
dir="${1:-}"
if [ -z "$dir" ]; then
  dir="$(tmux display-message -p '#{pane_current_path}')"
fi
hash="$(printf '%s' "$dir" | md5 -q | cut -c1-8)"
session="grok-${hash}"
grok="${HOME}/.local/bin/grok"
if ! tmux has-session -t "$session" 2>/dev/null; then
  tmux new-session -d -s "$session" -c "$dir" "$grok"
  tmux set-option -t "$session" @grok_origin "$dir"
fi
tmux display-popup -w90% -h90% -E "tmux attach-session -t $session"
