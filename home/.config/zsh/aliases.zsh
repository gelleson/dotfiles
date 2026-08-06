# Aliases and small functions, split by topic under aliases/. Drop a new .zsh
# file in there to add a group; nothing else needs editing.

for _alias_mod in ${0:A:h}/aliases/*.zsh(N); do
  source $_alias_mod
done
unset _alias_mod
