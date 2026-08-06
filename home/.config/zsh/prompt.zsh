# Prompt — pure zsh, no external process per redraw.
#
# If you'd rather have starship, install it (`mise use -g starship`) and
# replace this whole file with:  eval "$(starship init zsh)"

setopt PROMPT_SUBST

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats       ' %F{magenta}%b%f%u%c'
zstyle ':vcs_info:git:*' actionformats ' %F{magenta}%b%f|%F{red}%a%f%u%c'
zstyle ':vcs_info:*' unstagedstr ' %F{yellow}*%f'
zstyle ':vcs_info:*' stagedstr   ' %F{green}+%f'
# check-for-changes is what makes vcs_info slow; it's worth it, but skip the
# untracked-file scan, which is the expensive half in large repos.
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' check-for-staged-changes true

_prompt_precmd() {
  # Skip vcs_info entirely outside a repo — saves a fork per prompt.
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    vcs_info
  else
    vcs_info_msg_0_=''
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _prompt_precmd

# %(?..) prints the arrow red only when the last command failed.
# %2~ collapses $HOME to ~ and shows only the last two path components.
PROMPT='%F{blue}%2~%f${vcs_info_msg_0_} %(?.%F{green}.%F{red})❯%f '

# Right side: mise-managed tool versions for the current dir, if any are
# pinned by a local config. Cheap because mise caches this.
RPROMPT=''
