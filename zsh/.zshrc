# Environment
export JAVA_HOME="$HOME/.jdks/corretto-17.0.19"
export VOLTA_HOME="$HOME/.volta"

typeset -U path
path=(
    "$HOME/.local/bin"
    "$HOME/bin"
    "$JAVA_HOME/bin"
    "$VOLTA_HOME/bin"
    $path
)

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY

# Completion
autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git-aware prompt
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats ' (%b)'

precmd() {
    vcs_info
}

setopt PROMPT_SUBST

PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%F{yellow}${vcs_info_msg_0_}%f
%F{green}❯%f '

# Fuzzy history search (Ctrl+R)
if (( $+commands[fzf] )); then
    eval "$(fzf --zsh)"
fi

# Autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'

if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Syntax highlighting (load last)
if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi