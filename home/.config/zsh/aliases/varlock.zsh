# varlock — .env with a schema. No completions here on purpose: `varlock
# complete` is an internal protocol handler, not a script generator (it prints
# ":4"), so there is nothing to put in completions/.

if command -v varlock >/dev/null 2>&1; then
  alias vl=varlock
  # vlr pnpm dev — resolved env, nothing exported into this shell. Note varlock
  # redacts sensitive values out of the child's own output, so `vlr printenv X`
  # prints X half-masked; that's the leak guard working, not a wrong value.
  alias vlr='varlock run --'
fi
