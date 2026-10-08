# Read by every zsh, interactive or not (agent tool shells, launchd, editors), so it must stay fast and quiet.
# Everything here must stay free of output and of anything that needs a tty.
[[ -r "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

export PI_CACHE_RETENTION=long
export EDITOR=nvim
export VISUAL=nvim

export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/Library/pnpm"

export GROK_TELEMETRY_TRACE_UPLOAD=0
export GROK_TELEMETRY_ENABLED=0
