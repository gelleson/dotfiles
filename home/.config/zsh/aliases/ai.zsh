# Claude Code, per model. The [1m] suffix selects the 1M-token context
# variant; haiku has no 1m variant, so it's plain.
if command -v claude >/dev/null 2>&1; then
  alias op='claude --model "opus[1m]"'
  alias opus='claude --model "opus[1m]"'
  alias sonnet='claude --model "sonnet[1m]"'
  alias haiku='claude --model haiku'
fi

# Agent CLIs, named <cli><model>: c* is Claude Code, x* is Codex.
#   c   opus        x   codex 5.5
#   co  opus
#   cs  sonnet      xs  codex sol 5.6
#   ch  haiku       xt  codex terra
#                   xl  codex luna
# A leading effort flag skips the picker: -l low, -m medium, -h high, -x xhigh,
# -X max. Without one, gum asks with high preselected. Remaining arguments pass
# straight through.
_ai() {
  emulate -L zsh
  local cli=$1 model=$2 effort
  shift 2
  case ${1-} in
    -l) effort=low;    shift ;;
    -m) effort=medium; shift ;;
    -h) effort=high;   shift ;;
    -x) effort=xhigh;  shift ;;
    -X) effort=max;    shift ;;
    *)  effort=$(gum choose --header="$model effort" --selected=high low medium high xhigh max) || return ;;
  esac
  [[ -n $effort ]] || return
  if [[ $cli == claude ]]; then
    claude --model $model --effort $effort "$@"
  else
    codex -m $model -c model_reasoning_effort="$effort" "$@"
  fi
}
if command -v claude >/dev/null 2>&1 && command -v gum >/dev/null 2>&1; then
  alias c='_ai claude "opus[1m]"'    # opus is the default, so plain `c` gets it
  alias co='_ai claude "opus[1m]"'
  alias cs='_ai claude "sonnet[1m]"'
  alias ch='_ai claude haiku'
fi
if command -v codex >/dev/null 2>&1 && command -v gum >/dev/null 2>&1; then
  alias x='_ai codex 5.5'
  alias xs='_ai codex sol-5.6'
  alias xt='_ai codex terra'
  alias xl='_ai codex luna'
fi

