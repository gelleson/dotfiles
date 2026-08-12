export PATH="$HOME/.local/bin:$PATH"

# Homebrew — casks, plus the few formulae mise's registry lacks (see Brewfile).
# Deliberately BEFORE the mise shims below: both prepend to PATH, so whichever
# runs last wins, and mise must win for every tool it declares. Guarded, so
# this is a no-op on a machine without Homebrew.
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# mise shims — resolves tools for non-interactive shells, scripts, and IDEs.
# Interactive zsh additionally runs `mise activate` from ~/.zshrc, which takes
# precedence and gives full env/hook support.
export PATH="$HOME/.local/share/mise/shims:$PATH"

# OrbStack, the Docker daemon — now a cask in the Brewfile. Its installer added
# this line; kept for the completions. It also puts ~/.orbstack/bin on PATH,
# which carries a second docker client, but `mise activate` in .zshrc prepends
# the shims afterwards, so the mise-declared docker-cli still wins. Guarded, so
# it's a no-op on a machine without OrbStack.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
