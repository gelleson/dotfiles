# dotfiles

Repeatable machine setup: **mise** for tools + env, a plain git repo for config,
**sops + age** for secrets. No dotfile manager — `mise run link` does the linking.

## Layout

```
home/            mirrors $HOME; every file here gets symlinked into place
secrets/         sops-encrypted; safe to commit
mise.toml        tasks for managing this repo (link/unlink/status/secrets:*)
.sops.yaml       which age recipients can decrypt secrets/
```

## Bootstrap a new machine

```sh
# 1. mise
curl https://mise.run | sh

# 2. this repo
git clone git@github.com:USER/dotfiles.git ~/.dotfiles

# 3. the age private key — THE ONE MANUAL STEP.
#    Restore it from your password manager into the login keychain.
#    It is never in this repo and never on disk.
security add-generic-password -a "$USER" -s sops-age-key \
  -l "sops age key (dotfiles)" -D "age private key" \
  -T /usr/bin/security -U -w        # -w with no value prompts, so it stays off your shell history

# 4. link everything into $HOME, then restart the shell
cd ~/.dotfiles
SOPS_AGE_KEY="$(security find-generic-password -s sops-age-key -w)" \
  ~/.local/bin/mise run link
exec zsh
```

Step 4 passes the key inline because the global mise config already references
the encrypted file, but `~/.zshenv` (which normally exports it) isn't linked
yet. After the first link it's automatic.

If you're migrating a machine that still has a key *file*, `mise run key:import`
moves it into the keychain and tells you how to shred the file.

## Daily use

| Command | What it does |
|---|---|
| `mise run link` | Symlink `home/` into `$HOME` (idempotent; backs up conflicts to `*.bak`) |
| `mise run status` | Show which files are linked, unlinked, or missing |
| `mise run unlink` | Replace symlinks with real copies |
| `mise run secrets:edit` | Edit secrets in `$EDITOR`, re-encrypted on save |
| `mise run secrets:show` | Print decrypted secrets to stdout |
| `mise run secrets:rotate` | Re-encrypt after changing recipients in `.sops.yaml` |
| `mise run key:status` | Is the age key in the keychain? Which recipient? Any stray key file? |
| `mise run key:import` | Move a key file into the keychain |
| `mise run key:export` | Write the keychain key back to a file (recovery only) |

Adding a dotfile: move it under `home/` at its `$HOME`-relative path, then
`mise run link`.

Adding a secret: `mise run secrets:edit`, add a key, save. It becomes an env var
in every new shell — mise decrypts `secrets/env.json` via the `[env] _.file`
entry in `home/.config/mise/config.toml`.

## Secrets model

- `secrets/env.json` is encrypted with age. Values are ciphertext; **keys stay in
  plaintext** so diffs remain reviewable. Don't put anything sensitive in a key name.
- The private key lives **only in the macOS login keychain** (service
  `sops-age-key`), encrypted at rest and unlocked by your login password. There
  is no copy on disk. `~/.zshenv` reads it into `SOPS_AGE_KEY` at shell start.
- Back it up somewhere you'd trust with a password — `mise run key:export -` is
  not a thing; use `security find-generic-password -s sops-age-key -w` and paste
  it into your password manager. Losing it means losing every secret here.
- Rotating: generate a new key, put its public half in `.sops.yaml`, run
  `mise run secrets:rotate` while the *old* key is still in the keychain, then
  replace the keychain entry.
- **Trade-off to know:** because `SOPS_AGE_KEY` is exported, every process you
  launch inherits the private key, not just mise. That's a wider blast radius
  than a mode-600 file that only sops reads. It's a deliberate call here — the
  decrypted secrets are already exported as env vars by design, so any process
  that could steal the key could already read the secrets. If you later add a
  high-value secret, consider dropping `[env] _.file` from the global config and
  loading secrets per-project instead.
- Adding a second machine: generate an age key there, add its **public** key to
  `.sops.yaml`, run `secrets:rotate`, commit. That machine can now decrypt
  without ever copying the original private key.

## Gotchas

- mise's built-in sops decryptor doesn't fall back to sops' default key path, so
  `~/.zshenv` exports `SOPS_AGE_KEY_FILE` explicitly.
- `~/.config/mise/config.toml` is a symlink into this repo. `mise use -g` edits
  it in place (comments and non-`[tools]` keys survive), so those changes land in
  the repo directly — commit them.
- macOS GUI apps launched from Finder read none of these files. If a GUI app
  needs mise tools, use `launchctl config user path`.
- mise renders task bodies as Tera templates before running them, so a brace
  followed by a hash opens a template comment and breaks the task. Shell
  brace-length syntax is therefore unusable in `mise.toml`; use `wc -c`.
- Never write `${SOPS_AGE_KEY:-something}` in a diagnostic — that expands to the
  key's *value* when set, printing the private key. Test with `:+` only.
