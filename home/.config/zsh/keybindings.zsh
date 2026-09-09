# ctrl+e accepts the autosuggestion ghost text. No binding needed: ctrl+e is
# already end-of-line, and zsh-autosuggestions accepts on end-of-line.

# Up/down search history for entries starting with what is already typed,
# instead of stepping through every past command: `cd ~/<Up>` walks only the
# `cd ~/...` lines. Both widgets ship with zsh but are neither loaded nor
# bound by default, hence the autoload + zle -N. Plain previous-command is
# still on ctrl+p / ctrl+n.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search   # arrows as the terminal sends them
bindkey '^[[B' down-line-or-beginning-search
bindkey '^[OA' up-line-or-beginning-search   # same arrows in application mode
bindkey '^[OB' down-line-or-beginning-search

# Skip repeats while walking, so holding Up cycles through distinct commands.
setopt HIST_FIND_NO_DUPS
