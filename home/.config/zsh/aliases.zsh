# Git shortcuts, keeping the names oh-my-zsh's git plugin uses so muscle
# memory carries over. Only the ones actually reached for, not all ~150.
# Anything destructive (force push, reset --hard, clean) is spelled out on
# purpose, so it cannot be typed by accident.

alias g='git'

# Status and inspection
alias gst='git status'
alias gd='git diff'
alias gds='git diff --staged'
alias gsh='git show'
alias glo='git log --oneline --decorate'
alias glog='git log --oneline --decorate --graph'
alias gb='git branch'
alias gba='git branch --all'

# Staging and committing
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gcm='git commit -m'
# The ! suffix is oh-my-zsh's mark for "rewrites the last commit".
alias gc!='git commit -v --amend'
alias gcn!='git commit -v --amend --no-edit'
alias grs='git restore'
alias grss='git restore --staged'

# Moving between branches. gco is the old spelling, gsw the modern one;
# both are here because git kept checkout working and fingers remember it.
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gswc='git switch -c'

# Syncing with the remote
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gl='git pull'
alias gp='git push'
alias gpu='git push --set-upstream origin $(git branch --show-current)'
# --force-with-lease refuses the push if someone else pushed in the meantime,
# unlike plain --force which would drop their work.
alias gpf='git push --force-with-lease'

# Replaying and combining work
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gm='git merge'
alias grb='git rebase'
alias grbi='git rebase --interactive'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'

# Stash
alias gsta='git stash push'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gstd='git stash drop'
