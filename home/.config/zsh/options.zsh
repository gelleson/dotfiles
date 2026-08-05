# Shell behaviour.

# Navigation
setopt AUTO_CD              # `foo` cds into ./foo
setopt AUTO_PUSHD           # every cd pushes onto the dir stack
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT         # don't print the stack after every cd
setopt CDABLE_VARS          # `cd myvar` works if myvar holds a path

# Globbing
setopt EXTENDED_GLOB        # ^, ~, # in patterns — worth learning
setopt GLOB_DOTS            # * matches dotfiles too
setopt NUMERIC_GLOB_SORT    # file10 sorts after file9
unsetopt CASE_GLOB          # case-insensitive globbing

# Safety / correctness
setopt NO_CLOBBER           # `>` won't overwrite; use `>|` to force
setopt INTERACTIVE_COMMENTS # allow # comments when typing commands
unsetopt FLOW_CONTROL       # free up ctrl-s / ctrl-q
setopt NO_BEEP

# Jobs
setopt LONG_LIST_JOBS
setopt AUTO_RESUME          # `foo` resumes a suspended job named foo
setopt NOTIFY               # report job status immediately, not at next prompt
