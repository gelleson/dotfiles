# Editor, pager, listing, navigation, safety.

# Editor — neovim is installed via mise.
if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
  export VISUAL=nvim
  alias vi=nvim
  alias vim=nvim
fi
export PAGER=less
export LESS='-FRX'   # quit if one screen, keep colour, don't clear on exit

# Listing. macOS ls needs -G for colour; GNU coreutils isn't installed.
alias ls='ls -G'
alias ll='ls -lhG'
alias la='ls -lhAG'
alias lt='ls -lhtrG'   # newest last

# tree — GNU tree isn't packaged for mise (source-only upstream), so this is
# lsd's tree mode. Takes the same -L depth flag.
if command -v lsd >/dev/null 2>&1; then
  alias tree='lsd --tree'
  alias tree2='lsd --tree --depth 2'
  alias tree3='lsd --tree --depth 3'
fi

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# Safety. -i prompts before clobbering; NO_CLOBBER already guards `>`.
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

