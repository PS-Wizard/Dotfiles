#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias lz='lazygit'
# export GOPATH=$HOME/.config/go
# export GOBIN=$HOME/.config/go/bin/
# export PATH=$GOBIN:$PATH
PS1='[\u@\h \W]\$ '
. "$HOME/.cargo/env"
