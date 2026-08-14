# Homebrew packages, installed by `brew bundle --file ~/.dotfiles/Brewfile`.
# bootstrap.sh runs this for you.
#
# Keep this file SMALL. mise is still the source for every CLI tool and
# language runtime — see home/.config/mise/config.toml. Only two things belong
# here:
#
#   1. casks, which mise has no concept of
#   2. formulae mise's registry genuinely lacks
#
# Anything that resolves under `mise registry` goes in the mise config instead,
# so it stays version-pinned per project.

# --- formulae ---------------------------------------------------------------
# Shell-script UI widgets, used by prompts and scratch scripts. Absent from
# mise's registry; came from zerobrew until that was dropped for Homebrew.
brew "gum"

# Local proxy that exposes Gemini CLI / Codex / Claude Code / Qwen as an API
# on :8317. Not in mise's registry. Config: ~/.cli-proxy-api/config.yaml
# (untracked — holds provider credentials). `brew services start cliproxyapi`.
brew "cliproxyapi"

# --- casks ------------------------------------------------------------------
# These are the reason Homebrew is here at all. Both were previously manual
# .dmg installs that a rebuild silently skipped, documented in the README as
# "not reproducible" — declaring them here is what closes that gap.

# Docker daemon. First launch installs a privileged helper, so a fresh machine
# still needs one `open -a OrbStack` after bundling. Paid for commercial use.
cask "orbstack"

# Local LLM GUI. Pairs with `ollama` from mise — same GGUF models.
cask "lm-studio"
