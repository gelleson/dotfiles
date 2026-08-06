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

_prompt_precmd() {
  # %2~ collapses $HOME to ~ and keeps only the last two path components.
  _prompt_path=${(%):-%2~}

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
  _prompt_path="${${common_dir:A:h}:t}/${branch}${prefix:+/${prefix%/}}"
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_precmd

# %(?..) prints the arrow red only when the last command failed.
# _prompt_path is already expanded by the precmd hook above.
PROMPT='%F{blue}${_prompt_path}%f${vcs_info_msg_0_} %(?.%F{green}.%F{red})❯%f '

# Right side: mise-managed tool versions for the current dir, if any are
# pinned by a local config. Cheap because mise caches this.
RPROMPT=''
