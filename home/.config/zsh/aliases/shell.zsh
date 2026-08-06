# Shell odds and ends.

# Reload the shell after editing config.
alias reload='exec zsh'

# mkdir and cd into it.
take() { mkdir -p "$1" && cd "$1"; }

# als [pattern] — list every alias and verify its target actually exists.
# Many aliases here are guarded on `command -v`, so a missing tool means the
# alias silently isn't defined; others can point at a tool that was later
# uninstalled. This shows both. Reads zsh's own $aliases map rather than
# parsing this file, so it covers aliases defined anywhere.
als() {
  emulate -L zsh
  local pat=${1:-} name val cmd
  local -a words
  local -i ok=0 broken=0
  for name in ${(ok)aliases}; do
    val=${aliases[$name]}
    [[ -n $pat && $name != *$pat* && $val != *$pat* ]] && continue
    # Explicit array assignment: ${${(z)val}[1]} subscripts the *string*, so a
    # single-word target like "nvim" would yield "n".
    words=(${(z)val})
    cmd=$words[1]
    if (( $+commands[$cmd] || $+functions[$cmd] || $+builtins[$cmd] || $+aliases[$cmd] )) \
       || (( ${reswords[(I)$cmd]} )); then
      printf '%-10s %s\n' "$name" "$val"
      (( ok++ ))
    else
      printf '\e[31m%-10s %s  <- %s not found\e[0m\n' "$name" "$val" "$cmd"
      (( broken++ ))
    fi
  done
  printf '\e[2m%d ok' $ok
  (( broken )) && printf ', \e[31m%d broken\e[0m\e[2m' $broken
  printf '%s\e[0m\n' "${pat:+ (filter: $pat)}"

  # gh keeps its own alias system in ~/.config/gh/config.yml — those work
  # outside zsh, so they're easy to forget about. Show them too.
  if [[ -z $pat ]] && command -v gh >/dev/null 2>&1; then
    print -r -- $'\n\e[2mgh aliases (from .config/gh/config.yml):\e[0m'
    gh alias list 2>/dev/null | sed 's/^/  gh /'
  fi
}

# Directory jumping is zoxide's job now — see navigation.zsh (`z`, `zi`).
