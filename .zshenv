export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Point zsh at this configuration directory (symlinked to $XDG_CONFIG_HOME/zsh
# by init.sh) so the rest of the startup files — .zprofile, .zshrc, aliases.zsh,
# theme.zsh, functions.zsh — are read from here instead of $HOME.
if [ -d "$XDG_CONFIG_HOME/zsh" ]; then
    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi

export PATH="$HOME/.local/bin:$PATH"

