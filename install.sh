#!/usr/bin/env bash

git pull origin main

function install() {
    rsync --exclude ".git/" \
        --exclude ".vscode" \
        --exclude "install.sh" \
        --exclude "README.md" \
        --exclude "LICENSE" \
        -avh --no-perms . ~
    source ~/.config/zsh/.zshrc
}

if [ "$1" == "--force" ] || [ "$1" == "-f" ]; then
    install
else
    read -pr "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install
    fi
fi

unset install
