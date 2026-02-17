# History
HISTSIZE=50
SAVEHIST=50
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# Basic completion
autoload -U compinit; compinit
source ~/.config/fzf-tab/fzf-tab.plugin.zsh
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Vi mode
bindkey -v

# Your aliases (converted from fish)
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias lz='lazygit'
alias n='nvim'
alias oc='opencode'
alias t='tmux'
alias cc='cargo check'
alias cb='RUSTFLAGS="-C target-cpu=native" cargo build --release'
alias mn='touch "$(date +%F).md" && echo "Created $(date +%F).md"'
alias hs='hugo serve -D --ignoreCache --disableFastRender'
alias sway='sway --unsupported-gpu'

# Git clone functions
clone() {
    git clone "https://github.com/$1.git"
}

mclone() {
    git clone "https://github.com/PS-Wizard/$1.git"
}

# Cargo test function
ct() {
    local flags=""
    local ignored=false
    local release=false
    local nocapture=false
    local crate=""
    local test_name=""
    
    # Parse first argument for flags
    # Flags:
    # i - ignored tests (--ignored)
    # r - release mode (--release)
    # v - verbose/print (replaces 'p') (--nocapture)
    if [[ $# -gt 0 && "$1" =~ ^[irv]+$ ]]; then
        flags="$1"
        shift
        
        [[ "$flags" == *i* ]] && ignored=true
        [[ "$flags" == *r* ]] && release=true
        # Changed 'p' to 'v' for nocapture/verbose output
        [[ "$flags" == *v* ]] && nocapture=true
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

# Test chess engine
test_mah_engine() {
    cchess -engine cmd=stockfish name=Stockfish option."UCI_LimitStrength"=true option."UCI_Elo"=1320 \
           -engine cmd=./engine name=OopsMate \
           -each tc=1+0 -games 100 -repeat -concurrency 1
}

# Go test function
gt() {
    local flags=""
    local verbose=false
    local run_pattern=""
    local package=""
    
    # Parse first argument for flags
    if [[ $# -gt 0 && "$1" =~ ^[v]+$ ]]; then
        flags="$1"
        shift
        
        [[ "$flags" == *v* ]] && verbose=true
    fi
    
    # Parse remaining arguments
    if [ $# -eq 1 ]; then
        # Check if it's a package path
        if [[ "$1" =~ ^\.\/ ]] || [[ "$1" =~ ^\.\. ]]; then
            package="$1"
        else
            run_pattern="$1"
        fi
    elif [ $# -eq 2 ]; then
        run_pattern="$1"
        package="$2"
    fi
    
    # Build command
    local cmd="go test"
    
    if [ "$verbose" = true ]; then
        cmd="$cmd -v"
    fi
    
    if [ -n "$run_pattern" ]; then
        cmd="$cmd -run $run_pattern"
    fi
    
    if [ -n "$package" ]; then
        cmd="$cmd $package"
    fi
    
    # Execute
    eval $cmd
}

# Environment variables
export EDITOR=nvim
export BROWSER=zen-browser
export GOPATH=$HOME/.config/go
export GOBIN=$HOME/.config/go/bin
export PATH=$GOBIN:$PATH

# pnpm
export PNPM_HOME="$HOME/.pnpm/bin"
export PATH=$PNPM_HOME:$PATH

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

# Cargo
export PATH=$HOME/.cargo/bin:$PATH

# Turso (your DB stuff)
export PATH=$PATH:/home/wizard/.turso
export TURSO_DATABASE_URL="libsql://summerclass-wiseguywilly.aws-ap-south-1.turso.io"
export TURSO_AUTH_TOKEN="eyJhbGciOiJFZERTQSIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3NTU2NzI1MjcsImlkIjoiMGFjM2U0YWYtYzc5Yy00ZmExLTk3Y2ItYzljMzU3OTE1ZGQyIiwicmlkIjoiMmZmYTdlODItMzhkMi00NGE0LWJhYmEtMTgyZDc2NTc4Zjc5In0.x9Ts86SfnlG2wjdG6aFTlUXcMkRsY0gH48g6_8mvLEQmHKS2G8FFS8RfsxfGslrrfleTvabjDYHP45OlNomcDA"

# Node
export NODE_OPTIONS="--dns-result-order=ipv4first"

# fzf
export FZF_DEFAULT_COMMAND="fd --type f --hidden"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden"
eval "$(fzf --zsh)"

# zoxide - MUST come after compinit for tab completion
# Using --cmd cd gives you inline completions instead of fzf
eval "$(zoxide init --cmd cd zsh)"

# Accept suggestions with right arrow or Ctrl+f
bindkey '^f' forward-word  # Ctrl+f accepts one word
bindkey '^[[C' forward-char  # Right arrow accepts one char

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line

# Simple prompt (like your fish one)
PROMPT='[%F{green}%n%f@%F{blue}%m%f %F{yellow}%~%f] -> '

# bun completions
[ -s "/home/wizard/.bun/_bun" ] && source "/home/wizard/.bun/_bun"
