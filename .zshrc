# ===============================================
# MODERN ZSH CONFIGURATION
# ===============================================

# ===============================================
# POWERLEVEL10K INSTANT PROMPT
# ===============================================
# Must stay near the top of ~/.zshrc. Anything that prints to stdout/stderr
# above this line will break instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ===============================================
# OS DETECTION
# ===============================================

case "$OSTYPE" in
    darwin*) IS_MACOS=1 ;;
    linux*)  IS_LINUX=1 ;;
esac

# ===============================================
# PATH / PACKAGE MANAGER INTEGRATIONS
# ===============================================

# Homebrew (sets PATH, MANPATH, INFOPATH)
if [[ -n "$IS_MACOS" ]] && [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# User-local binaries
export PATH="$HOME/.local/bin:$PATH"

# ===============================================
# OH MY ZSH CONFIGURATION
# ===============================================

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins. zsh-syntax-highlighting must be last.
plugins=(
    git
    zsh-completions
    zsh-autosuggestions
    colored-man-pages
    command-not-found
    docker
    docker-compose
    kubectl
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

if [[ -n "$IS_MACOS" ]]; then
    plugins+=(macos brew)
fi

# zsh-syntax-highlighting must be loaded last per its docs.
plugins+=(zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# ===============================================
# ENVIRONMENT VARIABLES
# ===============================================

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Use --wait so git/crontab/etc. block until the editor closes.
export EDITOR='code --wait'
export VISUAL='code --wait'

# History
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE

# ===============================================
# ALIASES
# ===============================================

# Modern ls (lsd) with Nerd Font icons.
alias ls="lsd"
alias ll="lsd -l"
alias la="lsd -la"
alias lt="lsd --tree"
alias l="lsd"

# Modern replacements — exposed under short names so scripts and pipes
# that rely on stock `cat`/`grep`/`find`/`du`/`df` keep working.
# `rg`, `dust`, `duf`, `htop` are invoked directly by their own names.
alias b="bat"
alias f="fd"

# Git
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

# Kubernetes
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get services"
alias kgd="kubectl get deployments"
alias kaf="kubectl apply -f"
alias kdel="kubectl delete"
alias kdes="kubectl describe"
alias klogs="kubectl logs"

# Docker
alias d="docker"
alias dc="docker-compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias di="docker images"
alias drm="docker rm"
alias drmi="docker rmi"
alias dstop="docker stop"
alias dstart="docker start"

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"

# Interactive variants — opt-in instead of shadowing the builtins.
alias cpi="cp -iv"
alias mvi="mv -iv"
alias rmi="rm -iv"
alias mkdirp="mkdir -pv"

# Utility
alias reload="source ~/.zshrc"
alias zshconfig='${EDITOR:-code} ${DOTFILES:-$HOME/dotfiles}/.zshrc'
alias ohmyzsh='${EDITOR:-code} ~/.oh-my-zsh'
alias hosts='sudo ${EDITOR:-code} /etc/hosts'
alias myip="curl -s ipinfo.io/ip"

if [[ -n "$IS_MACOS" ]]; then
    alias localip="ipconfig getifaddr en0"
fi

# ===============================================
# FUNCTIONS
# ===============================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Find and terminate processes by name (SIGTERM, then SIGKILL on -9 flag).
killp() {
    if [[ "$1" == "-9" ]]; then
        shift
        pkill -9 -f "$1"
    else
        pkill -f "$1"
    fi
}

# Weather
weather() {
    curl -s "wttr.in/$1?format=3"
}

# ===============================================
# COMPLETION
# ===============================================
# OMZ already runs compinit. Just tweak styles here.

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

# ===============================================
# LAZY-LOADED TOOLS
# ===============================================

# nvm — lazy load to keep shell startup fast.
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    nvm() {
        unset -f nvm node npm npx
        \. "$NVM_DIR/nvm.sh"
        [[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
        nvm "$@"
    }
    node() { unset -f nvm node npm npx; \. "$NVM_DIR/nvm.sh"; node "$@"; }
    npm()  { unset -f nvm node npm npx; \. "$NVM_DIR/nvm.sh"; npm "$@"; }
    npx()  { unset -f nvm node npm npx; \. "$NVM_DIR/nvm.sh"; npx "$@"; }
fi

# pyenv
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init -)"
fi

# fzf
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# ===============================================
# FINAL CONFIGURATIONS
# ===============================================

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Local overrides (kept out of the repo)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
