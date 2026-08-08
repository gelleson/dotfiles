# uv — Python packaging. Nothing here activates a venv: mise does that, via
# `python.uv_venv_auto = true` in the global mise config, so cd'ing into a
# project with a .venv puts its python on PATH. `uv tool install` drops binaries
# in ~/.local/bin, which .zshrc already prepends.

if command -v uv >/dev/null 2>&1; then
  alias uvr='uv run'
  alias uvs='uv sync'
  alias uva='uv add'
  alias uvrm='uv remove'
  alias uvt='uv tool'      # uvt install ruff, uvt list, uvt upgrade --all
  alias py='uv run python' # works outside a project too — uv makes a temp env
fi
