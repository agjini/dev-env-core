
export PATH=${PATH}:~/.bin

# If not running interactively, do not do anything
[[ $- != *i* ]] && return
[[ -z "$TMUX" ]] && exec tmux

alias ll="ls -al"
alias vi=vim

source /usr/share/fzf/key-bindings.bash

eval "$(starship init bash)"

source ~/.bash_aliases


source /usr/share/git/completion/git-completion.bash