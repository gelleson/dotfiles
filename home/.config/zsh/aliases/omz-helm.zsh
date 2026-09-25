# Oh My Zsh's helm plugin (ohmyzsh/ohmyzsh@74965c9), ported plugin-free.
# Skipped: h (history has it).

command -v helm >/dev/null 2>&1 || return

alias hin='helm install'
alias hun='helm uninstall'
alias hse='helm search'
alias hup='helm upgrade'
