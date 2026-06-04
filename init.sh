#!/bin/sh
# Bootstrap script for this zsh configuration.
#
# It wires the files in this folder into the locations zsh actually reads from:
#   * symlinks this directory to $XDG_CONFIG_HOME/zsh, which becomes $ZDOTDIR
#     (so .zprofile/.zshrc/aliases.zsh/theme.zsh/functions.zsh are found here)
#   * symlinks .zshenv into $HOME, since zsh reads $HOME/.zshenv first and that
#     is what sets ZDOTDIR to the directory above
#   * creates the state/cache dirs the config writes to (history, zcompdump)
#   * ensures starship (the prompt/theme provider) is installed
#
# Safe to re-run; it only acts on what's missing and backs up anything it would
# otherwise overwrite (moving it to <name>.bak).

set -eu

# Resolve the directory this script lives in (the source of truth for config).
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

ZSH_CONFIG_DIR="$XDG_CONFIG_HOME/zsh"

has() { command -v "$1" >/dev/null 2>&1; }

# --- symlink helper -------------------------------------------------------
# link <source> <dest>: point dest at source, backing up whatever is already
# there. No-op if dest already links to source.
link() {
    src="$1"
    dest="$2"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "  ✔ $dest already links to $src"
        return 0
    fi

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "  Backing up $dest → $dest.bak"
        mv -f "$dest" "$dest.bak"
    fi

    ln -s "$src" "$dest"
    echo "  Linked $dest → $src"
}

# --- directories the config reads/writes ----------------------------------
# .zshrc stores history under $XDG_STATE_HOME/zsh and the completion dump under
# $XDG_CACHE_HOME/zsh; both parent dirs must exist before the first launch.
echo "📁 Creating state/cache directories..."
mkdir -p "$XDG_STATE_HOME/zsh"
mkdir -p "$XDG_CACHE_HOME/zsh"
mkdir -p "$XDG_CONFIG_HOME"

# --- wire the config into place -------------------------------------------
echo "🔗 Linking zsh configuration..."
# $ZDOTDIR → this folder, so the rest of the startup files are read from here.
link "$SCRIPT_DIR" "$ZSH_CONFIG_DIR"
# zsh always reads $HOME/.zshenv first; that file sets ZDOTDIR to the dir above.
link "$ZSH_CONFIG_DIR/.zshenv" "$HOME/.zshenv"

# --- starship -------------------------------------------------------------

install_starship() {
    if has starship; then
        echo "starship already installed ($(command -v starship))"
        return 0
    fi

    echo "Installing starship..."

    # Prefer a native package manager when one is available, so updates flow
    # through the system. Fall back to the official installer otherwise.
    if has brew; then
        # macOS or Linuxbrew
        brew install starship
    elif has pacman; then
        # Arch / Manjaro
        sudo pacman -S --needed --noconfirm starship
    elif has dnf; then
        # Fedora / RHEL
        sudo dnf install -y starship || install_starship_script
    elif has zypper; then
        # openSUSE
        sudo zypper install -y starship || install_starship_script
    elif has apk; then
        # Alpine
        sudo apk add starship || install_starship_script
    else
        # Debian/Ubuntu's apt has no starship package; use the official
        # installer here and as the universal fallback for everything else.
        install_starship_script
    fi

    if has starship; then
        echo "starship installed ($(command -v starship))"
    else
        echo "ERROR: starship installation failed" >&2
        return 1
    fi
}

# Official cross-platform installer. Downloads a prebuilt binary into
# ~/.local/bin (already on PATH per .zshenv) without needing root.
install_starship_script() {
    bindir="${HOME}/.local/bin"
    mkdir -p "$bindir"

    if has curl; then
        fetch="curl -fsSL https://starship.rs/install.sh"
    elif has wget; then
        fetch="wget -qO- https://starship.rs/install.sh"
    else
        echo "ERROR: need curl or wget to install starship" >&2
        return 1
    fi

    $fetch | sh -s -- --yes --bin-dir "$bindir"
}

install_starship

echo ""
echo "✨ zsh configuration linked."
echo ""
echo "📝 Notes:"
echo "  • ZDOTDIR is now $ZSH_CONFIG_DIR (a symlink to this repo)."
echo "  • Any pre-existing ~/.zshenv, ~/.zshrc or ~/.zprofile in \$HOME are now"
echo "    superseded — zsh reads those from \$ZDOTDIR instead. Old files were"
echo "    left in place (the ones this script replaced are saved as *.bak)."
echo "  • Open a new shell or run: ZDOTDIR=$ZSH_CONFIG_DIR exec zsh"
