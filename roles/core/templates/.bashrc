
export PATH=${PATH}:~/.bin

# If not running interactively, do not do anything
[[ $- != *i* ]] && return
[[ -z "$TMUX" ]] && exec tmux

alias ll="ls -al"
alias vi=vim

source /usr/share/fzf/key-bindings.bash

if [ -f /usr/lib/bash-git-prompt/gitprompt.sh ]; then
               # To only show the git prompt in or under a repository directory
               # GIT_PROMPT_ONLY_IN_REPO=1
               # To use upstream's default theme
               # GIT_PROMPT_THEME=Default
               # To use upstream's default theme, modified by arch maintainer
               GIT_PROMPT_THEME=Default_Arch
               source /usr/lib/bash-git-prompt/gitprompt.sh
fi

source ~/.bash_aliases


source /usr/share/git/completion/git-completion.bash