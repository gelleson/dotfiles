# pnpm. `pn` is the short name pnpm's own completion already claims
# (`#compdef pnpm pn`), so it completes too.

if command -v pnpm >/dev/null 2>&1; then
  alias pn=pnpm
  alias pni='pnpm install'
  alias pna='pnpm add'
  alias pnr='pnpm run'
  alias pnx='pnpm dlx'   # one-off, nothing installed — npx's replacement
fi
