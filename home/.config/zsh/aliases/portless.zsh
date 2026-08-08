# portless — https://<name>.localhost instead of remembering port numbers.
# No completions: the CLI has no generator (`portless completion` is not a
# command). Bare `portless` runs the project's dev script through the proxy.

if command -v portless >/dev/null 2>&1; then
  alias pl=portless
  alias pll='portless list'     # what's routed right now
  alias pld='portless doctor'   # proxy, routes, DNS, CA trust
fi
