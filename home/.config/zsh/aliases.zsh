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

# Fuzzy-free directory jump: cd to the first match under $HOME.
# (If you later install zoxide via mise, drop this in favour of `z`.)
cdf() {
  local d
  d=$(find "$HOME" -maxdepth 4 -type d -name "*$1*" -not -path '*/.*' 2>/dev/null | head -1)
  [[ -n $d ]] && cd "$d" || echo "no match for $1"
}
