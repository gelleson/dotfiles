# Oh My Zsh's npm plugin (ohmyzsh/ohmyzsh@74965c9), ported plugin-free.
# Aliases only. Dropped npmE — `npm bin` was removed in npm 9.

command -v npm >/dev/null 2>&1 || return

# Install dependencies globally
alias npmg="npm i -g "

# npm package names are lowercase
# Thus, we've used camelCase for the following aliases:

# Install and save to dependencies in your package.json
# npms is used by https://www.npmjs.com/package/npms
alias npmS="npm i -S "

# Install and save to dev-dependencies in your package.json
# npmd is used by https://github.com/dominictarr/npmd
alias npmD="npm i -D "

# Force npm to fetch remote resources even if a local copy exists on disk.
alias npmF='npm i -f'

# Check which npm modules are outdated
alias npmO="npm outdated"

# Update all the packages listed to the latest version
alias npmU="npm update"

# Check package versions
alias npmV="npm -v"

# List packages
alias npmL="npm list"

# List top-level installed packages
alias npmL0="npm ls --depth=0"

# Run npm start
alias npmst="npm start"

# Run npm test
alias npmt="npm test"

# Run npm scripts
alias npmR="npm run"

# Run npm publish
alias npmP="npm publish"

# Run npm init
alias npmI="npm init"

# Run npm info
alias npmi="npm info"

# Run npm search
alias npmSe="npm search"

# Run npm run dev
alias npmrd="npm run dev"

# Run npm run build
alias npmrb="npm run build"
