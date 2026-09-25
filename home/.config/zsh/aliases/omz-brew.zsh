# Oh My Zsh's brew plugin (ohmyzsh/ohmyzsh@74965c9), ported plugin-free.
# Aliases only; .zprofile already puts brew on PATH.

command -v brew >/dev/null 2>&1 || return

alias ba='brew autoremove'
alias bcfg='brew config'
alias bci='brew info --cask'
alias bcin='brew install --cask'
alias bcl='brew list --cask'
alias bcn='brew cleanup'
alias bco='brew outdated --cask'
alias bcrin='brew reinstall --cask'
alias bcubc='brew upgrade --cask && brew cleanup'
alias bcubo='brew update && brew outdated --cask'
alias bcup='brew upgrade --cask'
alias bdr='brew doctor'
alias bfu='brew upgrade --formula'
alias bi='brew install'
alias bih='brew install --HEAD'
alias bl='brew list'
alias bo='brew outdated'
alias br='brew reinstall'
alias brewp='brew pin'
alias brewsp='brew list --pinned'
alias brh='brew reinstall --HEAD'
alias bs='brew search'
alias bsl='brew services list'
alias bsoff='brew services stop'
alias bsoffa='bsoff --all'
alias bson='brew services start'
alias bsona='bson --all'
alias bsr='brew services run'
alias bsra='bsr --all'
alias bu='brew update'
alias bubo='brew update && brew outdated'
alias bubu='bubo && bup'
alias bubug='bubo && bugbc'
alias bugbc='brew upgrade --greedy && brew cleanup'
alias bup='brew upgrade'
alias buz='brew uninstall --zap'

function brews() {
  local formulae="$(brew leaves | xargs brew deps --installed --for-each)"
  local casks="$(brew list --cask 2>/dev/null)"

  local blue="$(tput setaf 4)"
  local bold="$(tput bold)"
  local off="$(tput sgr0)"

  echo "${blue}==>${off} ${bold}Formulae${off}"
  echo "${formulae}" | sed "s/^\(.*\):\(.*\)$/\1${blue}\2${off}/"
  echo "\n${blue}==>${off} ${bold}Casks${off}\n${casks}"
}
