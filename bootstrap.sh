#!/usr/bin/env sh
# Bootstrap a machine from scratch: mise + these dotfiles + every declared tool.
#
#   curl -fsSL https://raw.githubusercontent.com/gelleson/dotfiles/main/bootstrap.sh | sh
#
# Safe to re-run: it pulls instead of cloning, and relinks in place.
# Override anything with env vars, e.g.
#   DOTFILES_REPO=... NVIM=0 TOOLS=0 sh bootstrap.sh

set -eu

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
DOTFILES_REPO="${DOTFILES_REPO:-gelleson/dotfiles}"
NVIM_REPO="${NVIM_REPO:-gelleson/nvim}"
NVIM_DIR="${NVIM_DIR:-$HOME/.config/nvim}"
MISE="$HOME/.local/bin/mise"
NVIM="${NVIM:-1}"   # 0 to skip the neovim config
TOOLS="${TOOLS:-1}" # 0 to skip `mise install` (just link the dotfiles)
AUTH="${AUTH:-1}"   # 0 to skip the gh auth prompt
BREW="${BREW:-1}"   # 0 to skip Homebrew and the Brewfile (casks won't install)

say()  { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m warn\033[0m %s\n' "$1"; }
die()  { printf '\033[1;31m!!\033[0m %s\n' "$1" >&2; exit 1; }

# --- prerequisites ----------------------------------------------------------
# On a fresh Mac, `git` exists only as a stub that triggers the Command Line
# Tools installer. Detect that before we depend on it.
if ! command -v git >/dev/null 2>&1; then
  die "git not found. On macOS run: xcode-select --install"
fi
if [ "$(uname -s)" = "Darwin" ] && ! xcode-select -p >/dev/null 2>&1; then
  die "Command Line Tools missing. Run: xcode-select --install"
fi
command -v curl >/dev/null 2>&1 || die "curl not found"

# --- mise -------------------------------------------------------------------
if [ -x "$MISE" ]; then
  say "mise already installed ($("$MISE" --version | head -1))"
else
  say "installing mise"
  curl -fsSL https://mise.run | sh
  [ -x "$MISE" ] || die "mise install failed — expected it at $MISE"
fi

# --- dotfiles ---------------------------------------------------------------
# Try HTTPS first (works anonymously for a public repo, and for a private one
# if a credential helper or gh is set up). Fall back to SSH.
clone_repo() {
  _repo="$1"; _dest="$2"
  if git clone -q "https://github.com/${_repo}.git" "$_dest" 2>/dev/null; then
    return 0
  fi
  warn "HTTPS clone of ${_repo} failed (private repo?), trying SSH"
  git clone -q "git@github.com:${_repo}.git" "$_dest"
}

if [ -d "$DOTFILES_DIR/.git" ]; then
  say "dotfiles present, pulling"
  git -C "$DOTFILES_DIR" pull --ff-only -q || warn "pull failed, continuing with local copy"
else
  say "cloning dotfiles into $DOTFILES_DIR"
  clone_repo "$DOTFILES_REPO" "$DOTFILES_DIR"
fi

# --- link -------------------------------------------------------------------
say "linking dotfiles into \$HOME"
"$MISE" trust -q "$DOTFILES_DIR" 2>/dev/null || true
"$MISE" run --cd "$DOTFILES_DIR" link

# --- fonts ------------------------------------------------------------------
if [ "$(uname -s)" = "Darwin" ]; then
  say "installing nerd fonts"
  "$MISE" run --cd "$DOTFILES_DIR" fonts || warn "font install failed"
fi

# --- tools ------------------------------------------------------------------
# One failing tool must not abort the run — some backends build from source and
# are fragile. Report what broke and carry on.
if [ "$TOOLS" = "1" ]; then
  say "installing declared tools (this is slow the first time)"
  if ! "$MISE" install -y; then
    warn "some tools failed to install — check with: mise ls"
  fi
else
  say "skipping tool install (TOOLS=0)"
fi

# --- homebrew ---------------------------------------------------------------
# Only for casks and the handful of formulae mise's registry lacks — see the
# Brewfile. mise stays the source for everything else.
#
# The installer needs sudo, and under `curl | sh` stdin is the script itself,
# so there is no terminal to prompt on. Same problem as gh auth below: detect
# it and print instructions rather than hang.
BREW_BIN=/opt/homebrew/bin/brew
if [ "$BREW" = "1" ]; then
  if [ ! -x "$BREW_BIN" ]; then
    if [ -t 0 ]; then
      say "installing Homebrew (needs sudo)"
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
        || warn "Homebrew install failed"
    else
      warn "no terminal for Homebrew's sudo prompt — install it by hand, then rerun:"
      warn '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    fi
  fi
  # Don't let the installer append its own shellenv line to ~/.zprofile — that
  # file is a symlink into this repo and already evals it, guarded.
  if [ -x "$BREW_BIN" ]; then
    say "installing Brewfile packages"
    eval "$("$BREW_BIN" shellenv)"
    "$BREW_BIN" bundle --file "$DOTFILES_DIR/Brewfile" || warn "brew bundle had failures"
    say "OrbStack needs one launch to install its privileged helper: open -a OrbStack"
    # cliproxyapi's default config path is fixed at build time and the brew
    # service passes no flags, so point it at the config in the auth-dir.
    # That config holds live provider keys, so the repo only carries the
    # sops-encrypted copy — decrypt it into place. Needs the age key at
    # ~/Library/Application Support/sops/age/keys.txt, which by definition
    # isn't in this repo; without it the daemon has no config and won't start.
    if [ -x /opt/homebrew/opt/cliproxyapi/bin/cliproxyapi ]; then
      mkdir -p "$HOME/.cli-proxy-api"
      if [ -f "$HOME/.cli-proxy-api/config.yaml" ]; then
        say "cliproxyapi config already present, leaving it alone"
      elif sops -d "$DOTFILES_DIR/secrets/cliproxyapi.yaml" \
             > "$HOME/.cli-proxy-api/config.yaml" 2>/dev/null; then
        chmod 600 "$HOME/.cli-proxy-api/config.yaml"
        say "decrypted cliproxyapi config"
      else
        rm -f "$HOME/.cli-proxy-api/config.yaml"
        warn "could not decrypt secrets/cliproxyapi.yaml — restore the age key, then:"
        warn "  sops -d $DOTFILES_DIR/secrets/cliproxyapi.yaml > ~/.cli-proxy-api/config.yaml"
      fi
      ln -sfn "$HOME/.cli-proxy-api/config.yaml" /opt/homebrew/etc/cliproxyapi.conf
      "$BREW_BIN" services start cliproxyapi >/dev/null || warn "cliproxyapi service failed to start"
    fi
  fi
else
  say "skipping Homebrew (BREW=0)"
fi

# --- github cli -------------------------------------------------------------
# gh is declared in the mise config, so it exists by now unless TOOLS=0.
# Auth is interactive and can't be automated: with `curl | sh`, stdin is the
# script itself, so there's no terminal to prompt on. Detect that and print
# instructions instead of hanging.
if [ "$AUTH" = "1" ] && [ -x "$("$MISE" which gh 2>/dev/null || true)" ]; then
  if "$MISE" exec -- gh auth status >/dev/null 2>&1; then
    say "gh already authenticated"
  elif [ -t 0 ]; then
    say "gh is not authenticated — launching login (choose SSH)"
    "$MISE" exec -- gh auth login || warn "gh auth login failed or was cancelled"
  else
    warn "gh is not authenticated. Run this once the shell is back:"
    printf '        gh auth login    # choose SSH\n'
  fi
fi

# --- neovim config ----------------------------------------------------------
if [ "$NVIM" = "1" ]; then
  if [ -d "$NVIM_DIR/.git" ]; then
    say "neovim config present, pulling"
    git -C "$NVIM_DIR" pull --ff-only -q || warn "pull failed, continuing"
  elif [ -e "$NVIM_DIR" ]; then
    warn "$NVIM_DIR exists but isn't a git checkout — leaving it alone"
  else
    say "cloning neovim config into $NVIM_DIR"
    mkdir -p "$(dirname "$NVIM_DIR")"
    clone_repo "$NVIM_REPO" "$NVIM_DIR"
  fi
fi

# --- done -------------------------------------------------------------------
say "done"
cat <<'EOF'

  Next:
    exec zsh          reload the shell with the new config
    nvim              first launch installs plugins (takes a minute)

  Notes:
    ~/.zshrc.local    untracked; put tokens and machine-specific config here
    mise ls           what's installed vs declared
EOF
