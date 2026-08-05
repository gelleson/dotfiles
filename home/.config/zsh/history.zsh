# History. The defaults are far too small to be useful.

HISTFILE=$HOME/.zsh_history
HISTSIZE=200000        # in-memory
SAVEHIST=200000        # on-disk

setopt EXTENDED_HISTORY       # record timestamp + duration per entry
setopt INC_APPEND_HISTORY     # write as you go, not just at shell exit
setopt SHARE_HISTORY          # new commands visible in already-open shells
setopt HIST_IGNORE_DUPS       # skip a command identical to the one before
setopt HIST_IGNORE_ALL_DUPS   # and drop older copies of a repeated command
setopt HIST_IGNORE_SPACE      # leading space = don't record (use for secrets)
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY            # expand !! and let you confirm before running
setopt HIST_NO_STORE          # don't record `history` itself

# Never record these — noise, or credential-bearing.
HISTORY_IGNORE='(ls|ll|cd|pwd|exit|clear|history|* --password *|* --token *)'
