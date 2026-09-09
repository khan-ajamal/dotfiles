# Tab through the completion list with the current choice highlighted, instead
# of just printing the list. Arrow keys move around it; Enter picks.
zstyle ':completion:*' menu select

# Case-insensitive matching, so `cd doc<Tab>` also finds `Documents`.
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
