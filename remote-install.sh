#!/usr/bin/env bash

SOURCE="https://github.com/ceiphr/dotfiles.git"
TARGET="/tmp/dotfiles"

if [[ "$CI" ]]; then
    TARGET="$HOME/.dotfiles"
fi

# For echo -e color support.
TXT_DEFAULT='\033[0m'
TXT_GREEN='\033[0;32m'
TXT_RED='\033[0;31m'

# https://no-color.org/
if [[ -n "${NO_COLOR}" ]]; then
    TXT_DEFAULT='\033[0m'
    TXT_GREEN='\033[0m'
    TXT_RED='\033[0m'
fi

# Clean up after ourselves.
function install_reset() {
    unset -f handle_sigint error install_reset
}

# In case the user quits the program in the critical section, we can
# simply unlock the section before exiting.
function handle_sigint() {
    install_reset
    exit 1
}

trap 'handle_sigint' INT

# Error handling and cleanup.
# Usage: echo "Hello world!" || error "Error message"
function error() {
    echo -e "${TXT_RED}!${TXT_DEFAULT} $1"
    echo -e "${TXT_RED}!${TXT_DEFAULT} Exiting."
    install_reset
    exit 1
}

if [[ -x "$(command -v "git")" ]]; then
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing dotfiles..."
    CURRENT_DIR=$(pwd)

    # Clone repository
    rm -rf "$TARGET"
    git clone $SOURCE "$TARGET"

    # Run bootstrap script
    cd "$TARGET" || error "Error changing directory to $TARGET"
    chmod +x bootstrap.sh
    sh bootstrap.sh "$@"

    # Cleanup
    cd "$CURRENT_DIR" || error "Error changing directory to $CURRENT_DIR"
else
    error "Required dependency 'git' not found. Please install git and try again."
fi

exit 0
