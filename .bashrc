#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
set -o vi

export GOPATH=$HOME/.config/go
export GOBIN=$HOME/.config/go/bin/
export PATH=$GOBIN:$PATH

alias java-test='java -jar ../lib/junit-platform-console-standalone-1.8.2.jar -cp "." --select-class'
alias java-compile-test='javac -cp "../lib/junit-platform-console-standalone-1.8.2.jar"'
alias lodepng_compile='gcc -ansi -pedantic -Wall -Wextra -O3 main.c ../lib/lodepng.o -o lodepng_program'

export PATH=~/.config/pnpm-installs/bin:$PATH
