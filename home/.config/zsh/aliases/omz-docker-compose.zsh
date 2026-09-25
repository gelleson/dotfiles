# Oh My Zsh's docker-compose plugin (ohmyzsh/ohmyzsh@74965c9), ported plugin-free.

command -v docker >/dev/null 2>&1 || command -v docker-compose >/dev/null 2>&1 || return

# Support Compose v2 as docker CLI plugin
#
# This tests that the (old) docker-compose command is in $PATH and that
# it resolves to an existing executable file if it's a symlink.
[[ -x "${commands[docker-compose]:A}" ]] && dccmd='docker-compose' || dccmd='docker compose'

alias dco="$dccmd"
alias dcb="$dccmd build"
alias dcc="$dccmd config"
alias dce="$dccmd exec"
alias dcps="$dccmd ps"
alias dcrestart="$dccmd restart"
alias dcrm="$dccmd rm"
alias dcr="$dccmd run"
alias dcstop="$dccmd stop"
alias dcup="$dccmd up"
alias dcupb="$dccmd up --build"
alias dcupd="$dccmd up -d"
alias dcupdb="$dccmd up -d --build"
alias dcdn="$dccmd down"
alias dcl="$dccmd logs"
alias dclf="$dccmd logs -f"
alias dclF="$dccmd logs -f --tail 0"
alias dcpull="$dccmd pull"
alias dcstart="$dccmd start"
alias dck="$dccmd kill"
alias dcv="$dccmd version"
alias dcsts="$dccmd stats"
alias dci="$dccmd images"

unset dccmd
