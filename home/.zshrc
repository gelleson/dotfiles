# ASCII BOAT SHELL INTEGRATION START boat
case ":$PATH:" in
  *":/Users/gelleson/.ascii/bin:"*) ;;
  *) PATH="/Users/gelleson/.ascii/bin:$PATH" ;;
esac
export PATH
# ASCII BOAT SHELL INTEGRATION END boat

# Interactive shell config. Symlinked from ~/.dotfiles/home/.zshrc.
# Login-only setup lives in .zprofile — keep it there, since everything here
# runs on every new terminal.

typeset -U path PATH   # keep PATH deduped (.zprofile sets some of these too)
export PATH="$HOME/.local/bin:$PATH"

# mise: tool versions + project env. Early, so later config sees its tools.
# $HOME rather than a hardcoded path, so this file works on any machine.
eval "$($HOME/.local/bin/mise activate zsh)"

# Modules, sourced in order. Each is independent — comment one out freely.
ZSH_MODULES=$HOME/.config/zsh
for _mod in options history completion keybindings aliases navigation prompt; do
  [[ -r $ZSH_MODULES/$_mod.zsh ]] && source $ZSH_MODULES/$_mod.zsh
done
unset _mod

# Machine-local overrides — untracked, never committed. Put tokens and
# work-specific config here rather than anywhere under ~/.dotfiles.
[[ -r $HOME/.zshrc.local ]] && source $HOME/.zshrc.local

# Added by the Hunk installer (https://hunk.dev)
export PATH='/Users/gelleson/.hunk/bin':"$PATH"

# ASCII BOAT SHELL INTEGRATION START boat
boat() {
  current_file=$(mktemp)
  convo_file=$(mktemp)
  old_current_file=${BOAT_CURRENT_ID_FILE-}
  old_convo_file=${BOAT_CURRENT_CONVO_FILE-}
  export BOAT_CURRENT_ID_FILE="$current_file"
  export BOAT_CURRENT_CONVO_FILE="$convo_file"
  command "/Users/gelleson/.ascii/bin/boat" "$@"
  boat_status=$?
  if [ "$boat_status" -eq 0 ]; then
    case "${1:-}" in
      new|start|fork)
        if [ -s "$current_file" ]; then
          current_id=$(tr -d '[:space:]' < "$current_file")
          if [ -n "$current_id" ]; then export BOAT_CURRENT_ID="$current_id"; fi
        fi
        ;;
    esac
    case "${1:-}" in
      prompt)
        if [ -s "$convo_file" ]; then
          IFS= read -r current_convo < "$convo_file" || current_convo=""
          if [ -n "$current_convo" ]; then export BOAT_CURRENT_CONVO="$current_convo"; fi
        fi
        ;;
    esac
  fi
  if [ -n "$old_current_file" ]; then export BOAT_CURRENT_ID_FILE="$old_current_file"; else unset BOAT_CURRENT_ID_FILE; fi
  if [ -n "$old_convo_file" ]; then export BOAT_CURRENT_CONVO_FILE="$old_convo_file"; else unset BOAT_CURRENT_CONVO_FILE; fi
  rm -f "$current_file" "$convo_file"
  return "$boat_status"
}
# ASCII BOAT SHELL INTEGRATION END boat
