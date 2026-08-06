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

