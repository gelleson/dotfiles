export PATH="$HOME/.local/bin:$PATH"

# mise shims — resolves tools for non-interactive shells, scripts, and IDEs.
# Interactive zsh additionally runs `mise activate` from ~/.zshrc, which takes
# precedence and gives full env/hook support.
export PATH="$HOME/.local/share/mise/shims:$PATH"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
