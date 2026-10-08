# Easy Complete pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/easy-complete/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/easy-complete/shell/zshrc.pre.zsh"

# Interactive zsh only. Environment variables live in .zshenv and PATH in .zprofile, each in one place.

# ---- Runtimes: full mise activation (the login shell only puts its shims on PATH) ----
eval "$(/opt/homebrew/bin/mise activate zsh)"

# ---- History (shared, deduped) ----
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS INC_APPEND_HISTORY EXTENDED_HISTORY

# ---- OrbStack (command-line tools and integration) ----
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# ---- Completions ----
autoload -Uz compinit && compinit

# ---- Prompt: colours follow ~/.config/theme/mode ----
posh-reload() {
  local cfg=~/.config/oh-my-posh/butler_light.omp.json
  [[ "$(~/.config/theme/mode)" == dark ]] && cfg=~/.config/oh-my-posh/butler_dark.omp.json
  eval "$(oh-my-posh init zsh --config "$cfg")"
}
posh-reload

# The theme/watch LaunchAgent keeps ~/.config/theme/current in step with macOS light/dark; re-colour this prompt when it changes.
__theme_seen="$(<~/.config/theme/current 2>/dev/null)"
__theme_follow() {
  local now
  now="$(<${THEME_CURRENT_FILE:-$HOME/.config/theme/current} 2>/dev/null)"
  [[ -n "$now" && "$now" != "$__theme_seen" ]] || return 0
  __theme_seen="$now"
  posh-reload
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd __theme_follow

theme() { ~/.config/theme/switch "$@"; posh-reload; }

# ---- Aliases ----
alias c="claude --permission-mode bypassPermissions"
alias vi=nvim
alias vim=nvim
alias ..="cd .."
alias kssh=ssh

# ---- Images in the terminal: Ghostty (and herdr, inside it) speak the Kitty graphics protocol; chafa is the viewer ----
icat() { chafa -f kitty "$@"; }

# Thumbnails of the images in the current directory (or of the files you pass)
lsimg() {
  local f; local -a files=("$@")
  (( $#files )) || files=(*.(png|jpg|jpeg|gif|webp)(N))
  for f in $files; do print -- $f; chafa -f kitty -s 40x12 $f; done
}

# Show the image currently on the macOS clipboard (Cmd+V only pastes text)
clipimg() {
  local f
  f="$(mktemp -t clipimg).png" || return
  pngpaste "$f" || { rm -f "$f"; print -u2 "clipimg: 剪贴板里没有图片"; return 1 }
  chafa -f kitty "$f"
  rm -f "$f"
}

# ---- Keep Homebrew's framework Python out of the macOS Dock: upgrades reset LSUIElement, so re-apply when it is missing ----
for plist in /opt/homebrew/Cellar/python@3.1*/*/Frameworks/Python.framework/Versions/*/Resources/Python.app/Contents/Info.plist(N); do
  grep -q LSUIElement "$plist" 2>/dev/null && continue
  /usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$plist" 2>/dev/null
done
unset plist

# ---- Plugins — order matters: autosuggestions, then syntax-highlighting, then history-substring-search ----
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh 2>/dev/null

# Prefix + Up/Down searches matching history
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P'   history-substring-search-up
bindkey '^N'   history-substring-search-down
# Cmd+Delete sends ^U: delete to start of line. Cmd/Option+arrows move by line/word.
bindkey '^U'      backward-kill-line
bindkey '^[[1;9D' beginning-of-line
bindkey '^[[1;9C' end-of-line
bindkey '^[[1;3D' backward-word
bindkey '^[[1;3C' forward-word

# Easy Complete post block. Keep near the bottom of this file.
[[ -f "${HOME}/Library/Application Support/easy-complete/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/easy-complete/shell/zshrc.post.zsh"
