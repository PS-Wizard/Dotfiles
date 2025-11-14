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

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Turso
export PATH="$PATH:/home/wizard/.turso"
export TURSO_DATABASE_URL="libsql://summerclass-wiseguywilly.aws-ap-south-1.turso.io"
export TURSO_AUTH_TOKEN="eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3NTU2NzI1MjcsImlkIjoiMGFjM2U0YWYtYzc5Yy00ZmExLTk3Y2ItYzljMzU3OTE1ZGQyIiwicmlkIjoiMmZmYTdlODItMzhkMi00NGE0LWJhYmEtMTgyZDc2NTc4Zjc5In0.x9Ts86SfnlG2wjdG6aFTlUXcMkRsY0gH48g6_8mvLEQmHKS2G8FFS8RfsxfGslrrfleTvabjDYHP45OlNomcDA"

. "$HOME/.cargo/env"
alias mn='touch "$(date +%F).md" && echo "Created $(date +%F).md"'

alias cc="cargo check"
ct() {
    local flags=""
    local ignored=false
    local release=false
    local nocapture=false
    local crate=""
    local test_name=""
    
    # Parse first argument for flags
    if [[ $# -gt 0 && "$1" =~ ^[irp]+$ ]]; then
        flags="$1"
        shift
        
        [[ "$flags" == *i* ]] && ignored=true
        [[ "$flags" == *r* ]] && release=true
        [[ "$flags" == *p* ]] && nocapture=true
    fi
    
    # Parse remaining arguments
    if [ $# -eq 1 ]; then
        # Check if it's a crate name or test name
        if cargo metadata --no-deps --format-version 1 2>/dev/null | grep -q "\"name\":\"$1\""; then
            crate="$1"
        else
            test_name="$1"
        fi
    elif [ $# -eq 2 ]; then
        crate="$1"
        test_name="$2"
    fi
    
    # Build command
    local cmd="cargo test"
    
    # Add RUSTFLAGS if release mode
    if [ "$release" = true ]; then
        cmd="RUSTFLAGS=\"-C target-cpu=native\" $cmd --release"
    fi
    
    # Add package flag if crate specified
    if [ -n "$crate" ]; then
        cmd="$cmd -p $crate"
    fi
    
    # Add test name if specified
    if [ -n "$test_name" ]; then
        cmd="$cmd $test_name"
    fi
    
    # Add test arguments
    cmd="$cmd --"
    
    if [ "$ignored" = true ]; then
        cmd="$cmd --ignored"
    fi
    
    if [ "$nocapture" = true ]; then
        cmd="$cmd --nocapture"
    fi
    
    # Execute
    eval $cmd
}

alias cb='RUSTFLAGS="-C target-cpu=native" cargo build --release'

test_mah_engine() {
    cchess -engine cmd=stockfish name=Stockfish option."UCI_LimitStrength"=true option."UCI_Elo"=1320   -engine cmd=./engine name=OopsMate   -each tc=1+0 -games 100 -repeat -concurrency 1
}

export NODE_OPTIONS="--dns-result-order=ipv4first"
alias hs="hugo serve -D --ignoreCache --disableFastRender"
alias n="nvim"
alias t="tmux"

eval "$(zoxide init bash --cmd cd)"

