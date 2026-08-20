# sshd hands non-interactive sessions PATH=/usr/bin:/bin:/usr/sbin:/sbin and no
# login shell runs, so ~/.zprofile never fires. mosh-server lives in Homebrew.
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
