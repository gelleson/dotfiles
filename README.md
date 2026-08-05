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
#    Restore from your password manager; it is never in this repo.
mkdir -p ~/.config/sops/age
pbpaste > ~/.config/sops/age/keys.txt     # or however you transport it
chmod 600 ~/.config/sops/age/keys.txt

# 4. link everything into $HOME, then restart the shell
cd ~/.dotfiles
SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt ~/.local/bin/mise run link
exec zsh
```

Step 4 needs `SOPS_AGE_KEY_FILE` set inline because the global mise config
already references the encrypted file, but `~/.zshenv` (which normally exports
it) isn't linked yet. After the first link, it's automatic.

## Daily use

| Command | What it does |
|---|---|
| `mise run link` | Symlink `home/` into `$HOME` (idempotent; backs up conflicts to `*.bak`) |
| `mise run status` | Show which files are linked, unlinked, or missing |
| `mise run unlink` | Replace symlinks with real copies |
| `mise run secrets:edit` | Edit secrets in `$EDITOR`, re-encrypted on save |
| `mise run secrets:show` | Print decrypted secrets to stdout |
| `mise run secrets:rotate` | Re-encrypt after changing recipients in `.sops.yaml` |

Adding a dotfile: move it under `home/` at its `$HOME`-relative path, then
`mise run link`.

Adding a secret: `mise run secrets:edit`, add a key, save. It becomes an env var
in every new shell — mise decrypts `secrets/env.json` via the `[env] _.file`
entry in `home/.config/mise/config.toml`.

## Secrets model

- `secrets/env.json` is encrypted with age. Values are ciphertext; **keys stay in
  plaintext** so diffs remain reviewable. Don't put anything sensitive in a key name.
- The private key lives only at `~/.config/sops/age/keys.txt`, mode 600, and is
  gitignored everywhere. Back it up somewhere you'd trust with a password.
- Losing that key means losing every secret in this repo. Rotating it means
  editing `.sops.yaml` and running `mise run secrets:rotate`.
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
