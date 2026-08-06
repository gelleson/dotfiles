# dotfiles

Repeatable machine setup: **mise** for tools + env, a plain git repo for config.
No dotfile manager — `mise run link` does the linking.

## Layout

```
home/            mirrors $HOME; every file here gets symlinked into place
  .zshrc         sources the modules below
  .zprofile      login-only PATH setup
  .config/zsh/   options, history, completion, keybindings, aliases, prompt
  .config/mise/  global tool versions
  .local/bin/    small wrapper scripts
  .claude/       CLAUDE.md — global agent instructions
  .codex/        AGENTS.md — symlink to the same file
mise.toml        tasks for managing this repo (link/unlink/status)
```

## zsh

No framework — no oh-my-zsh, no zinit. Everything is plain zsh, which keeps
startup at roughly **40 ms warm** (165 ms on the first shell after a config
change, when `compinit` rebuilds its dump).

`.zshrc` sources six modules from `.config/zsh/`, each independent and safe to
comment out:

| Module | Contains |
|---|---|
| `options.zsh` | `AUTO_CD`, pushd stack, extended globbing, `NO_CLOBBER` |
| `history.zsh` | 200k entries, shared across shells, dedup, ignore-on-leading-space |
| `completion.zsh` | `compinit` with a 24h-cached dump, case-insensitive matching, menu select |
| `keybindings.zsh` | emacs mode, prefix history search on ↑/↓, `^X^E` to edit in `$EDITOR` |
| `aliases.zsh` | git/ls/mise/gh/claude shortcuts, `take`, `als` |
| `navigation.zsh` | zoxide (`z`, `zi`) and fzf keybindings |
| `prompt.zsh` | `vcs_info` git prompt, no subprocess per redraw |

Two things worth knowing:

- **Prefix history search** is bound to ↑/↓. Type `git c` then press ↑ and you
  cycle only through commands starting with `git c`. This replaces the
  `zsh-history-substring-search` plugin with a built-in.
- **A leading space keeps a command out of history** (`HIST_IGNORE_SPACE`). Use
  it when a command carries a token.
- **`z <partial>` jumps** to the best-matching directory you've been in before,
  `zi` opens an fzf picker over the matches. Plain `cd` is deliberately left
  alone; to have zoxide replace it outright, use `zoxide init zsh --cmd cd` in
  `navigation.zsh`.
- **`als`** lists every alias and checks that its target exists, printing broken
  ones in red. `als git` filters. Most aliases here are guarded on
  `command -v`, so a missing tool means the alias silently isn't defined —
  `als` is how you notice. It also prints gh's own aliases, which live in
  `.config/gh/config.yml` and work outside zsh.
- **fzf binds ctrl-r / ctrl-t / alt-c** for history, files, and cd. It's guarded
  on `[[ -t 0 ]]` because its ZLE widgets need a real terminal — without that,
  every `zsh -ic` in a script prints `can't change option: zle`.

Swapping the prompt for starship: `mise use -g starship`, then replace
`prompt.zsh` with `eval "$(starship init zsh)"`.

## Bootstrap a new machine

```sh
curl -fsSL https://raw.githubusercontent.com/gelleson/dotfiles/main/bootstrap.sh | sh
```

That installs mise, clones this repo, links everything into `$HOME`, installs
every declared tool, and clones the neovim config. Then `exec zsh`.

It's idempotent — re-running pulls and relinks rather than failing.

**This URL only works if the repo is public.** `raw.githubusercontent.com`
returns 404 for a private repo without a token. If you keep this private, clone
first and run the script locally:

```sh
git clone git@github.com:gelleson/dotfiles.git ~/.dotfiles
sh ~/.dotfiles/bootstrap.sh
```

Knobs, all env vars:

| Var | Default | Effect |
|---|---|---|
| `TOOLS` | `1` | `0` skips `mise install` — just link the dotfiles |
| `NVIM` | `1` | `0` skips cloning the neovim config |
| `DOTFILES_DIR` | `~/.dotfiles` | where to clone |
| `DOTFILES_REPO` | `gelleson/dotfiles` | fork-friendly |

```sh
TOOLS=0 sh ~/.dotfiles/bootstrap.sh    # config only, no 2GB of runtimes
```

Prerequisites the script checks for and fails loudly on: `git`, `curl`, and on
macOS the Command Line Tools (`xcode-select --install`). A bare Mac has a `git`
stub that only triggers the CLT installer, so this is checked explicitly rather
than discovered halfway through.

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

## gh

`gh` is declared in the mise config, and `.config/gh/config.yml` is tracked —
SSH as the git protocol, nvim as the editor, and a handful of aliases (`gh co`,
`gh prs`, `gh prv`, …). Those work everywhere, unlike the zsh aliases in
`aliases.zsh`, which only exist in interactive shells.

**`~/.config/gh/hosts.yml` holds the OAuth token and is gitignored.** Don't move
it under `home/`. gh rewrites `config.yml` in place when you run `gh config
set`, and since it's a symlink those edits land in this repo — commit them.

Auth can't be automated: `bootstrap.sh` runs `gh auth login` if it has a
terminal, and prints the command if it doesn't (with `curl | sh`, stdin is the
script, so there's nothing to prompt on). Skip it with `AUTH=0`.

## Agent instructions

`home/.claude/CLAUDE.md` holds the global rules every coding agent on this
machine follows. `home/.codex/AGENTS.md` is a **symlink inside the repo**
pointing at it, so Claude Code and Codex read the same file and it can't drift.

That's why the link/unlink/status tasks match `-type f -o -type l` rather than
just `-type f` — a plain `-type f` silently skips symlinked entries, so
`AGENTS.md` would never get linked.

Project-level `CLAUDE.md` / `AGENTS.md` override this; it's the base layer.

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
