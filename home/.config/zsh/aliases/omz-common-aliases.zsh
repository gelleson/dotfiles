# Oh My Zsh's common-aliases plugin (ohmyzsh/ohmyzsh@74965c9), ported plugin-free.
# Skipped because core.zsh already has them: la ll lt rm cp mv. `l` comes from
# omz-directories.zsh and `h` from omz-history.zsh. fd stays the fd tool.
# Dropped global aliases for tools that aren't here (M: most, P: pygmentize)
# and CA (macOS cat has no -A). Suffix aliases point media/docs at `open`.

# ls, the common ones I use a lot shortened for rapid fire usage
alias lr='ls -tRFh'   #sorted by date,recursive,show type,human readable
alias ldot='ls -ld .*'
alias lS='ls -1FSsh'
alias lart='ls -1Fcart'
alias lrt='ls -1Fcrt'
alias lsr='ls -lARFh' #Recursive list of files and directories
alias lsn='ls -1'     #A column contains name of files and directories

alias zshrc='${=EDITOR} ${ZDOTDIR:-$HOME}/.zshrc' # Quick access to the .zshrc file

alias grep='grep --color'
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS} '

alias t='tail -f'

# Command line head / tail shortcuts
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L="| less"
alias -g LL="2>&1 | less"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"

alias dud='du -d 1 -h'
(( $+commands[duf] )) || alias duf='du -sh *'
alias ff='find . -type f -name'

alias hgrep="fc -El 0 | grep"
alias help='man'
alias p='ps -f'
alias sortnr='sort -n -r'
alias unexport='unset'

# Typing a file name opens it by its suffix.
for ft in cpp cxx cc c hh h inl asc txt TXT tex; do alias -s $ft='$EDITOR'; done
for ft in pdf ps dvi chm djvu ape avi flv m4a mkv mov mp3 mpeg mpg ogg ogm rm wav webm; do alias -s $ft=open; done
unset ft

#list what's inside packed file
alias -s zip="unzip -l"
alias -s tar="tar tf"
