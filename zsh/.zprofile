# PATH lives here, not in .zshenv: /etc/zprofile's path_helper reorders PATH after .zshenv has run.
eval "$(/opt/homebrew/bin/brew shellenv)"
typeset -U path PATH
path=("$HOME/.local/bin" "$HOME/.bun/bin" "$HOME/Library/pnpm" "$HOME/.lmstudio/bin" $path)
eval "$(/opt/homebrew/bin/mise activate zsh --shims)"
