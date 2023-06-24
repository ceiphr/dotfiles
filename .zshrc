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

# Standard plugins -> ~/.oh-my-zsh/plugins/*
# Custom plugins -> ~/.oh-my-zsh/custom/plugins/
plugins=(
  gitfast
  npm
  pip
  pyenv
  python
  sudo
  vscode
  zsh-autosuggestions
  zsh-completions 
  zsh-interactive-cd
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Completions dump only run every 24h
# https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2308206
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"
  break
done
compinit -C -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

# Load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$PATH`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{exports,aliases,functions,completions,p10k.zsh}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;
