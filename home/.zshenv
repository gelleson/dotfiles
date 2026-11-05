# sshd hands non-interactive sessions PATH=/usr/bin:/bin:/usr/sbin:/sbin and no
# login shell runs, so ~/.zprofile never fires. mosh-server lives in Homebrew.
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PATH=/usr/local/RemoteDevelopmentToolkit/bin:$PATH

# ASCII BOAT SHELL INTEGRATION START boat
case ":$PATH:" in
  *":/Users/gelleson/.ascii/bin:"*) ;;
  *) PATH="/Users/gelleson/.ascii/bin:$PATH" ;;
esac
export PATH
# ASCII BOAT SHELL INTEGRATION END boat
