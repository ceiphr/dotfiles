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

PATH="$PATH:$HOME/.local/bin"

git pull origin main >/dev/null 2>&1 || error "Unable to pull latest changes."

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
    echo -e "${TXT_RED}!${TXT_DEFAULT} Exiting."
    exit 1
}

function dotfiles_reset() {
    unset -f yes_or_no error install_omz install_dnf install_flatpak install_apt \
        install_python install_node install_pkgs install_fzf install_gnome_extensions \
        install_gnome_settings install dotfiles_reset
}

function install_dnf() {
    # Add third-party repos.
    # 1Password
    echo -e "${TXT_YELLOW}+${TXT_DEFAULT} Adding 1Password repo."
    sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
    sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo' >/dev/null 2>&1 || error "Unable to add 1Password repo."
    # Charm
    echo -e "${TXT_YELLOW}+${TXT_DEFAULT} Adding Charm repo."
    sudo sh -c 'echo -e "[charm]\nname=Charm\nbaseurl=https://repo.charm.sh/yum/\nenabled=1\ngpgcheck=1\ngpgkey=https://repo.charm.sh/yum/gpg.key" > /etc/yum.repos.d/charm.repo' >/dev/null 2>&1 || error "Unable to add Charm repo."
    # VSCode
    echo -e "${TXT_YELLOW}+${TXT_DEFAULT} Adding VSCode repo."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo' >/dev/null 2>&1 || error "Unable to add VSCode repo."
    # Insync
    echo -e "${TXT_YELLOW}+${TXT_DEFAULT} Adding Insync repo."
    sudo rpm --import https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key
    sudo sh -c 'echo -e "[insync]\nname=insync repo\nbaseurl=http://yum.insync.io/fedora/38/\ngpgcheck=1\ngpgkey=https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key\nenabled=1\nmetadata_expire=120m" > /etc/yum.repos.d/insync.repo' >/dev/null 2>&1 || error "Unable to add Insync repo."
    # Tailscale
    echo -e "${TXT_YELLOW}+${TXT_DEFAULT} Adding Tailscale repo."
    sudo dnf config-manager --add-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo >/dev/null 2>&1 || error "Unable to add Tailscale repo."

    # Install packages.
    [ ! "$CODESPACES" ] && echo -e "${TXT_GREEN}>${TXT_DEFAULT} Enter your password if prompted."
    sudo dnf upgrade -y || error "Unable to upgrade packages."
    sudo dnf install -y $(cat packages/dnf) || error "Unable to install packages."
}

function install_flatpak() {
    flatpak update -y || error "Unable to update flatpak."
    flatpak remote-add -u --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1 || error "Unable to add flathub remote."
    flatpak install -u -y $(cat packages/flatpak) || error "Unable to install flatpak packages."
}

function install_gnome_settings() {
    dconf load /org/gnome/shell/extensions/ <gnome-settings/extensions.conf
    dconf load /org/gnome/desktop/ <gnome-settings/desktop.conf
    dconf load /org/gnome/shell/ <gnome-settings/shell.conf
    dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ <gnome-settings/keybindings.conf
}

function install_apt() {
    [ ! "$CODESPACES" ] && echo -e "${TXT_GREEN}>${TXT_DEFAULT} Enter your password if prompted."
    sudo apt-get update -y >/dev/null 2>&1 || error "Unable to update packages."
    sudo apt install -y $(cat packages/apt) || error "Unable to install packages."
}

function install_python() {
    pip install --upgrade pip >/dev/null 2>&1 || error "Unable to update pip."
    pip install $(cat packages/pip) || error "Unable to install python packages."
}

function install_gnome_extensions() {
    # Note: Must be run after install_python. gnome-extensions-cli is installed via pip.
    gnome-extensions-cli install $(cat packages/gnome-extensions) || error "Unable to install gnome extensions."
}

