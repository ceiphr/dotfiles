#!/usr/bin/env bash

SOURCE="https://github.com/ceiphr/dotfiles.git"
TARGET="/tmp/.dotfiles"

if [[ -x "$(command -v "git")" ]]; then
    echo "Installing dotfiles..."
    rm -rf $TARGET
    git clone $SOURCE $TARGET

    chmod +x $TARGET/bootstrap.sh
    sh $TARGET/bootstrap.sh "$@"
else
    echo "Required dependency 'git' not found. Please install git and try again."
    exit 1
fi
