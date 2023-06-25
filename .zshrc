# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set name of the theme to load
ZSH_THEME=powerlevel10k/powerlevel10k

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

plugins=(
  # Standard plugins
  1password
  aliases
  ansible
  charm
  gitfast
  github
  golang
  dnf
  dotenv
  fzf
  npm
  nvm
  pip
  pyenv
  python
  rsync
  rust
  systemd
  tmux
  sudo
  vscode
  zsh-interactive-cd
  zsh-navigation-tools

  # Custom plugins
  zsh-autosuggestions
  zsh-completions 
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
for file in ~/.{path,exports,functions,aliases,completions,p10k.zsh}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;
