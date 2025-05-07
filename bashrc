#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto -p'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
set -o vi

export GOPATH=$HOME/.config/go
export GOBIN=$HOME/.config/go/bin/
export PATH=$GOBIN:$PATH
alias lz='lazygit'
# alias java-test='java -jar ../lib/junit-platform-console-standalone-1.8.2.jar -cp "." --select-class'
# alias java-compile-test='javac -cp "../lib/junit-platform-console-standalone-1.8.2.jar"'
# alias java-db-compile='javac -cp "/usr/share/java/mysql-connector-java.jar:."'
# alias java-db='java -cp "/usr/share/java/mysql-connector-java.jar:."'
# export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -Dswing.crossplatformlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel"
export COURSIER_CACHE=~/.config/java-stuff/
export CLASSPATH=$(find ~/.config/java-stuff/ -name "*.jar" | tr '\n' ':')

# Turso
export PATH="$PATH:/home/wizard/.turso"
export TURSO_AUTH_TOKEN="eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3NDI2MjQ5MzQsImlkIjoiMTQ4NmEyZWQtNjRlMy00NzJiLTg5ODItN2EzOThhYzkwMDk0IiwicmlkIjoiNmE5ZWIzMTctODYyOC00MGZiLTgxZTUtMjVlYTFmYjUyMTY1In0.EWeDanU1KitFJXVLRgiu4LfstuPmmI3d34xZ8kwwLyoC6k6BB_jThHdHGyULqcbB86jsBHrSwriB8sFzilp8DQ"
export TURSO_DATABASE_URL="libsql://votingsystem-wizard.turso.io"

export EDITOR=nvim
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# export NODE_EXTRA_CA_CERTS=$(mkcert -CAROOT)/rootCA.pem
#
