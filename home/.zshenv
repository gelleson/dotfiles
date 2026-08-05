# Read by every zsh invocation (interactive, login, and scripts) before
# .zprofile and .zshrc — so this is set by the time `mise activate` runs.

# --- age key for sops -------------------------------------------------------
# The private key lives in the macOS login keychain (encrypted at rest,
# unlocked by your login password) rather than as a plaintext file on disk.
# mise and the sops CLI both accept the key material via SOPS_AGE_KEY.
#
# The -z guard matters: .zshenv runs for every zsh, including every script.
# Child shells inherit the value and skip the keychain call, so only the first
# shell in a process tree pays the lookup cost.
if [[ -z ${SOPS_AGE_KEY:-} && -z ${SOPS_AGE_KEY_FILE:-} ]]; then
  __age_key=$(security find-generic-password -s sops-age-key -w 2>/dev/null)
  if [[ -n $__age_key ]]; then
    export SOPS_AGE_KEY=$__age_key
  elif [[ -f $HOME/.config/sops/age/keys.txt ]]; then
    # Fallback for bootstrap, before the key has been imported to the keychain.
    export SOPS_AGE_KEY_FILE=$HOME/.config/sops/age/keys.txt
  fi
  unset __age_key
fi
