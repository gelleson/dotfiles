# Aliases and small functions.

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

# git
alias g=git
alias gs='git status --short --branch'
alias gd='git diff'
alias gds='git diff --staged'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -20'
alias gco='git checkout'
alias gb='git branch'
command -v lazygit >/dev/null 2>&1 && alias lg=lazygit

# gh — more aliases live in .config/gh/config.yml (gh's own alias system,
# which works everywhere, not just interactive zsh).
if command -v gh >/dev/null 2>&1; then
  alias ghpr='gh pr create --fill'
  alias ghprs='gh pr list'
  alias ghco='gh pr checkout'
  alias ghw='gh repo view --web'
  alias ghrun='gh run watch'
fi

# Claude Code, per model. The [1m] suffix selects the 1M-token context
# variant; haiku has no 1m variant, so it's plain.
if command -v claude >/dev/null 2>&1; then
  alias op='claude --model "opus[1m]"'
  alias opus='claude --model "opus[1m]"'
  alias sonnet='claude --model "sonnet[1m]"'
  alias haiku='claude --model haiku'
fi

# dotfiles — this repo
alias dot='cd ~/.dotfiles'
alias dotl='mise run --cd ~/.dotfiles link'
alias dots='mise run --cd ~/.dotfiles status'

# mise
alias mi='mise install'
alias mu='mise use'
alias mls='mise ls'
alias mx='mise exec --'

# Reload the shell after editing config.
alias reload='exec zsh'

# mkdir and cd into it.
take() { mkdir -p "$1" && cd "$1"; }

# Directory jumping is zoxide's job now — see navigation.zsh (`z`, `zi`).
