# Read by every zsh invocation (interactive, login, and scripts) before
# .zprofile and .zshrc — so this is set by the time `mise activate` runs.

# mise's built-in sops decryptor does not fall back to sops' default key
# location, so point at it explicitly. This is a path, not a secret.
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
