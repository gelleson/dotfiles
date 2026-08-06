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
