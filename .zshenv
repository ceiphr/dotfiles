skip_global_compinit=1

# xdg
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Shell
export ZSH="$XDG_DATA_HOME/oh-my-zsh"
export OSH="$XDG_DATA_HOME/oh-my-bash"

# Misc
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc
export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/pass

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

# Node
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history # Enable persistent REPL history for `node`.
export NODE_REPL_HISTORY_SIZE='32768'                       # Allow 32³ entries; the default is 1000.
export NODE_REPL_MODE='sloppy'                              # Use sloppy mode by default, matching web browsers.

# NVM
export NVM_DIR="$XDG_DATA_HOME"/nvm

# Rust
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export CARGO_HOME="$XDG_DATA_HOME"/cargo

# Go
export GOPATH="$XDG_DATA_HOME"/go

# Gradle
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle

# PostgreSQL
export PSQL_HISTORY="$XDG_DATA_HOME/psql_history"

# Podman
export DOCKER_HOST=unix:///run/user/1000/podman/podman.sock

# AWS
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME"/aws/credentials
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config

# Android
export ANDROID_HOME="$XDG_DATA_HOME"/android

# Python -> Make Python use UTF-8 encoding for output to stdin, stdout, and stderr.
export PYTHONIOENCODING='UTF-8'

# If rg is installed, use it as fzf command.
if [[ -x "$(command -v "rg")" ]]; then
    export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow -g "!{.git,node_modules}/*" 2> /dev/null'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
