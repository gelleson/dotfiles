# Oh My Zsh's lib/directories.zsh (ohmyzsh/ohmyzsh@74965c9), ported plugin-free.
# Skipped because core.zsh already has them: - ... .... la ll.
# options.zsh already sets auto_cd/auto_pushd. 1-9 use `cd +N` instead of OMZ's
# pushdminus + `cd -N` — same jump, no option change.

alias -g .....='../../../..'
alias -g ......='../../../../..'

# Jump back to the Nth directory in the list that `d` prints.
alias 1='cd +1'
alias 2='cd +2'
alias 3='cd +3'
alias 4='cd +4'
alias 5='cd +5'
alias 6='cd +6'
alias 7='cd +7'
alias 8='cd +8'
alias 9='cd +9'

alias md='mkdir -p'
alias rd=rmdir

function d () {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}
compdef _dirs d

# List directory contents
alias lsa='ls -lah'
alias l='ls -lah'
