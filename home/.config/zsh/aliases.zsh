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

# Sandboxed mise exec. mise runs the command with your mise tools on PATH but
# under macOS sandbox restrictions — useful for npx one-offs, postinstall
# hooks, build scripts, anything you'd rather not trust with your $HOME.
# Verified: --deny-write returns "Operation not permitted" outside /tmp, which
# stays writable by design; --deny-read blocks reading your dotfiles;
# --deny-net blocks outbound; --deny-env hides everything but
# PATH/HOME/USER/SHELL/TERM/LANG.
alias mxn='mise exec --deny-net --'      # offline
alias mxw='mise exec --deny-write --'    # read-only filesystem (/tmp still writable)
alias mxe='mise exec --deny-env --'      # don't leak env vars to the child
alias mxs='mise exec --deny-net --deny-write --deny-env --'  # the practical one
alias mxa='mise exec --deny-all --'      # also blocks reads; breaks most things

# Allowlist forms take a value and imply deny-for-everything-else:
#   mise exec --allow-net registry.npmjs.org -- npm install
#   mise exec --allow-write ./dist -- npm run build
#   mise exec --allow-env 'MYAPP_*' -- ./script.sh

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

# hs [<namespace>[/<group>]] — attach to that namespace's herdr session, creating
# it in the namespace directory the first time. A bare group name resolves on its
# own (`hs curran` -> sides/curran); no argument picks one with fzf. Session names
# can't hold '/', so sides/curran runs as `sides-curran`.
hs() {
  local root=~/codes/namespaces ns=$1 d
  local -a cands
  for d in $root/*(/N) $root/*/*(/N); do
    [[ -d $d/.git ]] || cands+=(${d#$root/})   # repos aren't namespaces
  done
  (( $#cands )) || { print -u2 "hs: no namespaces under $root"; return 1 }
  cands=(${(o)cands})

  if [[ -z $ns ]]; then
    ns=$(print -l $cands | fzf --prompt='session ▸ ' --height=40% --border) || return
  elif [[ ! -d $root/$ns ]]; then
    # Match on the last component, so a group name alone is enough when unique.
    local -a hits=(${(M)cands:#(*/)#$ns})
    case $#hits in
      1) ns=$hits[1] ;;
      0) print -u2 "hs: no namespace matching '$ns' under $root"; return 1 ;;
      *) ns=$(print -l $hits | fzf --prompt="session ▸ " --height=40% --border --select-1) || return ;;
    esac
  fi
  [[ -n $ns ]] || return
  (cd $root/$ns && herdr --session ${ns//\//-})
}
