# Temporal. `server start-dev` is a self-contained dev cluster — in-memory
# SQLite, web UI on :8233, no docker-compose and no datastore to provision.

if command -v temporal >/dev/null 2>&1; then
  alias tsd='temporal server start-dev'   # UI at http://localhost:8233
  alias tw='temporal workflow'
  alias twl='temporal workflow list'
fi
