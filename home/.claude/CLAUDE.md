# Global agent instructions

Applies to every project on this machine unless a project's own CLAUDE.md /
AGENTS.md overrides it.

## Where to write instruction changes

When asked to add, change, or remove an agent instruction:

* **Only if the request says GLOBAL** — edit this file. It is a symlink to
  `~/.dotfiles/home/.claude/CLAUDE.md`, so also commit and push the dotfiles
  repo; `~/.codex/AGENTS.md` symlinks to it and updates automatically.
* **Otherwise** — edit the current project's own `CLAUDE.md` / `AGENTS.md`,
  creating it at the repo root if absent. Never edit this file for a
  project-specific rule.

If it's ambiguous which is meant, treat it as project-local and say so.

## This machine is reproducible — keep it that way

Everything that survives a reinstall lives in `~/.dotfiles`, which is a private
GitHub repo (`gelleson/dotfiles`) rebuilt by `bootstrap.sh` in one command.

| What | Where |
|---|---|
| Every CLI tool and language runtime | `~/.dotfiles/home/.config/mise/config.toml` |
| Shell config (options, history, completion, keybindings, aliases, navigation, prompt) | `~/.dotfiles/home/.config/zsh/` |
| Everything else under `$HOME` | `~/.dotfiles/home/<same path>`, symlinked into place |
| Repo tasks (`link`, `unlink`, `status`) | `~/.dotfiles/mise.toml` |
| One-line machine bootstrap | `~/.dotfiles/bootstrap.sh` |

**Use the `system-state` skill** before installing a tool, changing shell
config, or adding any file under `$HOME`. It has the workflow and the traps.

Never install with brew, `curl | sh`, or a downloaded package — tools come from
mise so they're declared and reinstallable. Never edit a file in `$HOME`
expecting it to persist: most are symlinks into `~/.dotfiles`, and anything not
committed and pushed is lost on the next machine.

Secrets never go in the repo. They belong in `~/.zshrc.local` (untracked) or the
login keychain.

## Keep Code Simple

Prefer the simplest implementation that correctly solves the current task.

* Do not overengineer or introduce abstractions for hypothetical future needs.
* Do not create unnecessary helpers, wrappers, factories, interfaces, base classes, or configuration layers.
* Reuse existing project patterns and utilities before adding new ones.
* Keep changes small and focused on the requested behavior.
* Do not refactor unrelated code.
* Avoid adding comments that merely restate the code.
* Avoid excessive validation, fallbacks, and error handling for impossible or unspecified cases.
* Do not add dependencies when a small local implementation is sufficient.
* Prefer readable, explicit code over clever or highly generic code.
* Only extract shared logic when it is genuinely reused.
* Match the existing architecture and style instead of introducing a new pattern.
* Implement only what is requested. Do not add speculative features.
* When several solutions are valid, choose the one with the least code and lowest conceptual complexity.
