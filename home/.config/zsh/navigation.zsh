# Directory navigation and fuzzy finding.
# Loaded after completion.zsh — both zoxide and fzf register completions, so
# compinit must already have run.

# --- zoxide -----------------------------------------------------------------
# `z foo` jumps to the best-matching directory you've visited before; `zi`
# opens an fzf picker over the matches. Plain `cd` is left intact on purpose —
# if you'd rather zoxide take over cd entirely, change this to:
#   eval "$(zoxide init zsh --cmd cd)"
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# --- fzf --------------------------------------------------------------------
# Adds ctrl-r (history), ctrl-t (files), alt-c (cd into subdir).
# These complement the prefix history search on the arrow keys — ctrl-r is
# fuzzy across all history, the arrows filter by what you've already typed.
if command -v fzf >/dev/null 2>&1; then
  # fzf's integration installs ZLE widgets, which need a real terminal. Without
  # the -t guard, any `zsh -ic 'cmd'` in a script prints "can't change option:
  # zle" twice to stderr.
  [[ -t 0 ]] && source <(fzf --zsh)

  export FZF_DEFAULT_OPTS='
    --height=40% --layout=reverse --border=rounded
    --info=inline --cycle
    --bind=ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down'

  # Use fd for file/dir listings when present — respects .gitignore and skips
  # .git, which the default `find` walk does not.
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
  fi
fi
