typeset -U path  # Ensures no duplicate paths
path=(
    "/opt/homebrew/bin"
    "$HOME/.cargo/bin"
    "$HOME/.pyenv/bin"
    "$HOME/.nvm/versions/node/v18.7.0/bin"
    "/Library/Frameworks/Python.framework/Versions/3.10/bin"
    "/usr/local/bin"
    "/System/Cryptexes/App/usr/bin"
    "/usr/bin"
    "/bin"
    "/usr/sbin"
    "/sbin"
    "/usr/local/go/bin"
    "/Library/Apple/usr/bin"
    "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin"
    "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin"
    "/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin"
    "/opt/homebrew/opt/llvm/bin"
    "/opt/homebrew/opt/mysql-client/bin"
    "/opt/homebrew/opt/mysql-client@8.4/bin"
    "/opt/homebrew/opt/openjdk@21/bin"
    "/Users/fmpi.santos/.local/share/bob/nvim-bin"
    "$path[@]"  # Include existing paths at the end
)
export PATH

# Homebrew setup - only set if Homebrew is installed
if [[ -d "/opt/homebrew" ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
    export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
    export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:"
    export INFOPATH="$HOMEBREW_PREFIX/share/info:${INFOPATH:-}"
fi

# Lazy load NVM for faster shell startup
export NVM_DIR="$HOME/.nvm"
nvm() {
    unset -f nvm
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && source "/opt/homebrew/opt/nvm/nvm.sh"
    nvm "$@"
    nvm use default >/dev/null
    export __NVM_LOADED=1
}

# Only load NVM on first node/npm call
node() {
    unset -f node
    if [ -z "$__NVM_LOADED" ]; then
        nvm
    fi
    node "$@"
}

npm() {
    unset -f npm
    if [ -z "$__NVM_LOADED" ]; then
        nvm
    fi
    npm "$@"
}

# JDTLS setup
export JDTLS_JVM_ARGS="-javaagent:/Users/fmpi.santos/.local/share/nvim/mason/packages/jdtls/lombok.jar"

# Set the default editor to nvim
export EDITOR="nvim"
export VISUAL="nvim"

# # Ensure the proper environment setup for Jenv and Cargo
. "$HOME/.cargo/env"
if which jenv > /dev/null; then eval "$(jenv init -)"; fi

# .profile
export PROJECTS=/Users/fmpi.santos/Projects/NeuralNetwork
export MASON=/Users/fmpi.santos/.local/share/nvim/mason
export PATH="$PATH:/Users/fmpi.santos/Library/Application Support/Coursier/bin"
export XDG_CONFIG_HOME="$HOME/.config"

# Java setup via Jenv
if which jenv > /dev/null; then
  export JAVA_HOME="$(jenv which java | sed 's:/bin/java::')"
fi

# For compilers to find llvm you may need to set:
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

# opencode
export PATH=/Users/fmpi.santos/.opencode/bin:$PATH
export DEEPL_API_KEY=64740df2-c430-43e3-ac63-e55d3dae9784:fx
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export PATH="$HOME/.local/bin:$PATH"

# Auto-start tmux: if tmux is installed (and we're in an interactive shell not
# already inside tmux), attach to an existing session, or start a new one if
# there are no sessions to attach to.
if command -v tmux >/dev/null 2>&1 && [[ -o interactive ]] && [[ -z "$TMUX" ]]; then
    tmux attach 2>/dev/null || tmux
fi
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
