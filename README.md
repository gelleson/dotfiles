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
| `aliases.zsh` | git/ls/mise/gh/claude/uv/pnpm/temporal/varlock/portless shortcuts, `take`, `als` |
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

## uv (Python)

`uv` comes from mise; everything Python-project-shaped goes through it.

- **Venvs activate themselves.** `python.uv_venv_auto = "source"` in the mise
  config puts `.venv/bin` on PATH when you `cd` into a project and takes it off
  when you leave — no `source .venv/bin/activate` ever. It triggers on
  **`uv.lock`**, so a bare `uv venv` with no lockfile is not enough; `uv sync` is.
- **`"source"`, not `true`.** `true` is create-then-source: mise runs `uv venv`
  *in the cd hook*. Enter a project pinned to a Python that isn't downloaded yet
  and the prompt blocks on a CPython download — and because `.venv` still doesn't
  exist, the next prompt starts another `uv venv`, and they pile up into a hang.
  `"source"` only ever activates a venv that already exists. Creating one stays
  your job: `uv sync`.
- **`python` outside a project** is still mise's 3.13 (there for the nvim LSPs).
  uv keeps its own interpreters under `~/.local/share/uv/python`, so the two
  never fight. `py` (= `uv run python`) works anywhere, project or not.
- **`uv tool install ruff`** lands binaries in `~/.local/bin`, already first on
  PATH from `.zshrc`. `uvx ruff` runs one without installing.
- **Completions** for `uv` and `uvx` are committed under
  `.config/zsh/completions/`, generated rather than eval'd at startup — the eval
  form costs 60 ms, more than this whole shell. Regenerate after an upgrade with
  the commands in `completion.zsh`.

Aliases (`uv.zsh`): `uvr` run, `uvs` sync, `uva` add, `uvrm` remove, `uvt` tool,
`py` python.

## portless

`https://myapp.localhost` instead of `localhost:3000`. Bare `portless` runs the
project's dev script through the proxy; `pl`, `pll` (list), `pld` (doctor).

Two things `bootstrap.sh` can't do for you, because both touch the OS rather than
`$HOME` — run them once per machine:

```sh
portless trust             # generate the local CA, add it to the trust store
portless service install   # start the HTTPS proxy at login (it binds :443)
portless hosts sync        # only if you use Safari, which ignores .localhost
```

`portless doctor` tells you which of those are still missing. State lives in
`~/.portless` — **not** under `home/`, deliberately: it holds the CA's private
key. `portless clean` removes the state, the trust entry, and the hosts block.

The npm backend means portless runs on whatever `node` is on PATH, and it needs
>= 24. In a project pinning an older node it will refuse to start; run it from
outside that project, or bump the project.

## Agent instructions

`home/.claude/CLAUDE.md` holds the global rules every coding agent on this
machine follows. `home/.codex/AGENTS.md` is a **symlink inside the repo**
pointing at it, so Claude Code and Codex read the same file and it can't drift.

That's why the link/unlink/status tasks match `-type f -o -type l` rather than
just `-type f` — a plain `-type f` silently skips symlinked entries, so
`AGENTS.md` would never get linked.

Project-level `CLAUDE.md` / `AGENTS.md` override this; it's the base layer.

## Secrets

**Nothing under `home/` is encrypted** — no API tokens in `home/.zshrc`, no keys
under `home/.config/`. Everything there is symlinked into place and read by
programs that can't decrypt, so it has to stay plaintext, which means it has to
stay boring. Keep real secrets in the login keychain, a password manager, or an
untracked `~/.zshrc.local` sourced at the end of `home/.zshrc`.

`secrets/` is the exception: sops-encrypted files that are *not* symlinked
anywhere, for config that has to survive a rebuild but holds live credentials.
`bootstrap.sh` decrypts them into place, which makes the age key a hard
dependency of a rebuild — see the warning below.
`.sops.yaml` encrypts only the secret-bearing keys (`api-key`, `api-keys`,
`secret-key`, `token`, `password`), so the rest stays readable in diffs.

```sh
sops secrets/cliproxyapi.yaml       # edit decrypted, re-encrypts on save
sops -d secrets/cliproxyapi.yaml    # print plaintext
```

One-time setup on a new machine, since the private key can obviously never be
in here:

```sh
age-keygen -o "$HOME/Library/Application Support/sops/age/keys.txt"
```

That's the path sops looks in by default on macOS, so `sops` works with no
`SOPS_AGE_KEY_FILE` and no shell config. **Back the private key up somewhere
outside this repo** — lose it and `secrets/` is gone with it, and `bootstrap.sh`
can't help: a fresh `age-keygen` makes a *different* key. The public key for
this repo lives in `.sops.yaml`; project repos each get their own.

`varlock` is the other half and not a competitor: it validates a project's
`.env.schema` and injects resolved values into one command (`vlr pnpm dev`),
where sops encrypts whole files that live in git. It comes from GitHub releases
as a standalone binary, so its npm plugins aren't bundled — a project that uses
one needs `varlock install-plugin <name>` first.

## Temporal

`"aqua:temporalio/cli"` in the mise config, not the registry's `temporal` — that
short name resolves to the *server* distribution (`temporal-server` plus
Cassandra/SQL tools, wants a real datastore). The CLI is the useful half and
embeds its own dev cluster:

```sh
tsd            # temporal server start-dev — SQLite, UI on http://localhost:8233
twl            # temporal workflow list
```

Completions are committed like uv's, but `_temporal` is cobra's dynamic kind — it
asks the binary on each tab, so it never needs regenerating after an upgrade.

## Homebrew and the Brewfile

