source "$ZDOTDIR/functions.zsh"

alias ll='ls -lh'
alias la='ls -lah'
alias vim="nvim"
alias mvnNoTests="mvn clean install -DskipTests"
alias mvnnt="mvn clean install -DskipTests"
alias mvnrun="mvnnt && mvn spring-boot:run"
alias documents='cd ~/Documents'
alias desktop='cd ~/Desktop'
alias downloads='cd ~/Downloads'
alias projects='cd ~/Projects'
alias notes="nvim -c 'GotoNotes'"
alias note="nvim -c 'GotoNotes' -c 'Note'"
alias todo="nvim -c 'GotoTodos' -c 'Todo'"
alias todos="nvim +'GotoTodos'"
alias ic="imageCleanup"
alias ocr="ocrf"
alias list-agents="list-agents"
alias close-agents="close-agents"
alias new-agents="new-agents"
# alias ssh='wezterm --config-file ~/.config/wezterm/.ssh_config.lua start -- ssh "$@"'
