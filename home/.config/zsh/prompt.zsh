# Prompt — pure zsh, no external process per redraw.
#
# If you'd rather have starship, install it (`mise use -g starship`) and
# replace this whole file with:  eval "$(starship init zsh)"

setopt PROMPT_SUBST

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
# The branch is part of _prompt_path below, so these carry only dirty/staged
# markers and any in-progress action (rebase, merge).
zstyle ':vcs_info:git:*' formats       '%u%c'
zstyle ':vcs_info:git:*' actionformats ' %F{red}%a%f%u%c'
zstyle ':vcs_info:*' unstagedstr ' %F{yellow}*%f'
zstyle ':vcs_info:*' stagedstr   ' %F{green}+%f'
# check-for-changes is what makes vcs_info slow; it's worth it, but skip the
# untracked-file scan, which is the expensive half in large repos.
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' check-for-staged-changes true

# Readable 256-color shades for namespace names; which one a namespace gets is
# a hash of its name, so it's stable across machines and never needs configuring.
_prompt_ns_palette=(39 45 75 114 141 147 168 175 180 208 214 216)

_prompt_precmd() {
  # %2~ collapses $HOME to ~ and keeps only the last two path components.
  # PROMPT_SUBST expands these variables before prompt escapes, so escapes in
  # them are live — which is why literal % from a path gets doubled below.
  _prompt_path='%2~'
  _prompt_ns=''

  # Skip vcs_info entirely outside a repo — saves a fork per prompt.
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    vcs_info_msg_0_=''
    return
  fi
  vcs_info

  # Inside a repo the tail of the path can say very little — worst in a linked
  # worktree, which lives somewhere unrelated (~/.herdr/worktrees/..., say).
  # Show repo/branch/subdir. One fork; output order follows the flags.
  local common_dir prefix branch
  { read -r common_dir; read -r prefix; read -r branch } < <(
    git rev-parse --git-common-dir --show-prefix --abbrev-ref HEAD 2>/dev/null)
  [[ -n $common_dir ]] || return
  [[ $branch == HEAD ]] && branch=$(git rev-parse --short HEAD 2>/dev/null)
  local root=${common_dir:A:h} p="${${common_dir:A:h}:t}/${branch}${prefix:+/${prefix%/}}"
  _prompt_path=${p//\%/%%}

  # Repos live at ~/codes/namespaces/<namespace>/<repo>; call the namespace out
  # in its own color so which one you're in reads at a glance.
  if [[ $root == $HOME/codes/namespaces/*/* ]]; then
    local ns=${${root#$HOME/codes/namespaces/}%%/*} ch h=0 i
    for (( i = 1; i <= $#ns; i++ )); do
      ch=$ns[i]
      (( h = h * 31 + #ch ))
    done
    _prompt_ns="%F{$_prompt_ns_palette[h % $#_prompt_ns_palette + 1]}${ns//\%/%%}%f "
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_precmd

# %(?..) prints the arrow red only when the last command failed.
# _prompt_path is already expanded by the precmd hook above.
PROMPT='${_prompt_ns}%F{blue}${_prompt_path}%f${vcs_info_msg_0_} %(?.%F{green}.%F{red})❯%f '

# Right side: mise-managed tool versions for the current dir, if any are
# pinned by a local config. Cheap because mise caches this.
RPROMPT=''
