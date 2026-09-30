# vlogscli — reuse the VictoriaLogs port-forward if one is already listening on
# :9428, otherwise start it in the background (it outlives the CLI, so the next
# run is instant) against whatever kube context is current.
vlogscli() {
  if ! nc -z localhost 9428 2>/dev/null; then
    kubectl -n monitoring port-forward svc/victoria-logs 9428:9428 >/dev/null 2>&1 &!
    local i
    for i in {1..50}; do
      nc -z localhost 9428 2>/dev/null && break
      sleep 0.1
    done
    nc -z localhost 9428 2>/dev/null || { print -u2 "vlogscli: port-forward to svc/victoria-logs failed"; return 1 }
    print "vlogscli: port-forward inited (localhost:9428)"
  fi
  command vlogscli "$@"
}
