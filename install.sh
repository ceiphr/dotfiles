#!/usr/bin/env bash

source .config/zsh/.zshenv
CUSTOM_DIR=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

git pull origin main

function install() {
    # Sync dotfiles to home directory
    rsync --exclude ".git/" \
        --exclude ".vscode/" \
        --exclude "install.sh" \
        --exclude "README.md" \
        --exclude "LICENSE" \
        -avh --no-perms . ~

    # Clean up old files
    rm -rf ~/.fzf
    rm -rf "${CUSTOM_DIR}"/themes/powerlevel10k
    rm -rf "${CUSTOM_DIR}"/plugins/zsh-autosuggestions
    rm -rf "${CUSTOM_DIR}"/plugins/zsh-completions
    rm -rf "${CUSTOM_DIR}"/plugins/zsh-interactive-cd
    rm -rf "${CUSTOM_DIR}"/plugins/zsh-syntax-highlighting

    # Install fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --bin

    # Install nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

    # Install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Install zsh theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k "${CUSTOM_DIR}"/themes/powerlevel10k

    # Install zsh plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions "${CUSTOM_DIR}"/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-completions "${CUSTOM_DIR}"/plugins/zsh-completions
    git clone https://github.com/changyuheng/zsh-interactive-cd "${CUSTOM_DIR}"/plugins/zsh-interactive-cd
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "${CUSTOM_DIR}"/plugins/zsh-syntax-highlighting

    # If current shell is not zsh, switch to zsh
    if [ "$SHELL" != "/usr/bin/zsh" ]; then
        zsh
    fi
    source ~/.config/zsh/.zshrc
}

if [ "$1" == "--force" ] || [ "$1" == "-f" ]; then
    install
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install
    fi
fi

unset install
