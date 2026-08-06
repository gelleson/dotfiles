# Herdr sessions, one per ~/codes/namespaces namespace.

# hs [<namespace>[/<group>]] — attach to that namespace's herdr session, creating
# it in the namespace directory the first time. A bare group name resolves on its
# own (`hs curran` -> sides/curran); no argument picks one with fzf. Session names
# can't hold '/', so sides/curran runs as `sides-curran`.
hs() {
  emulate -L zsh -o extended_glob   # the (*/)# match patterns below need it
  local root=~/codes/namespaces ns=$1 name d
  local -a dirs sessions hits
  for d in $root/*(/N) $root/*/*(/N); do
    [[ -d $d/.git ]] || dirs+=(${d#$root/})   # repos aren't namespaces
  done
  dirs=(${(o)dirs})
  sessions=(${(f)"$(herdr session list 2>/dev/null | tail -n +2 | awk '{print $1}')"})

  # Bare `hs` is for jumping between sessions that already exist; naming a
  # namespace is what starts a new one.
  if [[ -z $ns ]]; then
    (( $#sessions )) || { print -u2 "hs: no sessions yet — try: hs <namespace>"; return 1 }
    ns=$(print -l $sessions | fzf --prompt='session ▸ ' --height=100% --border) || return
  fi
  [[ -n $ns ]] || return
  name=${ns//\//-}

  # A live session wins over the folder, so a namespace that has been renamed or
  # deleted underneath a running session still opens.
  if (( ! $sessions[(Ie)$name] )) && [[ ! -d $root/$ns ]]; then
    hits=(${(M)dirs:#(*/)#$ns} ${(M)sessions:#(*-)#$ns})
    case $#hits in
      1) ns=$hits[1]; name=${ns//\//-} ;;
      0) print -u2 "hs: no session or namespace matching '$ns'"; return 1 ;;
      *) ns=$(print -l $hits | fzf --prompt='session ▸ ' --height=100% --border --select-1) || return
         name=${ns//\//-} ;;
    esac
  fi

  if [[ -d $root/$ns ]]; then
    (cd $root/$ns && herdr --session $name)
  else
    herdr --session $name
  fi
}

# hsd [<filter>] — stop and delete a herdr session. The filter seeds fzf; you
# still pick the session and confirm it.
hsd() {
  emulate -L zsh
  local pick
  local -a sessions
  sessions=(${(f)"$(herdr session list 2>/dev/null | tail -n +2 | awk '{print $1}')"})
  sessions=(${sessions:#default})   # herdr refuses to delete the default session
  (( $#sessions )) || { print -u2 "hsd: no deletable sessions"; return 1 }

  pick=$(print -l $sessions | fzf --prompt='delete ▸ ' --height=100% --border --query="${1:-}") || return
  [[ -n $pick ]] || return
  read -q "REPLY?delete session '$pick'? [y/N] " || { print; return 1 }
  print
  herdr session stop "$pick" >/dev/null 2>&1   # delete only takes stopped sessions
  herdr session delete "$pick"
}
