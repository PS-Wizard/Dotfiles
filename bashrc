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

alias java-test='java -cp .:/usr/share/java/junit-4.13.2.jar:/usr/share/java/hamcrest/* org.junit.runner.JUnitCore MathUtilsTest'
alias java-compile-test='javac -cp .:/usr/share/java/junit-4.13.2.jar:/usr/share/java/hamcrest-core.jar *.java'


