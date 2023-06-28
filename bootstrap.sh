#!/usr/bin/env bash

# Bootstrap script for my dotfiles.
# https://github.com/ceiphr/dotfiles
# MIT License
# Copyright (c) 2023 Ari Birnbaum.

# Options -> Configure from command line...
INSTALL_PKGS=true
SYNC_DOTFILES=true
SYNC_GNOME=true
UNATTENDED=false

# For echo -e color support.
TXT_DEFAULT='\033[0m'
TXT_GREY='\033[2m'
TXT_GREEN='\033[0;32m'
TXT_YELLOW='\033[0;33m'
TXT_RED='\033[0;31m'
TXT_BOLD='\033[1m'

# https://no-color.org/
if [[ -n "${NO_COLOR}" ]]; then
    TXT_DEFAULT='\033[0m'
    TXT_GREY='\033[0m'
    TXT_YELLOW='\033[0m'
    TXT_GREEN='\033[0m'
    TXT_RED='\033[0m'
fi

PATH="$PATH:$HOME/.local/bin"

# Clean up after ourselves.
function bootstrap_reset() {
    unset -f yes_or_no error install_omz install_dnf install_flatpak install_apt \
        install_python install_node install_pkgs install_fzf install_gnome_extensions help \
        install_gnome_theme sync_gnome_settings sync_dotfiles install bootstrap_reset handle_sigint
}

# In case the user quits the program in the critical section, we can
# simply unlock the section before exiting.
function handle_sigint() {
    bootstrap_reset
    exit 1
}

trap 'handle_sigint' INT

# Error handling and cleanup.
# Usage: echo "Hello world!" || error "Error message"
function error() {
    echo -e "${TXT_RED}!${TXT_DEFAULT} $1"
    echo -e "${TXT_RED}!${TXT_DEFAULT} Exiting."
    bootstrap_reset
    exit 1
}

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

function install_fzf() {
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing fzf..."
    rm -rf ~/.fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf >/dev/null 2>&1 || error "Unable to install fzf."
    ~/.fzf/install --all >/dev/null 2>&1 || error "Unable to install fzf."
}

