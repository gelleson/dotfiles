#!/bin/sh
# Tag every space rooted under ~/codes/namespaces with its namespace path, so
# the sidebar can show it above the space name. Runs on startup and whenever a
# workspace is created.
set -eu
herdr=${HERDR_BIN_PATH:-herdr}

"$herdr" api snapshot | python3 -c '
import json, os, subprocess, sys

herdr, root = sys.argv[1], os.path.expanduser("~/codes/namespaces") + "/"
snap = json.load(sys.stdin)["result"]["snapshot"]
cwds = {}
for pane in snap["panes"]:
    cwds.setdefault(pane["workspace_id"], pane.get("cwd") or "")

for ws in snap["workspaces"]:
    cwd = cwds.get(ws["workspace_id"], "")
    if not cwd.startswith(root):
        continue
    # Everything between the root and the repo is the label, so resolve the repo
    # rather than assuming a depth — a pane may sit in a subdirectory of it.
    repo = subprocess.run(["git", "-C", cwd, "rev-parse", "--show-toplevel"],
                          capture_output=True, text=True).stdout.strip() or cwd
    ns = "/".join(repo[len(root):].split("/")[:-1]) if repo.startswith(root) else ""
    if ns and ws.get("tokens", {}).get("namespace") != ns:
        subprocess.run([herdr, "workspace", "report-metadata", ws["workspace_id"],
                        "--source", "namespaces", "--token", "namespace=" + ns], check=True)
' "$herdr"
