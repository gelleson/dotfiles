# Interactive shell config. Symlinked from ~/.dotfiles/home/.zshrc.
# Login-only setup lives in .zprofile — keep it there, since everything here
# runs on every new terminal.

typeset -U path PATH   # keep PATH deduped (.zprofile sets some of these too)
export PATH="$HOME/.local/bin:$PATH"

# mise: tool versions + project env. Early, so later config sees its tools.
# $HOME rather than a hardcoded path, so this file works on any machine.
eval "$($HOME/.local/bin/mise activate zsh)"

# Modules, sourced in order. Each is independent — comment one out freely.
ZSH_MODULES=$HOME/.config/zsh
for _mod in options history completion keybindings aliases navigation prompt; do
  [[ -r $ZSH_MODULES/$_mod.zsh ]] && source $ZSH_MODULES/$_mod.zsh
done
unset _mod

# Machine-local overrides — untracked, never committed. Put tokens and
# work-specific config here rather than anywhere under ~/.dotfiles.
[[ -r $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/gelleson/.lmstudio/bin"
# End of LM Studio CLI section