function install_omz() {
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing oh-my-zsh and plugins..."

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

function install_dnf() {
    # Add third-party repos.
    echo -e "${TXT_YELLOW}+${TXT_DEFAULT} Adding third-party DNF repos..."
    [[ ! "$CODESPACES" ]] && echo -e "${TXT_GREEN}>${TXT_DEFAULT} Enter your password if prompted."

    # RPM Fusion
    echo -e "${TXT_YELLOW}+${TXT_DEFAULT} Adding RPM Fusion repo..."
    sudo dnf install -y \
        https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y \
        https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    # 1Password
    echo -e "${TXT_YELLOW}+${TXT_DEFAULT} Adding 1Password repo..."
    sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
    sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo' >/dev/null 2>&1 || error "Unable to add 1Password repo."

    # Charm
    echo -e "${TXT_YELLOW}+${TXT_DEFAULT} Adding Charm repo..."
    sudo sh -c 'echo -e "[charm]\nname=Charm\nbaseurl=https://repo.charm.sh/yum/\nenabled=1\ngpgcheck=1\ngpgkey=https://repo.charm.sh/yum/gpg.key" > /etc/yum.repos.d/charm.repo' >/dev/null 2>&1 || error "Unable to add Charm repo."

    # Lazygit
    sudo dnf copr enable atim/lazygit -y || error "Unable to add Lazygit repo."

    # VSCode
    echo -e "${TXT_YELLOW}+${TXT_DEFAULT} Adding VSCode repo..."
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo' >/dev/null 2>&1 || error "Unable to add VSCode repo."

    # Insync
    echo -e "${TXT_YELLOW}+${TXT_DEFAULT} Adding Insync repo..."
    sudo rpm --import https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key
    sudo sh -c 'printf "[insync]\nname=insync repo\nbaseurl=http://yum.insync.io/fedora/$(rpm -E %fedora)/\ngpgcheck=1\ngpgkey=https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key\nenabled=1\nmetadata_expire=120m\n" > /etc/yum.repos.d/insync.repo' >/dev/null 2>&1 || error "Unable to add Insync repo."

    # Tailscale
    echo -e "${TXT_YELLOW}+${TXT_DEFAULT} Adding Tailscale repo..."
    sudo dnf config-manager --add-repo https://pkgs.tailscale.com/stable/fedora/tailscale.repo || error "Unable to add Tailscale repo."

    # Install packages
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing DNF packages..."
    sudo dnf upgrade -y || error "Unable to upgrade packages."
    sudo dnf install -y $(cat packages/dnf) || error "Unable to install packages."
}

function install_flatpak() {
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing Flatpak packages..."

    # Note: Must be run after install_dnf. flatpak is installed via dnf.
    flatpak update -y || error "Unable to update flatpak."
    flatpak remote-add -u --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo >/dev/null 2>&1 || error "Unable to add flathub remote."
    flatpak install -u -y $(cat packages/flatpak) || error "Unable to install flatpak packages."
}

function install_apt() {
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing APT packages..."
    [[ ! "$CODESPACES" ]] && echo -e "${TXT_GREEN}>${TXT_DEFAULT} Enter your password if prompted."

    sudo apt-get update -y >/dev/null 2>&1 || error "Unable to update packages."
    sudo apt install -y $(cat packages/apt) || error "Unable to install packages."
}

function install_python() {
    [[ -x "$(command -v python3)" ]] || (echo -e "${TXT_YELLOW}!${TXT_DEFAULT} Python3 not installed. Skipping Python packages." && return)

    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing Python packages..."
    pip install --upgrade pip >/dev/null 2>&1 || error "Unable to update pip."
    pip install $(cat packages/pip) || error "Unable to install python packages."
}

function install_gnome_extensions() {
    [[ -x "$(command -v gnome-extensions-cli)" ]] || (echo -e "${TXT_YELLOW}!${TXT_DEFAULT} gnome-extensions-cli not installed. Skipping GNOME extensions." && return)

    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing GNOME extensions..."
    # Note: Must be run after install_python. gnome-extensions-cli is installed via pip.
    gnome-extensions-cli install $(cat packages/gnome-extensions) || error "Unable to install gnome extensions."
}

function install_gnome_theme() {
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing GNOME theme..."

    # Clone MoreWaita repo to /tmp and run local-install.sh to install theme
    rm -rf /tmp/MoreWaita
    git clone https://github.com/somepaulo/MoreWaita.git /tmp/MoreWaita >/dev/null 2>&1 || error "Unable to clone MoreWaita repo."
    bash /tmp/MoreWaita/local-install.sh >/dev/null 2>&1 || error "Unable to install MoreWaita theme."
}

function install_node() {
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Installing NVM and Node packages..."

    # Install nvm
    [[ -d $NVM_DIR ]] || mkdir -p "$NVM_DIR"
    curl -s https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash || error "Unable to install nvm."
    (source "$NVM_DIR"/nvm.sh && nvm install --lts) || error "Unable to install nvm."

    # Note: GitHub Actions CI tries to update npm and fails. Don't update npm in CI.
    [[ ! "$CI" ]] && (npm update -g || error "Unable to update npm.")

    # Install npm packages
    npm install -g $(cat packages/npm) || error "Unable to install npm packages."
}

function install_pkgs() {
    source /etc/os-release

    # Install OS-specific packages
    if [[ "$ID" == "fedora" ]] || [[ $ID == "rhel" ]]; then
        install_dnf
        install_flatpak
    elif [[ $ID == "ubuntu" ]] || [[ "$CODESPACES" ]]; then
        install_apt
    else
        error "Unsupported OS."
    fi

    install_python
    install_node
}

function sync_gnome_settings() {
    [[ -x "$(command -v dconf)" ]] || (echo -e "${TXT_YELLOW}!${TXT_DEFAULT} dconf not installed. Skipping GNOME settings." && return)

    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Syncing GNOME settings..."
    # Load GNOME settings into dconf
    dconf load /org/gnome/shell/extensions/ <gnome-settings/extensions.conf
    dconf load /org/gnome/desktop/ <gnome-settings/desktop.conf
    dconf load /org/gnome/shell/ <gnome-settings/shell.conf
    dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ <gnome-settings/keybindings.conf
}

function sync_dotfiles() {
    [[ -x "$(command -v rsync)" ]] || (echo -e "${TXT_YELLOW}!${TXT_DEFAULT} rsync not installed. Skipping dotfiles." && return)

    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Syncing dotfiles..."
    rsync -avh --no-perms src/ ~ >/dev/null 2>&1 || error "Unable to sync files."
}

function install() {
    # Pull latest changes from repo and submodules.
    git pull --recurse-submodules origin >/dev/null 2>&1 || error "Unable to pull latest changes."

    # Needs to be run first to set up environment variables
    source src/.zshenv

    # Install packages
    # Note: We don't install packages in CI. Erorr prone and not necessary.
    [[ ! "$CI" ]] && ([[ "$INSTALL_PKGS" == true ]] && install_pkgs)

    # Install various plugins and extensions
    install_fzf
    install_omz

    # Install GNOME extensions and theme if running GNOME
    if [[ "$DESKTOP_SESSION" == "gnome" ]] && [[ "$SYNC_GNOME" == true ]]; then
        install_gnome_extensions
        install_gnome_theme
        sync_gnome_settings
    fi

    [[ "$SYNC_DOTFILES" == true ]] && sync_dotfiles

    # Change default shell to zsh if it's not already
    if [[ "$SHELL" != "/usr/bin/zsh" ]] && [[ ! "$CI" ]]; then
        echo -e "${TXT_GREEN}>${TXT_DEFAULT} Changing shell to zsh..."
        [[ ! "$CODESPACES" ]] && echo -e "${TXT_GREEN}>${TXT_DEFAULT} Enter your password if prompted."
        sudo chsh "$(id -un)" --shell "/usr/bin/zsh" >/dev/null 2>&1 || error "Unable to change shell. Change it manually."
    fi

    zsh -c "source ~/.zshrc" >/dev/null 2>&1 || error "Unable to reload terminal."
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} Done."
}

