# Oh My Zsh's deno plugin (ohmyzsh/ohmyzsh@74965c9), ported plugin-free.
# Skipped: dc (the dc calculator) and dck (docker-compose kill has it).

command -v deno >/dev/null 2>&1 || return

alias dca='deno cache'
alias dfmt='deno fmt'
alias dh='deno help'
alias dli='deno lint'
alias drn='deno run'
alias drA='deno run -A'
alias drw='deno run --watch'
alias dsv='deno serve'
alias dts='deno test'
alias dup='deno upgrade'
