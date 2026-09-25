# Oh My Zsh's herdr plugin (ohmyzsh/ohmyzsh@74965c9), ported plugin-free.
# Sits alongside herdr.zsh (hs, hsd, hp); none of these names clash.

command -v herdr >/dev/null 2>&1 || return

alias hrdr='herdr'
alias hrdrst='herdr status'
alias hrdrup='herdr update'
alias hrdrsl='herdr session list'
alias hrdrsa='herdr session attach'
alias hrdrr='herdr --remote'
alias hrdral='herdr agent list'
alias hrdrwl='herdr workspace list'
alias hrdrwc='herdr workspace create'
alias hrdrwt='herdr worktree create'
alias hrdrps='herdr pane split'
alias hrdrrc='herdr server reload-config'

# FUNCTIONS
# Pick a session and attach to it, with fzf if available or a numbered menu otherwise.
function hrdrs {
  setopt localoptions extendedglob
  local -a lines
  lines=("${(@f)$(herdr session list 2>/dev/null)}")
  lines=("${(@)lines%%[[:space:]]#[^[:space:]]#}")  # drop the socket column
  if (( $#lines < 2 )); then
    print "hrdrs: no herdr sessions found" >&2
    return 1
  fi

  local choice
  if (( $+commands[fzf] )); then
    choice=$(print -l -- "${lines[@]}" | fzf --header-lines=1 --prompt='herdr session> ') || return
  else
    print -- "${lines[1]}"
    local PS3="Attach to session: "
    select choice in "${lines[@]:1}"; do
      [[ -n "$choice" ]] && break
    done
  fi
  [[ -n "$choice" ]] || return 1

  herdr session attach "${${(z)choice}[1]}"
}
