#
# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias lz='lazygit'


set -o vi
set editing-mode vi

export EDITOR=nvim
export BROWSER=zen-browser
alias sway='sway --unsupported-gpu'
shopt -s histappend
PROMPT_COMMAND='history -a'
export GOPATH=$HOME/.config/go
export GOBIN=$HOME/.config/go/bin/
export PATH=$GOBIN:$PATH
PS1='[\u@\h \W]\$ '

# pnpm configuration
export PNPM_HOME="$HOME/.pnpm/bin"
export PNPM_STORE_DIR="$HOME/.pnpm/store"
export PNPM_CACHE_DIR="$HOME/.pnpm/cache"
export PATH="$PNPM_HOME:$PATH"
eval "$(fzf --bash)"

export FZF_DEFAULT_COMMAND="fd --type f --hidden"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden"

# fd will automatically use ~/.ignore
_fzf_compgen_path() { 
    fd --hidden --exclude .git . "$1"
}

_fzf_compgen_dir() { 
    fd --type=d --hidden --exclude .git . "$1"
}

clone() {
  git clone "https://github.com/$1.git"
}
mclone() {
  git clone "https://github.com/PS-Wizard/$1.git"
}
. "$HOME/.cargo/env"
