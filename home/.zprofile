export PATH="$HOME/.local/bin:$PATH"

# mise shims — resolves tools for non-interactive shells, scripts, and IDEs.
# Interactive zsh additionally runs `mise activate` from ~/.zshrc, which takes
# precedence and gives full env/hook support.
export PATH="$HOME/.local/share/mise/shims:$PATH"
