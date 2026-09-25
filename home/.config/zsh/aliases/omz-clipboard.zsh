# Oh My Zsh's copybuffer, copypath and copyfile plugins (ohmyzsh/ohmyzsh@74965c9),
# ported plugin-free, plus the macOS half of its lib/clipboard.zsh.

function clipcopy() { cat "${1:-/dev/stdin}" | pbcopy; }
function clippaste() { pbpaste; }

# ctrl-o copies the command line you're typing.
copybuffer () {
  printf "%s" "$BUFFER" | clipcopy
}

zle -N copybuffer

bindkey -M emacs "^O" copybuffer
bindkey -M viins "^O" copybuffer
bindkey -M vicmd "^O" copybuffer

# Copies the path of given directory or file to the system or X Windows clipboard.
# Copy current directory if no parameter.
function copypath {
  # If no argument passed, use current directory
  local file="${1:-.}"

  # If argument is not an absolute path, prepend $PWD
  [[ $file = /* ]] || file="$PWD/$file"

  # Copy the absolute path without resolving symlinks
  # If clipcopy fails, exit the function with an error
  print -n "${file:a}" | clipcopy || return 1

  echo ${(%):-"%B${file:a}%b copied to clipboard."}
}

# Copies the contents of a given file to the system or X Windows clipboard
#
# Usage: copyfile <file>
function copyfile {
  emulate -L zsh

  if [[ -z "$1" ]]; then
    echo "Usage: copyfile <file>"
    return 1
  fi

  if [[ ! -f "$1" ]]; then
    echo "Error: '$1' is not a valid file."
    return 1
  fi

  clipcopy $1
  echo ${(%):-"%B$1%b copied to clipboard."}
}