function install_node() {
    # Install nvm
    [[ -d "$XDG_DATA_HOME"/nvm ]] || mkdir -p "$XDG_DATA_HOME"/nvm
    curl -s https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash || error "Unable to install nvm."
    bash -c "source $XDG_DATA_HOME/nvm/nvm.sh && nvm install --lts" || error "Unable to install nvm."

    # Install npm packages
    npm update -g || error "Unable to update npm."
    npm install -g $(cat packages/npm) || error "Unable to install npm packages."
}

function install_pkgs() {
    source /etc/os-release

    # Install OS-specific packages
    if [[ "$ID" == "fedora" ]] || [[ $ID == "rhel" ]]; then
        echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing DNF packages..."
        install_dnf
        echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing Flatpak packages..."
        install_flatpak
    elif [[ $ID == "ubuntu" ]] || [[ "$CODESPACES" ]]; then
        echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing APT packages..."
        install_apt
    else
        error "Unsupported OS."
    fi

    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing Python packages..."
    install_python
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing NVM and Node packages..."
    install_node

    if [[ "$DESKTOP_SESSION" == "gnome" ]]; then
        echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing GNOME extensions..."
        install_gnome_extensions

        echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing GNOME settings..."
        install_gnome_settings
    fi
}

function install_fzf() {
    rm -rf ~/.fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf >/dev/null 2>&1 || error "Unable to install fzf."
    ~/.fzf/install --all >/dev/null 2>&1 || error "Unable to install fzf."
}

function install_omz() {
    CUSTOM_DIR="${ZSH_CUSTOM:-$ZSH/custom}"

    # Remove old oh-my-zsh installation
    rm -rf "$ZSH"

    # Install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >/dev/null 2>&1 || error "Unable to install oh-my-zsh."

    # Install zsh theme
    git clone --depth=1 https://github.com/romkatv/powerlevel10k "${CUSTOM_DIR}"/themes/powerlevel10k >/dev/null 2>&1 || error "Unable to install powerlevel10k."

    # Install zsh plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions "${CUSTOM_DIR}"/plugins/zsh-autosuggestions >/dev/null 2>&1 || error "Unable to install zsh-autosuggestions."
    git clone https://github.com/zsh-users/zsh-completions "${CUSTOM_DIR}"/plugins/zsh-completions >/dev/null 2>&1 || error "Unable to install zsh-completions."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "${CUSTOM_DIR}"/plugins/zsh-syntax-highlighting >/dev/null 2>&1 || error "Unable to install zsh-syntax-highlighting."
}

function install() {
    # Needs to be run first to set up environment variables
    source .zshenv

    # Install fzf
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing fzf..."
    install_fzf

    # Install oh-my-zsh and plugins
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing oh-my-zsh and plugins..."
    install_omz

    # Install packages
    install_pkgs

    # Sync dotfiles to home directory
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Syncing dotfiles..."
    rsync --exclude ".git/" \
        --exclude ".vscode/" \
        --exclude "gnome-settings/" \
        --exclude "packages/" \
        --exclude "extras/" \
        --exclude ".gitmodules" \
        --exclude "bootstrap.sh" \
        --exclude "README.md" \
        --exclude "LICENSE" \
        -avh --no-perms . ~ >/dev/null 2>&1 || error "Unable to sync files."

    # Change default shell to zsh if it's not already
    if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
        echo -e "${TXT_GREEN}>${TXT_DEFAULT} Changing shell to zsh..."
        [ ! "$CODESPACES" ] && echo -e "${TXT_GREEN}>${TXT_DEFAULT} Enter your password if prompted."
        sudo chsh "$(id -un)" --shell "/usr/bin/zsh" >/dev/null 2>&1 || error "Unable to change shell. Change it manually."
    fi

    # Reload terminal
    zsh -c "source ~/.zshrc" >/dev/null 2>&1 || error "Unable to reload terminal."

    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Done."
}

if [ "$1" == "--force" ] || [ "$1" == "-f" ] || [ "$CODESPACES" ]; then
    install
else
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} This may overwrite existing files in your home directory."
    yes_or_no "Are you sure?" || (dotfiles_reset && exit 1)
    install
fi

dotfiles_reset