mise owns every CLI tool and runtime. Homebrew exists for the one thing mise
has no concept of — **casks** — plus the rare formula missing from mise's
registry. That split is the whole rule; the `Brewfile` at the repo root is
deliberately three entries long, and `bootstrap.sh` runs `brew bundle` on it.

Adding to it should be rare. Check `mise registry | grep -i <name>` first —
if it resolves there, it belongs in the mise config instead, where it stays
pinnable per project.

```sh
brew bundle        --file ~/.dotfiles/Brewfile   # install what's declared
brew bundle check  --file ~/.dotfiles/Brewfile   # what's missing?
brew bundle cleanup --file ~/.dotfiles/Brewfile  # what's installed but undeclared?
```

This replaced [zerobrew](https://github.com/lucasgelfond/zerobrew), which was
faster but formulae-only: its `zb install --help` claims "formulas and casks",
yet as of v0.3.2 a cask token only ever hits the *formula* endpoint, so
`zb install orbstack` failed as *missing formula*. Casks were the reason to
have it, so it lost its job.

**OrbStack** (the Docker daemon, and **paid for commercial use**) still needs
one `open -a OrbStack` after a rebuild to install its privileged helper.
`docker-cli` and `docker-compose` stay on mise; OrbStack registers an
`orbstack` docker context on launch, so they find it with no `DOCKER_HOST` and
no shell config. **LM Studio** runs GGUF models locally and ships the `lms`
CLI.

**cliproxyapi** ([CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI))
wraps Claude Code, Codex, Gemini CLI and Qwen as one OpenAI-shaped API on
`127.0.0.1:8317`, run as a `brew services` daemon. Absent from mise's registry.
Its config path is baked in at build time and the service passes no flags, so
`bootstrap.sh` symlinks `/opt/homebrew/etc/cliproxyapi.conf` at
`~/.cli-proxy-api/config.yaml`; brew's own example survives as `.conf.example`.

That config is **not** under `home/` and is not symlinked into the repo. It
holds four live provider keys, so the tracked copy is the encrypted
`secrets/cliproxyapi.yaml` and `bootstrap.sh` decrypts it into place. It has to
live outside `home/` because `mise run link` symlinks everything under there
unconditionally, which would put ciphertext where the daemon expects config.
The same directory is the *auth-dir*, so the OAuth tokens land beside it;
`.gitignore` excludes the whole directory. Log in per provider once after a
rebuild:

```sh
cliproxyapi -claude-login    # also -codex-login, -kimi-login, -xai-login
```

A second instance runs on the Hetzner box
(`gelleson@ubuntu-16gb-fsn1-1.betta-iwato.ts.net`), same version but installed
by hand: binary at `~/cliproxyapi/cli-proxy-api`, config beside it at
`~/cliproxyapi/config.yaml` (found via the unit's `WorkingDirectory`, not
`~/.cli-proxy-api/`), run by the user unit `~/.config/systemd/user/
cliproxyapi.service`.

Both hosts run the **same config**, `secrets/cliproxyapi.yaml`: fill-first
routing over every credential, with client-visible model ids normalised to
OpenRouter slugs (`anthropic/claude-opus-5`, `openai/gpt-5.6-sol`) so a client
can be pointed at either machine without touching its model names. 91 models
across the two OAuth logins and four keyed providers. `api-keys` is the union
of what both hosts were using — `local`, `sk-local`, and the generated hex one —
so nothing that already worked stopped working.

Edit it with `sops secrets/cliproxyapi.yaml`, then push it to both:

```sh
sops -d secrets/cliproxyapi.yaml > ~/.cli-proxy-api/config.yaml
brew services restart cliproxyapi

sops -d secrets/cliproxyapi.yaml \
  | ssh gelleson@ubuntu-16gb-fsn1-1.betta-iwato.ts.net \
      'cat > ~/cliproxyapi/config.yaml && systemctl --user restart cliproxyapi'
```

## Gotchas

- `~/.config/mise/config.toml` is a symlink into this repo. `mise use -g` edits
  it in place (comments and non-`[tools]` keys survive), so global tool changes
  land in the repo directly — `git status` here goes dirty whenever you install
  a tool. Commit them.
- **herdr panes are persistent, so they don't see shell config changes.** A pane
  started before you edited `.config/zsh/` is still running the shell that
  sourced the old config — `z`, new aliases and newly installed tools will all
  appear missing. Run `reload` (`exec zsh`) in that pane. New panes are fine.
- macOS GUI apps launched from Finder read none of these shell files. If a GUI
  app needs mise tools, use `launchctl config user path`.
- **Quit an app before `brew install --cask --adopt` it.** Adopting hands an
  already-installed `.app` to Homebrew without redownloading, but it writes
  xattrs to files inside the bundle, and macOS refuses that while the app is
  running. Adopting a running OrbStack failed on exactly that — and brew's
  rollback *deletes the app*, backup included. `~/.orbstack` (containers,
  images, VM state) survived and a plain `brew install --cask orbstack`
  restored everything, but the ten seconds in between were not fun.
- **Homebrew's installer wants to append its `shellenv` line to `~/.zprofile`,
  which is a symlink into this repo.** Don't let it — it writes a hardcoded
  `/Users/<you>` path into the tracked file. `.zprofile` already evals it,
  guarded, and *before* the mise shims: both prepend to PATH, so the one
  running last wins, and mise must win for every tool it declares.
- mise renders task bodies as Tera templates before running them, so a brace
  followed by a hash opens a template comment and breaks the task. Shell
  brace-length syntax is therefore unusable in `mise.toml`; use `wc -c`.
