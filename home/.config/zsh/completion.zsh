# Completion. compinit is the single slowest thing in most zsh startups, so
# the dump file is only rebuilt once a day rather than on every shell.

fpath=($HOME/.config/zsh/completions $fpath)

autoload -Uz compinit
_zcompdump=$HOME/.cache/zsh/zcompdump
mkdir -p ${_zcompdump:h}
# -C skips the security audit of fpath; the glob picks a dump newer than 24h.
if [[ -n $_zcompdump(#qN.mh-24) ]]; then
  compinit -C -d $_zcompdump
else
  compinit -d $_zcompdump
fi
unset _zcompdump

zmodload -i zsh/complist

setopt ALWAYS_TO_END        # move cursor to end after completing
setopt COMPLETE_IN_WORD     # complete from the cursor, not end of word
setopt AUTO_MENU            # cycle through matches on a second tab
unsetopt MENU_COMPLETE      # ...but don't insert the first one immediately

zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose true
zstyle ':completion:*:descriptions' format '%F{yellow}%B%d%b%f'
zstyle ':completion:*:warnings' format '%F{red}no matches%f'

# Case-insensitive, then partial-word (f.b -> foo.bar), then substring.
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $HOME/.cache/zsh/compcache

# Colour completion listings like ls does.
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Don't offer the file you're already working on, or . / .. as cd targets.
zstyle ':completion:*:rm:*' ignore-line other
zstyle ':completion:*:cd:*' ignore-parents parent pwd

# Nicer process completion for kill.
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
