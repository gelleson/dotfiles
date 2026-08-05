# Keybindings. Emacs-style — swap to `bindkey -v` if you want vi mode.
bindkey -e

# Up/down search history for what you've already typed, rather than stepping
# blindly through every command. This is the single biggest quality-of-life
# win here, and it needs no plugin.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search      # up
bindkey '^[[B' down-line-or-beginning-search    # down
bindkey '^P'   up-line-or-beginning-search
bindkey '^N'   down-line-or-beginning-search

# Word-wise movement with alt+arrows, and ctrl+arrows in most terminals.
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# Home/End/Delete across terminal types.
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# Treat / and . as word boundaries, so ctrl+w deletes one path segment
# instead of the whole path.
autoload -Uz select-word-style && select-word-style bash

# Edit the current command line in $EDITOR — invaluable for long pipelines.
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# In the completion menu, use vi keys to move around.
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
