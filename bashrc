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

alias lz='lazygit'

alias java-db-compile='javac -cp "/usr/share/java/mysql-connector-java.jar:."'
alias java-db='java -cp "/usr/share/java/mysql-connector-java.jar:."'
export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.crossplatformlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel"
