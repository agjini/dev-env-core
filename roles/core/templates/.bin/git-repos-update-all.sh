#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#/ Usage:       git-repos-update-all.sh
#/ Version:     2.0
#/ Description: Find all git repository from `~/` and update them in multi-thread mode.
#/ Options:
#/   --help:     Display this help message
function usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

readonly MAX_PROC=10
export SCREEN_COLS; SCREEN_COLS=$(tput cols)
export BRANCH_WIDTH; BRANCH_WIDTH=$((SCREEN_COLS - 70 - 13))

export PF_NORMAL; PF_NORMAL="\e[0;39m%s\e[m"
export PF_ROUGE; PF_ROUGE="\e[1;31m%s\e[m"
export PF_VERT; PF_VERT="\e[1;32m%s\e[m"
export PF_JAUNE; PF_JAUNE="\e[1;33m%s\e[m"
export PF_BOLD; PF_BOLD="\e[1m%s\e[m"

log() {
  ( flock -n 200

    local color; color=$1
    shift
    branchformat="%-${BRANCH_WIDTH}s"
    local branch; branch=$2
    if [ "$branch" != "master" ] && [ "$branch" != "develop" ]; then branchformat="\e[96m%-${BRANCH_WIDTH}s\e[m"; fi

    printf "%-70s $branchformat $color\n" "$@"

  ) 200>"/var/lock/.$(basename "$0").lock"
}
log_dirty(){ log "$PF_JAUNE" "$@" "DIRTY"; }
log_updated(){ log "$PF_VERT" "$@" "UPDATED"; }
log_uptodate(){ log "$PF_VERT" "$@" "UP-TO-DATE"; }
log_error(){
  ( flock -n 200
    printf '%*s\n' "${COLUMNS:-$SCREEN_COLS}" '' | tr ' ' =
    printf "%-70s %-${BRANCH_WIDTH}s $PF_ROUGE %s\n" "$1" "$2" "$3";
    printf "\n %s \n" "$4";
    printf '%*s\n' "${COLUMNS:-$SCREEN_COLS}" '' | tr ' ' =
  ) 200>"/var/lock/.$(basename "$0").lock"
}

_update_git_repo() {
  local LANG=en_US
  local gitdir=$1
  readonly GIT="git --git-dir=$gitdir --work-tree=$(dirname "$gitdir")"
  local CURRENT_REPO; CURRENT_REPO=$($GIT config --get remote.origin.url 2>/dev/null)
  local CURRENT_BRANCH; CURRENT_BRANCH=$($GIT symbolic-ref -q --short HEAD 2>/dev/null || $GIT describe --tags --exact-match 2>/dev/null)

  if [[ ! -z $($GIT status --porcelain 2>/dev/null) ]]; then
    log_dirty "$CURRENT_REPO" "$CURRENT_BRANCH"
    return
  fi

  if ! $GIT fetch -v --dry-run 2>&1 | grep -Eq "^ = \[up.to.date\] +${CURRENT_BRANCH} "; then
    if OUTPUT=$($GIT pull 2>&1); then
      log_updated "$CURRENT_REPO" "$CURRENT_BRANCH"
    else
      log_error "$CURRENT_REPO" "$CURRENT_BRANCH" "ERROR" "--> ${OUTPUT}"
      printf "\t* %s\n" "$gitdir" >"$fifo" &
    fi
  fi
}

# shellcheck disable=SC2059
_display_result() {
  local startTime; startTime=$1
  local errorFile; errorFile=$2
  local endTime; endTime=$(date +%s%3N)

  local duration; duration=$(bc -l <<< "scale=2; ($endTime - $startTime) / 1000")

  printf "\nUpdates terminated in ${PF_BOLD}s\n\n" "$duration"
  local errors; errors=$(<"$errorFile")
  if [ ! -z "$errors" ]; then
    printf "Repository not updated beacause of ${PF_ROUGE} :\n" "ERRORS"
    printf  "${PF_ROUGE}\n\n" "$errors"
  fi
}

_cleanup() {
    rm -f "$1"
    exit
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
  readonly START_TIME=$(date +%s%3N)

  export fifo; fifo=$(mktemp -u)
  mkfifo "$fifo"
  echo "" > "$fifo"& # to avoid block the read at the end
  trap '_cleanup "$fifo"' INT TERM EXIT

  export -f _update_git_repo
  export -f log
  export -f log_dirty
  export -f log_error
  export -f log_updated
  export -f log_uptodate

  find -L ~/workspace -maxdepth 5 -path "*.git" -not -path "*zprezto*" -type d -print0 2> /dev/null | xargs --null --max-proc=$MAX_PROC -n 1 -I {} bash -c "_update_git_repo {}" || true

  _display_result "$START_TIME" "$fifo"
fi
