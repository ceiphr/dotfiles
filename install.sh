#!/usr/bin/env bash

# For echo -e color support.
TXT_DEFAULT='\033[0m'
TXT_GREEN='\033[0;32m'
TXT_YELLOW='\033[0;33m'
TXT_RED='\033[0;31m'
TXT_BOLD='\033[1m'

# https://no-color.org/
if [[ -n "${NO_COLOR}" ]]; then
    TXT_DEFAULT='\033[0m'
    TXT_YELLOW='\033[0m'
    TXT_GREEN='\033[0m'
    TXT_RED='\033[0m'
fi

PLUGINS=(
    "zsh-autosuggestions"
    "zsh-completions"
    "zsh-interactive-cd"
    "zsh-syntax-highlighting"
)
THEMES=("powerlevel10k")

git pull origin main

# Tiago Lopo: https://stackoverflow.com/a/29436423/9264137
# This is used to ask the user for confirmation.
function yes_or_no {
    while true; do
        read -r -p "$(echo -e "${TXT_YELLOW}?${TXT_DEFAULT} ${TXT_BOLD}$*${TXT_DEFAULT} [y/N]: ")" yn
        case $yn in
        [Yy]*) return 0 ;;
        [Nn]*)
            echo -e "${TXT_RED}!${TXT_DEFAULT} Aborted."
            return 1
            ;;
        *)
            echo -e "${TXT_RED}!${TXT_DEFAULT} Aborted."
            return 1
            ;;
        esac
    done
}

function error() {
    echo -e "${TXT_RED}!${TXT_DEFAULT} $1"
    exit 1
}

function dotfiles_reset() {
    unset -f yes_or_no install_plugins install dotfiles_reset
}

function install_plugins() {
    CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH/custom}"

    # Remove old plugins
    for plugin in "${PLUGINS[@]}"; do
        rm -rf "${CUSTOM_DIR}"/plugins/"${plugin}"
    done
    for theme in "${THEMES[@]}"; do
        rm -rf "${CUSTOM_DIR}"/themes/"${theme}"
    done

    # Install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Install zsh theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k "${CUSTOM_DIR}"/themes/powerlevel10k

    # Install zsh plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions "${CUSTOM_DIR}"/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-completions "${CUSTOM_DIR}"/plugins/zsh-completions
    git clone https://github.com/changyuheng/zsh-interactive-cd "${CUSTOM_DIR}"/plugins/zsh-interactive-cd
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "${CUSTOM_DIR}"/plugins/zsh-syntax-highlighting
}

function install() {
    # Needs to be run first to set up environment variables
    source .zshenv

    # Clean up old files
    rm -rf ~/.fzf

    # Install fzf
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf >/dev/null 2>&1
    ~/.fzf/install --all >/dev/null 2>&1 || error "Unable to install fzf. Try again."

    # Install nvm
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing nvm..."
    [[ -d "$XDG_DATA_HOME"/nvm ]] || mkdir -p "$XDG_DATA_HOME"/nvm
    curl -s https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash >/dev/null 2>&1 || error "Unable to install nvm. Try again."
    bash -c "source $XDG_DATA_HOME/nvm/nvm.sh && nvm install --lts >/dev/null 2>&1" || error "Unable to install nvm. Try again."

    # Sync dotfiles to home directory
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing dotfiles..."
    rsync --exclude ".git/" \
        --exclude ".vscode/" \
        --exclude "install.sh" \
        --exclude "README.md" \
        --exclude "LICENSE" \
        -avh --no-perms . ~ >/dev/null 2>&1 || error "Unable to sync files. Try again."

    # Install plugins
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing plugins..."
    install_plugins

    # Change shell to zsh
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Changing shell to zsh..."
    [ ! "$CODESPACES" ] && echo -e "${TXT_GREEN}>${TXT_DEFAULT} Enter your password if prompted."
    sudo chsh "$(id -un)" --shell "/usr/bin/zsh" >/dev/null 2>&1 || error "Unable to change shell. Change it manually."

    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Done. Reload your terminal."
}

if [ "$1" == "--force" ] || [ "$1" == "-f" ] || [ "$CODESPACES" ]; then
    install
else
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} This may overwrite existing files in your home directory."
    yes_or_no "Are you sure?" || (dotfiles_reset && exit 1)
    install
fi

dotfiles_reset
