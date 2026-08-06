export PATH="$HOME/.local/bin:$PATH"

# mise shims — resolves tools for non-interactive shells, scripts, and IDEs.
# Interactive zsh additionally runs `mise activate` from ~/.zshrc, which takes
# precedence and gives full env/hook support.
export PATH="$HOME/.local/share/mise/shims:$PATH"

# OrbStack, the Docker daemon — see the README, it's the one thing bootstrap
# can't reinstall. Added by its installer; kept for the completions. It also
# puts ~/.orbstack/bin on PATH, which carries a second docker client, but
# `mise activate` in .zshrc prepends the shims afterwards, so the mise-declared
# docker-cli still wins. Guarded, so it's a no-op on a machine without OrbStack.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
