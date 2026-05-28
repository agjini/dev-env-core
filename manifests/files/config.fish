
if status is-interactive
    and not set -q TMUX
    exec tmux
end

set -x TERM xterm-256color

alias zed='zeditor'
zoxide init fish | source

alias pp='git pp'

alias cat='bat -p'

bind \ca beginning-of-buffer
bind \ce end-of-buffer
