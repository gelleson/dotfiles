# dotfiles

Repeatable machine setup: **mise** for tools + env, a plain git repo for config.
No dotfile manager — `mise run link` does the linking.

## Layout

```
home/            mirrors $HOME; every file here gets symlinked into place
mise.toml        tasks for managing this repo (link/unlink/status)
```

## Bootstrap a new machine

```sh
# 1. mise
curl https://mise.run | sh

# 2. this repo
git clone git@github.com:USER/dotfiles.git ~/.dotfiles

# 3. link everything into $HOME, then restart the shell
cd ~/.dotfiles
~/.local/bin/mise run link
exec zsh
```

## Daily use

| Command | What it does |
|---|---|
| `mise run link` | Symlink `home/` into `$HOME` (idempotent; backs up conflicts to `*.bak`) |
| `mise run status` | Show which files are linked, unlinked, or missing |
| `mise run unlink` | Replace symlinks with real copies |

Adding a dotfile: move it under `home/` at its `$HOME`-relative path, then
`mise run link`.

Note that `link` only ever adds symlinks — it never removes one whose source has
been deleted from `home/`. If you drop a file from the repo, delete its symlink
in `$HOME` by hand.

## Secrets

Not handled here. Nothing in this repo is encrypted, so **don't commit
credentials** — no API tokens in `home/.zshrc`, no keys under `home/.config/`.
Keep them in the login keychain, a password manager, or an untracked
`~/.zshrc.local` sourced at the end of `home/.zshrc`.

## Gotchas

- `~/.config/mise/config.toml` is a symlink into this repo. `mise use -g` edits
  it in place (comments and non-`[tools]` keys survive), so global tool changes
  land in the repo directly — `git status` here goes dirty whenever you install
  a tool. Commit them.
- macOS GUI apps launched from Finder read none of these shell files. If a GUI
  app needs mise tools, use `launchctl config user path`.
- mise renders task bodies as Tera templates before running them, so a brace
  followed by a hash opens a template comment and breaks the task. Shell
  brace-length syntax is therefore unusable in `mise.toml`; use `wc -c`.
