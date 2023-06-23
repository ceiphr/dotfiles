skip_global_compinit=1

export ZDOTDIR="$HOME"/.config/zsh
export ZSH="/home/${USER}/.oh-my-zsh"

# Enable colors
export CLICOLOR=1

# Prefer US English and use UTF-8.
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'

# Editor
export EDITOR="vim"
export VISUAL="code"

# Increase Bash history size. Allow 32³ entries; the default is 500.
export HISTSIZE='32768'
export HISTFILESIZE="${HISTSIZE}"
export HISTCONTROL='ignoreboth' # Omit duplicates and commands that begin with a space from history.
export HISTFILE="$XDG_STATE_HOME"/zsh/history

# xdg
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Node
export NODE_REPL_HISTORY=~/.node_history # Enable persistent REPL history for `node`.
export NODE_REPL_HISTORY_SIZE='32768'    # Allow 32³ entries; the default is 1000.
export NODE_REPL_MODE='sloppy'           # Use sloppy mode by default, matching web browsers.

# Python -> Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export PYTHONIOENCODING='UTF-8'
