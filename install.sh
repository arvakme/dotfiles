#!/usr/bin/env bash
# Put these dotfiles into ~/.config: symlink each folder (default) or copy it (--copy).
# Anything already in the way is MOVED to ~/.dotfiles-backup/<timestamp>/ first; nothing is deleted.
# Usage: ./install.sh [--copy] [--dry-run]
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
MODE=link
DRY=0
for arg in "$@"; do
  case "$arg" in
    --copy) MODE=copy ;;
    --dry-run | -n) DRY=1 ;;
    -h | --help) sed -n '2,4p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

[[ "$(uname)" == Darwin ]] || { echo "these dotfiles are for macOS" >&2; exit 1; }
[[ "$SRC" != "$(cd "$CONFIG" 2>/dev/null && pwd -P)" ]] || { echo "clone this repo somewhere else, not into $CONFIG itself" >&2; exit 1; }

run() { if ((DRY)); then echo "    would run: $*"; else "$@"; fi; }
moved=0

# place <source> <target> [link|copy]: back up whatever is at <target>, then link or copy <source> there.
place() {
  local src=$1 dst=$2 how=${3:-$MODE}
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "ok      $dst"
    return
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    local saved="$BACKUP/${dst#"$HOME"/}"
    run mkdir -p "$(dirname "$saved")"
    run mv "$dst" "$saved"
    echo "backup  $dst -> $saved"
    moved=1
  fi
  run mkdir -p "$(dirname "$dst")"
  if [[ "$how" == link ]]; then run ln -s "$src" "$dst"; else run cp -R "$src" "$dst"; fi
  echo "$how    $dst"
}

# Whole folders become ~/.config/<name>. git/ goes file by file, so an existing ~/.config/git/config stays where it is.
for dir in ghostty herdr karabiner lazygit mise nvim oh-my-posh theme tmux yazi zsh; do
  place "$SRC/$dir" "$CONFIG/$dir"
done
for file in delta-dark.gitconfig delta-light.gitconfig ignore shared.gitconfig; do
  place "$SRC/git/$file" "$CONFIG/git/$file"
done

# zsh reads ~/.zshenv before it knows ZDOTDIR, so this small bootstrap has to live in $HOME.
bootstrap='# Bootstrap: zsh keeps its config in ~/.config/zsh (written by dotfiles/install.sh).
export ZDOTDIR="$HOME/.config/zsh"
[[ -f "$ZDOTDIR/.zshenv" ]] && source "$ZDOTDIR/.zshenv"'
if [[ -f "$HOME/.zshenv" && "$(cat "$HOME/.zshenv")" == "$bootstrap" ]]; then
  echo "ok      $HOME/.zshenv"
else
  if [[ -e "$HOME/.zshenv" || -L "$HOME/.zshenv" ]]; then
    run mkdir -p "$BACKUP"
    run mv "$HOME/.zshenv" "$BACKUP/.zshenv"
    echo "backup  $HOME/.zshenv -> $BACKUP/.zshenv"
    moved=1
  fi
  if ((DRY)); then echo "    would write $HOME/.zshenv"; else printf '%s\n' "$bootstrap" >"$HOME/.zshenv"; fi
  echo "write   $HOME/.zshenv"
fi

# `theme` command on PATH (.zprofile puts ~/.local/bin first).
place "$CONFIG/theme/switch" "$HOME/.local/bin/theme" link

# First paint: same mode as macOS right now (creates tmux/themes/current.conf and git/delta.gitconfig).
mode=light
defaults read -g AppleInterfaceStyle 2>/dev/null | grep -qi dark && mode=dark
run "$CONFIG/theme/switch" "$mode" >/dev/null || echo "note: theme/switch $mode failed; run it again after installing tmux" >&2

echo
((moved)) && echo "Your previous files are in $BACKUP"
cat <<'NEXT'
Next:
  git config --global --add include.path ~/.config/git/shared.gitconfig
  mise install
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm   # then in tmux: Ctrl-T, then I
  open a new Ghostty window (or: exec zsh -l), then run nvim once to install plugins
NEXT
