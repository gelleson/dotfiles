typeset -U path PATH   # keep PATH deduped (.zprofile sets some of these too)
export PATH="$HOME/.local/bin:$PATH"
eval "$(/Users/gelleson/.local/bin/mise activate zsh)"
