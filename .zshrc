# ===============================================
# 🚀 MODERN ZSH CONFIGURATION
# ===============================================

# If you come from bash you might have to change your $PATH.
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# ===============================================
# 🎨 OH MY ZSH CONFIGURATION
# ===============================================

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme configuration - Using Powerlevel10k for modern look
ZSH_THEME="powerlevel10k/powerlevel10k"

# ===============================================
# 🔌 PLUGINS CONFIGURATION
# ===============================================

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    colored-man-pages
    command-not-found
    docker
    docker-compose
    kubectl
    brew
    macos
    web-search
    copypath
    copyfile
    dirhistory
    history
    jsontools
    sudo
    extract
    z
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ===============================================
# 🌈 ENVIRONMENT VARIABLES
# ===============================================

# Language environment
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Preferred editor
export EDITOR='code'
export VISUAL='code'

# History configuration
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

# ===============================================
# 🎯 MODERN ALIASES
# ===============================================

# Enhanced ls commands
alias ls="lsd -al --color=auto"
alias ll="lsd -l --color=auto"
alias la="lsd -la --color=auto"
alias lt="lsd --tree --color=auto"
alias l="lsd --color=auto"

# Git aliases
alias g="git"
alias ga="git add"
alias gaa="git add ."
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gs="git status"
alias gd="git diff"
alias gb="git branch"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gl="git log --oneline --graph --decorate"
alias gla="git log --oneline --graph --decorate --all"

# Kubernetes aliases
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get services"
alias kgd="kubectl get deployments"
alias kaf="kubectl apply -f"
alias kdel="kubectl delete"
alias kdes="kubectl describe"
alias klogs="kubectl logs"

# Docker aliases
alias d="docker"
alias dc="docker-compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias di="docker images"
alias drm="docker rm"
alias drmi="docker rmi"
alias dstop="docker stop"
alias dstart="docker start"

# System aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"

# Utility aliases
alias reload="source ~/.zshrc"
alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias hosts="sudo code /etc/hosts"
alias ip="curl ipinfo.io/ip"
alias localip="ipconfig getifaddr en0"
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"

# File operations
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -iv"
alias mkdir="mkdir -pv"

# Modern replacements
alias cat="bat"
alias find="fd"
alias grep="rg"
alias top="htop"
alias du="dust"
alias df="duf"

# ===============================================
# 🛠️ FUNCTIONS
# ===============================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract any archive
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find and kill process by name
killp() {
    ps aux | grep $1 | grep -v grep | awk '{print $2}' | xargs kill -9
}

# Weather function
weather() {
    curl -s "wttr.in/$1?format=3"
}

# Note: Google search is available via the web-search plugin
# Use: google "search term" or web_search google "search term"

# ===============================================
# 🎨 POWERLEVEL10K INSTANT PROMPT
# ===============================================

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ===============================================
# 🔧 ADDITIONAL CONFIGURATIONS
# ===============================================

# Auto-completion
autoload -Uz compinit
compinit

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Colored completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Menu selection
zstyle ':completion:*' menu select

# ===============================================
# 📦 PACKAGE MANAGER INTEGRATIONS
# ===============================================

# Homebrew
if command -v brew &> /dev/null; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Node Version Manager (if installed)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Python pyenv (if installed)
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init -)"
fi

# ===============================================
# 🎯 FINAL CONFIGURATIONS
# ===============================================

# Load Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load custom configurations if they exist
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Welcome message
echo "🚀 Welcome to your modern terminal!"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
