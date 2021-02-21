
export PATH=${PATH}:~/.bin

# If not running interactively, do not do anything
[[ $- != *i* ]] && return
[[ -z "$TMUX" ]] && exec tmux

alias ll="ls -al"
alias vi=vim

source /usr/share/fzf/key-bindings.bash

eval "$(starship init bash)"

[[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh

source ~/.bash_aliases


source /usr/share/git/completion/git-completion.bash