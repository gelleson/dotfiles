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