function help() {
    echo -e "$(
        cat <<-EOF
Usage: $(basename "$0") [options]
${TXT_GREY}
Ari's dotfiles bootstrap script.
${TXT_DEFAULT}
Options:
    -np, --no-packages    Skip installing packages
    -ns, --no-symlinks    Skip syncing dotfiles
    -ng, --no-gnome       Skip configuring GNOME
    -u,  --unattended     Skip all prompts
    -h,  --help           Show this help message and exit
EOF
    )"
}

while [[ $# -gt 0 ]]; do
    case $1 in
    -np | --no-packages)
        INSTALL_PKGS=false
        shift
        ;;
    -ns | --no-symlinks)
        SYNC_DOTFILES=false
        shift
        ;;
    -ng | --no-gnome)
        SYNC_GNOME=false
        shift
        ;;
    -u | --unattended)
        UNATTENDED=true
        shift
        ;;
    -h | --help)
        help
        exit 0
        ;;
    *)
        echo -e "${TXT_RED}!${TXT_DEFAULT} Unknown option: $1"
        exit 1
        ;;
    esac
done

if [[ "$UNATTENDED" == true ]] || [[ "$CODESPACES" ]]; then
    install
else
    echo -e "${TXT_GREEN}>${TXT_DEFAULT} This may overwrite existing files in your home directory."
    yes_or_no "Are you sure?" || (bootstrap_reset && exit 1)
    install
fi

# Reload terminal
bootstrap_reset
exit 0
